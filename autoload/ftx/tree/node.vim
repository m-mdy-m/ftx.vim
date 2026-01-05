" Copyright (c) 2026 m-mdy-m
" MIT License
function! ftx#tree#node#Create(path, depth) abort
  let is_dir = ftx#utils#IsDirectory(a:path)
  
  return {
        \ 'path': a:path,
        \ 'name': ftx#utils#GetBasename(a:path),
        \ 'depth': a:depth,
        \ 'is_dir': is_dir,
        \ 'is_link': ftx#utils#IsSymlink(a:path),
        \ 'is_expanded': 0,
        \ 'git_status': ''
        \ }
endfunction

function! ftx#tree#node#GetIcon(node) abort
  let icon_info = ftx#ui#icons#GetForNode(a:node)
  return icon_info.icon
endfunction

function! ftx#tree#node#IsMarked(node) abort
  return g:ftx_enable_marks && ftx#features#marks#IsMarked(a:node.path)
endfunction

function! ftx#tree#node#GetMarkIcon(node) abort
  return ftx#tree#node#IsMarked(a:node) ? g:ftx_icon_marked . ' ' : ''
endfunction

function! ftx#tree#node#GetGitIcon(node) abort
  if !g:ftx_enable_git || !g:ftx_git_status || empty(a:node.git_status)
    return ''
  endif
  return a:node.git_status . ' '
endfunction

function! ftx#tree#node#SetGitStatus(node, status) abort
  let a:node.git_status = a:status
endfunction

function! ftx#tree#node#ToggleExpand(node) abort
  if !a:node.is_dir
    return 0
  endif
  
  let a:node.is_expanded = !a:node.is_expanded
  return 1
endfunction