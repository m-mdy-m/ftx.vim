" Copyright (c) 2026 m-mdy-m
" MIT License

let s:tree = []
let s:expanded = {}

function! ftx#renderer#Render(root) abort
  let bufnr = ftx#GetBufnr()
  if bufnr == -1
    return
  endif
  
  setlocal modifiable
  silent %delete _
  
  let s:tree = []
  call s:BuildTree(a:root, 0)
  
  if g:ftx_git_status
    call ftx#git#UpdateStatus(a:root)
  endif
  
  let lines = []
  for node in s:tree
    let line = s:FormatNode(node)
    call add(lines, line)
  endfor
  
  call setline(1, lines)
  setlocal nomodifiable
endfunction

function! s:BuildTree(path, depth) abort
  let items = s:ReadDir(a:path)
  
  if g:ftx_sort_dirs_first
    let dirs = filter(copy(items), 'isdirectory(a:path . "/" . v:val)')
    let files = filter(copy(items), '!isdirectory(a:path . "/" . v:val)')
    let items = sort(dirs) + sort(files)
  else
    let items = sort(items)
  endif
  
  for item in items
    let full_path = a:path . '/' . item
    let is_dir = isdirectory(full_path)
    
    let node = {
          \ 'path': full_path,
          \ 'name': item,
          \ 'depth': a:depth,
          \ 'is_dir': is_dir,
          \ 'is_expanded': 0,
          \ 'git_status': ''
          \ }
    
    call add(s:tree, node)
    
    if is_dir && get(s:expanded, full_path, 0)
      let node.is_expanded = 1
      call s:BuildTree(full_path, a:depth + 1)
    endif
  endfor
endfunction

function! s:ReadDir(path) abort
  let items = glob(a:path . '/*', 0, 1)
  
  if g:ftx_show_hidden
    let items += glob(a:path . '/.[^.]*', 0, 1)
  endif
  
  let items = map(items, 'fnamemodify(v:val, ":t")')
  return items
endfunction

function! s:FormatNode(node) abort
  let indent = repeat('  ', a:node.depth)
  let icon = a:node.is_dir ? (a:node.is_expanded ? '▾ ' : '▸ ') : '  '
  let git = a:node.git_status !=# '' ? ' ' . a:node.git_status : ''
  
  return indent . icon . a:node.name . git
endfunction

function! ftx#renderer#GetNode() abort
  let lnum = line('.')
  if lnum > len(s:tree)
    return {}
  endif
  return s:tree[lnum - 1]
endfunction

function! ftx#renderer#ToggleExpand(node) abort
  if !a:node.is_dir
    return
  endif
  
  let s:expanded[a:node.path] = !get(s:expanded, a:node.path, 0)
  call ftx#Refresh()
endfunction

function! ftx#renderer#SetGitStatus(path, status) abort
  for node in s:tree
    if node.path ==# a:path
      let node.git_status = a:status
      break
    endif
  endfor
endfunction

function! ftx#renderer#GetTree() abort
  return s:tree
endfunction