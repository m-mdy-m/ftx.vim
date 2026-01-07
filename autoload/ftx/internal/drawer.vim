" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Drawer management system
" ----------------------------------------------------------------------

function! ftx#internal#drawer#is_drawer(...) abort
  let bufnr = a:0 ? a:1 : bufnr('%')
  return getbufvar(bufnr, '&filetype') ==# 'ftx'
endfunction

function! ftx#internal#drawer#is_left_drawer() abort
  return ftx#internal#drawer#is_drawer() && get(g:, 'ftx_position', 'left') ==# 'left'
endfunction

function! ftx#internal#drawer#is_right_drawer() abort
  return ftx#internal#drawer#is_drawer() && get(g:, 'ftx_position', 'left') ==# 'right'
endfunction

function! ftx#internal#drawer#resize() abort
  let width = get(g:, 'ftx_width', 30)
  execute 'vertical resize' width
endfunction

function! ftx#internal#drawer#open(...) abort
  let options = extend({
        \ 'toggle': 0,
        \ 'focus': 1,
        \}, a:0 ? a:1 : {})
  
  if s:focus_drawer()
    if options.toggle
      close
      return
    endif
    if !options.focus
      wincmd p
    endif
    return
  endif
  
  call s:create_drawer(options)
endfunction

function! s:create_drawer(options) abort
  let position = get(g:, 'ftx_position', 'left')
  let width = get(g:, 'ftx_width', 30)
  
  let cmd = position ==# 'right' ? 'botright' : 'topleft'
  execute 'keepalt' cmd width . 'vnew'
  
  " Create buffer first
  let bufnr = ftx#internal#buffer#create()
  
  " Setup buffer settings
  call s:setup_buffer()
  
  " Initialize drawer features
  call ftx#internal#drawer#init()
  
  if !a:options.focus
    wincmd p
  endif
  
  return bufnr
endfunction

function! s:setup_buffer() abort
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
  setlocal nonumber
  setlocal norelativenumber
  setlocal signcolumn=no
  setlocal foldcolumn=0
  setlocal nomodeline
  setlocal nofoldenable
  setlocal cursorline
  setlocal filetype=ftx
  setlocal nomodifiable
  setlocal winfixwidth
endfunction

function! s:focus_drawer() abort
  let winnr = s:find_drawer_window()
  if winnr == 0
    return 0
  endif
  call win_gotoid(win_getid(winnr))
  return 1
endfunction

function! s:find_drawer_window() abort
  for winnr in range(1, winnr('$'))
    if ftx#internal#drawer#is_drawer(winbufnr(winnr))
      return winnr
    endif
  endfor
  return 0
endfunction

function! ftx#internal#drawer#init() abort
  if !ftx#internal#drawer#is_drawer()
    return
  endif
  
  call ftx#internal#drawer#auto_resize#init()
  call ftx#internal#drawer#auto_restore_focus#init()
  call ftx#internal#drawer#smart_quit#init()
  call ftx#internal#drawer#resize()
endfunction