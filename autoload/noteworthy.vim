""
" Entrypoint. Sets inital values, autocmd for handling dynamic libraries if
" any exist, and sets the library to the cached library if one exists.
function! noteworthy#Init() abort
  let s:app = {
        \   'cache_file': get(g:, 'noteworthy_cache_dir', $HOME . '/.cache/noteworthy') . '/notelibrary.txt',
        \   'dynamic_library_name': get(g:, 'noteworthy_dynamic_library_name', 'dynamic'),
        \   'prefer_dynamic': get(g:, 'noteworthy_prefer_dynamic'),
        \   'current_library': get(g:, 'noteworthy_default_library'),
        \   'auto_cache_library': get(g:, 'noteworthy_auto_cache_library'),
        \   'libraries': get(g:, 'noteworthy_libraries'),
        \   'split_size': get(g:, 'noteworthy_split_size', ''),
        \   'vsplit_size': get(g:, 'noteworthy_vsplit_size', ''),
        \   'dynamic_libraries': get(g:, 'noteworthy_dynamic_libraries', {}),
        \   'file_extension': get(g:, 'noteworthy_file_extension', 'md'),
        \   'ambiguous': get(g:, 'noteworthy_ambiguous'),
        \   'delimiter': get(g:, 'noteworthy_delimiter', '_'),
        \   'use_header': get(g:, 'noteworthy_use_header', 1),
        \   'use_code_block': get(g:, 'noteworthy_use_code_block', 1),
        \   'current_directory': function('s:GetCurrentDirectory'),
        \   'validate': function('s:Validate'),
        \   'file_name': function('s:GetFileName')
        \ }
  if !empty(s:app.dynamic_libraries)
    augroup noteworthy
      autocmd!
      autocmd VimEnter,BufRead,DirChanged * call <SID>HandleDynamicLibraries()
    augroup END
  endif
  if filereadable(s:app.cache_file)
    let l:library = readfile(s:app.cache_file)[0]
    if has_key(s:app.libraries, l:library)
      silent call noteworthy#Library(0, l:library)
    endif
  endif
endfunction

""
" Enable or disable ambiguous file extensions.
function! noteworthy#Ambiguous(enable_or_disable) abort
  let s:app.ambiguous = a:enable_or_disable
endfunction

""
" Create or open a note in the current library.
function! noteworthy#Open(command, file, range, line1, line2) abort
  let l:file = s:app.file_name(a:file, s:app.delimiter, 1)
  let l:basedir = fnamemodify(l:file, ':h')
  if a:range
    let l:lines = getline(a:line1, a:line2)
    if s:app.use_code_block
      let l:indent_level = s:GetIndentLevel(l:lines)
      let l:callback = "substitute(v:val, '\\s\\{" . l:indent_level . "}', '', '')"
      let l:lines = ['```' . &ft] + map(l:lines, l:callback) + ['```']
    endif
  endif
  if !isdirectory(l:basedir) | call mkdir(l:basedir, 'p') | endif
  execute get(s:app, a:command . '_size', '') . a:command l:file
  if s:app.use_header && getfsize(l:file) <= 0
    let l:title = substitute(fnamemodify(l:file, ':t:r'), s:app.delimiter, ' ', 'g')
    let l:func = exists('*NoteworthyHeader') ? 'NoteworthyHeader' : 's:Header'
    call append(0, call(l:func, [l:title, l:file]))
  endif
  if exists('l:lines')
    let l:last_line = trim(getline(line('$'))) == '' ? line('$') - 1 : line('$')
    call append(l:last_line, l:lines)
  endif
endfunction

""
" Completion for :NoteLibrary
function! noteworthy#LibraryCompletion(...) abort
  if !s:app.validate() | return '' | endif
  return join(keys(s:app.libraries), "\n")
endfunction

""
" Completion for :Note.
function! noteworthy#Completion(arg_lead, cmd_line, cursor_pos) abort
  if !s:app.validate() | return '' | endif
  let l:fext = s:app.ambiguous ? '*' : s:app.file_extension
  let l:dir = s:app.current_directory()
  if !isdirectory(l:dir) | return '' | endif
  let l:list = glob(l:dir . '**/*.' . l:fext, 0, 1)
  return join(map(l:list, "substitute(v:val, l:dir, '', '')"), "\n")
endfunction

""
" Call for :NoteLibrary. Decides if we're getting or setting, and calls the
" appropriate function.
function! noteworthy#Library(cache, ...) abort
  if !s:app.validate() | return | endif
  if a:0
    if !has_key(s:app.libraries, a:1)
      call s:Error(a:1 . ' is not a valid library')
      return
    endif
    let l:msg = 'Setting library to "' . a:1 . '"'
    if a:cache || s:app.auto_cache_library
      if a:1 == s:app.dynamic_library_name
        call s:Warn("Caching dynamic library.")
      endif
      call s:CacheLibrary(a:1)
    endif
    let s:app.current_library = a:1
  else
    let l:msg = 'Current library is set to "' . s:app.current_library . '"'
    if a:cache
      if filereadable(s:app.cache_file) | call delete(s:app.cache_file) | endif
    endif
  endif
  echo l:msg
endfunction

""
" Search the note library for files containing pattern and populate the
" quickfix window with the results.
function! noteworthy#Search(pattern, ...) abort
  if !s:app.validate() | return | endif
  let l:directory = s:app.current_directory()
  if a:0 | let l:directory .= a:1 . '/' | endif
  let l:directory .= '**/*.' . s:app.file_extension
  try
    exec 'vimgrep! /' . a:pattern . '/gj' . ' ' . l:directory
    botright copen
  catch
    call s:Error(
          \   "No results found for " . a:pattern . " in library "
          \   . s:app.current_library
          \ )
  endtry
endfunction

""
" Get or set the extension to use for notes.
function! noteworthy#Extension(...) abort
  if !a:0
    echo 'Current extension is set to "' . s:app.file_extension . '"'
    return
  endif
  echo 'Setting extension to "' . a:1 . '"'
  let s:app.file_extension = a:1
endfunction

""
" Get or set the delimiter to use for file names.
function! noteworthy#Delimiter(...) abort
  if a:0
    echo 'Setting delimiter to "' . a:1 . '"'
    let s:app.delimiter = a:1
    return
  endif
  echo 'Current delimiter is set to "' . s:app.delimiter . '"'
endfunction

" PRIVATE API

""
" Adds the dynamic library to the list of libraries. If preferred, will
" automatically set current library to the dynamic library.
function! s:HandleDynamicLibraries() abort
  if has_key(s:app.dynamic_libraries, getcwd())
    let s:app.libraries[s:app.dynamic_library_name] =
          \ s:app.dynamic_libraries[getcwd()]
    if s:app.prefer_dynamic
      let s:app.current_library = s:app.dynamic_library_name
    endif
  else
    if s:app.current_library == s:app.dynamic_library_name
      unlet! s:app.current_library
    endif
    if has_key(s:app.libraries, s:app.dynamic_library_name)
      unlet s:app.libraries[s:app.dynamic_library_name]
    endif
  endif
endfunction

function! s:GetFileName(file, delim, directory) abort dict
  let l:segments = split(a:file)
  let l:dir = s:app.current_directory()
  let l:fext = s:app.file_extension
  let l:regex = a:delim . '*\/' . a:delim . '*'
  let l:file = substitute(tolower(join(l:segments, a:delim)), l:regex, '/', 'g')
  let l:file = substitute(l:file, '_\.' . l:fext . '$', '.' . l:fext, '')
  if !s:app.ambiguous && l:file !~# '\.' . l:fext . '$'
    let l:file .= '.' . l:fext
  endif
  if a:directory | let l:file = l:dir . l:file | endif
  return l:file
endfunction

function! s:Header(title, file) abort
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

function! s:CacheLibrary(library) abort
  let l:dir = fnamemodify(s:app.cache_file, ':h')
  if !isdirectory(l:dir) | call mkdir(l:dir, 'p') | endif
  let l:text = [a:library]
  call writefile(l:text, s:app.cache_file)
endfunction

function! s:GetIndentLevel(lines) abort
  let l:indent_levels = []
  for l:string in a:lines
    if empty(trim(l:string)) | continue | endif
    call add(l:indent_levels, match(l:string, '^\s*\zs'))
  endfor
  return min(l:indent_levels)
endfunction

""
" The directory of the current library in use.
function! s:GetCurrentDirectory() abort dict
  return resolve(expand(s:app.libraries[self.current_library])) . '/'
endfunction
