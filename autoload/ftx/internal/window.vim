" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#internal#window#create() abort
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
  let winid = ftx#internal#buffer#winid()
  
  if winid != -1
    call win_gotoid(winid)
  endif
endfunction

function! ftx#internal#window#execute(cmd) abort
  let winid = ftx#internal#buffer#winid()
  
  if winid == -1
    throw 'FTX window does not exist'
  endif
  
  call win_execute(winid, a:cmd)
endfunction