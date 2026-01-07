" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:state = {'expanded': {}, 'root': ''}

function! ftx#tree#tree#build(root, depth, ...) abort
  let opts = extend({
        \ 'max_depth': 100,
        \ 'lazy': 0,
        \}, a:0 ? a:1 : {})
  
  if opts.lazy && a:depth > opts.max_depth
    return ftx#async#promise#resolve([])
  endif
  
  let cached = ftx#tree#cache#get(a:root)
  
  if cached isnot v:null && !ftx#tree#cache#check_changed(a:root)
    return ftx#async#promise#resolve(cached)
  endif
  
  return ftx#async#fs#readdir(a:root)
        \.then({entries -> s:process_entries(a:root, entries, a:depth)})
        \.then({nodes -> s:cache_nodes(a:root, nodes)})
        \.catch({err -> s:handle_error(err)})
endfunction

function! s:cache_nodes(root, nodes) abort
  call ftx#tree#cache#set(a:root, a:nodes)
  return a:nodes
endfunction

function! s:process_entries(root, entries, depth) abort
  let filtered = ftx#tree#filter#apply(a:entries, [
        \ ftx#tree#filter#hidden()
        \])
  
  let sorted = s:sort_entries(filtered)
  let nodes = []
  
  for entry in sorted
    let node = ftx#tree#node#create(entry.path, a:depth)
    call add(nodes, node)
  endfor
  
  return nodes
endfunction

function! s:sort_entries(entries) abort
  if !get(g:, 'ftx_sort_dirs_first', 1)
    return sort(copy(a:entries), {a, b -> a.name > b.name ? 1 : -1})
  endif
  
  let dirs = filter(copy(a:entries), 'v:val.is_dir')
  let files = filter(copy(a:entries), '!v:val.is_dir')
  
  call sort(dirs, {a, b -> a.name > b.name ? 1 : -1})
  call sort(files, {a, b -> a.name > b.name ? 1 : -1})
  
  return dirs + files
endfunction

function! s:handle_error(err) abort
  call ftx#helpers#logger#error('Tree build failed', a:err)
  return []
endfunction

function! ftx#tree#tree#flatten(nodes, ...) abort
  let result = []
  let depth = get(a:, 1, 0)
  
  for node in a:nodes
    call add(result, node)
    
    if node.is_dir && get(node, 'is_expanded', 0) && has_key(node, 'children')
      let child_flat = ftx#tree#tree#flatten(node.children, depth + 1)
      call extend(result, child_flat)
    endif
  endfor
  
  return result
endfunction

function! ftx#tree#tree#expand_node(node) abort
  if !a:node.is_dir || get(a:node, 'is_expanded', 0)
    return ftx#async#promise#resolve(0)
  endif
  
  let a:node.is_expanded = 1
  call s:set_expanded(a:node.path, 1)
  
  return ftx#tree#tree#build(a:node.path, a:node.depth + 1)
        \.then({children -> s:attach_children(a:node, children)})
        \.then({_ -> 1})
endfunction

function! ftx#tree#tree#collapse_node(node) abort
  if !a:node.is_dir || !get(a:node, 'is_expanded', 0)
    return ftx#async#promise#resolve(0)
  endif
  
  let a:node.is_expanded = 0
  call s:set_expanded(a:node.path, 0)
  
  if has_key(a:node, 'children')
    unlet a:node.children
  endif
  
  return ftx#async#promise#resolve(1)
endfunction

function! ftx#tree#tree#toggle_node(node) abort
  if get(a:node, 'is_expanded', 0)
    return ftx#tree#tree#collapse_node(a:node)
  else
    return ftx#tree#tree#expand_node(a:node)
  endif
endfunction

function! s:attach_children(parent, children) abort
  let a:parent.children = a:children
  return a:parent
endfunction

function! ftx#tree#tree#expand_all(nodes) abort
  for node in a:nodes
    if node.is_dir
      call s:set_expanded(node.path, 1)
    endif
  endfor
endfunction

function! ftx#tree#tree#collapse_all() abort
  let s:state.expanded = {}
endfunction

function! s:set_expanded(path, state) abort
  if a:state
    let s:state.expanded[a:path] = 1
  elseif has_key(s:state.expanded, a:path)
    unlet s:state.expanded[a:path]
  endif
endfunction

function! ftx#tree#tree#is_expanded(path) abort
  return get(s:state.expanded, a:path, 0)
endfunction

function! ftx#tree#tree#set_root(root) abort
  let s:state.root = a:root
endfunction

function! ftx#tree#tree#get_root() abort
  return get(s:state, 'root', getcwd())
endfunction

function! ftx#tree#tree#clear() abort
  let s:state = {'expanded': {}, 'root': ''}
endfunction