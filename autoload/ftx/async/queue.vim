" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#async#queue#schedule(func, ...) abort
  let id = ftx#async#state#next_task_id()
  let task = {
        \ 'id': id,
        \ 'func': a:func,
        \ 'args': a:000,
        \ 'created_at': reltime(),
        \ }
  call ftx#async#state#add_task(task)
  call ftx#async#worker#ensure_workers()
  return id
endfunction

function! ftx#async#queue#spawn(funcs) abort
  let task_ids = []
  
  for Func in a:funcs
    call add(task_ids, ftx#async#queue#schedule(Func))
  endfor
  
  return task_ids
endfunction

function! ftx#async#queue#sleep(ms, callback) abort
  call timer_start(a:ms, {-> ftx#async#queue#schedule(a:callback)})
endfunction