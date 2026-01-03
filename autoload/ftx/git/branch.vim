" Copyright (c) 2026 m-mdy-m
" MIT License
" Git branch operations

let s:branch_info = {}
let s:stash_job = -1

function! ftx#git#branch#ParseLine(line) abort
  let branch_match = matchlist(a:line, '## \([^.[:space:]]\+\)')
  let ahead_match = matchlist(a:line, 'ahead \(\d\+\)')
  let behind_match = matchlist(a:line, 'behind \(\d\+\)')
  
  let s:branch_info = {
        \ 'branch': len(branch_match) > 1 ? branch_match[1] : '',
        \ 'ahead': len(ahead_match) > 1 ? str2nr(ahead_match[1]) : 0,
        \ 'behind': len(behind_match) > 1 ? str2nr(behind_match[1]) : 0,
        \ 'has_stash': 0
        \ }
endfunction

function! ftx#git#branch#CheckStash() abort
  let root = ftx#git#status#GetRoot()
  if empty(root)
    call s:UpdateDisplay()
    return
  endif
  
  let cmd = ['git', '-C', root, 'rev-parse', '--verify', 'refs/stash']
  let s:stash_job = job_start(cmd, {
        \ 'out_cb': function('s:OnStashCheck'),
        \ 'exit_cb': function('s:OnStashExit'),
        \ 'err_mode': 'nl',
        \ })
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
  call ftx#ui#renderer#UpdateGitStatus(ftx#git#status#GetCache())
  call ftx#UpdateStatusLine()
endfunction

function! ftx#git#branch#GetInfo() abort
  return s:branch_info
endfunction

function! ftx#git#branch#ShowInfo() abort
  if !g:ftx_enable_git || empty(s:branch_info)
    call ftx#utils#EchoError('No git repository or branch info available')
    return
  endif
  
  let lines = s:FormatInfo()
  
  if g:ftx_branch_info_float && ftx#ui#popup#IsSupported()
    call ftx#ui#popup#Info(lines)
  else
    for line in lines
      echo line
    endfor
  endif
endfunction

function! s:FormatInfo() abort
  let lines = []
  call add(lines, '╔═══════════════════════════════╗')
  call add(lines, '║     Git Branch Information    ║')
  call add(lines, '╠═══════════════════════════════╣')
  call add(lines, '║                               ║')
  call add(lines, '║  Branch: ' . ftx#utils#PadRight(get(s:branch_info, 'branch', 'unknown'), 20) . '║')
  
  if get(s:branch_info, 'ahead', 0) > 0
    call add(lines, '║  Ahead:  ↑ ' . ftx#utils#PadRight(s:branch_info.ahead . ' commits', 17) . '║')
  endif
  
  if get(s:branch_info, 'behind', 0) > 0
    call add(lines, '║  Behind: ↓ ' . ftx#utils#PadRight(s:branch_info.behind . ' commits', 17) . '║')
  endif
  
  if get(s:branch_info, 'has_stash', 0)
    call add(lines, '║  Stash:  $ exists             ║')
  endif
  
  call add(lines, '║                               ║')
  call add(lines, '╚═══════════════════════════════╝')
  
  return lines
endfunction

function! ftx#git#branch#Cleanup() abort
  if s:stash_job != -1 && job_status(s:stash_job) ==# 'run'
    call job_stop(s:stash_job)
  endif
  let s:branch_info = {}
endfunction