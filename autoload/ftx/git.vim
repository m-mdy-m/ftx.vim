" Copyright (c) 2025 m-mdy-m
" MIT License

let s:jobs = {}
let s:timer = -1
let s:git_root = ''
let s:status_cache = {}
let s:branch_info = {}

function! ftx#git#UpdateStatus(path) abort
  if !executable('git')
    return
  endif
  
  let git_root = s:FindGitRoot(a:path)
  if git_root ==# ''
    return
  endif
  
  let s:git_root = git_root
  let s:status_cache = {}
  let s:branch_info = {}
  
  call s:CancelTimer()
  call s:RunGitStatus()
  
  let s:timer = timer_start(g:ftx_git_update_time, function('s:TimerCallback'), {'repeat': -1})
endfunction

function! s:TimerCallback(timer) abort
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
        \ 'exit_cb': function('s:OnExit'),
        \ 'cwd': s:git_root,
        \ })
  
  if job_status(job) ==# 'run'
    let s:jobs.status = job
  endif
endfunction

function! s:OnStdout(channel, msg) abort
  if a:msg =~# '^##'
    call s:ParseBranchLine(a:msg)
  else
    call s:ParseFileLine(a:msg)
  endif
endfunction

function! s:ParseBranchLine(line) abort
  let ahead_match = matchlist(a:line, 'ahead \(\d\+\)')
  let behind_match = matchlist(a:line, 'behind \(\d\+\)')
  
  let s:branch_info = {
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
  
  let symbols = ''
  
  if status =~# '^[MARC]'
    let symbols .= '+'
  elseif status =~# '^ [MARC]'
    let symbols .= '*'
  endif
  
  if status =~# '??'
    let symbols .= '?'
  endif
  
  if symbols !=# ''
    let s:status_cache[full_path] = symbols
  endif
endfunction

function! s:OnExit(job, status) abort
  if a:status != 0
    return
  endif
  
  call s:CheckStash()
  call s:UpdateDisplay()
endfunction

function! s:CheckStash() abort
  let cmd = ['git', '-C', s:git_root, 'rev-parse', '--verify', 'refs/stash']
  let job = job_start(cmd, {
        \ 'out_cb': function('s:OnStashCheck'),
        \ 'err_mode': 'nl',
        \ })
  
  if job_status(job) ==# 'run'
    let s:jobs.stash = job
  endif
endfunction

function! s:OnStashCheck(channel, msg) abort
  if a:msg =~# '^[0-9a-f]\{40\}'
    let s:branch_info.has_stash = 1
    call s:UpdateDisplay()
  endif
endfunction

function! s:UpdateDisplay() abort
  let bufnr = ftx#GetBufnr()
  if bufnr == -1
    return
  endif
  
  " build branch_status
  let branch_status = ''
  if get(s:branch_info, 'has_stash', 0)
    let branch_status .= '$'
  endif
  if get(s:branch_info, 'ahead', 0) > 0
    let branch_status .= '↑' . s:branch_info.ahead
  endif
  if get(s:branch_info, 'behind', 0) > 0
    let branch_status .= '↓' . s:branch_info.behind
  endif

  for [path, status] in items(s:status_cache)
    let full_status = status . branch_status
    call ftx#renderer#SetGitStatus(path, full_status)
  endfor

  let tree = ftx#renderer#GetTree()
  let lines = []
  for node in tree
    let indent = repeat('  ', node.depth)
    let icon = node.is_dir ? (node.is_expanded ? '▾ ' : '▸ ') : '  '
    let git = node.git_status !=# '' ? ' ' . node.git_status : ''
    call add(lines, indent . icon . node.name . git)
  endfor

  let winid = bufwinid(bufnr)
  if winid == -1
    return
  endif

  let was_modifiable = getbufvar(bufnr, '&modifiable')
  if !was_modifiable
    call win_execute(winid, 'setlocal modifiable')
  endif

  let cur_lines = getbufline(bufnr, 1, '$')
  if cur_lines !=# lines
    call win_execute(winid, 'silent %delete _ | call setline(1, ' . string(lines) . ')')
  endif

  if !was_modifiable
    call win_execute(winid, 'setlocal nomodifiable')
  endif
endfunction

function! s:FindGitRoot(path) abort
  let path = fnamemodify(a:path, ':p')
  
  while path !=# '/' && path !=# ''
    if isdirectory(path . '/.git')
      return path
    endif
    let path = fnamemodify(path, ':h')
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

function! s:CancelTimer() abort
  if s:timer != -1
    call timer_stop(s:timer)
    let s:timer = -1
  endif
endfunction

function! ftx#git#Cleanup() abort
  call s:CancelTimer()
  call s:StopJobs()
  let s:git_root = ''
  let s:status_cache = {}
  let s:branch_info = {}
endfunction