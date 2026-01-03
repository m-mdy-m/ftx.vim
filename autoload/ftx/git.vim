" Copyright (c) 2026 m-mdy-m
" MIT License

let s:jobs = {}
let s:git_root = ''
let s:status_cache = {}
let s:branch_info = {}
let s:status_lines = []

function! ftx#git#UpdateStatus(path) abort
  if !g:ftx_git_status || !executable('git')
    return
  endif
  
  let git_root = s:FindGitRoot(a:path)
  if git_root ==# ''
    let s:git_root = ''
    let s:status_cache = {}
    let s:branch_info = {}
    call ftx#UpdateStatusLine()
    return
  endif
  
  let s:git_root = git_root
  let s:status_cache = {}
  let s:branch_info = {}
  let s:status_lines = []
  
  call s:RunGitStatus()
endfunction

function! s:RunGitStatus() abort
  if s:git_root ==# ''
    return
  endif
  
  call s:StopJobs()
  
  let cmd = ['git', '-C', s:git_root, 'status', '--porcelain', '-b']
  let job = job_start(cmd, {
        \ 'out_cb': function('s:OnStdout'),
        \ 'exit_cb': function('s:OnStatusExit'),
        \ 'err_mode': 'nl',
        \ })
  
  if job_status(job) ==# 'run'
    let s:jobs.status = job
  endif
endfunction

function! s:OnStdout(channel, msg) abort
  call add(s:status_lines, a:msg)
endfunction

function! s:OnStatusExit(job, status) abort
  if a:status != 0
    return
  endif
  
  for line in s:status_lines
    if line =~# '^##'
      call s:ParseBranchLine(line)
    else
      call s:ParseFileLine(line)
    endif
  endfor
  
  call s:CheckStash()
endfunction

function! s:ParseBranchLine(line) abort
  let branch_match = matchlist(a:line, '## \([^.[:space:]]\+\)')
  let branch = len(branch_match) > 1 ? branch_match[1] : ''
  
  let ahead_match = matchlist(a:line, 'ahead \(\d\+\)')
  let behind_match = matchlist(a:line, 'behind \(\d\+\)')
  
  let s:branch_info = {
        \ 'branch': branch,
        \ 'ahead': len(ahead_match) > 1 ? str2nr(ahead_match[1]) : 0,
        \ 'behind': len(behind_match) > 1 ? str2nr(behind_match[1]) : 0,
        \ 'has_stash': 0
        \ }
endfunction

function! s:ParseFileLine(line) abort
  if len(a:line) < 3
    return
  endif
  
  let status = a:line[0:1]
  let file = substitute(a:line[3:], ' -> .*', '', '')
  let full_path = s:git_root . '/' . file
  
  let symbol = ''
  
  if status[0] ==# 'M' || status[0] ==# 'A' || status[0] ==# 'R' || status[0] ==# 'C'
    let symbol = '+'
  elseif status[1] ==# 'M'
    let symbol = '*'
  elseif status[0] ==# 'D' || status[1] ==# 'D'
    let symbol = '-'
  elseif status ==# '??'
    let symbol = '?'
  elseif status ==# 'UU' || status ==# 'AA'
    let symbol = '!'
  endif
  
  if symbol !=# ''
    let s:status_cache[full_path] = symbol
    
    let dir = fnamemodify(full_path, ':h')
    while dir !=# s:git_root && dir !=# '/'
      if !has_key(s:status_cache, dir)
        let s:status_cache[dir] = '*'
      endif
      let dir = fnamemodify(dir, ':h')
    endwhile
  endif
endfunction

function! s:CheckStash() abort
  if s:git_root ==# ''
    return
  endif
  
  let cmd = ['git', '-C', s:git_root, 'rev-parse', '--verify', 'refs/stash']
  let job = job_start(cmd, {
        \ 'out_cb': function('s:OnStashCheck'),
        \ 'err_mode': 'nl',
        \ 'exit_cb': function('s:OnStashExit'),
        \ })
  
  if job_status(job) ==# 'run'
    let s:jobs.stash = job
  endif
endfunction

function! s:OnStashCheck(channel, msg) abort
  if a:msg =~# '^[0-9a-f]\{40\}'
    let s:branch_info.has_stash = 1
  endif
endfunction

function! s:OnStashExit(job, status) abort
  call s:UpdateDisplay()
endfunction

function! s:UpdateDisplay() abort
  call ftx#renderer#SetGitStatus(s:status_cache)
  
  call ftx#renderer#UpdateGitStatus()
  
  call ftx#UpdateStatusLine()
endfunction

function! s:FindGitRoot(path) abort
  let path = fnamemodify(a:path, ':p:h')
  
  let max_depth = 20
  let depth = 0
  
  while path !=# '/' && path !=# '' && depth < max_depth
    if isdirectory(path . '/.git')
      return path
    endif
    let path = fnamemodify(path, ':h')
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

function! ftx#git#Cleanup() abort
  call s:StopJobs()
  let s:git_root = ''
  let s:status_cache = {}
  let s:branch_info = {}
  let s:status_lines = []
endfunction

function! ftx#git#GetBranchInfo() abort
  return s:branch_info
endfunction

function! ftx#git#Refresh() abort
  let root = ftx#GetRoot()
  if root !=# ''
    call ftx#git#UpdateStatus(root)
  endif
endfunction