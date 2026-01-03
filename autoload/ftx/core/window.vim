" Copyright (c) 2026 m-mdy-m
" MIT License
" Window management

function! ftx#core#window#Create() abort
  let pos = g:ftx_position ==# 'right' ? 'botright' : 'topleft'
  execute pos . ' ' . g:ftx_width . 'vnew'
  
  return ftx#core#buffer#Create()
endfunction

function! ftx#core#window#Close() abort
  let winid = ftx#core#buffer#GetWinId()
  if winid == -1
    return
  endif
  
  execute win_id2win(winid) . 'close'
  call ftx#core#buffer#Clear()
endfunction

function! ftx#core#window#Focus() abort
  let winid = ftx#core#buffer#GetWinId()
  if winid != -1
    call win_gotoid(winid)
  endif
endfunction

function! ftx#core#window#IsLast() abort
  return winnr('$') == 1
endfunction

function! ftx#core#window#IsFTXWindow() abort
  return bufnr('%') == ftx#core#buffer#Get()
endfunction

function! ftx#core#window#SaveCursor() abort
  return [line('.'), col('.')]
endfunction

function! ftx#core#window#RestoreCursor(pos) abort
  call cursor(a:pos[0], a:pos[1])
endfunction

function! ftx#core#window#Execute(cmd) abort
  let winid = ftx#core#buffer#GetWinId()
  if winid == -1
    return
  endif
  call win_execute(winid, a:cmd)
endfunction