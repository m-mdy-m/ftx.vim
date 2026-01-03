# FTX - File Tree eXplorer

Fast async file browser for Vim with git integration.

## What is FTX

Clean tree view of your project files with real-time git status indicators. Built for speed with async operations and minimal overhead.

No dependencies. No bloat. Just a file tree that works.

## Features

- Async file operations
- Git status integration
- Simple interface
- Lightweight
- Vim 8.0+ compatible

## Requirements

- Vim 8.0 or later with +job and +timers
- git (optional, for git integration)

Check if your Vim supports required features:

```vim
:echo has('job') && has('timers')
```

## Installation

### vim-plug

```vim
Plug 'm-mdy-m/ftx.vim'
```

### Vim 8 packages

```bash
git clone https://github.com/m-mdy-m/ftx.vim ~/.vim/pack/ftx/start/ftx
```

### Manual

```bash
git clone https://github.com/m-mdy-m/ftx.vim
cd ftx.vim
make install
```

## Quick Start

```vim
:FTX            " Open tree
:FTXToggle      " Toggle tree
```

Inside FTX:
- `o` or `Enter` to open
- `t` for new tab
- `s` for split
- `v` for vsplit
- `I` to toggle hidden files
- `q` to close

## Configuration

```vim
let g:ftx_width = 30              " Window width
let g:ftx_position = 'left'       " Window position (left/right)
let g:ftx_show_hidden = 0         " Show hidden files
let g:ftx_git_status = 1          " Enable git integration
let g:ftx_sort_dirs_first = 1     " Sort directories first
let g:ftx_auto_close = 0          " Auto close when last window
let g:ftx_git_update_time = 1000  " Git update interval (ms)
```

## Git Integration

Status indicators:

```
*   Modified (uncommitted changes)
+   Staged (ready to commit)
?   Untracked (not in git)
$   Stash exists
↑n  Ahead by n commits
↓n  Behind by n commits
```

Example tree:

```
▾ src
  ▸ components
    file.js *
    utils.js +
  ▸ styles
    main.css ?
```

Disable git:

```vim
let g:ftx_git_status = 0
```

## Documentation

Full documentation: [docs/FILE_TREE.md.md](docs/FILE_TREE.md.md)

## Development

Run tests:

```bash
make test
```

Create version tag:

```bash
make tag
```

Show version:

```bash
make version
```

## Contributing

Contributions welcome. Keep changes focused and include tests for new features.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT License - Copyright (c) 2025 m-mdy-m

See [LICENSE](LICENSE) for full text.

## Author

m-mdy-m - bitsgenix@gmail.com

## Links

- Issues: https://github.com/m-mdy-m/ftx.vim/issues
- Source: https://github.com/m-mdy-m/ftx.vim