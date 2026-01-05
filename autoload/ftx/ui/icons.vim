" Copyright (c) 2026 m-mdy-m
" MIT License
let s:default_icons = get(g:, 'ftx_icons', {
      \ 'vim': '',
      \ 'c': '',
      \ 'md': '',
      \ 'txt': '',
      \ })
let s:special_patterns = get(g:, 'ftx_special_icons', {
      \ 'README': '',
      \ 'LICENSE': '',
      \ 'Makefile': '',
      \ '.gitignore': '',
      \ })

function! ftx#ui#icons#Get(filename) abort
  if !g:ftx_enable_icons
    return ''
  endif
  
  let lower = tolower(a:filename)
  
  for [pattern, icon] in items(s:special_patterns)
    if lower =~? tolower(pattern)
      return icon
    endif
  endfor
  let ext = tolower(fnamemodify(a:filename, ':e'))
  if has_key(s:default_icons, ext)
    return s:default_icons[ext]
  endif
  return g:ftx_icon_file
endfunction

function! ftx#ui#icons#GetForNode(node) abort
  if a:node.is_dir
    return a:node.is_expanded ? g:ftx_icon_expanded : g:ftx_icon_collapsed
  endif
  
  if a:node.is_link
    return g:ftx_icon_symlink
  endif
  
  return ftx#ui#icons#Get(a:node.name)
endfunction

function! ftx#ui#icons#GetExtension(filename) abort
  return tolower(fnamemodify(a:filename, ':e'))
endfunction