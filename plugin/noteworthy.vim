if exists('g:loaded_noteworthy') || &cp
  finish
endif
let g:loaded_noteworthy = 1

""
" :Note
" Create or edit a note.
command! -nargs=+ -complete=custom,noteworthy#Completion
      \ Note call noteworthy#File(<f-args>)

""
" :NoteLibrary
" Show or change the current library.
command! -nargs=? -complete=custom,noteworthy#LibraryCompletion
      \ NoteLibrary call noteworthy#Library(<f-args>)
