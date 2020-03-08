# vim-noteworthy
Plugin that assists with note-taking in vim.

## Installation
This project is under construction. It's in a working order, but I haven't
finished this README. I have, however, got some of the
[documentation](doc/noteworthy.txt)  going. You can install the plugin, generate
the help tags, and read the docs for more info.

### Vim 8+ with Packages
Clone the repository in a package directory, or copy and paste:

```sh
mkdir -p $HOME/.vim/pack/evanthegrayt/start
git clone https://github.com/evanthegrayt/vim-noteworthy.git \
    $HOME/.vim/pack/evanthegrayt/start/vim-noteworthy
```

Generate and view the help from within vim.

```sh
:helptags ALL
:help noteworthy
```

### Pathogen
Clone the repository in your `bundle`  directory.

```sh
mkdir -p $HOME/.vim/bundle
git clone https://github.com/evanthegrayt/vim-noteworthy.git \
    $HOME/.vim/bundle/vim-noteworthy
```

Generate and view the help from within vim.

```sh
:Helptags
:help noteworthy
```
