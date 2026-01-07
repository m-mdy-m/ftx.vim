" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#mapping#node#cd() abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node)
    return
  endif
  
  let path = node.is_dir ? node.path : ftx#helpers#path#dirname(node.path)
  
  if !isdirectory(path)
    call ftx#helpers#logger#error('Invalid directory', path)
    return
  endif
  
  let target_win = s:find_target_window()
  
  if target_win != -1
    execute target_win . 'wincmd w'
  else
    wincmd p
  endif
  
  if has('nvim')
    execute 'terminal'
    call chansend(b:terminal_job_id, 'cd ' . shellescape(path) . "\<CR>")
  else
    execute 'terminal ++curwin'
    call term_sendkeys(bufnr('%'), 'cd ' . shellescape(path) . "\<CR>")
  endif
  
  call ftx#helpers#logger#info('Opened terminal in ' . path)
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