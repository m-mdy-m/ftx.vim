# Configuration

This page lists only stable and practical options that are useful in real projects.

## Core behavior

```vim
let g:ftx_width = 30            " Tree width (columns)
let g:ftx_position = 'left'     " 'left' | 'right'
let g:ftx_show_hidden = 1       " Show dotfiles
let g:ftx_sort_dirs_first = 1   " Directories before files
let g:ftx_auto_close = 0        " Quit Vim when FTX is last window
let g:ftx_auto_sync = 0         " Follow current buffer path
let g:ftx_close_on_open = 0     " Close FTX after opening a file
```

## Feature switches

```vim
let g:ftx_enable_icons = 1
let g:ftx_enable_marks = 1
let g:ftx_enable_git = 1
```

## Git options

```vim
let g:ftx_git_status = 1
let g:ftx_git_update_time = 2000    " ms
let g:ftx_git_blame = 0
let g:ftx_show_ignored = 0
```

### Git rendering options

```vim
let g:ftx_git_status_style = 'icon' " 'icon' | 'xy'
let g:ftx_git_status_icons = {
      \ 'M': '●',
      \ 'A': '+',
      \ '?': '?',
      \ }
```

## Icon and color customization

```vim
let g:ftx_icon_expanded = '▾'
let g:ftx_icon_collapsed = '▸'
let g:ftx_icon_file = ''
let g:ftx_icon_symlink = '→'
let g:ftx_icon_marked = '✓'

let g:ftx_git_icon_added = '+'
let g:ftx_git_icon_modified = '*'
let g:ftx_git_icon_deleted = '-'
let g:ftx_git_icon_renamed = '→'
let g:ftx_git_icon_untracked = '?'
let g:ftx_git_icon_ignored = '◌'
let g:ftx_git_icon_unmerged = '!'

let g:ftx_icons = { 'vim': '', 'md': '', 'py': '' }
let g:ftx_special_icons = { 'README': '', 'LICENSE': '' }
let g:ftx_colors = { 'vim': 'guifg=#019733 ctermfg=35' }
```

## Recommended profiles

### Minimal / fast

```vim
let g:ftx_enable_git = 0
let g:ftx_enable_icons = 0
let g:ftx_enable_marks = 0
let g:ftx_auto_sync = 0
```

### Large repositories

```vim
let g:ftx_enable_git = 1
let g:ftx_git_update_time = 5000
let g:ftx_git_blame = 0
let g:ftx_auto_sync = 0
```