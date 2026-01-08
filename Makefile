SHELL := /bin/bash
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DATE := $(shell date -u '+%Y-%m-%d %H:%M:%S UTC')
.PHONY: test help install clean release helptags

help:
	@echo "FTX - File Tree eXplorer"
	@echo ""
	@echo "Commands:"
	@echo "  make test       Run tests"
	@echo "  make install    Install plugin"
	@echo "  make clean      Clean build files"
	@echo "  make version    Show version"
	@echo "  make tag        Create version tag"
	@echo "  make helptags   Generate help tags"
	@echo "  make release    Create release"

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
	@cp -r plugin autoload syntax doc ~/.vim/pack/ftx/start/ftx/
	@echo "FTX installed to ~/.vim/pack/ftx/start/ftx"
	@echo ""
	@echo "Restart Vim and run :FTX to use"

clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.swp" -delete 2>/dev/null || true
	@find . -name "*.swo" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@rm -f doc/tags
	@echo "Clean complete"

helptags:
	@echo "Generating help tags..."
	@vim -u NONE -c "helptags doc/" -c "quit"
	@echo "Help tags generated"

tag:
	@echo "Current version: $(VERSION)"
	@read -p "Enter new version (e.g., 0.5.0): " version; \
	if [ -z "$$version" ]; then \
		echo "Version required"; \
		exit 1; \
	fi; \
	echo "Creating tag v$$version..."; \
	git tag -a "v$$version" -m "Release v$$version"; \
	git push origin "v$$version"; \
	echo "Tagged and pushed v$$version"

release: helptags
	@echo "Preparing release..."
	@echo "Current version: $(VERSION)"
	@read -p "Enter release version (e.g., 0.5.0): " version; \
	if [ -z "$$version" ]; then \
		echo "Version required"; \
		exit 1; \
	fi; \
	if git rev-parse "v$$version" >/dev/null 2>&1; then \
		echo "Error: Tag v$$version already exists"; \
		exit 1; \
	fi; \
	echo "Creating release v$$version..."; \
	git add doc/tags; \
	git commit -m "chore: generate help tags for v$$version" || true; \
	git tag -a "v$$version" -m "Release v$$version"; \
	echo ""; \
	echo "Release ready. To publish, run:"; \
	echo "  git push origin main"; \
	echo "  git push origin v$$version"
