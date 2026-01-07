" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Git-like tree cache system with content-based hashing
" Inspired by git's tree/blob architecture for efficient caching
" ----------------------------------------------------------------------

let s:cache = {}
let s:tree_cache = {}
let s:hash_cache = {}

function! ftx#tree#cache#init() abort
  let s:cache = {}
  let s:tree_cache = {}
  let s:hash_cache = {}
endfunction

function! ftx#tree#cache#compute_hash(path) abort
  if has_key(s:hash_cache, a:path)
    let cached = s:hash_cache[a:path]
    let mtime = getftime(a:path)
    if cached.mtime == mtime
      return cached.hash
    endif
  endif
  
  let content = isdirectory(a:path)
        \ ? s:hash_directory(a:path)
        \ : s:hash_file(a:path)
  
  let hash = s:djb2_hash(content)
  let s:hash_cache[a:path] = {
        \ 'hash': hash,
        \ 'mtime': getftime(a:path),
        \ }
  
  return hash
endfunction

function! s:hash_file(path) abort
  let size = getfsize(a:path)
  let mtime = getftime(a:path)
  return printf('file:%s:%d:%d', a:path, size, mtime)
endfunction

function! s:hash_directory(path) abort
  let items = ftx#helpers#sys#readdir_names(a:path)
  let content = join(sort(items), '|')
  return printf('tree:%s:%s', a:path, content)
endfunction

function! s:djb2_hash(str) abort
  let hash = 5381
  for i in range(len(a:str))
    let hash = (hash * 33 + char2nr(a:str[i])) % 0x7FFFFFFF
  endfor
  return hash
endfunction

function! ftx#tree#cache#get(path) abort
  let hash = ftx#tree#cache#compute_hash(a:path)
  let key = printf('%s:%s', a:path, hash)
  
  if has_key(s:cache, key)
    return s:cache[key]
  endif
  return v:null
endfunction

function! ftx#tree#cache#set(path, node) abort
  let hash = ftx#tree#cache#compute_hash(a:path)
  let key = printf('%s:%s', a:path, hash)
  let s:cache[key] = a:node
endfunction

function! ftx#tree#cache#invalidate(path) abort
  if has_key(s:hash_cache, a:path)
    unlet s:hash_cache[a:path]
  endif
  
  let prefix = a:path . ':'
  for key in keys(s:cache)
    if key[:len(prefix)-1] ==# prefix
      unlet s:cache[key]
    endif
  endfor
endfunction

function! ftx#tree#cache#invalidate_tree(root) abort
  call ftx#tree#cache#invalidate(a:root)
  
  for path in keys(s:hash_cache)
    if path[:len(a:root)-1] ==# a:root
      unlet s:hash_cache[path]
    endif
  endfor
  
  for key in keys(s:cache)
    if key[:len(a:root)-1] ==# a:root
      unlet s:cache[key]
    endif
  endfor
endfunction

function! ftx#tree#cache#get_tree(root) abort
  let hash = ftx#tree#cache#compute_hash(a:root)
  let key = printf('tree:%s:%s', a:root, hash)
  
  if has_key(s:tree_cache, key)
    return s:tree_cache[key]
  endif
  
  return v:null
endfunction

function! ftx#tree#cache#set_tree(root, tree) abort
  let hash = ftx#tree#cache#compute_hash(a:root)
  let key = printf('tree:%s:%s', a:root, hash)
  let s:tree_cache[key] = a:tree
endfunction

function! ftx#tree#cache#check_changed(path) abort
  if !has_key(s:hash_cache, a:path)
    return 1
  endif
  
  let cached = s:hash_cache[a:path]
  let current_mtime = getftime(a:path)
  
  if cached.mtime == current_mtime
    return 0
  endif
  
  let old_hash = cached.hash
  let new_hash = ftx#tree#cache#compute_hash(a:path)
  
  return old_hash != new_hash
endfunction

function! ftx#tree#cache#stats() abort
  return {
        \ 'nodes': len(s:cache),
        \ 'trees': len(s:tree_cache),
        \ 'hashes': len(s:hash_cache),
        \ }
endfunction

function! ftx#tree#cache#clear() abort
  call ftx#tree#cache#init()
endfunction