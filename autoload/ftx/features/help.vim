" Copyright (c) 2026 m-mdy-m
" MIT License
" Help system

function! ftx#features#help#Show() abort
  let lines = s:GetHelpContent()
  call ftx#ui#popup#Large(lines)
endfunction

function! s:GetHelpContent() abort
  let lines = []
  
  call add(lines, '╔════════════════════════════════════════════════════════════╗')
  call add(lines, '║                    FTX - KEYMAPS                           ║')
  call add(lines, '╠════════════════════════════════════════════════════════════╣')
  
  call s:AddSection(lines, 'BASIC OPERATIONS', [
        \ ['o, Enter', 'Open file / Toggle directory'],
        \ ['t', 'Open in new tab'],
        \ ['s', 'Open in horizontal split'],
        \ ['v', 'Open in vertical split'],
        \ ['-', 'Go to parent directory'],
        \ ['~', 'Go to home directory'],
        \ ])
  
  call s:AddSection(lines, 'TREE OPERATIONS', [
        \ ['r', 'Refresh tree'],
        \ ['R', 'Refresh git status'],
        \ ['I', 'Toggle hidden files'],
        \ ['O', 'Expand all directories'],
        \ ['C', 'Collapse all directories'],
        \ ])
  
  call s:AddSection(lines, 'MARK OPERATIONS', [
        \ ['m', 'Toggle mark on file/directory'],
        \ ['M', 'Clear all marks'],
        \ ['mo', 'Open all marked files'],
        \ ['mg', 'Stage all marked files (git)'],
        \ ])
  
  call s:AddSection(lines, 'FILE OPERATIONS', [
        \ ['cd', 'Open terminal in path'],
        \ ])
  
  call s:AddSection(lines, 'GIT OPERATIONS', [
        \ ['gb', 'Show git blame'],
        \ ['gi', 'Show branch info'],
        \ ])
  
  call s:AddSection(lines, 'OTHER', [
        \ ['?', 'Show this help'],
        \ ['q', 'Close FTX'],
        \ ])
  
  call s:AddSection(lines, 'GLOBAL (Outside FTX)', [
        \ ['F2', 'Toggle FTX'],
        \ ['F3', 'Refresh FTX'],
        \ ['<leader>n', 'Toggle FTX'],
        \ ['<leader>nf', 'Focus FTX'],
        \ ['<leader>nh', 'Show this help'],
        \ ])
  
  call add(lines, '╚════════════════════════════════════════════════════════════╝')
  call add(lines, '')
  call add(lines, '  Press any key to close | j/k to scroll')
  
  return lines
endfunction

function! s:AddSection(lines, title, mappings) abort
  call add(a:lines, '║                                                            ║')
  call add(a:lines, '║  ' . ftx#utils#PadRight(a:title, 56) . '  ║')
  
  for [key, desc] in a:mappings
    let line = '║    ' . ftx#utils#PadRight(key, 16) . ' ' . ftx#utils#PadRight(desc, 35) . '  ║'
    call add(a:lines, line)
  endfor
endfunction