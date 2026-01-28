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
  
  let origin_tab = tabpagenr()
  let origin_win = winnr()
  
  call s:open_file(node.path, a:cmd, origin_tab, origin_win)
  
  if get(g:, 'ftx_close_on_open', 0)
    call ftx#close()
  endif
endfunction

function! s:open_file(path, cmd, origin_tab, origin_win) abort
  let target_win = s:find_target_window_in_tab(a:origin_tab)
  
  if target_win > 0
    execute 'tabnext' a:origin_tab
    execute target_win . 'wincmd w'
  else
    execute 'tabnext' a:origin_tab
    wincmd p
    
    " If still in FTX, create new window
    if &filetype ==# 'ftx'
      if ftx#internal#drawer#is_drawer()
        wincmd l
        if &filetype ==# 'ftx'
          botright vnew
        endif
      else
        wincmd p
        if &filetype ==# 'ftx'
          botright new
        endif
      endif
    endif
  endif
  
  execute a:cmd . ' ' . fnameescape(a:path)
endfunction

function! s:find_target_window_in_tab(tabnr) abort
  let ftx_bufnr = ftx#internal#buffer#get()
  let current_tab = tabpagenr()
  execute 'tabnext' a:tabnr
  
  let target_win = 0
  let winnr_count = winnr('$')
  
  for winnr in range(1, winnr_count)
    let bufnr = winbufnr(winnr)
    if bufnr == ftx_bufnr
      continue
    endif
    if getbufvar(bufnr, '&buftype') ==# ''
      let target_win = winnr
      break
    endif
  endfor
  execute 'tabnext' current_tab
  
  return target_win
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