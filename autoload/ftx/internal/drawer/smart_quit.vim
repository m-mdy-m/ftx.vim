" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Smart quit handling to prevent closing Vim accidentally
" ----------------------------------------------------------------------

let s:quit_pre_called = 0

function! ftx#internal#drawer#smart_quit#init() abort
  if get(g:, 'ftx_disable_smart_quit', 0)
    return
  endif
  
  augroup ftx_drawer_smart_quit_local
    autocmd! * <buffer>
    autocmd BufEnter <buffer> nested call s:handle_quit()
  augroup END
endfunction

function! s:on_quit_pre() abort
  let s:quit_pre_called = 1
  call timer_start(0, {-> extend(s:, {'quit_pre_called': 0})})
endfunction

function! s:handle_quit() abort
  if !s:quit_pre_called
    return
  endif
  
  let s:quit_pre_called = 0
  
  let keep = get(g:, 'ftx_auto_close', 0)
  let width = get(g:, 'ftx_width', 30)
  
  if winnr('$') != 1
    return
  endif
  
  if keep
    quit
  else
    let winid = win_getid()
    if has('patch-8.1.1756') || has('nvim-0.7.1')
      call timer_start(0, {-> s:complement(winid, width)})
    else
      call s:complement(winid, width)
    endif
  endif
endfunction

function! s:complement(winid, width) abort
  keepjumps call win_gotoid(a:winid)
  vertical botright new
  let winid_saved = win_getid()
  keepjumps call win_gotoid(a:winid)
  execute 'vertical resize' a:width
  keepjumps call win_gotoid(winid_saved)
endfunction

augroup ftx_drawer_smart_quit_global
  autocmd!
  autocmd QuitPre * call s:on_quit_pre()
augroup END