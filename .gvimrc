" Prevent the last tab from closing with CMD-W
macm File.Close key=<nop>
nnoremap <silent> <D-w> <Esc>:bd<CR>


" Tab labels
function! GuiTabLabel()
    let label = ''
    " Get list of buffer numbers in this tab
    let buf_list = tabpagebuflist(v:lnum)

    " Iterate over all the buffers and check if any of them are modified, and
    " if so, start the label with a '+'
    for buf_number in buf_list
        if getbufvar(buf_number, "&modified")
            let label = '+'
            break
        endif
    endfor

    " Get the currently selected buffer filename
    let filename = bufname(buf_list[tabpagewinnr(v:lnum) - 1])
    let filename = fnamemodify(filename, ':p')

    " Get the filename (basename)
    let idx = strridx(filename, '/')
    let basename = strpart(filename, idx + 1, strlen(filename))

    if !strlen(basename)
        return label . '[No name]'
    endif

    " Get the last part of the path
    let path = strpart(filename, 0, idx)
    let idx = strridx(path, '/')
    let path = strpart(path, idx + 1, strlen(path))

    return label . path . '/' . basename
endfunction
set guitablabel=%{GuiTabLabel()}