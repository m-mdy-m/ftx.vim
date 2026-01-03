# FTX - File Tree eXplorer

Fast async file browser for Vim with git integration.

## Table of Contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Commands](#commands)
- [Keymaps](#keymaps)
- [Git Integration](#git-integration)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

## Introduction

FTX displays your project files in a tree structure with real-time git status indicators. Built for speed with async operations.

Key features:
- Async file operations prevent UI blocking
- Real-time git status with visual indicators
- Simple, clean interface without clutter
- Lightweight and fast
- Vim 8.0+ compatible (no Neovim required)

## Requirements

Minimum requirements:
- Vim 8.0 or later
- +job feature
- +timers feature

Optional:
- git (for git integration)

Check if your Vim has required features:

```vim
:echo has('job') && has('timers')
```

Should return 1. If it returns 0, your Vim version is too old.

Check Vim version:

```vim
:version
```

Look for "Included patches" and ensure you have at least 8.0.

## Installation

### Using vim-plug

Add to your vimrc:

```vim
Plug 'm-mdy-m/ftx.vim'
```

Then run:

```vim
:PlugInstall
```

### Using Vim 8 packages

```bash
git clone https://github.com/m-mdy-m/ftx.vim \
    ~/.vim/pack/ftx/start/ftx
```

Restart Vim and FTX is ready.

### Manual installation

```bash
git clone https://github.com/m-mdy-m/ftx.vim
cd ftx.vim
make install
```

This copies files to `~/.vim/pack/ftx/start/ftx/`.

## Quick Start

Open FTX in current directory:

```vim
:FTX
```

Toggle FTX window:

```vim
:FTXToggle
```

Inside FTX, press:
- `o` or `Enter` to open file or expand directory
- `t` to open in new tab
- `q` to close FTX

## Configuration

Add these to your vimrc to customize FTX:

```vim
" Window width (default: 30)
let g:ftx_width = 35

" Window position: 'left' or 'right' (default: 'left')
let g:ftx_position = 'right'

" Show hidden files by default (default: 0)
let g:ftx_show_hidden = 1

" Enable git status integration (default: 1)
let g:ftx_git_status = 1

" Sort directories before files (default: 1)
let g:ftx_sort_dirs_first = 1

" Auto close FTX when it's the last window (default: 0)
let g:ftx_auto_close = 1

" Git status update interval in milliseconds (default: 1000)
let g:ftx_git_update_time = 2000
```

### Configuration Examples

Minimal setup (git disabled, wider window):

```vim
let g:ftx_width = 40
let g:ftx_git_status = 0
```

Full-featured setup:

```vim
let g:ftx_width = 35
let g:ftx_position = 'right'
let g:ftx_show_hidden = 1
let g:ftx_git_status = 1
let g:ftx_auto_close = 1
let g:ftx_git_update_time = 1500
```

## Commands

### :FTX [path]

Open FTX in specified path or current directory.

Examples:

```vim
:FTX
:FTX /home/user/projects
:FTX ~/Documents
```

If path doesn't exist, shows error message and doesn't open.

### :FTXToggle

Toggle FTX window visibility. If open, closes it. If closed, opens it.

Example keymap:

```vim
nnoremap <C-n> :FTXToggle<CR>
```

### :FTXClose

Close FTX window. Safe to call even if FTX is not open.

### :FTXRefresh

Refresh tree display. Useful after external file system changes.

Example:

```vim
" Auto refresh on focus
autocmd FocusGained * if exists(':FTXRefresh') | FTXRefresh | endif
```

### :FTXFocus

Move cursor to FTX window. If FTX is not open, does nothing.

## Keymaps

Default keymaps inside FTX window:

| Key | Action |
|-----|--------|
| `o`, `Enter` | Open file or toggle directory |
| `t` | Open in new tab |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `r`, `R` | Refresh tree |
| `I` | Toggle hidden files |
| `q` | Close FTX |
| `<2-LeftMouse>` | Open file or toggle directory |

Keymaps only work inside FTX buffer. They don't affect normal editing.

### Custom Keymaps

Add your own keymaps in vimrc:

```vim
" Open FTX with Ctrl+n
nnoremap <C-n> :FTXToggle<CR>

" Open FTX with leader+f
nnoremap <leader>f :FTX<CR>

" Focus FTX with leader+n
nnoremap <leader>n :FTXFocus<CR>
```

## Git Integration

FTX shows git status for each file when inside a git repository. Status indicators appear after the file name.

### Status Indicators

| Symbol | Meaning |
|--------|---------|
| `*` | Modified (uncommitted changes) |
| `+` | Staged (ready for commit) |
| `?` | Untracked (not in git index) |
| `$` | Stash exists in repository |
| `↑n` | Ahead by n commits |
| `↓n` | Behind by n commits |

Multiple indicators can appear together: `file.js *+↑2` means file is modified, staged, and branch is 2 commits ahead.

### Example Display

```
▸ src
▾ components
    Button.jsx *
    Input.jsx +
  ▸ utils
    helpers.js ?
▸ styles
  main.css *+
```

Explanation:
- `Button.jsx *` - Modified but not staged
- `Input.jsx +` - Staged for commit
- `helpers.js ?` - Untracked file
- `main.css *+` - Modified and staged

### Git Update Timing

Git status updates automatically:
- When you open FTX
- Every second (configurable)
- After buffer changes

Change update interval:

```vim
let g:ftx_git_update_time = 2000  " Update every 2 seconds
```

### Disabling Git Integration

If you don't need git integration:

```vim
let g:ftx_git_status = 0
```

This improves performance in large repositories.

## Advanced Usage

### Opening Specific Directories

Open FTX in a specific location:

```vim
:FTX ~/projects/myapp
```

### Working with Multiple Projects

You can have different FTX configurations per project using local vimrc:

Create `.vimrc.local` in project root:

```vim
let g:ftx_width = 40
let g:ftx_show_hidden = 1
```

Load local config in your main vimrc:

```vim
if filereadable('.vimrc.local')
  source .vimrc.local
endif
```

### Integration with Other Plugins

FTX works well with other plugins. Example with fzf:

```vim
" Use fzf to find file, then open with FTX focused
nnoremap <leader>ff :FTXFocus<CR>:Files<CR>
```

### Auto-opening FTX

Open FTX automatically when Vim starts:

```vim
autocmd VimEnter * FTX
```

Open FTX only for specific file types:

```vim
autocmd FileType javascript,python FTXToggle
```

## Troubleshooting

### FTX doesn't load

Check if features are available:

```vim
:echo has('job') && has('timers')
```

If returns 0, upgrade Vim to 8.0 or later.

Check if FTX loaded:

```vim
:echo exists(':FTX')
```

Should return 2. If returns 0, plugin didn't load.

### Git status doesn't show

Check if git is available:

```bash
which git
```

Check if you're in a git repository:

```bash
git status
```

Check if git integration is enabled:

```vim
:echo g:ftx_git_status
```

Should return 1.

### Window appears in wrong position

Check position setting:

```vim
:echo g:ftx_position
```

Change it:

```vim
let g:ftx_position = 'left'  " or 'right'
:FTXToggle
:FTXToggle
```

### Hidden files not showing

Press `I` inside FTX to toggle hidden files.

Or set default in vimrc:

```vim
let g:ftx_show_hidden = 1
```

### FTX too slow in large directories

Disable git integration:

```vim
let g:ftx_git_status = 0
```

Increase git update interval:

```vim
let g:ftx_git_update_time = 5000  " Update every 5 seconds
```

### Colors look wrong

FTX uses your colorscheme's default colors. If they look wrong, try:

```vim
:colorscheme default
:FTXRefresh
```

Or manually set colors in vimrc:

```vim
highlight FTXGitModified ctermfg=yellow
highlight FTXGitStaged ctermfg=green
```

### Tree structure breaks after editing

FTX buffer is non-modifiable. If you somehow edited it:

```vim
:FTXClose
:FTX
```

### Getting help

If you found a bug or have a question:

1. Check if issue already exists: https://github.com/m-mdy-m/ftx.vim/issues
2. Open new issue with details:
   - Vim version (`:version`)
   - FTX version (`git describe --tags`)
   - Steps to reproduce
   - Expected vs actual behavior

## Tips

### Keyboard-driven workflow

```vim
" Open FTX, find file, open in split
<C-n>           " Toggle FTX
/filename       " Search for file
<Enter>         " Navigate to it
s               " Open in split
<C-n>           " Hide FTX
```

### Git workflow

```vim
" Check changes before committing
:FTX            " See modified files (marked with *)
o               " Open modified file
:w              " Edit and save
q               " Close file
:FTXRefresh     " See updated git status
```

### Project navigation

```vim
" Jump between project sections
:FTX
/src/           " Find src directory
<Enter>         " Expand it
/components     " Find components
<Enter>         " Open
```

### Performance tips

For large projects:
- Disable git integration if not needed
- Increase update interval
- Don't show hidden files by default
- Close FTX when not needed

```vim
let g:ftx_git_status = 0
let g:ftx_show_hidden = 0
```