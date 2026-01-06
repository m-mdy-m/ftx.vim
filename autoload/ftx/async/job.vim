" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Promise wrapper over goroutine-style scheduler
" Provides clean, chainable async API
" ----------------------------------------------------------------------
function! ftx#async#job#run(cmd, ...) abort
  let opts = get(a:000, 0, {})
  
  return ftx#async#promise#new({resolve, reject ->
        \ s:job_executor(a:cmd, opts, resolve, reject)
        \ })
endfunction

function! s:job_executor(cmd, opts, resolve, reject) abort
  let cwd = get(a:opts, 'cwd', getcwd())
  let output = []
  
  if has('nvim')
    call s:nvim_job(a:cmd, cwd, output, a:resolve, a:reject)
  else
    call s:vim_job(a:cmd, cwd, output, a:resolve, a:reject)
  endif
endfunction

function! s:nvim_job(cmd, cwd, output, resolve, reject) abort
  call jobstart(a:cmd, {
        \ 'cwd': a:cwd,
        \ 'on_stdout': {j, d, e -> extend(a:output, filter(d, '!empty(v:val)'))},
        \ 'on_exit': {j, c, e -> c == 0 ? a:resolve(a:output) : a:reject('Job failed: ' . c)}
        \ })
endfunction

function! s:vim_job(cmd, cwd, output, resolve, reject) abort
  call job_start(a:cmd, {
        \ 'cwd': a:cwd,
        \ 'out_cb': {ch, msg -> add(a:output, msg)},
        \ 'exit_cb': {j, c -> c == 0 ? a:resolve(a:output) : a:reject('Job failed: ' . c)}
        \ })
endfunction