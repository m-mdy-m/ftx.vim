" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Promise wrapper over goroutine-style scheduler
" Provides clean, chainable async API
" ----------------------------------------------------------------------

function! ftx#async#fs#readdir(path) abort
  return ftx#async#promise#new({resolve, reject ->
        \ s:readdir_executor(a:path, resolve, reject)
        \ })
endfunction

function! s:readdir_executor(path, resolve, reject) abort
  if !isdirectory(a:path)
    return a:reject('Not a directory: ' . a:path)
  endif
  
  let cmd = has('win32')
        \ ? ['cmd', '/c', 'dir', '/b', '/a', a:path]
        \ : ['ls', '-1A', a:path]
  
  call ftx#async#job#run(cmd, {'cwd': a:path})
        \.then({lines -> s:parse_entries(lines, a:path)})
        \.then(a:resolve)
        \.catch(a:reject)
endfunction

function! s:parse_entries(lines, base_path) abort
  let entries = []
  
  for line in a:lines
    if empty(line) || line ==# '.' || line ==# '..'
      continue
    endif
    
    let full_path = a:base_path . '/' . line
    call add(entries, {
          \ 'name': line,
          \ 'path': full_path,
          \ 'is_dir': isdirectory(full_path),
          \ })
  endfor
  
  return entries
endfunction

function! ftx#async#fs#exists(path) abort
  return ftx#async#promise#resolve(filereadable(a:path) || isdirectory(a:path))
endfunction

function! ftx#async#fs#stat(path) abort
  return ftx#async#promise#resolve({
        \ 'exists': filereadable(a:path) || isdirectory(a:path),
        \ 'is_dir': isdirectory(a:path),
        \ 'is_file': filereadable(a:path),
        \ 'is_link': getftype(a:path) ==# 'link',
        \ })
endfunction