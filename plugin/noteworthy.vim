if exists('g:loaded_noteworthy') || &cp
  finish
endif
let g:loaded_noteworthy = 1

if exists('g:noteworthy_dynamic_libraries')
  augroup noteworthy
    autocmd!
    autocmd VimEnter,BufRead,DirChanged * call noteworthy#HandleDynamicLibraries()
  augroup END
endif

""
" :Note {topic}, ...
" Create or edit a note. Opens in current window.
command! -nargs=+ -range=0 -complete=custom,noteworthy#Completion Note
      \ call noteworthy#Note(<range> ? <line1> : 0, <range> ? <line2> : 0, <f-args>)

""
" :[N]VNote {topic}, ...
" Create or edit a note. Opens in vertical split, [N] columns wide (default:
" split current window in half)
command! -range=0 -nargs=+ -complete=custom,noteworthy#Completion Vnote
      \ call noteworthy#Vnote(<range> ? <line1> : 0, <range> ? <line2> : 0, <f-args>)

""
" :[N]SNote {topic}, ...
" Create or edit a note. Opens in split, [N] columns wide (default: split
" current window in half)
command! -range=0 -nargs=+ -complete=custom,noteworthy#Completion Snote
      \ call noteworthy#Snote(<range> ? <line1> : 0, <range> ? <line2> : 0, <f-args>)

""
" :TNote {topic}, ...
" Create or edit a note. Opens in new tab.
command! -range=0 -nargs=+ -complete=custom,noteworthy#Completion Tnote
      \ call noteworthy#Tnote(<range> ? <line1> : 0, <range> ? <line2> : 0, <f-args>)

""
" :NoteLibrary [{directory}]
" Show or change the current library.
command! -bang -nargs=? -complete=custom,noteworthy#LibraryCompletion NoteLibrary
      \ call noteworthy#Library(<bang>0, <f-args>)

""
" :NoteExtension {extension}
" Show or change the file extension used when creating/searching for notes.
command! -nargs=? NoteExtension call noteworthy#Extension(<f-args>)

""
" :NoteAmbiguousEnable
" Turn ambiguous completion on. Completion will search for *.*
command! NoteAmbiguousEnable let g:noteworthy_ambiguous = 1

""
" :NoteAmbiguousDisable
" Turn ambiguous completion off. Completion will search for *.ext, where ext
" is the result of g:noteworthy_file_ext
command! NoteAmbiguousDisable let g:noteworthy_ambiguous = 0

""
" :NoteDelimiter [{delimiter}]
" Show or change the current delimiter.
command! -nargs=? NoteDelimiter call noteworthy#Delimiter(<f-args>)

""
" :NoteSearch {pattern}
" Search for {pattern} in the current note library.
command! -nargs=+ NoteSearch call noteworthy#Search(<f-args>)
