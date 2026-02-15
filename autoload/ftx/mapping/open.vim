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
  
  call ftx#api#open_node_with(a:cmd, node)
  
  if get(g:, 'ftx_close_on_open', 0)
    call ftx#close()
  endif
endfunction

function! ftx#mapping#open#open_path(path, cmd) abort
  if ftx#internal#window#goto_previous()
    execute a:cmd . ' ' . fnameescape(a:path)
    return
  endif
  let target_winid = ftx#internal#window#find_suitable()
  
  if target_winid != -1
    call win_gotoid(target_winid)
    execute a:cmd . ' ' . fnameescape(a:path)
    return
  endif
  if ftx#internal#drawer#is_drawer()
    let position = get(g:, 'ftx_position', 'left')
    if position ==# 'left'
      wincmd l
    else
      wincmd h
    endif
    
    if &filetype ==# 'ftx'
      if position ==# 'left'
        botright vnew
      else
        topleft vnew
      endif
    endif
  else
    wincmd p
    
    if &filetype ==# 'ftx'
      botright new
    endif
  endif
  
  execute a:cmd . ' ' . fnameescape(a:path)
endfunction

function! ftx#mapping#open#in_split(vertical) abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node) || node.is_dir
    return
  endif
  
  call ftx#mapping#open#execute(a:vertical ? 'vsplit' : 'split')
endfunction

function! ftx#mapping#open#in_tab() abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node) || node.is_dir
    return
  endif
  
  call ftx#mapping#open#execute('tabedit')
endfunction