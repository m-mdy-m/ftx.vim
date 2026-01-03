SHELL := /bin/bash
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DATE := $(shell date -u '+%Y-%m-%d %H:%M:%S UTC')

help:
	@echo "FTX - File Tree eXplorer"
	@echo ""
	@echo "Commands:"
	@echo "  make test       Run tests"
	@echo "  make install    Install plugin"
	@echo "  make clean      Clean build files"
	@echo "  make version    Show version"
	@echo "  make tag        Create version tag"
	@echo "  make lint       Check code style"

version:
	@echo "FTX version: $(VERSION)"
	@echo "Build date: $(BUILD_DATE)"
	@echo "Author: m-mdy-m"

test:
	@echo "Running FTX test suite..."
	@vim -u test/vimrc -c "source test/test_ftx.vim" || exit 1

install:
	@echo "Installing FTX..."
	@mkdir -p ~/.vim/pack/ftx/start/ftx
	@cp -r plugin autoload syntax docs ~/.vim/pack/ftx/start/ftx/
	@echo "FTX installed to ~/.vim/pack/ftx/start/ftx"
	@echo ""
	@echo "Restart Vim and run :FTX to use"

clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.swp" -delete 2>/dev/null || true
	@find . -name "*.swo" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@echo "Clean complete"

tag:
	@echo "Current version: $(VERSION)"
	@read -p "Enter new version (e.g., 1.0.0): " version; \
	if [ -z "$$version" ]; then \
		echo "Version required"; \
		exit 1; \
	fi; \
	git tag -a "v$$version" -m "Release v$$version"; \
	git push origin "v$$version"; \
	echo "Tagged and pushed v$$version"

lint:
	@echo "Checking code style..."
	@echo ""
	@echo "Checking file structure..."
	@test -f plugin/ftx.vim || (echo "Missing: plugin/ftx.vim"; exit 1)
	@test -f autoload/ftx.vim || (echo "Missing: autoload/ftx.vim"; exit 1)
	@test -f autoload/ftx/renderer.vim || (echo "Missing: autoload/ftx/renderer.vim"; exit 1)
	@test -f autoload/ftx/git.vim || (echo "Missing: autoload/ftx/git.vim"; exit 1)
	@test -f autoload/ftx/action.vim || (echo "Missing: autoload/ftx/action.vim"; exit 1)
	@test -f autoload/ftx/style.vim || (echo "Missing: autoload/ftx/style.vim"; exit 1)
	@test -f syntax/ftx.vim || (echo "Missing: syntax/ftx.vim"; exit 1)
	@echo "File structure OK"
	@echo ""
	@echo "Checking license headers..."
	@grep -q "Copyright (c) 2026 m-mdy-m" plugin/ftx.vim || (echo "Missing license in plugin/ftx.vim"; exit 1)
	@grep -q "Copyright (c) 2026 m-mdy-m" autoload/ftx.vim || (echo "Missing license in autoload/ftx.vim"; exit 1)
	@echo "License headers OK"
	@echo ""
	@echo "Checking function naming..."
	@! grep -rn "^function! [a-z]" autoload/ && echo "Function naming OK" || \
		(echo "Error: Functions must start with capital or contain :"; exit 1)
	@echo ""
	@echo "All checks passed"
