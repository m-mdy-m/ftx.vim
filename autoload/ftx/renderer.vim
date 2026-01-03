" Copyright (c) 2026 m-mdy-m
" MIT License

let s:tree = []
let s:expanded = {}
let s:git_status_map = {}

function! ftx#renderer#Render(root) abort
  let bufnr = ftx#GetBufnr()
  if bufnr == -1
    return
  endif
  
  let winid = bufwinid(bufnr)
  if winid == -1
    return
  endif
  
  call win_execute(winid, 'setlocal modifiable')
  
  let s:tree = []
  call s:BuildTree(a:root, 0)
  
  let lines = []
  for node in s:tree
    let line = s:FormatNode(node)
    call add(lines, line)
  endfor
  
  call win_execute(winid, 'silent %delete _')
  call setbufline(bufnr, 1, lines)
  
  call win_execute(winid, 'setlocal nomodifiable')
endfunction

function! s:BuildTree(path, depth) abort
  let items = s:ReadDir(a:path)
  
  if g:ftx_sort_dirs_first
    let dirs = []
    let files = []
    
    for item in items
      let full_path = a:path . '/' . item
      if isdirectory(full_path)
        call add(dirs, item)
      else
        call add(files, item)
      endif
    endfor
    
    let items = sort(dirs) + sort(files)
  else
    let items = sort(items)
  endif
  
  for item in items
    let full_path = a:path . '/' . item
    let is_dir = isdirectory(full_path)
    
    let git_status = get(s:git_status_map, full_path, '')
    
    let node = {
          \ 'path': full_path,
          \ 'name': item,
          \ 'depth': a:depth,
          \ 'is_dir': is_dir,
          \ 'is_expanded': 0,
          \ 'git_status': git_status
          \ }
    
    call add(s:tree, node)
    
    if is_dir && get(s:expanded, full_path, 0)
      let node.is_expanded = 1
      call s:BuildTree(full_path, a:depth + 1)
    endif
  endfor
endfunction

function! s:ReadDir(path) abort
  let items = []
  
  let regular = glob(a:path . '/*', 1, 1)
  for item in regular
    let basename = fnamemodify(item, ':t')
    call add(items, basename)
  endfor
  
  if g:ftx_show_hidden
    let hidden = glob(a:path . '/.[^.]*', 1, 1)
    for item in hidden
      let basename = fnamemodify(item, ':t')
      if index(items, basename) == -1
        call add(items, basename)
      endif
    endfor
  endif
  
  return items
endfunction

function! s:FormatNode(node) abort
  let indent = repeat('  ', a:node.depth)
  
  if a:node.is_dir
    let icon = a:node.is_expanded ? '▾ ' : '▸ '
  else
    let icon = '  '
  endif
  
  let git = a:node.git_status !=# '' ? a:node.git_status . ' ' : ''
  
  return indent . icon . git . a:node.name
endfunction

function! ftx#renderer#GetNode() abort
  let lnum = line('.')
  if lnum > len(s:tree) || lnum < 1
    return {}
  endif
  return s:tree[lnum - 1]
endfunction

function! ftx#renderer#ToggleExpand(node) abort
  if !a:node.is_dir
    return
  endif
  
  let s:expanded[a:node.path] = !get(s:expanded, a:node.path, 0)
  
  let bufnr = ftx#GetBufnr()
  if bufnr == -1
    return
  endif
  
  let winid = bufwinid(bufnr)
  if winid == -1
    return
  endif
  
  let save_line = line('.')
  let save_col = col('.')
  
  call win_execute(winid, 'setlocal modifiable')
  
  let s:tree = []
  call s:BuildTree(ftx#GetRoot(), 0)
  
  let lines = []
  for node in s:tree
    let line = s:FormatNode(node)
    call add(lines, line)
  endfor
  
  call win_execute(winid, 'silent %delete _')
  call setbufline(bufnr, 1, lines)
  call cursor(save_line, save_col)
  
  call win_execute(winid, 'setlocal nomodifiable')
endfunction

function! ftx#renderer#SetGitStatus(status_map) abort
  let s:git_status_map = a:status_map
endfunction

function! ftx#renderer#UpdateGitStatus() abort
  let bufnr = ftx#GetBufnr()
  if bufnr == -1
    return
  endif
  
  let winid = bufwinid(bufnr)
  if winid == -1
    return
  endif
  
  let save_line = line('.')
  let save_col = col('.')
  
  call win_execute(winid, 'setlocal modifiable')
  
  for node in s:tree
    let node.git_status = get(s:git_status_map, node.path, '')
  endfor
  
  let lines = []
  for node in s:tree
    let line = s:FormatNode(node)
    call add(lines, line)
  endfor
  
  call win_execute(winid, 'silent %delete _')
  call setbufline(bufnr, 1, lines)
  call cursor(save_line, save_col)
  
  call win_execute(winid, 'setlocal nomodifiable')
endfunction

function! ftx#renderer#GetTree() abort
  return s:tree
endfunction

function! ftx#renderer#GetExpanded() abort
  return s:expanded
endfunction