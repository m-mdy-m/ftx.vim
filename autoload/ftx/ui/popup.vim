" Copyright (c) 2026 m-mdy-m
" MIT License
" Reusable popup utilities

" Create centered popup with content
function! ftx#ui#popup#Create(lines, ...) abort
  let opts = a:0 > 0 ? a:1 : {}
  
  if !has('popupwin')
    call s:EchoFallback(a:lines)
    return -1
  endif
  
  let default_opts = {
        \ 'pos': 'center',
        \ 'padding': [0, 1, 0, 1],
        \ 'border': [],
        \ 'highlight': 'Normal',
        \ 'borderhighlight': ['FTXBorder'],
        \ 'close': 'button',
        \ 'callback': function('s:DefaultCallback'),
        \ 'filter': function('s:DefaultFilter'),
        \ }
  
  let final_opts = extend(default_opts, opts)
  
  return popup_create(a:lines, final_opts)
endfunction

function! s:DefaultCallback(id, result) abort
  " Nothing to do
endfunction

function! s:DefaultFilter(id, key) abort
  if a:key ==# "\<Esc>" || a:key ==# 'q' || a:key ==# ' ' || a:key ==# "\<CR>"
    call popup_close(a:id)
    return 1
  endif
  
  " Scrolling
  if a:key ==# 'j' || a:key ==# "\<Down>"
    call win_execute(a:id, "normal! \<C-E>")
    return 1
  elseif a:key ==# 'k' || a:key ==# "\<Up>"
    call win_execute(a:id, "normal! \<C-Y>")
    return 1
  elseif a:key ==# 'g'
    call win_execute(a:id, "normal! gg")
    return 1
  elseif a:key ==# 'G'
    call win_execute(a:id, "normal! G")
    return 1
  endif
  
  return 0
endfunction

function! s:EchoFallback(lines) abort
  for line in a:lines
    echo line
  endfor
endfunction

function! ftx#ui#popup#Info(lines) abort
  let opts = {
        \ 'pos': 'center',
        \ 'padding': [0, 1, 0, 1],
        \ 'maxheight': 10,
        \ }
  return ftx#ui#popup#Create(a:lines, opts)
endfunction

function! ftx#ui#popup#Large(lines) abort
  let opts = {
        \ 'pos': 'center',
        \ 'padding': [1, 2, 1, 2],
        \ 'maxheight': &lines - 10,
        \ 'maxwidth': 70,
        \ }
  return ftx#ui#popup#Create(a:lines, opts)
endfunction

function! ftx#ui#popup#IsSupported() abort
  return has('popupwin')
endfunction