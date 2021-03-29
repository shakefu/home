package main

import (
	"embed"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"time"

	docopt "github.com/docopt/docopt-go"
	"github.com/google/shlex"
	"github.com/kataras/golog"
	"github.com/logrusorgru/aurora"
	"github.com/mattn/go-isatty"
)

const shell = "dash"

//go:embed VERSION
//go:embed install
//go:embed files
//go:embed files/.*
var embedded embed.FS
var tmpdir = "/tmp"
var ansi aurora.Aurora

type CliArgs struct {
	// Options
	DryRun  bool
	Upgrade bool
	Debug   bool
	Color   string
	// Args
	Command string
	Os      string
	Arch    string
	Names   []string
}

func main() {
	var err error
	var name string

	if os.Getenv("DEBUG") != "" {
		golog.SetLevel("debug")
	}

	// Get the current executable full path
	if name, err = os.Executable(); err != nil {
		golog.Fatal("Unable to retrieve executable name")
	}
	// Get the actual command name
	name = filepath.Base(name)
	oper := runtime.GOOS
	arch := runtime.GOARCH
	version := embeddedFile("VERSION")

	// Get a safe temp directory to use for downloads, etc.
	tmpdir, err = os.MkdirTemp("", name+"-")
	if err != nil {
		log.Fatal(err)
	}
	// Ensure we clean it up later
	defer os.RemoveAll(tmpdir)
	golog.Debug("tmpdir:", tmpdir)

	// Create the command help with our executable name
	usage := fmt.Sprintf(`Home directory management.

This command is intended to help manage home directory files and
dependencies. It can even be extended to set up a default environment for
development.

Usage:
    %v [-h|--help] [-d|--debug] [--version] [--color=<color>] [--os=<os>]
	 [--arch=<arch>] <command> [--dry-run] [--upgrade] [<names>...]

Options:
    --dry-run        don't make any changes
    --upgrade        upgrade installed if they exist
    --color=<color>  color output auto, always or never [default: auto]
    --os=<os>        operating system [default: %v]
    --arch=<arch>    platform [default: %v]
    -d --debug       show debug output
    -h --help        show this help
    --version        show the version

The subcommands are:
    setup      run install, copy, and status
    install    install system dependencies
    copy       copy user files into place
    status     report status of all installs and user files`, name, oper, arch)

	var args CliArgs

	// Parse the CLI args and store them
	parsed, _ := docopt.ParseArgs(usage, os.Args[1:], "v1.0.0")

	// Force color settings
	initColor(parsed["--color"].(string))

	// Bind to our struct
	if err = parsed.Bind(&args); err != nil {
		golog.Fatal(err)
	}

	// Set debug output in our logger
	if args.Debug {
		golog.SetLevel("debug")
	}
	golog.Debugf("args = %+v", args)

	// Sanity check so scripts can run
	if !commandExists("dash") {
		golog.Fatal("Error: Missing 'dash' shell")
	}

	cmd := args.Command
	golog.Debug("Running command: ", cmd)

	// Try to install all our dependencies (this should be idempotent)
	if cmd == "install" || cmd == "setup" {
		CliInstall(&args)
	}

	// Copy all our files in place, this is destructive
	if cmd == "copy" || cmd == "setup" {
		CliCopyFiles(&args)
	}

	// Report the status on all the files
	if cmd == "status" || cmd == "setup" {
		CliStatus(&args)
	}

	os.Exit(0)
}

// Set the logging and color libs to output color in line with the desired flags
// and/or TTY
func initColor(color string) {
	tty := isatty.IsTerminal(os.Stdout.Fd())
	if color == "" {
		color = "auto"
	}
	if color == "never" || !tty {
		// Disable manual colors
		ansi = aurora.NewAurora(false)
		// Disable logging colors
		for _, level := range golog.Levels {
			level.ColorCode = 7
			level.Style = nil
		}
		return
	}
	if color == "always" || tty {
		ansi = aurora.NewAurora(true)
		// There's no good way to force golog to output color if it's not a tty
	}
}

// Run all the embedded install scripts or exit.
// This will run all the install scripts, or a specified list of script names.
// If there is an error with any script it will exit this process.
func CliInstall(args *CliArgs, names ...string) {
	var targets map[string](bool)
	targets, names = Targets(args, &names)
	log := golog.Child(fmt.Sprint(ansi.Blue("[install]")))
	log.Infof("Installing %s...", strings.Join(names, ", "))

	// Get our target directory for the platform
	target := fmt.Sprintf("install/%v_%v", args.Os, args.Arch)

	// Append $HOME/.bin to $PATH
	binpath, _ := os.UserHomeDir()
	binpath += "/.bin"
	if !strings.Contains(os.Getenv("PATH"), binpath) {
		os.Setenv("PATH", os.Getenv("PATH")+":"+binpath)
	}

	// Get all our install scripts
	files, err := embedded.ReadDir(target)
	if err != nil {
		log.Fatal(err)
	}

	// Iterate through all the install scripts
	for _, fd := range files {
		// Actual script filename
		script_name := fd.Name()
		// Just the name portion of 00-name
		name := getInstallName(script_name)
		// We have targeted a subset to install
		if len(names) > 0 {
			// Skip anything not in our targets
			if _, ok := targets[name]; !ok {
				log.Debugf("Skipping '%v'", name)
				continue
			}
		}
		// If we're not upgrading or targeting, skip installed commands
		if commandExists(name) && (!args.Upgrade && len(names) == 0) {
			log.Debugf("Skipping '%v', already installed", name)
			continue
		}
		// Create Script
		script := Script{
			name: fmt.Sprintf("%v/%v", target, script_name),
			env:  []string{},
		}
		// Set the script name to use
		script.env = append(script.env, "NAME="+name)

		// Set the tmp path name for use in the scripts
		tmp := fmt.Sprintf("%v/%v-%v", tmpdir, name, time.Now().UnixNano())
		tmp = fmt.Sprintf("TMP=%v", tmp)
		script.env = append(script.env, tmp)

		verb := "Installing"
		// Set the upgrade flag if we need to
		if args.Upgrade || len(names) > 0 {
			script.env = append(script.env, "UPGRADE=true")
			verb = "Upgrading"
		}
		// Set the dry run flag
		if args.DryRun {
			script.env = append(script.env, "RUN=echo "+fmt.Sprint(ansi.Black("dry-run:")))
		}
		// Run our install script
		fmt.Println(ansi.Blue(verb), ansi.Blue(name))
		log.Debug(script.name)
		script.RunOrExit()

		if args.DryRun {
			fmt.Println(ansi.Yellow("No changes"))
		} else {
			fmt.Println(ansi.BrightGreen("Success"))
		}
	}
	log.Info("Done.")
}

func CliCopyFiles(args *CliArgs) {
	log := golog.Child(fmt.Sprint(ansi.Blue("[copy]")))
	log.Info("Copying files...")

	// Get the home directory
	home, _ := os.UserHomeDir()
	// This has to match the embedded path
	base := "files"

	// Filenames in embedded
	names := make([]string, 0, 50) // Just allocate something to save time

	// Get our filenames that we embedded
	getFileNames(base, &names)

	// Loop over our names copying them in
	for _, name := range names {
		// Strip the leading "files"
		target, _ := filepath.Rel(base, name)
		// Get just the directory part
		dir := path.Join(home, filepath.Dir(target))
		// Target to write file to
		target = path.Join(home, target)
		// Create the directories we need
		if _, err := os.Stat(dir); os.IsNotExist(err) {
			if args.DryRun {
				fmt.Println(ansi.Black("dry-run:"), "mkdir -p", "\""+dir+"\"")
			} else {
				if err := os.MkdirAll(dir, 0755); err != nil {
					log.Fatal(err)
				}
			}
		}

		// Write the file
		if args.DryRun {
			fmt.Println(ansi.Black("dry-run:"), "cp", "\"<embed>/"+name+"\"", "\""+target+"\"")
		} else {
			func() {
				// It's our file, we'll write if we want to
				os.Chmod(target, 0600)
				// Read the embedded file
				data, _ := embedded.ReadFile(name)
				// Write it back out
				if err := os.WriteFile(target, data, 0600); err != nil {
					log.Fatal(err)
				}
				if strings.Contains(name, ".githooks") {
					// TODO: Figure out a better way to not make this a hack
					// This is a hack so the githooks are executable
					os.Chmod(target, 0500)
				} else {
					// Make the files generated here read-only as a reminder to not
					// edit them directly
					os.Chmod(target, 0400)
				}
			}()
		}
	}
	log.Info("Done.")
}

func CliStatus(args *CliArgs, names ...string) {
	// Override args with local names

	// Check all the filesystem hashes against our embedded
}

// Return a map and a deduplicated slice of all the names given.
func Targets(args *CliArgs, names *[]string) (map[string]bool, []string) {
	targets := map[string](bool){}
	// Default to argument provided names
	if len(*names) == 0 {
		names = &(args.Names)
	}
	// Populate our map
	for _, name := range *names {
		targets[name] = true
	}

	// Get the slice of target names deduplicated
	keys := make([]string, len(targets))
	i := 0
	for key := range targets {
		keys[i] = key
		i++
	}

	return targets, keys
}

// Return the name portion of "00-name" scripts.
func getInstallName(name string) string {
	re := regexp.MustCompile(`^(?P<order>\d+)-(?P<command>.*)$`)
	matches := re.FindStringSubmatch(name)
	if len(matches) > 0 {
		return matches[re.SubexpIndex("command")]
	}
	return name
}

// Return true if cmd exists.
func commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

// Walk the embedded filesystem starting at base and populate paths.
// This is recursive and may sufffer with very large filesystems or very deep
// nested directories.
func getFileNames(base string, paths *[]string) {
	files, err := embedded.ReadDir(base)
	if err != nil {
		log.Fatal(err)
	}

	// Iterate through all the files
	for _, fd := range files {
		if fd.IsDir() {
			getFileNames(path.Join(base, fd.Name()), paths)
			continue
		}
		*paths = append(*paths, path.Join(base, fd.Name()))
	}
}

func Run(command string) int {
	argv, err := shlex.Split(command)
	if err != nil {
		golog.Fatal(err)
	}
	return RunCommand(argv)
}

func RunCommand(argv []string) int {
	exit, err := func() (int, error) {
		cmd := exec.Command(argv[0], argv[1:]...)

		// Always directly output to our calling tty
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		// Start the subprocess
		if err := cmd.Start(); err != nil {
			return -1, err
		}

		// Get the error code from the subprocess if it exists
		if exitError, ok := cmd.Wait().(*exec.ExitError); ok {
			return exitError.ExitCode(), exitError
		}

		return 0, nil
	}()

	// Handle bad exit codes
	if exit != 0 || err != nil {
		fmt.Println(err)
		if exit == 0 {
			exit = -2
		}
	}

	return exit
}

type Script struct {
	name string
	env  []string
}

func (script *Script) RunOrExit(args ...string) int {
	// Run the embedded script
	exit, err := script.Run(args...)
	if err != nil {
		golog.Fatal(err)
	}

	// This seems like an edge case
	if exit != 0 {
		golog.Fatal("Unknown error, exit code: ", exit)
	}

	// Exit codes are nice to have
	return exit
}

func (script *Script) Run(args ...string) (int, error) {
	// Get embedded script
	data := embeddedFile(script.name)

	// Set the script arguments
	argv := []string{"-s", "-"}
	argv = append(argv, args...)

	// And a shell to run it in
	cmd := exec.Command(shell, argv...)

	// Always directly output to our calling tty
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Set the runtime environment
	cmd.Env = os.Environ()
	cmd.Env = append(cmd.Env, script.env...)

	// Grab the pipe to the subprocess stdin
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return -1, err
	}

	// Start the subprocess
	if err := cmd.Start(); err != nil {
		return -1, err
	}

	// Write the script to stdin and close the pipe when finished
	go func() {
		defer stdin.Close()
		io.WriteString(stdin, string(data))
	}()

	// Get the error code from the subprocess if it exists
	if exitError, ok := cmd.Wait().(*exec.ExitError); ok {
		return exitError.ExitCode(), exitError
	}

	return 0, nil
}

// Shorthand for a slice of bytes.
type file = []byte

// Return the bytes for the named file in our embedded FS.
func embeddedFile(name string) file {
	data, err := embedded.ReadFile(name)
	if err != nil {
		golog.Fatal(err)
	}
	return data
}
