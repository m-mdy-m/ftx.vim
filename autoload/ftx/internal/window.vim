" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:previous_window = -1

function! ftx#internal#window#create() abort
  call s:save_previous_window()
  
  let position = get(g:, 'ftx_position', 'left')
  let width = get(g:, 'ftx_width', 30)
  
  let cmd = position ==# 'right' ? 'botright' : 'topleft'
  execute cmd . ' ' . width . 'vnew'
  
  return ftx#internal#buffer#create()
endfunction

function! ftx#internal#window#close() abort
  let winid = ftx#internal#buffer#winid()
  
  if winid == -1
    return
  endif
  
  let winnr = win_id2win(winid)
  execute winnr . 'close'
  
  call ftx#internal#buffer#clear()
endfunction

function! ftx#internal#window#focus() abort
  if &filetype !=# 'ftx'
    call s:save_previous_window()
  endif
  
  let winid = ftx#internal#buffer#winid()
  
  if winid != -1
    call win_gotoid(winid)
  endif
endfunction

function! s:save_previous_window() abort
  let current_win = win_getid()
  
  " Don't save if current window is FTX itself
  if getwinvar(current_win, '&filetype') !=# 'ftx'
    let s:previous_window = current_win
  endif
endfunction

function! ftx#internal#window#get_previous() abort
  return s:previous_window
endfunction

function! ftx#internal#window#goto_previous() abort
  if s:previous_window == -1
    return 0
  endif
  if !win_id2win(s:previous_window)
    let s:previous_window = -1
    return 0
  endif
  
  call win_gotoid(s:previous_window)
  return 1
endfunction

function! ftx#internal#window#execute(cmd) abort
  let winid = ftx#internal#buffer#winid()
  
  if winid == -1
    throw 'FTX window does not exist'
  endif
  
  call win_execute(winid, a:cmd)
endfunction

function! ftx#internal#window#find_suitable() abort
  if s:previous_window != -1 && win_id2win(s:previous_window)
    return s:previous_window
  endif
  let ftx_bufnr = ftx#internal#buffer#get()
  
  for winnr in range(1, winnr('$'))
    let winid = win_getid(winnr)
    let bufnr = winbufnr(winnr)
    if bufnr == ftx_bufnr
      continue
    endif
    if has('nvim')
      try
        let config = nvim_win_get_config(winid)
        if config.relative !=# ''
          continue
        endif
      catch
      endtry
    endif
    if getbufvar(bufnr, '&buftype') ==# ''
      let s:previous_window = winid
      return winid
    endif
  endfor
  
  return -1
endfunction