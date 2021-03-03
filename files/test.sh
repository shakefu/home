#!/bin/dash

echo "Args:"
echo "$1"
echo "$2"
echo "$3"
echo "$4"
echo "=="

for arg in "$@"; do
    echo "arg = $arg"
done

whoami

env | sort

exit 42