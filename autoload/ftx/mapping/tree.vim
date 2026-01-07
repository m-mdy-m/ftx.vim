" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Tree manipulation mappings
" ----------------------------------------------------------------------

function! ftx#mapping#tree#toggle_expand() abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node) || !node.is_dir
    return
  endif
  
  call ftx#tree#tree#toggle_node(node)
        \.then({changed -> changed ? ftx#refresh() : 0})
        \.catch({err -> ftx#helpers#logger#error('Toggle failed', err)})
endfunction

function! ftx#mapping#tree#expand_all() abort
  let nodes = ftx#tree#ui#get_all_nodes()
  call ftx#tree#tree#expand_all(nodes)
  call ftx#refresh()
endfunction

function! ftx#mapping#tree#collapse_all() abort
  call ftx#tree#tree#collapse_all()
  call ftx#refresh()
endfunction

function! ftx#mapping#tree#toggle_hidden() abort
  let g:ftx_show_hidden = !get(g:, 'ftx_show_hidden', 0)
  call ftx#refresh()
  
  let state = g:ftx_show_hidden ? 'shown' : 'hidden'
  call ftx#helpers#logger#info('Hidden files ' . state)
endfunction

function! ftx#mapping#tree#refresh() abort
  call ftx#refresh()
  call ftx#helpers#logger#info('Tree refreshed')
endfunction

function! ftx#mapping#tree#go_parent() abort
  let root = ftx#tree#tree#get_root()
  let parent = ftx#helpers#path#dirname(root)
  
  if parent ==# root || parent ==# '/'
    call ftx#helpers#logger#info('Already at root')
    return
  endif
  
  if ftx#helpers#path#is_directory(parent)
    call ftx#open(parent)
  endif
endfunction

function! ftx#mapping#tree#go_home() abort
  let home = expand('~')
  
  if ftx#helpers#path#is_directory(home)
    call ftx#open(home)
  endif
endfunction

function! ftx#mapping#tree#sync_to_current() abort
  let current_file = expand('%:p')
  
  if empty(current_file) || !ftx#helpers#path#is_readable(current_file)
    return
  endif
  
  let root = ftx#tree#tree#get_root()
  
  if current_file !~# '^' . escape(root, '\')
    return
  endif
  
  let dir = ftx#helpers#path#dirname(current_file)
  while dir !=# root && dir !=# '/'
    call ftx#tree#tree#expand_node({'path': dir, 'is_dir': 1, 'depth': 0})
    let dir = ftx#helpers#path#dirname(dir)
  endwhile
  
  call ftx#refresh()
        \.then({_ -> ftx#tree#ui#focus_node(current_file)})
        \.catch({err -> 0})
endfunction

function! ftx#mapping#tree#show_help() abort
  let lines = [
        \ '=== FTX Keybindings ===',
        \ '',
        \ 'File Operations:',
        \ '  o, <CR>  - Open file / Toggle directory',
        \ '  t        - Open in tab',
        \ '  s        - Open in split',
        \ '  v        - Open in vsplit',
        \ '',
        \ 'Tree Operations:',
        \ '  r, R     - Refresh tree',
        \ '  I        - Toggle hidden files',
        \ '  O        - Expand all',
        \ '  C        - Collapse all',
        \ '',
        \ 'Navigation:',
        \ '  -        - Go to parent',
        \ '  ~        - Go to home',
        \ '  cd       - Open terminal here',
        \ '',
        \ 'Marks:',
        \ '  m        - Toggle mark',
        \ '  M        - Clear marks',
        \ '  mo       - Open marked',
        \ '  mg       - Stage marked (git)',
        \ '',
        \ 'Yank:',
        \ '  yy       - Yank absolute path',
        \ '  yr       - Yank relative path',
        \ '  yn       - Yank filename',
        \ '',
        \ 'Other:',
        \ '  q        - Quit',
        \ '  ?        - Show this help',
        \]
  
  echo join(lines, "\n")
endfunction