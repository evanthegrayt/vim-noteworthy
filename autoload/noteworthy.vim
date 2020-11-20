function! noteworthy#Note(...) abort
  call s:File('edit', a:000)
endfunction

function! noteworthy#Tnote(...) abort
  call s:File('tabe', a:000)
endfunction

function! noteworthy#Snote(...) abort
  call s:File('split', a:000)
endfunction

function! noteworthy#Vnote(...) abort
  call s:File('vert split', a:000)
endfunction

""
" Call for :NoteLibrary. Decides if we're getting or setting, and calls the
" appropriate function.
function! noteworthy#Library(...) abort
  if a:0
    call s:SetCurrentLibrary(a:1)
    echo 'Setting library to [' . a:1 . ']'
    return
  endif

  call s:GetCurrentLibrary()
  echo 'Current library is set to [' . g:noteworthy_current_library . ']'
endfunction

""
" Completion for :NoteLibrary
function! noteworthy#LibraryCompletion(...) abort
  return join(keys(g:noteworthy_libraries), "\n")
endfunction

""
" Completion for :Note.
function! noteworthy#Completion(arg_lead, cmd_line, cursor_pos) abort
  let l:file_ext = get(g:, 'noteworthy_ambiguous', 0) ? '*' : s:GetNoteFileExt(1)
  let l:dir = s:GetCurrentLibrary()

  if !isdirectory(l:dir) | return '' | endif

  let l:olddir = chdir(l:dir)
  let l:list = glob('**/*.' . l:file_ext, 0, 1)
  call chdir(l:olddir)

  return join(l:list, "\n")
endfunction

function! noteworthy#Extension(...) abort
  if a:0
    let g:noteworthy_file_ext = a:1
  else
    echo get(g:, 'noteworthy_file_ext', s:GetNoteFileExt())
  endif
endfunction

" PRIVATE API

""
" The current library in use.
function! s:GetCurrentLibrary()
  if !exists('g:noteworthy_libraries')
    call s:Error("'g:noteworthy_libraries' is not set!")
    return 0
  elseif exists('g:noteworthy_current_library')
    let l:dir = g:noteworthy_libraries[g:noteworthy_current_library]
  elseif !exists('g:noteworthy_default_library')
    call s:Error("'g:noteworthy_default_library' not set! " .
          \ 'Set in vimrc or use :NoteLibrary [LIBRARY]')
    return 0
  else
    call s:SetCurrentLibrary(g:noteworthy_default_library)
    let l:dir = g:noteworthy_libraries[g:noteworthy_default_library]
  endif

  return resolve(expand(l:dir)) . '/'
endfunction

""
" Set the library.
function! s:SetCurrentLibrary(library) abort
  if !has_key(g:noteworthy_libraries, a:library)
    s:Error('Key [' . a:library . '] does not exist!')
    return 0
  endif

  let g:noteworthy_current_library = a:library
  return 1
endfunction

""
" Determines the file extension for notes.
function! s:GetNoteFileExt(...) abort
  return get(g:, 'noteworthy_file_ext', 'md')
endfunction

function s:Deprecated(from, to) abort
  call s:Warn(a:from . ' is deprecated. Use ' . a:to . 'instead.')
endfunction

function! s:Warn(message) abort
  echohl WarningMsg | echo 'Noteworthy: ' . a:message | echohl None
endfunction

function! s:Error(message) abort
  echohl ErrorMsg | echo 'Noteworthy: ' . a:message | echohl None
endfunction

""
" Create or open a note in the current library.
function! s:File(command, segments) abort
  let l:dir = s:GetCurrentLibrary()
  let l:file_ext = s:GetNoteFileExt()
  let l:file = l:dir . substitute(tolower(join(a:segments, '_')), "_*\/_*", "/", 'g')

  if l:file !~#  '\.' . l:file_ext . '$'
    let l:file = l:file . '.' . l:file_ext
  endif

  let l:basedir = fnamemodify(l:file, ':h')
  if !isdirectory(l:basedir) | call mkdir(l:basedir, 'p') | endif
  execute a:command l:file

  if getfsize(l:file) > 0 | return | endif
  let l:title = substitute(fnamemodify(l:file, ':t:r'), '_', ' ', 'g')

  if exists('g:noteworthy_use_header') && !g:noteworthy_use_header
    return
  elseif exists('g:noteworthy_header_command')
    let l:title = eval(g:noteworthy_header_command)
  else
    let l:title = '# ' . substitute(l:title, '\<.', '\u&', 'g')
  endif

  call append(0, [l:title])
endfunction
