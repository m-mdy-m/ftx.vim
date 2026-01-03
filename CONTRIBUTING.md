# Contributing

Thanks for your interest in FTX.

## Development Setup

Clone the repository:

```bash
git clone https://github.com/m-mdy-m/ftx.vim
cd ftx.vim
```

Run tests:

```bash
make test
```

## Making Changes

Keep changes focused on one thing. If you want to fix a bug and add a feature, make separate pull requests.

Test your changes before submitting. Make sure existing tests pass and add new tests for new features.

## Testing

Write tests for new features in `test/test_ftx.vim`. Tests should be simple assertions that pass or fail.

Test structure:

```vim
function! s:TestMyFeature() abort
  echo 'Testing my feature...'
  
  call s:Assert(condition, 'Feature works')
  call s:Assert(another_condition, 'Edge case handled')
endfunction
```

Run tests locally:

```bash
make test
```

Tests run automatically on push via GitHub Actions.

## Pull Requests

Describe what your change does and why. Include relevant issue numbers.

Make sure:
- Tests pass
- Documentation is updated if needed
- Code follows style guidelines
- Commit messages are clear

## Reporting Bugs

Open an issue with:
- Vim version (`:version`)
- FTX version (`git describe --tags`)
- Steps to reproduce
- Expected vs actual behavior
- Error messages if any

## Suggesting Features

Open an issue describing:
- What you want to achieve
- Why it's useful
- How it might work

Discuss before implementing to avoid wasted effort.

## Questions

Open an issue if you need help or want to discuss an idea.

You can also contact: bitsgenix@gmail.com