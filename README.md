# FTX - File Tree eXplorer

Fast async file browser for Vim with git integration.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Vim](https://img.shields.io/badge/vim-8.0%2B-green.svg)
![Version](https://img.shields.io/badge/version-0.3.0-blue.svg)


![FTX Screenshot](screenshot/tree.png)

## What is FTX

Clean tree view of your project files with real-time git status indicators. Built for speed with async operations and minimal overhead.

Key Features:
- Async file operations (non-blocking I/O)
- Fully customizable icons and symbols
- Git blame and branch information
- Multi-file marking for batch operations
- Auto-sync with buffer changes
- Terminal integration
- Lazy-loading for performance
- Auto-opens with vim .
- NERDTree-style keybindings

No dependencies. No bloat. Just a file tree that works.

## Features

Core:
- Async file tree rendering using Vim's job API
- Auto-sync tree when switching buffers
- Expand/Collapse all directories
- Show/hide hidden files
- Customizable icons for everything
- Mouse support

Git Integration:
- Real-time status indicators (+ * ? - !)
- Branch information with ahead/behind commits
- Git blame support (opt-in)
- Branch info tooltips/floats
- Stash detection
- Show/hide gitignore files
- Auto-update on file save

Multi-file Operations:
- Mark multiple files
- Open all marked files in tabs
- Stage all marked files to git
- Visual mark indicators

File Operations:
- Open terminal in file/directory path
- Open in splits, tabs, or current window

Help:
- Interactive help float showing all keymaps
- Press ? inside FTX or :FTXHelp

## Requirements

Minimum:
- Vim 8.0 or later with +job and +timers
- git (optional, for git integration)

Recommended:
- Vim with +popupwin (for tooltips and help)
- Unicode-capable terminal (for fancy icons)

Check if your Vim supports required features:

    :echo has('job') && has('timers')

## Installation

### vim-plug

    Plug 'm-mdy-m/ftx.vim'

Then run:

    :PlugInstall

### Vim 8 packages

    git clone https://github.com/m-mdy-m/ftx.vim ~/.vim/pack/ftx/start/ftx

### Manual

    git clone https://github.com/m-mdy-m/ftx.vim
    cd ftx.vim
    make install

## Quick Start

Basic Usage:

    :FTX            Open tree in current directory
    :FTXToggle      Toggle tree visibility
    F2              Toggle FTX (quick key)
    F3              Refresh tree
    ?               Show help inside FTX

Open with Directory:

    vim .           FTX opens automatically
    vim ~/projects  Opens FTX in ~/projects

## Documentation

In Vim:

    :help ftx
    :help ftx-configuration
    :help ftx-commands

Detailed Documentation:
- [Complete Guide](docs/README.md) - Start here
- [Configuration](docs/configuration.md) - All settings
- [Keymaps](docs/keymaps.md) - Keyboard shortcuts
- [Git Integration](docs/git.md) - Git features
- [Multi-file Marking](docs/marks.md) - Batch operations
- [Customization](docs/customization.md) - Icons and styling

## Contributing

Contributions welcome. Keep changes focused and include tests for new features.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT License - Copyright (c) 2026 m-mdy-m

See [LICENSE](LICENSE) for full text.

## Credits

Inspired by:
- **netrw** - Vim's built-in file browser
- **NERDTree** - Popular tree explorer
- **fern.vim** - Modern async file explorer
- **ranger.vim.vim** - integration in vim and neovim

Built with simplicity and performance in mind.
