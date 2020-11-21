# Noteworthy
I'll often be coding in `vim`, and want to quickly write a note. I have places
where I store notes for myself, and it's not usually in the same repository I'm
coding in. I made this plugin to make this process easier.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Setup](#setup)
    - [Defining library locations](#defining-library-locations)
    - [Header generation](#header-generation)
    - [Custom header](#custom-header)
    - [Changing the default file extension](#changing-the-default-file-extension)
    - [Allow any file extension in tab-completion](#allow-any-file-extension-in-tab-completion)
    - [Set the default file name delimiter](#set-the-default-file-name-delimiter)
  - [Commands](#commands)
    - [Create or edit a note](#create-or-edit-a-note)
    - [Listing and changing libraries](#listing-and-changing-libraries)
    - [Changing the file extension](#changing-the-file-extension)
    - [Changing tab-completion globbing](#changing-tab-completion-globbing)
    - [Change the file name delimiter](#change-the-file-name-delimiter)
  - [Tips and recommended plugins](#tips-and-recommended-plugins)
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
#### Defining library locations
To get started, define a dictionary of libraries and their file paths in your
`vimrc`, and tell it which is the default to use. If a default is not set, you
will have to tell it which library to use each time you open a new `vim`
instance.

```vim
let g:noteworthy_libraries = {
    \   'personal': $HOME . '/notes',
    \   'work':     $HOME . '/my_project/docs/notes',
    \ }

let g:noteworthy_default_library = 'personal'
```

#### Header generation
The plugin can automatically generate a title for new notes. If you call `:Note
remember this`, a file called `remember_this.md` will be created, and will be
given the following header.

```markdown
# Remember This
```

To disable the header generation, set this in your `vimrc`.

```vim
let g:noteworthy_use_header = 0
```

#### Custom header
If you want to define your own header-making command, you can create a string
containing commands to be `eval`'d and used as the header. For example, if you
want the title to be all upper-case instead of the default upper-case.

```vim
let g:noteworthy_header_command = "'# ' . toupper(title)"
```

This would make the header look like:

```markdown
# REMEMBER THIS
```

Note that you have access to the variables `file` and `title`, which will
resolve to the full file path to the current note, and the base file name with
any extension removed and underscores replaced by spaces, respectively. In other
words, if the current library is `/Users/me/notes`, and the note is
`things_to_remember.md`, then `file` would resolve to
`/Users/me/notes/things_to_remember.md`, and `title` would resolve to `things
to remember`.

#### Changing the default file extension

The default file extension is 'md' (markdown), but you can change this. Note
that this should be the file *extension* (without the dot), not the file *type*.

```vim
let g:noteworthy_file_ext = 'txt'
```

#### Allow any file extension in tab-completion
The default glob for tab-completion is `*.ext`, where `ext` is the result of
`g:noteworthy_file_ext`. To change the glob to `*.*` (any file extension), set
the following in your `vimrc`. Note that when this option is set to true,
`g:noteworthy_file_ext` will not be automatically added if a new file has no
extension; you must add it yourself.

```vim
let g:noteworthy_ambiguous = 1
```

#### Set the default file name delimiter
The default delimiter for joining file names together is `_`. For example, if
you type the following:

```
:Note something to remember
```

The file name will be `something_to_remember.md`. To change the underscores to
something different, set the following variable in your `vimrc`.

```vim
let g:noteworthy_delimiter = '-'
```

### Commands
#### Create or edit a note
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

Note that `:Snote`, `:Vnote`, and `:Tnote` commands also exist. They behave the
same as `:Note`, except they open the note in a split, vertical split, and new
tab, respectively.

#### Listing and changing libraries
To see which library is currently in use, call `:NoteLibrary`.

To change which library is being used, call `:NoteLibrary [library]`, where
`library` is a key from `g:noteworthy_libraries`. Tab-completion will list
available libraries.

```
:NoteLibrary work
```

#### Changing the file extension
To change the file extension being used for note creation and tab-completion
globbing, call `:NoteExtension` and pass it the extension you'd like to use. If
no argument is passed, will display the current extension being used.

```
:NoteExtension txt
```

#### Changing tab-completion globbing
Commands are provided for changing the value of `g:noteworthy_ambiguous`.

```
:NoteAmbiguousEnable
:NoteAmbiguousDisable
```

#### Change the file name delimiter
Change the delimiter used to join the file name. If a delimiter is not passed,
the current delimiter being used will be displayed.

```
:NoteDelimiter -
```

### Tips and recommended plugins
If you have a lot of notes, you can use vim's built-in way to show all available
completions at once. You can trigger this by hitting `<c-d>` from command-line
mode.

If you're using Markdown as your primary file type (as is the default), I
recommend using the [Tagbar](https://github.com/preservim/tagbar) plugin with
[Tagbar Markdown](https://github.com/lvht/tagbar-markdown). This indexes the
page by headers, and makes it much easier to navigate large note files.

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
