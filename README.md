# vim-noteworthy
Very often, I'll be coding in vim, and want to jot down a reminder. I have a
place where I store notes for myself, and it's not usually in the same
repository I'm coding in. I made this plugin to make this process easier.

Basically, you define a dictionary of libraries and their file paths in your
`vimrc`.

```vim
let g:noteworthy_libraries = {
      \   'work':     $HOME . '/workflow/notes/work',
      \   'personal': $HOME . '/workflow/notes/personal',
      \ }
```

Tell it which is the default to use.

```vim
let g:noteworthy_default_library = 'work'
```

The default file extension is 'md' (markdown), but you can change this.

```vim
let g:noteworthy_file_type = 'txt'
```

Create or edit a note with `:Note [subject...]`. The `subject` will be used as
the file name, and any spaces will be replaced by underscores. No file extension
is required.

```
:Note i need to remember this
```

This will open a file in your current library called
`i_need_to_remember_this.md`. Tab-completion will list existing notes in the
library.

You can also use subdirectories, and they will be created if they don't exist.
Just make sure your first argument has a slash in it.

```
:Note rails/remember this about rails
```

This will open a file called `rails/remember_this_about_rails.md` in your
current library.

To see which library is currently in use, call `:NoteLibrary`.

To change which library is being used, call `:NoteLibrary [library]`, where
`library` is a key from `g:noteworthy_libraries`. Tab-completion will list
available libraries.

The plugin can generate a title for you. Set this in your `vimrc`.

```vim
let noteworthy_use_default_header = 1
```

Now if you call `:Note remember this`, a file called `remember_this.md` will be
created, and will be given the following header.

```markdown
# REMEMBER THIS
```

If you want to define your own command, you can create a string containing
commands to be `eval`'d and used as the header. For example, if you want the
title to be lower-case instead of the default upper-case.

```vim
let g:noteworthy_header_command = 
      \ "'# ' . join(split(fnamemodify(l:file, ':t:r'), '_'), ' ')"
```

Note that you can use `l:file`, which will resolve to the full file path to the
current note being created.


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
