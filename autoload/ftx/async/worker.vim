" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Worker pool implementation for FTX async engine.
" Spawns and manages workers that execute queued tasks.
" Automatically scales based on queued tasks and max worker limit.
" ----------------------------------------------------------------------

function! ftx#async#worker#ensure_workers() abort
  if ftx#async#state#workers_len() == 0 && ftx#async#state#tasks_len() > 0
    call ftx#async#worker#spawn_worker()
  endif
endfunction

function! ftx#async#worker#spawn_worker() abort
  if ftx#async#state#workers_len() >= ftx#async#state#get_max_workers()
    return
  endif
  
  let timer_id = timer_start(0, function('ftx#async#worker#run'), {'repeat': -1})
  call ftx#async#state#add_worker({
        \ 'id': timer_id,
        \ 'tasks_completed': 0,
        \ 'started_at': reltime(),
        \ })
endfunction

function! ftx#async#worker#run(timer_id) abort
  if v:dying
     call ftx#async#worker#stop_worker(a:timer_id)
    return
  endif
  
  if !ftx#async#state#tasks_len()
    call ftx#async#worker#stop_worker(a:timer_id)
    return
  endif
  
  let task = ftx#async#state#pop_task()
  if task is v:null
    return
  endif
  try
    call call(task.func, task.args)
    let worker = ftx#async#state#find_worker(a:timer_id)
    if worker isnot v:null
      let worker.tasks_completed += 1
    endif
    
  catch
    echohl ErrorMsg
    echom '[FTX Scheduler Error] Task' task.id 'failed:'
    echom v:exception
    echom v:throwpoint
    echohl None
  endtry
  
  if ftx#async#state#tasks_len() > ftx#async#state#workers_len() && ftx#async#state#workers_len() < ftx#async#state#get_max_workers()
    call ftx#async#worker#spawn_worker()
  endif
endfunction

function! ftx#async#worker#stop_worker(timer_id) abort
  call timer_stop(a:timer_id)
  call ftx#async#state#remove_worker_by_timer(a:timer_id)
endfunction