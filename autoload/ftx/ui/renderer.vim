" Copyright (c) 2026 m-mdy-m
" MIT License
" Display rendering

let s:tree = []

function! ftx#ui#renderer#Render(root) abort
  if !ftx#core#buffer#Exists()
    return
  endif
  
  let pos = ftx#core#window#SaveCursor()
  
  let s:tree = ftx#tree#builder#Build(a:root, 0)
  let git_cache = ftx#git#status#GetCache()
  if !empty(git_cache)
    for node in s:tree
      let status = get(git_cache, node.path, '')
      if status !=# node.git_status
        call ftx#tree#node#SetGitStatus(node, status)
      endif
    endfor
  endif
  let lines = ftx#tree#formatter#FormatAll(s:tree)
  
  call ftx#core#buffer#SetLines(lines)
  
  call ftx#core#window#RestoreCursor(pos)
endfunction

function! ftx#ui#renderer#GetTree() abort
  return s:tree
endfunction

function! ftx#ui#renderer#GetNode() abort
  let lnum = line('.')
  if lnum < 1 || lnum > len(s:tree)
    return {}
  endif
  return s:tree[lnum - 1]
endfunction

function! ftx#ui#renderer#FindNodeByPath(path) abort
  for node in s:tree
    if node.path ==# a:path
      return node
    endif
  endfor
  return {}
endfunction

function! ftx#ui#renderer#ToggleExpand(node) abort
  if !ftx#tree#node#ToggleExpand(a:node)
    return
  endif
  
  call ftx#tree#builder#SetExpanded(a:node.path, a:node.is_expanded)
endfunction

function! ftx#ui#renderer#ExpandAll() abort
  call ftx#tree#builder#ExpandAll(s:tree)
endfunction

function! ftx#ui#renderer#CollapseAll() abort
  call ftx#tree#builder#CollapseAll()
endfunction

function! ftx#ui#renderer#SyncToFile(file) abort
  let path = fnamemodify(a:file, ':p')
  
  " Expand parents
  let dir = ftx#utils#GetParentDir(path)
  let root = ftx#GetRoot()
  
  while dir !=# root && dir !=# '/'
    call ftx#tree#builder#SetExpanded(dir, 1)
    let dir = ftx#utils#GetParentDir(dir)
  endwhile
  
  " Re-render
  call ftx#ui#renderer#Render(root)
  
  " Find and highlight file
  let lnum = 1
  for node in s:tree
    if node.path ==# path
      call cursor(lnum, 1)
      normal! zz
      break
    endif
    let lnum += 1
  endfor
endfunction

function! ftx#ui#renderer#UpdateGitStatus(status_map) abort
  for node in s:tree
    let status = get(a:status_map, node.path, '')
    call ftx#tree#node#SetGitStatus(node, status)
  endfor
  
  " Re-render
  let root = ftx#GetRoot()
  if !empty(root)
    call ftx#ui#renderer#Render(root)
  endif
endfunction