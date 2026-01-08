# FTX - File Tree eXplorer

![Support Vim 8.0 or above](https://img.shields.io/badge/support-Vim%208.0%2B-yellowgreen.svg)
![Support Neovim 0.4 or above](https://img.shields.io/badge/support-Neovim%200.4%2B-yellowgreen.svg)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/m-mdy-m/ftx.vim?label=version)](https://github.com/m-mdy-m/ftx.vim/releases/latest)
[![Doc](https://img.shields.io/badge/doc-%3Ah%20ftx-orange.svg)](doc/ftx.txt)
[![CI Status](https://github.com/m-mdy-m/ftx.vim/actions/workflows/ci.yml/badge.svg)](https://github.com/m-mdy-m/ftx.vim/actions/workflows/ci.yml)

<p align="center">
<img src="screenshot/tree.png" width="800">
</p>

FTX is an asynchronous file tree explorer written in pure Vim script.

---

## Features

- Supports both Vim and Neovim without external dependencies
- Asynchronous operations to keep Vim responsive
- Real-time git status integration
- Multi-file operations with marking system
- Simple and straightforward

## Installation

FTX has no dependencies. Use your favorite plugin manager:

### vim-plug
```vim
Plug 'm-mdy-m/ftx.vim'
```

### dein.vim
```vim
call dein#add('m-mdy-m/ftx.vim')
```

### minpac
```vim
call minpac#add('m-mdy-m/ftx.vim')
```

### Vim 8 packages
```bash
git clone https://github.com/m-mdy-m/ftx.vim ~/.vim/pack/ftx/start/ftx
```

### Neovim packages
```bash
git clone https://github.com/m-mdy-m/ftx.vim ~/.config/nvim/pack/ftx/start/ftx
```

## Usage

Open FTX on current directory:
```vim
:FTX .
```

Open FTX on parent of current buffer:
```vim
:FTX %:h
```

Open as project drawer:
```vim
:FTX . -drawer
```

Toggle FTX:
```vim
:FTXToggle
```

Or just:
```bash
vim .
```

FTX opens automatically when you run Vim on a directory.

## Documentation

- [Complete Guide](doc/README.md)
- [Configuration](doc/config.md)
- [Keymaps](doc/keymaps.md)
- [Git Integration](doc/git.md)
- `:help ftx` - Vim help

## Requirements

- Vim 8.0+
- OR Neovim 0.4+

## Contributing

Contributions welcome. Keep changes focused and add tests for new features.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).

## Credits

Inspired by:
- **netrw** - Vim's built-in file browser
- **NERDTree** - Popular tree explorer
- **fern.vim** - Modern async file explorer
- **ranger.vim.vim** - integration in vim and neovim

Built with simplicity and performance in mind.