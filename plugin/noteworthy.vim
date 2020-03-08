if (exists('g:loaded_noteworthy') && g:loaded_noteworthy) || &cp
  finish
endif
let g:loaded_noteworthy = 1

command! -nargs=+ -complete=custom,noteworthy#Completion
      \ Note call noteworthy#File(<f-args>)

" Default to show, switch if they pass an argument
command! -nargs=? -complete=custom,noteworthy#LibraryCompletion NoteLibrary call noteworthy#Library(<f-args>)
