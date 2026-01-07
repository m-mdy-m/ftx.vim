" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Git branch information with async operations
" ----------------------------------------------------------------------

let s:info = {
      \ 'branch': '',
      \ 'ahead': 0,
      \ 'behind': 0,
      \ 'has_stash': 0,
      \}

function! ftx#git#branch#parse(line) abort
  let branch_match = matchlist(a:line, '## \([^.[:space:]]\+\)')
  let ahead_match = matchlist(a:line, 'ahead \(\d\+\)')
  let behind_match = matchlist(a:line, 'behind \(\d\+\)')
  
  let s:info.branch = len(branch_match) > 1 ? branch_match[1] : ''
  let s:info.ahead = len(ahead_match) > 1 ? str2nr(ahead_match[1]) : 0
  let s:info.behind = len(behind_match) > 1 ? str2nr(behind_match[1]) : 0
  
  call s:check_stash()
endfunction

function! s:check_stash() abort
  let root = ftx#git#status#get_root()
  if empty(root)
    return
  endif
  
  let cmd = ['git', '-C', root, 'stash', 'list']
  
  call ftx#async#job#run(cmd, {'cwd': root})
        \.then({lines -> s:on_stash_result(lines)})
        \.catch({_ -> 0})
endfunction

function! s:on_stash_result(lines) abort
  let s:info.has_stash = !empty(a:lines)
endfunction

function! ftx#git#branch#get_info() abort
  return copy(s:info)
endfunction

function! ftx#git#branch#get_statusline() abort
  if empty(s:info.branch)
    return ''
  endif
  
  let parts = ['[' . s:info.branch . ']']
  
  if s:info.ahead > 0
    call add(parts, '↑' . s:info.ahead)
  endif
  
  if s:info.behind > 0
    call add(parts, '↓' . s:info.behind)
  endif
  
  if s:info.has_stash
    call add(parts, '$')
  endif
  
  return join(parts, ' ')
endfunction

function! ftx#git#branch#show_info() abort
  if !get(g:, 'ftx_enable_git', 1) || empty(s:info.branch)
    call ftx#helpers#logger#error('No git information available')
    return
  endif
  
  let lines = [
        \ '╔═══════════════════════════════╗',
        \ '║   Git Branch Information      ║',
        \ '╠═══════════════════════════════╣',
        \ '║                               ║',
        \]
  
  call add(lines, '║  Branch: ' . s:pad_right(s:info.branch, 20) . '║')
  
  if s:info.ahead > 0
    call add(lines, '║  Ahead:  ↑ ' . s:pad_right(s:info.ahead . ' commits', 17) . '║')
  endif
  
  if s:info.behind > 0
    call add(lines, '║  Behind: ↓ ' . s:pad_right(s:info.behind . ' commits', 17) . '║')
  endif
  
  if s:info.has_stash
    call add(lines, '║  Stash:  $ exists             ║')
  endif
  
  call extend(lines, [
        \ '║                               ║',
        \ '╚═══════════════════════════════╝',
        \])
  
  if has('popupwin')
    call popup_create(lines, {
          \ 'pos': 'center',
          \ 'border': [],
          \ 'padding': [0, 1, 0, 1],
          \ 'close': 'click',
          \ 'filter': {id, key -> key ==# 'q' || key ==# "\<Esc>" ? popup_close(id) : 0},
          \})
  else
    for line in lines
      echo line
    endfor
  endif
endfunction

function! s:pad_right(str, width) abort
  let len = len(a:str)
  return a:str . repeat(' ', max([0, a:width - len]))
endfunction

function! ftx#git#branch#cleanup() abort
  let s:info = {
        \ 'branch': '',
        \ 'ahead': 0,
        \ 'behind': 0,
        \ 'has_stash': 0,
        \}
endfunction