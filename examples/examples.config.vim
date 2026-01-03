" Basic Configuration
let g:ftx_width = 35
let g:ftx_position = 'left'
let g:ftx_show_hidden = 0
let g:ftx_git_status = 1
let g:ftx_sort_dirs_first = 1
let g:ftx_auto_close = 0

" Custom Keymaps
nnoremap <C-n> :FTXToggle<CR>
nnoremap <leader>ft :FTXToggle<CR>
nnoremap <leader>ff :FTXFocus<CR>
nnoremap <leader>fr :FTXRefresh<CR>
nnoremap <leader>fg :FTXRefreshGit<CR>

" Open FTX in specific projects
nnoremap <leader>fp :FTX ~/projects<CR>
nnoremap <leader>fh :FTX ~<CR>

" Auto-open FTX for certain directories (optional)
" autocmd VimEnter ~/projects/* FTX

" Minimal Configuration (Git disabled, wider window)
" let g:ftx_width = 40
" let g:ftx_git_status = 0
" let g:ftx_show_hidden = 0

" Full-Featured Configuration
" let g:ftx_width = 35
" let g:ftx_position = 'right'
" let g:ftx_show_hidden = 1
" let g:ftx_git_status = 1
" let g:ftx_auto_close = 1

" Integration with other plugins (optional)
" Example: Open FTX and then use fzf
" nnoremap <leader>pf :FTXFocus<CR>:Files<CR>

" Color customization (optional)
" highlight FTXDir ctermfg=blue guifg=#0087ff
" highlight FTXGitStaged ctermfg=green guifg=#00ff00
" highlight FTXGitModified ctermfg=yellow guifg=#ffff00