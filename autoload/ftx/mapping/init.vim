" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#mapping#init#setup() abort
  call s:setup_file_operations()
  call s:setup_tree_operations()
  call s:setup_navigation()
  call s:setup_marks()
  call s:setup_yank()
  call s:setup_other()
endfunction

function! s:setup_file_operations() abort
  nnoremap <buffer> <silent> o :<C-u>call ftx#mapping#open#execute('edit')<CR>
  nnoremap <buffer> <silent> <CR> :<C-u>call ftx#mapping#open#execute('edit')<CR>
  nnoremap <buffer> <silent> t :<C-u>call ftx#mapping#open#in_tab()<CR>
  nnoremap <buffer> <silent> s :<C-u>call ftx#mapping#open#in_split(0)<CR>
  nnoremap <buffer> <silent> v :<C-u>call ftx#mapping#open#in_split(1)<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :<C-u>call ftx#mapping#open#execute('edit')<CR>
endfunction

function! s:setup_tree_operations() abort
  nnoremap <buffer> <silent> r :<C-u>call ftx#mapping#tree#refresh()<CR>
  nnoremap <buffer> <silent> R :<C-u>call ftx#mapping#tree#refresh()<CR>
  nnoremap <buffer> <silent> I :<C-u>call ftx#mapping#tree#toggle_hidden()<CR>
  nnoremap <buffer> <silent> O :<C-u>call ftx#mapping#tree#expand_all()<CR>
  nnoremap <buffer> <silent> C :<C-u>call ftx#mapping#tree#collapse_all()<CR>
endfunction

function! s:setup_navigation() abort
  nnoremap <buffer> <silent> - :<C-u>call ftx#mapping#tree#go_parent()<CR>
  nnoremap <buffer> <silent> ~ :<C-u>call ftx#mapping#tree#go_home()<CR>
  nnoremap <buffer> <silent> cd :<C-u>call ftx#mapping#node#cd()<CR>
endfunction

function! s:setup_marks() abort
  if !get(g:, 'ftx_enable_marks', 1)
    return
  endif
  
  nnoremap <buffer> <silent> m :<C-u>call ftx#mapping#mark#toggle()<CR>
  nnoremap <buffer> <silent> M :<C-u>call ftx#mapping#mark#clear()<CR>
  nnoremap <buffer> <silent> mo :<C-u>call ftx#mapping#mark#open_all()<CR>
  
  if get(g:, 'ftx_enable_git', 1)
    nnoremap <buffer> <silent> mg :<C-u>call ftx#mapping#mark#stage_all()<CR>
  endif
endfunction

function! s:setup_yank() abort
  nnoremap <buffer> <silent> yy :<C-u>call ftx#mapping#yank#absolute()<CR>
  nnoremap <buffer> <silent> yr :<C-u>call ftx#mapping#yank#relative()<CR>
  nnoremap <buffer> <silent> yn :<C-u>call ftx#mapping#yank#name()<CR>
endfunction

function! s:setup_other() abort
  nnoremap <buffer> <silent> q :<C-u>call ftx#close()<CR>
  nnoremap <buffer> <silent> ? :<C-u>call ftx#mapping#tree#show_help()<CR>
endfunction