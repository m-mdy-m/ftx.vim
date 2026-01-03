# FTX Documentation

Complete guide to FTX features and configuration.

## Contents

- [Configuration](configuration.md) - All settings and options
- [Keymaps](keymaps.md) - Keyboard shortcuts
- [Git Integration](git.md) - Git features
- [Multi-file Marking](marks.md) - Batch operations
- [Customization](customization.md) - Icons and styling

## Quick Links

Get help inside FTX:
```vim
?           " Show keymaps
:FTXHelp    " Show help popup
:help ftx   " Vim help documentation
```

## Features Overview

**Tree Navigation**
- Async file tree
- Expand/collapse directories
- Show/hide hidden files
- Auto-sync with buffer changes

**Git Integration**
- Real-time status indicators
- Branch information
- Git blame
- Stage multiple files

**Multi-file Operations**
- Mark multiple files
- Open all marked files
- Stage all marked files

**Terminal**
- Open terminal in any directory
- Quick access with `cd` key

**Customization**
- Custom icons for everything
- Configure all behaviors
- Multiple preset configurations

## Common Tasks

**Open FTX**
```vim
vim .           " Auto-opens FTX
:FTX            " Open manually
F2              " Toggle
```

**Navigate tree**
```vim
o               " Open/toggle
-               " Parent directory
~               " Home directory
O               " Expand all
C               " Collapse all
```

**Mark files**
```vim
m               " Toggle mark
mo              " Open all marked
mg              " Stage all marked
M               " Clear marks
```

**Git operations**
```vim
R               " Refresh status
gi              " Branch info
gb              " Git blame
```

## Configuration Example

```vim
let g:ftx_width = 35
let g:ftx_enable_git = 1
let g:ftx_auto_sync = 1
let g:ftx_enable_marks = 1

" Custom icons
let g:ftx_icon_expanded = '▼'
let g:ftx_icon_marked = '✓'
```

See [configuration.md](configuration.md) for all options.

## Getting Help

- Press `?` inside FTX for keymaps
- Use `:help ftx` for complete documentation
- Check examples in `examples/examples.config.vim`
- Read feature-specific docs in this directory

## Troubleshooting

**FTX not working?**
```vim
:echo has('job') && has('timers')  " Should return 1
```

**Git not showing?**
```vim
:echo g:ftx_enable_git             " Should be 1
:FTXRefreshGit                     " Force refresh
```

**Help doesn't work?**
```vim
:helptags ~/.vim/pack/ftx/start/ftx/doc
```

See individual docs for detailed troubleshooting.