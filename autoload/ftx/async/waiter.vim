" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Allows waiting for multiple async tasks to complete before callback.
" ----------------------------------------------------------------------

let s:wait_groups = {}
function! ftx#async#waiter#waitgroup() abort
  let wg_id = string(localtime()) . '_' . string(rand())
  let s:wait_groups[wg_id] = {
        \ 'counter': 0,
        \ 'callbacks': [],
        \ }
  return wg_id
endfunction

function! ftx#async#waiter#wg_add(wg_id, delta) abort
  if !has_key(s:wait_groups, a:wg_id)
    throw 'WaitGroup not found'
  endif
  
  let wg = s:wait_groups[a:wg_id]
  let wg.counter += a:delta
  
  if wg.counter < 0
    throw 'WaitGroup counter negative'
  endif
  
  if wg.counter == 0
    for Callback in wg.callbacks
      call ftx#async#queue#schedule(Callback)
    endfor
    let wg.callbacks = []
  endif
endfunction

function! ftx#async#waiter#wg_wait(wg_id, callback) abort
  if !has_key(s:wait_groups, a:wg_id)
    throw 'WaitGroup not found'
  endif
  
  let wg = s:wait_groups[a:wg_id]
  
  if wg.counter == 0
    " Already done, call immediately
    call ftx#async#queue#schedule(a:callback)
  else
    call add(wg.callbacks, a:callback)
  endif
endfunction

function! ftx#async#waiter#wg_done(wg_id) abort
  call ftx#async#waiter#wg_add(a:wg_id, -1)
endfunction
