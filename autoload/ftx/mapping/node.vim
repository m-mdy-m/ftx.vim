" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#mapping#node#expand() abort
  let helper = s:get_helper()
  if empty(helper)
    return ftx#async#promise#reject('Not in FTX buffer')
  endif
  
  let node = helper.tree.get_cursor_node()
  if empty(node) || !node.is_dir
    return ftx#async#promise#resolve(0)
  endif
  
  if node.is_expanded
    return ftx#async#promise#resolve(0)
  endif
  
  let node.is_expanded = 1
  return helper.tree.expand(node)
        \.then({-> helper.redraw()})
        \.then({-> helper.sync_cursor(node)})
endfunction

function! ftx#mapping#node#collapse() abort
  let helper = s:get_helper()
  if empty(helper)
    return ftx#async#promise#reject('Not in FTX buffer')
  endif
  
  let node = helper.tree.get_cursor_node()
  if empty(node) || !node.is_dir
    return ftx#async#promise#resolve(0)
  endif
  
  if !node.is_expanded
    return ftx#async#promise#resolve(0)
  endif
  
  let node.is_expanded = 0
  return helper.tree.collapse(node)
        \.then({-> helper.redraw()})
        \.then({-> helper.sync_cursor(node)})
endfunction

function! ftx#mapping#node#toggle() abort
  let helper = s:get_helper()
  if empty(helper)
    return ftx#async#promise#reject('Not in FTX buffer')
  endif
  
  let node = helper.tree.get_cursor_node()
  if empty(node)
    return ftx#async#promise#resolve(0)
  endif
  
  if !node.is_dir
    return ftx#mapping#open#edit()
  endif
  
  return node.is_expanded 
        \ ? ftx#mapping#node#collapse()
        \ : ftx#mapping#node#expand()
endfunction

function! ftx#mapping#node#parent() abort
  let helper = s:get_helper()
  if empty(helper)
    return ftx#async#promise#reject('Not in FTX buffer')
  endif
  
  let node = helper.tree.get_cursor_node()
  if empty(node)
    return ftx#async#promise#resolve(0)
  endif
  
  let parent_path = ftx#helpers#path#dirname(node.path)
  if parent_path ==# node.path
    return ftx#async#promise#resolve(0)
  endif
  
  let parent = helper.tree.find_node(parent_path)
  if !empty(parent)
    return helper.sync_cursor(parent)
  endif
  
  return ftx#async#promise#resolve(0)
endfunction

function! s:get_helper() abort
  try
    return ftx#helper#get()
  catch
    return {}
  endtry
endfunction