# Configuration

All FTX settings with descriptions and defaults.

## Window Settings

**Width**
```vim
let g:ftx_width = 30
```
Tree window width in columns.

**Position**
```vim
let g:ftx_position = 'left'  " or 'right'
```
Where to open the tree window.

**Hidden Files**
```vim
let g:ftx_show_hidden = 0
```
Show files starting with `.` by default.

**Auto Close**
```vim
let g:ftx_auto_close = 0
```
Close FTX when it's the last window.

**Auto Sync**
```vim
let g:ftx_auto_sync = 1
```
Sync tree to current file when switching buffers.

**Sort Directories First**
```vim
let g:ftx_sort_dirs_first = 1
```
Show directories before files.

## Git Settings

**Enable Git**
```vim
let g:ftx_enable_git = 1
```
Master switch for all git features.

**Git Status**
```vim
let g:ftx_git_status = 1
```
Show real-time git status indicators.

**Update Time**
```vim
let g:ftx_git_update_time = 1000
```
Git status update interval in milliseconds.

**Git Blame**
```vim
let g:ftx_git_blame = 0
```
Enable git blame feature (opt-in).

**Branch Info**
```vim
let g:ftx_show_branch_info = 1
```
Show branch info in statusline.

**Branch Float**
```vim
let g:ftx_branch_info_float = 1
```
Use popup for branch info (requires +popupwin).

**Show Ignored**
```vim
let g:ftx_show_ignored = 0
```
Show gitignore files.

## Icon Settings

**Enable Icons**
```vim
let g:ftx_enable_icons = 1
```
Use custom icons (disable for pure ASCII).

**Tree Icons**
```vim
let g:ftx_icon_expanded = '▾'
let g:ftx_icon_collapsed = '▸'
let g:ftx_icon_file = ' '
let g:ftx_icon_symlink = '→'
let g:ftx_icon_marked = '✓'
```

**Git Icons**
```vim
let g:ftx_git_icon_added = '+'
let g:ftx_git_icon_modified = '*'
let g:ftx_git_icon_deleted = '-'
let g:ftx_git_icon_renamed = '→'
let g:ftx_git_icon_untracked = '?'
let g:ftx_git_icon_ignored = '◌'
let g:ftx_git_icon_unmerged = '!'
```

**File Type Icons**
```vim
let g:ftx_icons = {
      \ 'vim': '[V]',
      \ 'md': '<md>',
      \ }
```

**Special File Icons**
```vim
let g:ftx_special_icons = {
      \ 'README': '[R]',
      \ 'LICENSE': '',
      \ 'Makefile': '',
      \ '.gitignore': '',
      \ }
```

**File Type Colors**
```vim
let g:ftx_colors = {
      \ 'vim': 'guifg=#019733 ctermfg=35',
      \ 'py': 'guifg=#3572A5 ctermfg=67',
      \ 'js': 'guifg=#F1E05A ctermfg=221',
      \ }
```

## Feature Settings

**Enable Marks**
```vim
let g:ftx_enable_marks = 1
```
Enable multi-file marking system.

## Preset Configurations

**Minimal (no git, ASCII)**
```vim
let g:ftx_width = 40
let g:ftx_enable_git = 0
let g:ftx_enable_icons = 0
```

**Full Featured**
```vim
let g:ftx_width = 35
let g:ftx_position = 'right'
let g:ftx_enable_git = 1
let g:ftx_git_blame = 1
let g:ftx_auto_sync = 1
let g:ftx_enable_marks = 1
```

**Performance (large repos)**
```vim
let g:ftx_enable_git = 1
let g:ftx_git_update_time = 3000
let g:ftx_git_blame = 0
let g:ftx_auto_sync = 0
```

## Custom Keymaps

```vim
nnoremap <C-n> :FTXToggle<CR>
nnoremap <leader>ft :FTXToggle<CR>
nnoremap <leader>fb :FTXBranchInfo<CR>
```

See [keymaps.md](keymaps.md) for all mappings.