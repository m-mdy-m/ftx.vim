" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Auto-resize drawer width preservation
" ----------------------------------------------------------------------

function! ftx#internal#drawer#auto_resize#init() abort
  if get(g:, 'ftx_disable_auto_resize', 0)
    return
  endif
  
  if ftx#internal#drawer#is_right_drawer()
    augroup ftx_drawer_auto_resize_right
      autocmd! * <buffer>
      autocmd BufEnter,WinEnter <buffer> call s:load_width_right()
      autocmd WinLeave <buffer> call s:save_width_right()
    augroup END
  else
    augroup ftx_drawer_auto_resize
      autocmd! * <buffer>
      autocmd BufEnter,WinEnter <buffer> call s:load_width()
      autocmd WinLeave <buffer> call s:save_width()
    augroup END
  endif
endfunction

function! s:count_others() abort
  let bufnr = bufnr('%')
  let num = 0
  for winnr in range(1, winnr('$'))
    if winbufnr(winnr) != bufnr
      let num += 1
    endif
  endfor
  return num
endfunction

function! s:should_ignore() abort
  if has('nvim')
    try
      return nvim_win_get_config(win_getid()).relative !=# '' || s:count_others() == 0
    catch
      return s:count_others() == 0
    endtry
  else
    return s:count_others() == 0
  endif
endfunction

function! s:save_width() abort
  if s:should_ignore()
    return
  endif
  let t:ftx_drawer_width = winwidth(0)
endfunction

function! s:load_width() abort
  if s:should_ignore()
    return
  endif
  
  if !exists('t:ftx_drawer_width')
    call ftx#internal#drawer#resize()
  else
    execute 'vertical resize' t:ftx_drawer_width
  endif
endfunction

function! s:save_width_right() abort
  if s:should_ignore()
    return
  endif
  let t:ftx_drawer_width_right = winwidth(0)
endfunction

function! s:load_width_right() abort
  if s:should_ignore()
    return
  endif
  
  if !exists('t:ftx_drawer_width_right')
    call ftx#internal#drawer#resize()
  else
    execute 'vertical resize' t:ftx_drawer_width_right
  endif
endfunction