""
" The current library in use.
function! noteworthy#GetCurrentLibrary()
  if !exists('g:noteworthy_libraries')
    call s:Error("'g:noteworthy_libraries' no set!")
    return 0
  elseif exists('g:noteworthy_current_library')
    let l:dir = g:noteworthy_libraries[g:noteworthy_current_library]
  elseif !exists('g:noteworthy_default_library')
    call s:Error("'g:noteworthy_default_library' not set! " .
          \ 'Set in vimrc or use :NoteLibrary [LIBRARY]')
    return 0
  else
    call noteworthy#SetCurrentLibrary(g:noteworthy_default_library)
    let l:dir = g:noteworthy_libraries[g:noteworthy_default_library]
  endif

  return resolve(expand(l:dir)) . '/'
endfunction

""
" Create or open a note in the current library.
function! noteworthy#File(...) abort
  let l:dir = noteworthy#GetCurrentLibrary()
  let l:file_type = s:GetNoteFileType()
  let l:file = l:dir . tolower(join(a:000, '_'))

  if l:file !~#  '\.' . l:file_type . '$'
    let l:file = l:file . '.' . l:file_type
  endif

  let l:basedir = fnamemodify(l:file, ':h')
  if !isdirectory(l:basedir) | call mkdir(l:basedir, 'p') | endif
  execute 'edit' l:file

  if getfsize(l:file) > 0 | return | endif
  let l:title = substitute(fnamemodify(l:file, ':t:r'), '_', ' ', 'g')

  if exists('g:noteworthy_use_default_header') && g:noteworthy_use_default_header
    let l:title = '# ' . substitute(l:title, '\<.', '\u&', 'g')
  elseif exists('g:noteworthy_header_command')
    let l:title = eval(g:noteworthy_header_command)
  else
    return
  endif

  call append(0, [l:title])
endfunction

function! noteworthy#SetCurrentLibrary(library) abort
  if !has_key(g:noteworthy_libraries, a:library)
    s:Error('Key [' . a:library . '] does not exist!')
    return 0
  endif

  let g:noteworthy_current_library = a:library
  return 1
endfunction

function! noteworthy#Completion(arg_lead, cmd_line, cursor_pos) abort
  let l:dir = noteworthy#GetCurrentLibrary()

  if !isdirectory(l:dir) | return '' | endif

  let l:olddir = chdir(l:dir)
  let l:list = glob('**/*.md', 0, 1)

  call chdir(l:olddir)
  return join(l:list, "\n")
endfunction

function! noteworthy#Library(...) abort
  if a:0 == 0
    call noteworthy#GetCurrentLibrary()
    echo 'Current library set to [' . g:noteworthy_current_library . ']'
    return
  endif

  call noteworthy#SetCurrentLibrary(a:1)
  echo 'Setting library to [' . a:1 . ']'
endfunction

function! noteworthy#LibraryCompletion(...) abort
  return join(keys(g:noteworthy_libraries), "\n")
endfunction

" PRIVATE API

function! s:Warn(msg) abort
  echohl WarningMsg | echomsg 'NoteWorthy: ' . a:message | echohl None
endfunction

function! s:Error(msg) abort
  echohl ErrorMsg | echomsg 'NoteWorthy: ' . a:message | echohl None
endfunction

function! s:GetNoteFileType() abort
  if exists('g:noteworthy_file_type') | return g:noteworthy_file_type | endif

  return 'md'
endfunction
