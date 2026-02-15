" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Public extension API for plugin developers.
" ----------------------------------------------------------------------

let s:listeners = {}
let s:openers = {}

function! ftx#api#on(event, callback) abort
  if type(a:event) != v:t_string || empty(a:event)
    call ftx#helpers#logger#warn('Invalid event name for ftx#api#on')
    return 0
  endif

  if type(a:callback) != v:t_func
    call ftx#helpers#logger#warn('Callback must be a Funcref for ftx#api#on', a:event)
    return 0
  endif

  if !has_key(s:listeners, a:event)
    let s:listeners[a:event] = []
  endif

  call add(s:listeners[a:event], a:callback)
  return 1
endfunction

function! ftx#api#emit(event, payload) abort
  for cb in get(s:listeners, a:event, [])
    try
      call call(cb, [a:payload])
    catch
      call ftx#helpers#logger#warn('FTX event handler failed', {
            \ 'event': a:event,
            \ 'error': v:exception,
            \ })
    endtry
  endfor
endfunction

function! ftx#api#register_opener(name, callback) abort
  if type(a:name) != v:t_string || empty(a:name)
    call ftx#helpers#logger#warn('Invalid opener name for ftx#api#register_opener')
    return 0
  endif

  if type(a:callback) != v:t_func
    call ftx#helpers#logger#warn('Opener callback must be a Funcref', a:name)
    return 0
  endif

  let s:openers[a:name] = a:callback
  return 1
endfunction

function! ftx#api#open_with(name, path, ...) abort
  call s:ensure_builtin_openers()

  let callback = get(s:openers, a:name, v:null)
  if callback is v:null
    call ftx#helpers#logger#error('Unknown opener', a:name)
    return 0
  endif

  let ctx = a:0 ? a:1 : {}
  try
    call call(callback, [a:path, ctx])
    return 1
  catch
    call ftx#helpers#logger#error('Opener failed', {
          \ 'name': a:name,
          \ 'path': a:path,
          \ 'error': v:exception,
          \ })
    return 0
  endtry
endfunction

function! ftx#api#open_node_with(name, node) abort
  if empty(a:node) || get(a:node, 'is_dir', 0)
    return 0
  endif

  if !filereadable(a:node.path)
    call ftx#helpers#logger#error('File not readable', a:node.path)
    return 0
  endif

  let ok = ftx#api#open_with(a:name, a:node.path, {'node': a:node})
  if ok
    call ftx#api#emit('file:opened', {
          \ 'path': a:node.path,
          \ 'node': a:node,
          \ 'opener': a:name,
          \ })
  endif
  return ok
endfunction

function! s:ensure_builtin_openers() abort
  if !empty(s:openers)
    return
  endif

  call ftx#api#register_opener('edit', function('s:open_edit'))
  call ftx#api#register_opener('split', function('s:open_split'))
  call ftx#api#register_opener('vsplit', function('s:open_vsplit'))
  call ftx#api#register_opener('tabedit', function('s:open_tabedit'))
endfunction

function! s:open_edit(path, ctx) abort
  call ftx#mapping#open#open_path(a:path, 'edit')
endfunction

function! s:open_split(path, ctx) abort
  call ftx#mapping#open#open_path(a:path, 'split')
endfunction

function! s:open_vsplit(path, ctx) abort
  call ftx#mapping#open#open_path(a:path, 'vsplit')
endfunction

function! s:open_tabedit(path, ctx) abort
  call ftx#mapping#open#open_path(a:path, 'tabedit')
endfunction