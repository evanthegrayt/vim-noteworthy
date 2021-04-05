""
" Open/create a note.
function! noteworthy#Note(...) abort
  call s:File('edit', a:000)
endfunction

""
" Open/create a note in a new tab.
function! noteworthy#Tnote(...) abort
  call s:File('tabedit', a:000)
endfunction

""
" Open/create a note in a new split.
function! noteworthy#Snote(size, ...) abort
  let l:prefix = a:size ? a:size : get(g:, 'noteworthy_split_size', '')
  call s:File(l:prefix . 'split', a:000)
endfunction

""
" Open/create a note in a new vertical split.
function! noteworthy#Vnote(size, ...) abort
  let l:prefix = a:size ? a:size : get(g:, 'noteworthy_vsplit_size', '')
  call s:File(l:prefix . 'vsplit', a:000)
endfunction

""
" Completion for :NoteLibrary
function! noteworthy#LibraryCompletion(...) abort
  if !s:Validate() | return '' | endif
  return join(keys(g:noteworthy_libraries), "\n")
endfunction

""
" Adds the dynamic library to the list of libraries. If preferred, will
" automatically set current library to the dynamic library.
function! noteworthy#HandleDynamicLibraries() abort
  if has_key(g:noteworthy_dynamic_libraries, getcwd())
    let g:noteworthy_libraries[s:DynamicLibraryName()] =
          \ g:noteworthy_dynamic_libraries[getcwd()]
    if get(g:, 'noteworthy_prefer_dynamic')
      let g:noteworthy_current_library = s:DynamicLibraryName()
    endif
  else
    if get(g:, 'noteworthy_current_library') == s:DynamicLibraryName()
      unlet! g:noteworthy_current_library
    endif
    if has_key(g:noteworthy_libraries, s:DynamicLibraryName())
      unlet g:noteworthy_libraries[s:DynamicLibraryName()]
    endif
  endif
endfunction

""
" Completion for :Note.
function! noteworthy#Completion(arg_lead, cmd_line, cursor_pos) abort
  if !s:Validate() | return '' | endif
  let l:fext = get(g:, 'noteworthy_ambiguous') ? '*' : s:GetNoteFileExt()
  let l:dir = s:GetCurrentDirectory()
  if !isdirectory(l:dir) | return '' | endif
  let l:list = glob(l:dir . '**/*.' . l:fext, 0, 1)
  return join(map(l:list, "substitute(v:val, l:dir, '', '')"), "\n")
endfunction

""
" Call for :NoteLibrary. Decides if we're getting or setting, and calls the
" appropriate function.
function! noteworthy#Library(bang, ...) abort
  if !s:Validate() | return | endif
  if a:0
    if !s:SetCurrentLibrary(a:1) | return | endif
    let l:msg = 'Setting library to "' . a:1 . '"'
    if a:bang | let l:msg .= ' (' . g:noteworthy_libraries[a:1] . ')' | endif
  else
    let l:msg = 'Current library is set to "' . s:GetCurrentLibrary() . '"'
    if a:bang | let l:msg .= ' ('. s:GetCurrentDirectory() . ')' | endif
  endif
  echo l:msg
endfunction

""
" Search the note library for files containing pattern and populate the
" quickfix window with the results.
function! noteworthy#Search(pattern, ...) abort
  if !s:Validate() | return | endif
  let l:directory = s:GetCurrentDirectory()
  if a:0 | let l:directory .= a:1 . '/' | endif
  let l:directory .= '**/*.' . s:GetNoteFileExt()
  try
    exec 'vimgrep! /' . a:pattern . '/gj' . ' ' . l:directory
    botright copen
  catch
    call s:Error(
          \   "No results found for " . a:pattern . " in library "
          \   . g:noteworthy_current_library
          \ )
  endtry
endfunction

""
" Get or set the extension to use for notes.
function! noteworthy#Extension(...) abort
  if a:0
    echo 'Setting extension to "' . a:1 . '"'
    let g:noteworthy_file_ext = a:1
    return
  endif
  echo 'Current extension is set to "' .
        \ get(g:, 'noteworthy_file_ext', s:GetNoteFileExt()) . '"'
endfunction

""
" Get or set the delimiter to use for file names.
function! noteworthy#Delimiter(...) abort
  if a:0
    echo 'Setting delimiter to "' . a:1 . '"'
    let g:noteworthy_delimiter = a:1
    return
  endif
  echo 'Current delimiter is set to "' .
        \ get(g:, 'noteworthy_delimiter', s:GetNoteDelimiter()) . '"'
endfunction

" PRIVATE API

""
" The current library in use.
function! s:GetCurrentLibrary() abort
  if exists('g:noteworthy_current_library')
    return g:noteworthy_current_library
  endif
  call s:SetCurrentLibrary()
  return g:noteworthy_current_library
endfunction

""
" The directory of the current library in use.
function! s:GetCurrentDirectory() abort
  let l:library = s:GetCurrentLibrary()
  let l:dir = g:noteworthy_libraries[l:library]
  return resolve(expand(l:dir)) . '/'
endfunction

""
" Set the library.
function! s:SetCurrentLibrary(...) abort
  if !a:0 && !exists('g:noteworthy_default_library')
    call s:Error("'g:noteworthy_default_library' not set! " .
          \ 'Set in vimrc or use :NoteLibrary [LIBRARY]')
    return 0
  elseif a:0 && !has_key(g:noteworthy_libraries, a:1)
    call s:Error('Library [' . a:1 . '] does not exist!')
    return 0
  endif
  if a:0
    let g:noteworthy_current_library = a:1
  else
    if has_key(g:noteworthy_libraries, s:DynamicLibraryName()) &&
          \ get(g:, 'noteworthy_prefer_dynamic')
      let g:noteworthy_current_library = s:DynamicLibraryName()
    else
      let g:noteworthy_current_library = g:noteworthy_default_library
    endif
  endif
  return 1
endfunction

""
" Determines the file extension for notes.
function! s:GetNoteFileExt() abort
  return get(g:, 'noteworthy_file_ext', 'md')
endfunction

""
" Determines the file extension for notes.
function! s:GetNoteDelimiter() abort
  return get(g:, 'noteworthy_delimiter', '_')
endfunction

""
" Create or open a note in the current library.
function! s:File(command, segments) abort
  let l:delim = s:GetNoteDelimiter()
  let l:fext = s:GetNoteFileExt()
  let l:file = s:GetFileName(a:segments, l:delim)
  let l:basedir = fnamemodify(l:file, ':h')
  if !isdirectory(l:basedir) | call mkdir(l:basedir, 'p') | endif
  execute a:command l:file
  if getfsize(l:file) > 0 | return | endif
  let l:title = substitute(fnamemodify(l:file, ':t:r'), l:delim, ' ', 'g')
  if !get(g:, 'noteworthy_use_header', 1) | return | endif
  let l:formatted_title = s:GetFormattedTitle(l:title)
  call append(0, [l:formatted_title])
endfunction

function! s:GetFileName(segments, delim) abort
  let l:dir = s:GetCurrentDirectory()
  let l:fext = s:GetNoteFileExt()
  let l:regex = a:delim . '*\/' . a:delim . '*'
  let l:file = substitute(tolower(join(a:segments, a:delim)), l:regex, '/', 'g')
  if !get(g:, 'noteworthy_ambiguous') && l:file !~# '\.' . l:fext . '$'
    let l:file .= '.' . l:fext
  endif
  return l:dir . l:file
endfunction

function! s:GetFormattedTitle(title) abort
  if exists('g:noteworthy_header_command')
    return eval(g:noteworthy_header_command)
  endif
  return '# ' . substitute(a:title, '\<.', '\u&', 'g')
endfunction

function s:Deprecated(from, to) abort
  call s:Warn(a:from . ' is deprecated. Use ' . a:to . 'instead.')
endfunction

function! s:Warn(message) abort
  echohl WarningMsg | echo 'Noteworthy: ' . a:message | echohl None
endfunction

function! s:Error(message) abort
  echohl ErrorMsg | echomsg 'Noteworthy: ' . a:message | echohl None
endfunction

function! s:Validate(...) abort
  for l:variable in ['g:noteworthy_libraries', 'g:noteworthy_default_library']
    if !exists(l:variable)
      call s:Error(l:variable . ' not set.')
      let l:rc = 0
    endif
  endfor
  return get(l:, 'rc', 1)
endfunction

function! s:DynamicLibraryName() abort
  return get(g:, 'noteworthy_dynamic_library_name', 'dynamic')
endfunction
