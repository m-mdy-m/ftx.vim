" Copyright (c) 2026 m-mdy-m
" MIT License
" Git blame operations

let s:blame_cache = {}
let s:blame_job = -1

function! ftx#git#blame#Show() abort
  if !g:ftx_enable_git || !g:ftx_git_blame || !executable('git')
    call ftx#utils#EchoError('Git blame is disabled or not available')
    return
  endif
  
  let node = ftx#ui#renderer#GetNode()
  if empty(node) || node.is_dir
    call ftx#utils#EchoError('Select a file to show blame')
    return
  endif
  
  call s:RunBlame(node.path)
endfunction

function! s:RunBlame(file) abort
  if !ftx#utils#IsReadable(a:file)
    return
  endif
  
  let root = ftx#git#status#GetRoot()
  if empty(root)
    call ftx#utils#EchoError('Not in a git repository')
    return
  endif
  
  let cmd = ['git', '-C', root, 'log', '-n', '10', '--format=%h|%an|%ar|%s', '--', a:file]
  let s:blame_cache[a:file] = []
  
  let s:blame_job = job_start(cmd, {
        \ 'out_cb': {ch, msg -> s:OnOutput(a:file, msg)},
        \ 'exit_cb': {job, status -> s:OnExit(a:file, status)},
        \ 'err_mode': 'nl',
        \ })
endfunction

function! s:OnOutput(file, msg) abort
  if !has_key(s:blame_cache, a:file)
    let s:blame_cache[a:file] = []
  endif
  call add(s:blame_cache[a:file], a:msg)
endfunction

function! s:OnExit(file, status) abort
  if a:status != 0
    call ftx#utils#EchoError('Git blame failed')
    return
  endif
  
  call s:ShowPopup(a:file)
endfunction

function! s:ShowPopup(file) abort
  if !has_key(s:blame_cache, a:file) || empty(s:blame_cache[a:file])
    call ftx#utils#EchoError('No blame information available')
    return
  endif
  
  let lines = s:FormatBlame(a:file)
  
  if ftx#ui#popup#IsSupported()
    call ftx#ui#popup#Large(lines)
  else
    for line in lines
      echo line
    endfor
  endif
endfunction

function! s:FormatBlame(file) abort
  let lines = []
  call add(lines, '╔════════════════════════════════════════════════════════╗')
  call add(lines, '║              Git Blame - Recent Commits                ║')
  call add(lines, '╠════════════════════════════════════════════════════════╣')
  call add(lines, '║                                                        ║')
  
  for entry in s:blame_cache[a:file][:9]
    let parts = split(entry, '|')
    if len(parts) >= 4
      let hash = parts[0]
      let author = parts[1]
      let time = parts[2]
      let message = parts[3]
      
      call add(lines, '║  ' . hash . ' │ ' . ftx#utils#Truncate(author, 15) . '  ║')
      call add(lines, '║  ' . ftx#utils#PadRight(time, 48) . '  ║')
      call add(lines, '║  ' . ftx#utils#Truncate(message, 48) . '  ║')
      call add(lines, '║                                                        ║')
    endif
  endfor
  
  call add(lines, '╚════════════════════════════════════════════════════════╝')
  
  return lines
endfunction

function! ftx#git#blame#Cleanup() abort
  if s:blame_job != -1 && job_status(s:blame_job) ==# 'run'
    call job_stop(s:blame_job)
  endif
  let s:blame_cache = {}
endfunction