if exists('g:loaded_noteworthy') || &cp
  finish
endif
let g:loaded_noteworthy = 1

call noteworthy#Init()

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Note
      \ call noteworthy#Open('edit', <f-args>, <range>, <line1>, <line2>)

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Vnote
      \ call noteworthy#Open('vsplit', <f-args>, <range>, <line1>, <line2>)

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Snote
      \ call noteworthy#Open('split', <f-args>, <range>, <line1>, <line2>)

command! -range=0 -nargs=1 -complete=custom,noteworthy#Completion Tnote
      \ call noteworthy#Open('tabedit', <f-args>, <range>, <line1>, <line2>)

command! -bang -nargs=? -complete=custom,noteworthy#LibraryCompletion NoteLibrary
      \ call noteworthy#Library(<bang>0, <f-args>)

command! -nargs=? NoteExtension call noteworthy#Extension(<f-args>)

command! NoteAmbiguousEnable call noteworthy#Ambiguous(1)

command! NoteAmbiguousDisable call noteworthy#Ambiguous(0)

command! -nargs=? NoteDelimiter call noteworthy#Delimiter(<f-args>)

command! -nargs=+ NoteSearch call noteworthy#Search(<f-args>)
