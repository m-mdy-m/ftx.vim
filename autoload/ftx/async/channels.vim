" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Implements non-blocking communication between tasks and callbacks.
" ----------------------------------------------------------------------

let s:channels = {}

function! ftx#async#channels#channel() abort
  let ch_id = printf('%d_%d_%d', reltime()[0], reltime()[1], rand())
  while has_key(s:channels, ch_id)
    let ch_id = printf('%d_%d_%d', reltime()[0], reltime()[1], rand())
  endwhile

  let s:channels[ch_id] = {
        \ 'buffer': [],
        \ 'closed': 0,
        \ 'receivers': [],
        \ }
  return ch_id
endfunction

function! ftx#async#channels#send(ch_id, value) abort
  if !has_key(s:channels, a:ch_id)
    throw 'Channel not found'
  endif
  
  let ch = s:channels[a:ch_id]
  
  if ch.closed
    throw 'Send on closed channel'
  endif
  
  if !empty(ch.receivers)
    let Receiver = remove(ch.receivers, 0)
    call ftx#async#queue#schedule(Receiver, a:value)
  else
    call add(ch.buffer, a:value)
  endif
endfunction

function! ftx#async#channels#receive(ch_id, callback) abort
  if !has_key(s:channels, a:ch_id)
    throw 'Channel not found'
  endif
  
  let ch = s:channels[a:ch_id]
  
  if !empty(ch.buffer)
    let value = remove(ch.buffer, 0)
    call ftx#async#queue#schedule(a:callback, value)
  else
    call add(ch.receivers, a:callback)
  endif
endfunction

function! ftx#async#channels#close(ch_id) abort
  if has_key(s:channels, a:ch_id)
    let s:channels[a:ch_id].closed = 1
  endif
endfunction
function! ftx#async#channels#is_closed(ch_id) abort
  if !has_key(s:channels, a:ch_id)
    throw 'Channel not found'
  endif
  return s:channels[a:ch_id].closed
endfunction