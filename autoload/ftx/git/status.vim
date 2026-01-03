" Copyright (c) 2026 m-mdy-m
" MIT License
" Git status operations

let s:jobs = {}
let s:git_root = ''
let s:status_cache = {}
let s:status_lines = []

function! ftx#git#status#Update(path) abort
  if !g:ftx_enable_git || !g:ftx_git_status || !executable('git')
    return
  endif
  
  let git_root = s:FindGitRoot(a:path)
  if empty(git_root)
    let s:git_root = ''
    let s:status_cache = {}
    return
  endif
  
  let s:git_root = git_root
  let s:status_cache = {}
  let s:status_lines = []
  
  call s:RunGitStatus()
endfunction

function! s:RunGitStatus() abort
  if empty(s:git_root)
    return
  endif
  
  call s:StopJobs()
  
  let cmd = ['git', '-C', s:git_root, 'status', '--porcelain', '-b', '--ignored']
  let job = job_start(cmd, {
        \ 'out_cb': function('s:OnOutput'),
        \ 'exit_cb': function('s:OnExit'),
        \ 'err_mode': 'nl',
        \ })
  
  if job_status(job) ==# 'run'
    let s:jobs.status = job
  endif
endfunction

function! s:OnOutput(channel, msg) abort
  call add(s:status_lines, a:msg)
endfunction

function! s:OnExit(job, status) abort
  if a:status != 0
    return
  endif
  
  for line in s:status_lines
    if line =~# '^##'
      call ftx#git#branch#ParseLine(line)
    elseif line =~# '^!!'
      if g:ftx_show_ignored
        call s:ParseFileLine(line)
      endif
    else
      call s:ParseFileLine(line)
    endif
  endfor
  
  call ftx#git#branch#CheckStash()
endfunction

function! s:ParseFileLine(line) abort
  if len(a:line) < 3
    return
  endif
  
  let status = a:line[0:1]
  let file = substitute(a:line[3:], ' -> .*', '', '')
  let path = s:git_root . '/' . file
  
  let icon = s:GetStatusIcon(status)
  if !empty(icon)
    let s:status_cache[path] = icon
    call s:MarkParentDirs(path)
  endif
endfunction

function! s:GetStatusIcon(status) abort
  if a:status[0:1] ==# '!!'
    return g:ftx_git_icon_ignored
  elseif a:status[0] =~# '[MARC]'
    return g:ftx_git_icon_added
  elseif a:status[1] ==# 'M'
    return g:ftx_git_icon_modified
  elseif a:status =~# 'D'
    return g:ftx_git_icon_deleted
  elseif a:status ==# '??'
    return g:ftx_git_icon_untracked
  elseif a:status =~# 'UU\|AA'
    return g:ftx_git_icon_unmerged
  elseif a:status[0] ==# 'R'
    return g:ftx_git_icon_renamed
  endif
  return ''
endfunction

function! s:MarkParentDirs(path) abort
  let dir = ftx#utils#GetParentDir(a:path)
  while dir !=# s:git_root && dir !=# '/'
    if !has_key(s:status_cache, dir)
      let s:status_cache[dir] = g:ftx_git_icon_modified
    endif
    let dir = ftx#utils#GetParentDir(dir)
  endwhile
endfunction

function! s:FindGitRoot(path) abort
  let path = fnamemodify(a:path, ':p:h')
  let depth = 0
  
  while path !=# '/' && path !=# '' && depth < 20
    if isdirectory(path . '/.git')
      return path
    endif
    let path = ftx#utils#GetParentDir(path)
    let depth += 1
  endwhile
  
  return ''
endfunction

function! s:StopJobs() abort
  for [name, job] in items(s:jobs)
    if job_status(job) ==# 'run'
      call job_stop(job)
    endif
  endfor
  let s:jobs = {}
endfunction

function! ftx#git#status#GetCache() abort
  return s:status_cache
endfunction

function! ftx#git#status#GetRoot() abort
  return s:git_root
endfunction

function! ftx#git#status#Cleanup() abort
  call s:StopJobs()
  let s:git_root = ''
  let s:status_cache = {}
  let s:status_lines = []
endfunction