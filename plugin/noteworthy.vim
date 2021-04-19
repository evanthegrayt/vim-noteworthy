if exists('g:loaded_noteworthy') || &cp
  finish
endif
let g:loaded_noteworthy = 1

call noteworthy#Init()

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Note
      \ call noteworthy#Note(<range>, <line1>, <line2>, <f-args>)

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Vnote
      \ call noteworthy#Vnote(<range>, <line1>, <line2>, <f-args>)

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Snote
      \ call noteworthy#Snote(<range>, <line1>, <line2>, <f-args>)

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Tnote
      \ call noteworthy#Tnote(<range>, <line1>, <line2>, <f-args>)

command! -bang -nargs=? -complete=custom,noteworthy#LibraryCompletion NoteLibrary
      \ call noteworthy#Library(<bang>0, <f-args>)

command! -nargs=? NoteExtension call noteworthy#Extension(<f-args>)

command! NoteAmbiguousEnable let g:noteworthy_ambiguous = 1

command! NoteAmbiguousDisable let g:noteworthy_ambiguous = 0

command! -nargs=? NoteDelimiter call noteworthy#Delimiter(<f-args>)

command! -nargs=+ NoteSearch call noteworthy#Search(<f-args>)
