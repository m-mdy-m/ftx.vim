" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:renderer = {}
let s:is_refreshing = 0

function! ftx#open(...) abort
  let path = a:0 > 0 ? fnamemodify(a:1, ':p') : getcwd()

  if !isdirectory(path)
    call ftx#helpers#logger#error('Not a directory', path)
    return
  endif

  call ftx#tree#tree#set_root(path)

  if ftx#is_open()
    call ftx#focus()
    if ftx#tree#tree#get_root() !=# path
      call ftx#refresh()
    endif
    return
  endif

  call s:create_window()
  call ftx#refresh()
        \.then({_ -> ftx#git#status#init(path)})
        \.catch({err -> 0})
endfunction

function! ftx#toggle() abort
  if ftx#is_open()
    call ftx#close()
    call ftx#internal#window#goto_previous()
  else
    call ftx#open()
  endif
endfunction

function! ftx#close() abort
  if !ftx#is_open()
    return
  endif

  call ftx#internal#window#close()
  call ftx#tree#ui#clear()
endfunction

function! ftx#refresh(...) abort
  if !ftx#is_open() || s:is_refreshing
    return ftx#async#promise#resolve(0)
  endif

  let s:is_refreshing = 1
  
  let opts = extend({
        \ 'force': 0,
        \ 'path': v:null,
        \}, a:0 ? a:1 : {})

  let root = ftx#tree#tree#get_root()
  let cursor_pos = ftx#tree#ui#save_cursor()
  if !opts.force
    let cached = ftx#tree#cache#get_tree(root)
    if cached isnot v:null
      let s:is_refreshing = 0
      return s:expand_and_display(cached, cursor_pos)
    endif
  endif

  return ftx#tree#tree#build(root, 0)
        \.then({nodes -> s:expand_marked_nodes(nodes)})
        \.then({nodes -> s:cache_tree(root, nodes)})
        \.then({nodes -> s:display_tree(nodes, cursor_pos)})
        \.then({_ -> s:mark_done()})
        \.catch({err -> s:handle_error(err)})
endfunction

function! s:mark_done() abort
  let s:is_refreshing = 0
  return 0
endfunction

function! s:handle_error(err) abort
  let s:is_refreshing = 0
  call ftx#helpers#logger#error('Refresh failed', a:err)
  return 0
endfunction

function! s:display_tree(nodes, cursor_pos) abort
  let flat = ftx#tree#tree#flatten(a:nodes)

  return s:render_nodes(flat)
        \.then({lines -> s:display_lines(lines)})
        \.then({_ -> s:reapply_syntax()})
        \.then({_ -> ftx#tree#ui#restore_cursor(a:cursor_pos)})
endfunction

function! s:expand_and_display(nodes, cursor_pos) abort
  let flat = ftx#tree#tree#flatten(a:nodes)

  return s:render_nodes(flat)
        \.then({lines -> s:display_lines(lines)})
        \.then({_ -> s:reapply_syntax()})
        \.then({_ -> ftx#tree#ui#restore_cursor(a:cursor_pos)})
endfunction

function! s:cache_tree(root, nodes) abort
  call ftx#tree#cache#set_tree(a:root, a:nodes)
  return a:nodes
endfunction

function! s:expand_marked_nodes(nodes) abort
  let to_expand = []
  for node in a:nodes
    if node.is_dir && ftx#tree#tree#is_expanded(node.path)
      call add(to_expand, node)
    endif
  endfor
  
  if empty(to_expand)
    return ftx#async#promise#resolve(a:nodes)
  endif
  return s:expand_batch(to_expand, 0, a:nodes)
endfunction

function! s:expand_batch(nodes, idx, result) abort
  let batch_size = 5
  let promises = []
  
  for i in range(a:idx, min([a:idx + batch_size - 1, len(a:nodes) - 1]))
    call add(promises, ftx#tree#tree#expand_node(a:nodes[i]))
  endfor
  
  if empty(promises)
    return ftx#async#promise#resolve(a:result)
  endif
  
  return ftx#async#promise#all(promises)
        \.then({_ -> a:idx + batch_size >= len(a:nodes)
        \     ? a:result
        \     : s:expand_batch(a:nodes, a:idx + batch_size, a:result)
        \})
endfunction

function! s:render_nodes(nodes) abort
  call ftx#tree#ui#set_nodes(a:nodes)

  if empty(s:renderer)
    let s:renderer = ftx#renderer#default#new()
  endif

  return s:renderer.render(a:nodes)
endfunction

function! s:display_lines(lines) abort
  let bufnr = ftx#internal#buffer#get()

  if bufnr == -1
    return ftx#async#promise#reject('Buffer not found')
  endif

  call ftx#internal#replacer#replace(bufnr, a:lines)
  return ftx#async#promise#resolve(a:lines)
endfunction

function! s:reapply_syntax() abort
  if empty(s:renderer)
    let s:renderer = ftx#renderer#default#new()
  endif

  let bufnr = ftx#internal#buffer#get()
  if bufnr == -1
    return
  endif

  call win_execute(bufwinid(bufnr), 'call s:renderer.syntax()')
  call win_execute(bufwinid(bufnr), 'call s:renderer.highlight()')
endfunction

function! ftx#focus() abort
  if !ftx#is_open()
    return
  endif

  call ftx#internal#window#focus()
endfunction

function! ftx#is_open() abort
  return ftx#internal#buffer#exists() && ftx#internal#buffer#is_visible()
endfunction

function! s:create_window() abort
  call ftx#internal#window#create()
  call s:setup_buffer()
  call ftx#mapping#init#setup()
  call s:setup_autocmds()
  call s:setup_syntax()
  call s:setup_statusline()
  call ftx#internal#drawer#init()
endfunction

function! s:setup_buffer() abort
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
  setlocal nonumber
  setlocal norelativenumber
  setlocal signcolumn=no
  setlocal foldcolumn=0
  setlocal nomodeline
  setlocal nofoldenable
  setlocal cursorline
  setlocal filetype=ftx
  setlocal nomodifiable
endfunction

function! s:setup_autocmds() abort
  augroup ftx_buffer_local
    autocmd! * <buffer>
    autocmd BufEnter <buffer> call s:on_buf_enter()
  augroup END
endfunction

function! s:on_buf_enter() abort
  if get(g:, 'ftx_auto_sync', 1)
    call ftx#mapping#tree#sync_to_current()
  endif
endfunction

function! s:setup_syntax() abort
  if empty(s:renderer)
    let s:renderer = ftx#renderer#default#new()
  endif

  call s:renderer.syntax()
  call s:renderer.highlight()
endfunction

function! s:setup_statusline() abort
  setlocal statusline=%!ftx#git#statusline#render()
endfunction

function! ftx#cleanup() abort
  let s:is_refreshing = 0
  call ftx#tree#tree#clear()
  call ftx#tree#marks#clear()
  call ftx#tree#ui#clear()
  call ftx#tree#cache#clear()
endfunction