# 🌲 ftx.vim — Fast Tree eXplorer for Vim/Neovim

![Support Vim 8.0+](https://img.shields.io/badge/support-Vim%208.0%2B-yellowgreen.svg)
![Support Neovim 0.4+](https://img.shields.io/badge/support-Neovim%200.4%2B-yellowgreen.svg)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/m-mdy-m/ftx.vim?label=version)](https://github.com/m-mdy-m/ftx.vim/releases/latest)
[![Doc](https://img.shields.io/badge/doc-%3Ah%20ftx-orange.svg)](doc/ftx.txt)
[![CI Status](https://github.com/m-mdy-m/ftx.vim/actions/workflows/ci.yml/badge.svg)](https://github.com/m-mdy-m/ftx.vim/actions/workflows/ci.yml)

<p align="center">
<img src="screenshot/tree.png" width="900" alt="ftx tree screenshot">
</p>

FTX is a **pure Vim script**, **asynchronous** file tree explorer focused on speed, clean UX, and extensibility.

---

## Features
- ⚡ Async tree build/update (keeps editor responsive)
- 🌿 Git-aware tree (files + directories)
- 🧩 Plugin-ready API 
- 🪟 Split-window and drawer workflows

## Installation

Use your plugin manager.

```vim
" vim-plug
Plug 'm-mdy-m/ftx.vim'
```

```vim
" dein
call dein#add('m-mdy-m/ftx.vim')
```

## Usage

## Quick Start

```vim
:FTX .
:FTX %:h
:FTX . -drawer
:FTXToggle
```

When you run `vim .`, FTX auto-opens on that directory.

## Documentation

- [Complete Guide](doc/README.md)
- [Configuration](doc/config.md)
- [Keymaps](doc/keymaps.md)
- [Git Integration](doc/git.md)
- `:help ftx` - Vim help

## Developer / Plugin API

FTX exposes lightweight extension points:

- Hook events (`tree:opened`, `tree:rendered`, `tree:closed`)
- Register custom file openers (for fzf, debugger integrations, etc.)

See **[doc/developer.md](doc/developer.md)** for examples.

## Requirements

- Vim 8.0+
- OR Neovim 0.4+

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

## Credits

Inspired by:
- **netrw** - Vim's built-in file browser
- **NERDTree** - Popular tree explorer
- **fern.vim** - Modern async file explorer
- **ranger.vim.vim** - integration in vim and neovim