" Copyright (c) 2025 m-mdy-m
" MIT License

function! ftx#action#Open(cmd) abort
  let node = ftx#renderer#GetNode()
  
  if empty(node)
    return
  endif
  
  if node.is_dir
    call ftx#renderer#ToggleExpand(node)
    return
  endif
  
  if !filereadable(node.path)
    echohl ErrorMsg
    echo '[ftx] File not readable: ' . node.path
    echohl None
    return
  endif
  wincmd p
  execute a:cmd . ' ' . fnameescape(node.path)

  if get(g:, 'ftx_close_on_open', 0)
    call ftx#Close()
  endif
endfunction

function! ftx#action#ToggleHidden() abort
  let g:ftx_show_hidden = !g:ftx_show_hidden
  call ftx#Refresh()
  
  echo '[ftx] Hidden files: ' . (g:ftx_show_hidden ? 'shown' : 'hidden')
endfunction

function! s:FindSuitableWindow() abort
  let ftx_bufnr = ftx#GetBufnr()
  
  for winnr in range(1, winnr('$'))
    let bufnr = winbufnr(winnr)
    
    if bufnr == ftx_bufnr
      continue
    endif
    
    if getbufvar(bufnr, '&buftype') ==# ''
      return winnr
    endif
  endfor
  
  return -1
endfunction