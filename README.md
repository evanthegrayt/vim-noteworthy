# Noteworthy
I'll often be coding in `vim`, and want to quickly write a note. I have places
where I store notes for myself, and it's not usually in the same repository I'm
coding in. I made this plugin to make this process easier.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Setup](#setup)
  - [Commands](#commands)
- [Issues and Feature Requests](#issues-and-feature-requests)
- [Self-Promotion](#self-promotion)

## Installation
I recommend using a modern version of `vim` (version 8.0 or higher) and
cloning the repository in a package directory.

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

## Usage
### Setup
To get started, define a dictionary of libraries and their file paths in your
`vimrc`, and tell it which is the default to use. If a default is not set, you
will have to tell it which library to use each time you open a new `vim`
instance.

```vim
let g:noteworthy_libraries = {
    \   'general':    $HOME . '/notes',
    \   'my_project': $HOME . '/my_project/docs/notes',
    \ }

let g:noteworthy_default_library = 'general'
```

The default file extension is 'md' (markdown), but you can change this. Note
that this should be the file *extension* (without the dot), not the file *type*.

```vim
let g:noteworthy_file_ext = 'txt'
```

The plugin can automatically generate a title for new notes. Set this in your
`vimrc`.

```vim
let g:noteworthy_use_default_header = 1
```

Now if you call `:Note remember this`, a file called `remember_this.md` will be
created, and will be given the following header.

```markdown
# Remember This
```

If you want to define your own header-making command, you can create a string
containing commands to be `eval`'d and used as the header. For example, if you
want the title to be all upper-case instead of the default upper-case.

```vim
let g:noteworthy_header_command = "'# ' . toupper(l:title)"
```

This would make the header look like:

```markdown
# REMEMBER THIS
```

Note that you have access to the variables `l:file` and `l:title`, which will
resolve to the full file path to the current note, and the base file name with
any extension removed and underscores replaced by spaces, respectively. In other
words, if the current library is `/Users/me/notes`, and the note is
`things_to_remember.md`, then `l:file` would resolve to
`/Users/me/notes/things_to_remember.md`, and `l:title` would resolve to `things
to remember`.

### Commands
Create or edit a note with `:Note [subject...]`. The `subject` will be used as
the file name, and any spaces will be replaced by underscores. No file extension
is required.

```
:Note I need to remember this
:Note i_need_to_remember_this
:Note i_need_to_remember_this.md
```

Any one of the above commands will open a file in your current library called
`i_need_to_remember_this.md`. Tab-completion will list existing notes in the
library.

You can also use subdirectories, and they will be created if they don't exist.

```
:Note rails / remember this about rails
:Note rails/ remember_this_about_rails
:Note rails/remember_this_about_rails.md
```

Any one of the above commands will open a file called
`rails/remember_this_about_rails.md` in your current library.

To see which library is currently in use, call `:NoteLibrary`.

To change which library is being used, call `:NoteLibrary [library]`, where
`library` is a key from `g:noteworthy_libraries`. Tab-completion will list
available libraries.

## Issues and Feature Requests
This is a new project, and isn't feature-rich yet. I plan on doing a lot with
this plugin, so check the [issue
list](https://github.com/evanthegrayt/vim-noteworthy/issues) to see my ideas for
the future of it. Comments and feedback are more than welcome on the issues.

If you don't like a behavior, or would like a feature added, feel free to
[create an issue](https://github.com/evanthegrayt/vim-noteworthy/issues/new).
Just make sure the topic doesn't already exist.

## Self-Promotion
I do these projects for fun, and I enjoy knowing that they're helpful to people.
Consider starring [the
repository](https://github.com/evanthegrayt/vim-noteworthy) if you like it! If
you love it, follow me [on github](https://github.com/evanthegrayt)!
