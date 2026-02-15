# Configuration

All FTX settings, icons, and customization.

## Window Settings

```vim
let g:ftx_width = 30                    " Tree width (default: 30)
let g:ftx_position = 'left'             " 'left' or 'right' (default: 'left')
let g:ftx_show_hidden = 0               " Show dotfiles (default: 0)
let g:ftx_sort_dirs_first = 1           " Dirs before files (default: 1)
let g:ftx_auto_close = 0                " Close when last window (default: 0)
let g:ftx_auto_sync = 1                 " Sync to current file (default: 0)
let g:ftx_close_on_open = 0             " Close after opening file (default: 0)
let g:ftx_mapping_open_select = 'gw'    " Visual window selector mapping (default: 'gw', empty disables)
let g:ftx_select_labels = 'asdfjklqweruiopzxcvbnm1234567890' " selector labels order
```

## Git Settings

```vim
let g:ftx_enable_git = 1                " Master switch (default: 1)
let g:ftx_git_status = 1                " Show status (default: 1)
let g:ftx_git_update_time = 2000        " Update interval ms (default: 2000)
let g:ftx_git_blame = 0                 " Enable blame (default: 0)
let g:ftx_show_ignored = 0              " Show ignored files (default: 0)
```

## Feature Settings

```vim
let g:ftx_enable_icons = 1              " Use icons (default: 1)
let g:ftx_enable_marks = 1              " Enable marking (default: 1)
```

## Icons

### Tree Icons

```vim
let g:ftx_icon_expanded = '▾'           " Expanded directory
let g:ftx_icon_collapsed = '▸'          " Collapsed directory
let g:ftx_icon_file = ''                " Regular file
let g:ftx_icon_symlink = '→'            " Symbolic link
let g:ftx_icon_marked = '✓'             " Marked file
```

### Git Icons

```vim
let g:ftx_git_icon_added = '+'          " Staged
let g:ftx_git_icon_modified = '*'       " Modified
let g:ftx_git_icon_deleted = '-'        " Deleted
let g:ftx_git_icon_renamed = '→'        " Renamed
let g:ftx_git_icon_untracked = '?'      " Untracked
let g:ftx_git_icon_ignored = '◌'        " Ignored
let g:ftx_git_icon_unmerged = '!'       " Conflict
```

### File Type Icons

Custom icons by extension:
```vim
let g:ftx_icons = {
      \ 'vim': '',
      \ 'md': '',
      \ 'js': '',
      \ 'py': '',
      \ 'go': '',
      \ 'rs': '',
      \ }
```

### Special File Icons

Icons for specific filenames:
```vim
let g:ftx_special_icons = {
      \ 'README': '',
      \ 'LICENSE': '',
      \ 'Makefile': '',
      \ '.gitignore': '',
      \ 'package.json': '',
      \ }
```

## Colors

Custom colors by extension or filename:
```vim
let g:ftx_colors = {
      \ 'vim': 'guifg=#019733 ctermfg=35',
      \ 'py': 'guifg=#3572A5 ctermfg=67',
      \ 'js': 'guifg=#F1E05A ctermfg=221',
      \ 'md': 'guifg=#083fa1 ctermfg=27',
      \ 'go': 'guifg=#00ADD8 ctermfg=38',
      \ }
```

Or override highlight groups directly:
```vim
highlight FTXDir ctermfg=75 guifg=#5fafd7 gui=bold
highlight FTXFile ctermfg=252 guifg=#d0d0d0
highlight FTXGitModified ctermfg=221 guifg=#ffd787
```

## Icon Presets

### ASCII (no Unicode)

```vim
let g:ftx_enable_icons = 0
let g:ftx_icon_expanded = 'v'
let g:ftx_icon_collapsed = '>'
let g:ftx_git_icon_added = 'A'
let g:ftx_git_icon_modified = 'M'
```

### Fancy Unicode

```vim
let g:ftx_icon_expanded = '▼'
let g:ftx_icon_collapsed = '▶'
let g:ftx_icon_marked = '●'
let g:ftx_git_icon_added = '✚'
let g:ftx_git_icon_modified = '✱'
```

### Minimal

```vim
let g:ftx_icon_expanded = '-'
let g:ftx_icon_collapsed = '+'
let g:ftx_icon_marked = '*'
```

## Configuration Profiles

### Minimal (No Git, ASCII)

```vim
let g:ftx_enable_git = 0
let g:ftx_enable_icons = 0
let g:ftx_enable_marks = 0
let g:ftx_auto_sync = 0
```

### Full Featured

```vim
let g:ftx_width = 35
let g:ftx_auto_sync = 1
let g:ftx_enable_git = 1
let g:ftx_git_blame = 1
let g:ftx_git_update_time = 1000
let g:ftx_enable_marks = 1
```

### Performance (Large Repos)

```vim
let g:ftx_enable_git = 1
let g:ftx_git_status = 1
let g:ftx_git_update_time = 5000
let g:ftx_git_blame = 0
let g:ftx_auto_sync = 0
```

## Custom Keymaps

Add your own shortcuts:
```vim
" Quick access
nnoremap <C-n> :FTXToggle<CR>
nnoremap <C-f> :FTXFocus<CR>

" Leader mappings
nnoremap <leader>ft :FTXToggle<CR>
nnoremap <leader>ff :FTXFocus<CR>
nnoremap <leader>fr :FTXRefresh<CR>
```

## Project-Specific Settings

Use `.vimrc.local`:
```vim
" In project root: .vimrc.local
let g:ftx_width = 40
let g:ftx_show_hidden = 1

" In your ~/.vimrc
if filereadable('.vimrc.local')
  source .vimrc.local
endif
```

## Tips

- Reload config: `:source $MYVIMRC`
- Check setting: `:echo g:ftx_width`
- Test icons in FTX buffer
- Use `:FTXHelp` to verify keymaps work