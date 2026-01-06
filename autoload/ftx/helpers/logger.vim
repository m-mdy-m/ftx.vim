" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:log_levels = {
      \ 'debug': 0,
      \ 'info': 1,
      \ 'warn': 2,
      \ 'error': 3,
      \ }

let s:current_level = get(g:, 'ftx_log_level', 'debug')
let s:log_file = get(g:, 'ftx_log_file', '')

function! ftx#helpers#logger#debug(msg, ...) abort
  call s:log('debug', a:msg, a:000)
endfunction

function! ftx#helpers#logger#info(msg, ...) abort
  call s:log('info', a:msg, a:000)
endfunction

function! ftx#helpers#logger#warn(msg, ...) abort
  call s:log('warn', a:msg, a:000)
endfunction

function! ftx#helpers#logger#error(msg, ...) abort
  call s:log('error', a:msg, a:000)
endfunction

function! s:log(level, msg, args) abort
  if !s:should_log(a:level)
    return
  endif
  
  let timestamp = strftime('%Y-%m-%d %H:%M:%S')
  let level_str = printf('[%s]', toupper(a:level))
  let msg = a:msg
  
  if !empty(a:args)
    let msg .= ' ' . string(a:args)
  endif
  
  let log_line = printf('%s %s %s', timestamp, level_str, msg)
  if !empty(s:log_file)
    call s:write_to_file(log_line)
  endif
  
  if a:level ==# 'error'
    echohl ErrorMsg
    echom log_line
    echohl None
  elseif a:level ==# 'warn'
    echohl WarningMsg
    echom log_line
    echohl None
  elseif a:level ==# 'debug'
    echom log_line
  endif
endfunction

function! s:should_log(level) abort
  let current = get(s:log_levels, s:current_level, 2)
  let target = get(s:log_levels, a:level, 0)
  return target >= current
endfunction

function! s:write_to_file(line) abort
  call writefile([a:line], s:log_file, 'a')
endfunction

function! ftx#helpers#logger#set_level(level) abort
  if has_key(s:log_levels, a:level)
    let s:current_level = a:level
  endif
endfunction