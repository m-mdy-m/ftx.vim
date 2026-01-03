# Customization

Make FTX look and behave exactly how you want.

## Icon Customization

### Tree Icons

**Unicode (default)**
```vim
let g:ftx_icon_expanded = '▾'
let g:ftx_icon_collapsed = '▸'
let g:ftx_icon_file = ' '
let g:ftx_icon_symlink = '→'
let g:ftx_icon_marked = '✓'
```

**Fancy Unicode**
```vim
let g:ftx_icon_expanded = '▼'
let g:ftx_icon_collapsed = '▶'
let g:ftx_icon_file = '📄'
let g:ftx_icon_symlink = '🔗'
let g:ftx_icon_marked = '●'
```

**ASCII (for older terminals)**
```vim
let g:ftx_icon_expanded = 'v'
let g:ftx_icon_collapsed = '>'
let g:ftx_icon_file = ' '
let g:ftx_icon_symlink = '->'
let g:ftx_icon_marked = '*'
```

**Box Drawing**
```vim
let g:ftx_icon_expanded = '─'
let g:ftx_icon_collapsed = '+'
let g:ftx_icon_file = '·'
let g:ftx_icon_symlink = '→'
let g:ftx_icon_marked = '▪'
```

### Git Icons

**Default**
```vim
let g:ftx_git_icon_added = '+'
let g:ftx_git_icon_modified = '*'
let g:ftx_git_icon_deleted = '-'
let g:ftx_git_icon_renamed = '→'
let g:ftx_git_icon_untracked = '?'
let g:ftx_git_icon_ignored = '◌'
let g:ftx_git_icon_unmerged = '!'
```

**Fancy**
```vim
let g:ftx_git_icon_added = '✚'
let g:ftx_git_icon_modified = '✱'
let g:ftx_git_icon_deleted = '✖'
let g:ftx_git_icon_renamed = '➜'
let g:ftx_git_icon_untracked = '?'
let g:ftx_git_icon_ignored = '◌'
let g:ftx_git_icon_unmerged = '⚠'
```

**Simple**
```vim
let g:ftx_git_icon_added = 'A'
let g:ftx_git_icon_modified = 'M'
let g:ftx_git_icon_deleted = 'D'
let g:ftx_git_icon_renamed = 'R'
let g:ftx_git_icon_untracked = 'U'
let g:ftx_git_icon_ignored = 'I'
let g:ftx_git_icon_unmerged = 'C'
```

## Color Customization

Add to your colorscheme or `.vimrc`:

```vim
" Directory
highlight FTXDir guifg=#0087ff ctermfg=blue gui=bold

" File
highlight FTXFile guifg=#d0d0d0 ctermfg=white

" Icons
highlight FTXDirIcon guifg=#5a5a5a ctermfg=gray

" Git status
highlight FTXGitStaged guifg=#5faf5f ctermfg=green gui=bold
highlight FTXGitModified guifg=#d7af5f ctermfg=yellow gui=bold
highlight FTXGitUntracked guifg=#808080 ctermfg=gray
highlight FTXGitDeleted guifg=#d75f5f ctermfg=red gui=bold
highlight FTXGitConflict guifg=#af5fd7 ctermfg=magenta gui=bold

" Popup border
highlight FTXBorder guifg=#3a3a3a ctermfg=darkgray
```

## Behavior Customization

### Window Behavior

```vim
let g:ftx_width = 35              " Wider tree
let g:ftx_position = 'right'      " Right side
let g:ftx_auto_close = 1          " Close when last
let g:ftx_auto_sync = 1           " Sync to file
```

### Display Behavior

```vim
let g:ftx_show_hidden = 1         " Always show hidden
let g:ftx_sort_dirs_first = 1     " Dirs before files
```

### Git Behavior

```vim
let g:ftx_git_update_time = 500   " Faster updates
let g:ftx_git_blame = 1           " Enable blame
let g:ftx_show_ignored = 1        " Show ignored files
```

## Complete Profiles

### Minimal Profile
```vim
let g:ftx_width = 40
let g:ftx_enable_git = 0
let g:ftx_enable_icons = 0
let g:ftx_enable_marks = 0
let g:ftx_auto_sync = 0
```

### Power User Profile
```vim
let g:ftx_width = 35
let g:ftx_position = 'right'
let g:ftx_auto_sync = 1
let g:ftx_enable_git = 1
let g:ftx_git_blame = 1
let g:ftx_git_update_time = 500
let g:ftx_enable_marks = 1
let g:ftx_icon_expanded = '▼'
let g:ftx_icon_collapsed = '▶'
let g:ftx_git_icon_added = '✚'
let g:ftx_git_icon_modified = '✱'
```

### Performance Profile
```vim
let g:ftx_enable_git = 1
let g:ftx_git_status = 1
let g:ftx_git_update_time = 3000
let g:ftx_git_blame = 0
let g:ftx_auto_sync = 0
let g:ftx_enable_marks = 0
```

## Custom Keymaps

```vim
" Quick access
nnoremap <C-n> :FTXToggle<CR>
nnoremap <C-f> :FTXFocus<CR>

" Leader mappings
nnoremap <leader>ft :FTXToggle<CR>
nnoremap <leader>ff :FTXFocus<CR>
nnoremap <leader>fr :FTXRefresh<CR>
nnoremap <leader>fb :FTXBranchInfo<CR>
nnoremap <leader>fm :FTXMarkToggle<CR>
```

## Project-Specific Settings

Use local `.vimrc`:

```vim
" In project root: .vimrc.local
let g:ftx_width = 50
let g:ftx_show_hidden = 1

" In main ~/.vimrc
if filereadable('.vimrc.local')
  source .vimrc.local
endif
```

## Terminal Support

If icons don't show:

1. Install a Nerd Font from https://www.nerdfonts.com/
2. Or use ASCII icons:
   ```vim
   let g:ftx_enable_icons = 0
   ```

Check terminal Unicode support:
```bash
echo $LANG
# Should show UTF-8
```

## Tips

- Test icons: `:echo g:ftx_icon_expanded`
- Reload config: `:source $MYVIMRC`
- Check colors: `:highlight FTXDir`
- Test git icons in a git repo
- Use `:FTXHelp` to see current mappings