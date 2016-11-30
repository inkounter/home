syntax on

"Information on the following setting can be found with
":help set
set tabstop=4
set softtabstop=4
set expandtab
set autoindent 
set shiftwidth=4  "this is the level of autoindent, adjust to taste
set ruler
set backspace=indent,eol,start
set visualbell

" Uncomment below to make screen not flash on error
set vb t_vb=

colorscheme default
set hlsearch
"set incsearch
set t_Co=8
hi Comment ctermfg=6
hi Normal ctermfg=7
hi SpecialKey ctermbg=6
set nonumber
set colorcolumn=80
hi ColorColumn ctermbg=4
set matchpairs+=<:>

" modify what's saved in a Session.vim
set ssop=folds,curdir,tabpages

" increase tabpagemax (default 10 tabs)
set tabpagemax=20

" filename autocomplete in normal mode
set wildmenu
set wildmode=full

" Keymaps
nmap <silent><esc><esc> :noh<CR>
nmap <silent><C-t> :tabnew<CR>
nmap <silent><C-l> :tabnext<CR>
nmap <silent><C-h> :tabprevious<CR>
nmap <silent><C-k> :tabm +1<CR>
nmap <silent><C-j> :tabm -1<CR>

" FAT FINGERS
command -bang -nargs=* -complete=file E e<bang> <args>
command -bang -nargs=* -complete=file W w<bang> <args>
command -bang -nargs=* -complete=file Wq wq<bang> <args>
command -bang -nargs=* -complete=file WQ wq<bang> <args>
command -bang -nargs=* -complete=file Vsplit vsplit<bang> <args>
command -bang Wa wa<bang>
command -bang WA wa<bang>
command -bang Q q<bang>
command -bang QA qa<bang>
command -bang Qa qa<bang>

function! CurrentChar()
    return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

" Get the binary value of the currently hovered-over character
function! GetBinaryValue()
    let l:binaryValue = char2nr(CurrentChar())

    " Newlines characters are indistinguishable from null bytes in vimscript.
    if l:binaryValue == 10
        return 0
    else
        return l:binaryValue
    endif
endfunction
" Print the binary value as returned above in decimal/hex formats
command -nargs=0 Dec echom "Decimal value: " . GetBinaryValue()
command -nargs=0 Hex echom "Hex value: 0x" . printf("%02X", GetBinaryValue())

" save in binary mode without an EOL character
function! WriteBinary()
	set binary
	set noeol
	w
	set nobinary
endfunction
command -nargs=0 Wb call WriteBinary()

" Insert a line break at the next occurrence of a comma character and line up
" the values either at the previous occurrence of an open parentheses character
" or at the beginning of the line (after indentations).
function! CommaBreak()
    " Get the column to which the following line will need to be indented.
    normal f,
    if CurrentChar() != ','
        " There is no comma after the position we're in now. This function call
        " is a no-op.
        return
    endif
    let l:currentPos = col('.')

    normal F(
    if col('.') == l:currentPos
        " There is no '(' character earlier in the line. Go to one character
        " before the beginning of the line.
        normal ^h
    endif

    let l:indentEnd = col('.')

    " Insert a line break after the next comma.
    exe "normal f,a\<CR>\<esc>"

    " Fix the indentation.
    normal ^"_d0
    exe printf("normal %di ", l:indentEnd)
endfunction
nmap <silent>@< :call CommaBreak()<CR>

" clear undo history
function! ClearUndo()
    let old_undolevels = &undolevels
    set undolevels=-1
    exe "normal a \<BS>\<esc>"
    let &undolevels = old_undolevels
    unlet old_undolevels
endfunction
command -nargs=0 Clear call ClearUndo()

function! GetFileBaseName(fullName)
    " Remove the file extension (e.g. '.cpp', '.h')
    let fileBaseName = matchstr(a:fullName, '.*\%(\.[^.]*$\)\@=')

    " Remove trailing '.t' if applicable
    let fileBaseName = substitute(fileBaseName, '\.t$', '', '')

    return fileBaseName
endfunction

" open a [prefix].h alongside [prefix].cpp
function! VsplitPair(name)
    let fileFullName = a:name

    if strlen(fileFullName) == 0
        let fileFullName = @%
    endif

    let fileBaseName = GetFileBaseName(fileFullName)

    let fileExtension = matchstr(fileFullName, '\.[^.]*$', '', '')

    if fileExtension == '.cpp'
        " Open the .h if this is a .cpp or a .t.cpp
        exe printf('vsplit %s', fileBaseName . ".h")
    else
        exe printf('rightbelow vertical new %s', fileBaseName . ".cpp")
    endif
endfunction
command -nargs=* -complete=file Vsp call VsplitPair('<args>')

" open a [prefix].t.cpp in a new tab
function! OpenTest()
    let fileBaseName = GetFileBaseName(@%)

    exe printf('tabnew %s.t.cpp', fileBaseName)
endfunction
command -nargs=0 Test call OpenTest()
command -nargs=0 Tests call OpenTest()

" vimdiff files
function! Diff(file1, file2)
    exe printf('e %s', a:file2)
    difft
    exe printf('vsplit %s', a:file1)
    difft
endfunction
command -nargs=* Diff call Diff(<f-args>)

" execute the file currently being edited
command -nargs=* Run !%:p '<args>'

" grep for current word
function! GrepCurrentWord()
    let currentWord = expand("<cword>")
    exe printf('!grep -rIw %s $(if [ -n "$(echo $(pwd) | grep unittest)" ]; then echo ".."; else echo "."; fi)', currentWord)
endfunction
command -nargs=0 Grep call GrepCurrentWord()

" text insertions
command -nargs=0 Break exe "normal O<esc>d0i///////////////////////////////////////////////////////////////////////////////<esc>j"

if filereadable(expand("~/.vim/environmentSpecific"))
    source ~/.vim/environmentSpecific
endif
