" Copyright (c) 2026 m-mdy-m
" MIT License
" Tree building logic

let s:expanded = {}

function! ftx#tree#builder#Build(root, depth) abort
  let items = s:ReadDir(a:root)
  let items = s:SortItems(a:root, items)
  
  let nodes = []
  for item in items
    let path = a:root . '/' . item
    let node = ftx#tree#node#Create(path, a:depth)
    call add(nodes, node)
    
    " Recursively build if expanded
    if node.is_dir && s:IsExpanded(path)
      let node.is_expanded = 1
      let children = ftx#tree#builder#Build(path, a:depth + 1)
      call extend(nodes, children)
    endif
  endfor
  
  return nodes
endfunction

function! s:ReadDir(path) abort
  let items = []
  
  " Regular files
  let regular = glob(a:path . '/*', 1, 1)
  for item in regular
    call add(items, ftx#utils#GetBasename(item))
  endfor
  
  " Hidden files
  if g:ftx_show_hidden
    let hidden = glob(a:path . '/.[^.]*', 1, 1)
    for item in hidden
      let basename = ftx#utils#GetBasename(item)
      if index(items, basename) == -1
        call add(items, basename)
      endif
    endfor
  endif
  
  return items
endfunction

function! s:SortItems(root, items) abort
  if !g:ftx_sort_dirs_first
    return sort(a:items)
  endif
  
  let dirs = []
  let files = []
  
  for item in a:items
    let path = a:root . '/' . item
    if ftx#utils#IsDirectory(path)
      call add(dirs, item)
    else
      call add(files, item)
    endif
  endfor
  
  return sort(dirs) + sort(files)
endfunction

function! s:IsExpanded(path) abort
  return get(s:expanded, a:path, 0)
endfunction

function! ftx#tree#builder#SetExpanded(path, state) abort
  let s:expanded[a:path] = a:state
endfunction

function! ftx#tree#builder#ExpandAll(nodes) abort
  for node in a:nodes
    if node.is_dir
      let s:expanded[node.path] = 1
    endif
  endfor
endfunction

function! ftx#tree#builder#CollapseAll() abort
  let s:expanded = {}
endfunction

function! ftx#tree#builder#GetExpanded() abort
  return s:expanded
endfunction