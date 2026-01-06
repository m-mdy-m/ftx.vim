" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#async#internal#queue#schedule(func, ...) abort
  let id = ftx#async#internal#state#next_task_id()
  let task = {
        \ 'id': id,
        \ 'func': a:func,
        \ 'args': a:000,
        \ 'created_at': reltime(),
        \ }
  call ftx#async#internal#state#add_task(task)
  call ftx#async#internal#worker#ensure_workers()
  return id
endfunction

function! ftx#async#internal#queue#spawn(funcs) abort
  let task_ids = []
  
  for Func in a:funcs
    call add(task_ids, ftx#async#internal#queue#schedule(Func))
  endfor
  
  return task_ids
endfunction

function! ftx#async#internal#queue#sleep(ms, callback) abort
  call timer_start(a:ms, {-> ftx#async#internal#queue#schedule(a:callback)})
endfunction