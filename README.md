# Noteworthy
Note-taking is a practice that every good developer should employ, so why should
the process be tedious? Noteworthy provides a very quick and painless way to
create, open, and search through notes that are kept in predefined places. Works
with both static and project-specific libraries.

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
`vimrc`, and tell it which is the default to use.

```vim
let g:noteworthy_libraries = {
    \   'personal': $HOME . '/notes',
    \   'work':     $HOME . '/my_project/docs/notes',
    \ }

let g:noteworthy_default_library = 'personal'
```

##### Project-specific/dynamic libraries
You can define a dictionary of directories and their corresponding relative
library locations.

```vim
let g:noteworthy_dynamic_libraries = {
      \   '/home/me/project1': 'doc/notes',
      \   '/home/me/directory/project2': 'notes'
      \ }
```

When a file is opened, and the current directory is a key in
this dictionary, that library will be accessible with `:NoteLibrary dynamic`.
The name `dynamic` can be changed with `g:noteworthy_dynamic_library_name`.

```vim
" To make the dynamic library callable with `:NoteLibrary project`
let g:noteworthy_dynamic_library_name = 'project'
```

Because this library is not always available, it shouldn't be used as
`g:noteworthy_default_library`. If you would like the dynamic library to be the
default *when it's available*, you can set `g:noteworthy_prefer_dynamic` to
true.

```vim
let g:noteworthy_prefer_dynamic = 1
```

When set, any time a file is opened in, or the directory is changed to, a key in
the dictionary, it will automatically be set as the default library.

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
If you want to define your own header-making function, you can define a function
called `NotewothyHeader` that takes two arguments -- `title` and `file` -- which
will resolve to the base file name with any extension removed and underscores
replaced by spaces, and the full file path to the current note, respectively. In
other words, if the current library is `/Users/me/notes`, and the note is
`things_to_remember.md`, then `title` would resolve to `things to remember`, and
`file` would resolve to `/Users/me/notes/things_to_remember.md`.

```vim
function! NoteworthyHeader(title, file) abort
  return '# ' . toupper(a:title)
endfunction
```

This would make the header look like the following.

```markdown
# REMEMBER THIS
```

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

#### Change the default window height for splits

You can change the default window height for splits. The default is to split the
current window in half.

```vim
let g:noteworthy_split_size = 30
```

#### Change the default window width for vsplits

You can change the default window width for vertical splits. The default is to
split the current window in half.

```vim
let g:noteworthy_vsplit_size = 80
```

### Commands
#### Create or edit a note
Create or edit a note with `:Note SUBJECT...`. The `SUBJECT` will be used as
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

If called with a range (or a visual selection), the corresponding lines of your
current file will be appended to the note being edited. By default, the copied
text will be wrapped in a markdown code block with the file type. This can be
disabled by setting `g:noteworthy_use_code_block = 0`.

Note that `:Snote`, `:Vnote`, and `:Tnote` commands also exist. They behave the
same as `:Note`, except they open the note in a split, vertical split, and new
tab, respectively.

#### Searching the Current Library
You can search for a pattern in the current note library with the `:NoteSearch`
command, and the matches will be placed into the quickfix list. Note that if
your `PATTERN` contains a space, it must be escaped, or it will be recognized as
a multiple arguments. To scope the results to a specific subdirectory in the
library, pass the optional `SUBDIRECTORY` argument.

```
:NoteSearch PATTERN [SUBDIRECTORY]
```

This is basically just a wrapper for `:vimgrep`, so you are free to use regular
expressions. Note that very-magic mode is not enabled by default, but you can
prepend your search pattern with `\v` to enable it.

#### Listing and changing libraries
To see which library is currently in use, call `:NoteLibrary` with no arguments.

To change which library is being used, call `:NoteLibrary [LIBRARY]`, where
`LIBRARY` is a key from `g:noteworthy_libraries`. Tab-completion will list
available libraries.

```
:NoteLibrary work
```

When called with a `!` and a library, that library is cached so that next time
vim is opened, it will be the current library being used. When called with `!`
and no library, the cache is cleared. The directory used to store the cache is
`~/.cache/noteworthy` by default. This can be changed with
`g:noteworthy_cache_dir`.

```vim
let g:noteworthy_cache_dir = $HOME . '/.vim/cache/noteworthy'
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
This is a new project, and I plan on doing a lot with it, so check the [issue
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
