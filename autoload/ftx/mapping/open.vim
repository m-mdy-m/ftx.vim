" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#mapping#open#execute(cmd) abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node)
    return
  endif
  
  if node.is_dir
    call ftx#mapping#tree#toggle_expand()
    return
  endif
  
  if !filereadable(node.path)
    call ftx#helpers#logger#error('File not readable', node.path)
    return
  endif
  
  call s:open_file(node.path, a:cmd)
  
  if get(g:, 'ftx_close_on_open', 0)
    call ftx#close()
  endif
endfunction

function! s:open_file(path, cmd) abort
  let target_win = s:find_target_window()
  
  if target_win != -1
    execute target_win . 'wincmd w'
  else
    wincmd p
  endif
  
  execute a:cmd . ' ' . fnameescape(a:path)
endfunction

function! s:find_target_window() abort
  let ftx_bufnr = ftx#internal#buffer#get()
  
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

function! ftx#mapping#open#in_split(vertical) abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node) || node.is_dir
    return
  endif
  
  let cmd = a:vertical ? 'vsplit' : 'split'
  call ftx#mapping#open#execute(cmd)
endfunction

function! ftx#mapping#open#in_tab() abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node) || node.is_dir
    return
  endif
  
  call ftx#mapping#open#execute('tabedit')
endfunction