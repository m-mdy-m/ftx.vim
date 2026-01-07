" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Git blame operations with async and caching
" ----------------------------------------------------------------------

let s:cache = {}

function! ftx#git#blame#show() abort
  if !get(g:, 'ftx_enable_git', 1) || !get(g:, 'ftx_git_blame', 0)
    call ftx#helpers#logger#error('Git blame is disabled')
    return
  endif
  
  if !executable('git')
    call ftx#helpers#logger#error('Git not available')
    return
  endif
  
  let node = ftx#tree#ui#get_cursor_node()
  if empty(node) || node.is_dir
    call ftx#helpers#logger#error('Select a file for blame')
    return
  endif
  
  call s:fetch_blame(node.path)
        \.then({lines -> s:show_popup(lines, node.name)})
        \.catch({err -> ftx#helpers#logger#error('Blame failed', err)})
endfunction

function! s:fetch_blame(file) abort
  if has_key(s:cache, a:file)
    return ftx#async#promise#resolve(s:cache[a:file])
  endif
  
  let root = ftx#git#status#get_root()
  if empty(root)
    return ftx#async#promise#reject('Not in git repository')
  endif
  
  let cmd = ['git', '-C', root, 'log', '-n', '10', '--format=%h|%an|%ar|%s', '--', a:file]
  
  return ftx#async#job#run(cmd, {'cwd': root})
        \.then({lines -> s:cache_result(a:file, lines)})
endfunction

function! s:cache_result(file, lines) abort
  let s:cache[a:file] = a:lines
  return a:lines
endfunction

function! s:show_popup(lines, filename) abort
  if empty(a:lines)
    call ftx#helpers#logger#error('No blame information')
    return
  endif
  
  let formatted = s:format_blame(a:lines, a:filename)
  
  if has('popupwin')
    call popup_create(formatted, {
          \ 'title': ' Git Blame ',
          \ 'pos': 'center',
          \ 'minwidth': 60,
          \ 'maxheight': 20,
          \ 'border': [],
          \ 'padding': [0, 1, 0, 1],
          \ 'scrollbar': 1,
          \ 'close': 'click',
          \ 'filter': function('s:filter_blame_popup'),
          \})
  else
    for line in formatted
      echo line
    endfor
  endif
endfunction

function! s:filter_blame_popup(id, key) abort
  if a:key ==# 'q' || a:key ==# "\<Esc>" || a:key ==# ' ' || a:key ==# "\<CR>"
    call popup_close(a:id)
    return 1
  elseif a:key ==# 'j' || a:key ==# "\<Down>"
    call popup_setoptions(a:id, #{firstline: popup_getoptions(a:id).firstline + 1})
    return 1
  elseif a:key ==# 'k' || a:key ==# "\<Up>"
    call popup_setoptions(a:id, #{firstline: max([1, popup_getoptions(a:id).firstline - 1])})
    return 1
  endif
  return 0
endfunction

function! s:format_blame(lines, filename) abort
  let result = [
        \ '╔════════════════════════════════════════════════════════╗',
        \ '║  File: ' . s:truncate(a:filename, 48) . '  ║',
        \ '╠════════════════════════════════════════════════════════╣',
        \]
  
  for entry in a:lines[:9]
    let parts = split(entry, '|')
    if len(parts) >= 4
      let hash = parts[0]
      let author = s:truncate(parts[1], 15)
      let time = parts[2]
      let message = s:truncate(parts[3], 44)
      
      call extend(result, [
            \ '║                                                        ║',
            \ '║  ' . hash . ' │ ' . s:pad_right(author, 15) . '  ║',
            \ '║  ' . s:pad_right(time, 48) . '  ║',
            \ '║  ' . s:pad_right(message, 48) . '  ║',
            \])
    endif
  endfor
  
  call extend(result, [
        \ '║                                                        ║',
        \ '╚════════════════════════════════════════════════════════╝',
        \ '',
        \ 'Press q/Esc/Space/Enter to close, j/k to scroll',
        \])
  
  return result
endfunction

function! s:truncate(str, width) abort
  if len(a:str) <= a:width
    return a:str
  endif
  return a:str[:a:width-4] . '...'
endfunction

function! s:pad_right(str, width) abort
  let len = len(a:str)
  return a:str . repeat(' ', max([0, a:width - len]))
endfunction

function! ftx#git#blame#cleanup() abort
  let s:cache = {}
endfunction