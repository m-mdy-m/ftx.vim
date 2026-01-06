" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" State manager for FTX async engine.
" Maintains global task queue, worker pool, and configuration.
" Provides helpers for adding/removing tasks and workers.
" Core backbone for async operations in file tree rendering.
" ----------------------------------------------------------------------

function! ftx#async#internal#state#ensure() abort
  if !exists('g:ftx_async') || type(g:ftx_async) != v:t_dict
    let g:ftx_async = {
          \ 'tasks': [],
          \ 'workers': [],
          \ 'max_workers': 50,
          \ 'next_task_id': 0,
          \ }
  endif
endfunction

function! ftx#async#internal#state#init(...) abort
  call ftx#async#internal#state#ensure()
  if a:0
    let g:ftx_async.max_workers = a:1
  endif
endfunction

" --- Task helpers ---
function! ftx#async#internal#state#next_task_id() abort
  call ftx#async#internal#state#ensure()
  let id = g:ftx_async.next_task_id
  let g:ftx_async.next_task_id += 1
  return id
endfunction

function! ftx#async#internal#state#add_task(task) abort
  call ftx#async#internal#state#ensure()
  call add(g:ftx_async.tasks, a:task)
endfunction

function! ftx#async#internal#state#pop_task() abort
  call ftx#async#internal#state#ensure()
  if empty(g:ftx_async.tasks)
    return v:null
  endif
  return remove(g:ftx_async.tasks, 0)
endfunction

function! ftx#async#internal#state#peek_task() abort
  call ftx#async#internal#state#ensure()
  if empty(g:ftx_async.tasks)
    return v:null
  endif
  return g:ftx_async.tasks[0]
endfunction

function! ftx#async#internal#state#tasks_len() abort
  call ftx#async#internal#state#ensure()
  return len(g:ftx_async.tasks)
endfunction

function! ftx#async#internal#state#clear_tasks() abort
  call ftx#async#internal#state#ensure()
  let g:ftx_async.tasks = []
endfunction

function! ftx#async#internal#state#remove_task_by_id(id) abort
  call ftx#async#internal#state#ensure()
  for idx in range(len(g:ftx_async.tasks))
    if g:ftx_async.tasks[idx].id == a:id
      call remove(g:ftx_async.tasks, idx)
      return 1
    endif
  endfor
  return 0
endfunction

" --- Worker helpers ---
function! ftx#async#internal#state#add_worker(worker) abort
  call ftx#async#internal#state#ensure()
  call add(g:ftx_async.workers, a:worker)
endfunction

function! ftx#async#internal#state#remove_worker_by_timer(timer_id) abort
  call ftx#async#internal#state#ensure()
  let before = len(g:ftx_async.workers)
  call filter(g:ftx_async.workers, {_, w -> w.id != a:timer_id})
  return before - len(g:ftx_async.workers)
endfunction

function! ftx#async#internal#state#find_worker(timer_id) abort
  call ftx#async#internal#state#ensure()
  for w in g:ftx_async.workers
    if w.id == a:timer_id
      return w
    endif
  endfor
  return v:null
endfunction

function! ftx#async#internal#state#workers_len() abort
  call ftx#async#internal#state#ensure()
  return len(g:ftx_async.workers)
endfunction

function! ftx#async#internal#state#clear_workers() abort
  call ftx#async#internal#state#ensure()
  let g:ftx_async.workers = []
endfunction

" --- Config getters/setters ---
function! ftx#async#internal#state#get_max_workers() abort
  call ftx#async#internal#state#ensure()
  return g:ftx_async.max_workers
endfunction

function! ftx#async#internal#state#set_max_workers(n) abort
  if a:n <= 0
    throw 'max_workers must be positive'
  endif
  call ftx#async#internal#state#ensure()
  let g:ftx_async.max_workers = a:n
endfunction