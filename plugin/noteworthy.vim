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

command! -nargs=+ -range=0 -complete=custom,noteworthy#Completion Note
      \ call noteworthy#Note(<range>, <line1>, <line2>, <f-args>)

command! -range=0 -nargs=+ -complete=custom,noteworthy#Completion Vnote
      \ call noteworthy#Vnote(<range>, <line1>, <line2>, <f-args>)

command! -range=0 -nargs=+ -complete=custom,noteworthy#Completion Snote
      \ call noteworthy#Snote(<range>, <line1>, <line2>, <f-args>)

command! -range=0 -nargs=+ -complete=custom,noteworthy#Completion Tnote
      \ call noteworthy#Tnote(<range>, <line1>, <line2>, <f-args>)

command! -bang -nargs=? -complete=custom,noteworthy#LibraryCompletion NoteLibrary
      \ call noteworthy#Library(<bang>0, <f-args>)

command! -nargs=? NoteExtension call noteworthy#Extension(<f-args>)

command! NoteAmbiguousEnable let g:noteworthy_ambiguous = 1

command! NoteAmbiguousDisable let g:noteworthy_ambiguous = 0

command! -nargs=? NoteDelimiter call noteworthy#Delimiter(<f-args>)

command! -nargs=+ NoteSearch call noteworthy#Search(<f-args>)
