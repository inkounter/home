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

" don't expand folds on searches, show only one result per collapsed fold.
set fdo-=search

" modify what's saved in a Session.vim
set ssop=folds,curdir,tabpages

" increase tabpagemax (default 10 tabs)
set tabpagemax=20

" Always show tabline
set showtabline=2

" filename autocomplete in normal mode
set wildmenu
set wildmode=full

" === KEYMAPS ===
" generic keymaps
nmap <silent><esc><esc> :noh<CR>
nmap <silent><C-t> :tabnew<CR>
nmap <silent><C-l> :tabnext<CR>:file<CR>
nmap <silent><C-h> :tabprevious<CR>:file<CR>
nmap <silent><C-k> :tabm +1<CR>
nmap <silent><C-j> :tabm -1<CR>

" circumvent '^E', as used by tmux
nmap <silent><C-g> <C-e>

" disable visual mode
nmap <silent>Q :redraw<CR>

" set whether whitespace is ignored when in diff mode
nmap <Bslash>s :set diffopt+=iwhite<CR>
nmap <Bslash>S :set diffopt-=iwhite<CR>

" FAT FINGERS
command -bang -nargs=* -complete=file E e<bang> <args>
command -bang -nargs=* -complete=file W w<bang> <args>
command -bang -nargs=* -complete=file Wq wq<bang> <args>
command -bang -nargs=* -complete=file WQ wq<bang> <args>
command -bang -nargs=* -complete=file Vsplit vsplit<bang> <args>
command -bang -nargs=* -complete=file Tabnew tabnew<bang> <args>
command -bang Wa wa<bang>
command -bang WA wa<bang>
command -bang Q q<bang>
command -bang QA qa<bang>
command -bang Qa qa<bang>

" Search for git merge conflicts
nmap <silent>@C /^\(<\\|=\\|>\)\{7\}<CR>

" Bind '^W + t' to open the file under the cursor in a new tab
nmap <C-w>t <C-w>gf

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

" Insert a line break after the next comma character and line up the values
" either:
": o at the latest previously-occurring open parentheses character that is
":   not matched before the found comma character, or
":
": o at the beginning of the line (after indentations).
function! CommaBreak()
    " Find the next comma character.
    normal f,
    if CurrentChar() != ','
        " There is no comma after the position we're in now. This function call
        " is a no-op.
        return
    endif
    let l:commaPos = getcurpos()

    " Find the latest open parenthesis character that is not matched before the
    " comma character.
    let l:openPos = l:commaPos
    while 1
        " Save the position of the open parenthesis character in the previous
        " loop iteration.
        let l:previousOpenPos = l:openPos

        normal F(
        let l:openPos = getcurpos()

        if l:openPos == l:previousOpenPos
            " There is not another open parenthesis character. Go to one
            " character before the beginning of the line.
            normal ^h
            break
        endif

        "Find the matching closing parenthesis character.
        normal %

        let l:closePos = getcurpos()

        if l:closePos == l:openPos
            " There is no matching parenthesis in the file. Break the loop.
            break
        endif

        if l:closePos[1] != l:openPos[1] || l:closePos[2] > l:commaPos[2]
            " The matching closing parenthesis is not on this line or is
            " after the comma. Go back to the opening parenthesis and break
            " the loop.
            normal %
            break
        endif

        " Go back to the opening parenthesis and continue looping.
        normal %
    endwhile

    " The cursor should now be in the column of the last space for the new line
    " to be inserted.
    let l:indentEnd = col('.')

    " Insert a line break after the comma.
    call setpos('.', l:commaPos)
    exe "normal a\<CR>\<esc>"

    " Fix the indentation. Delete into the black hole register.
    normal ^"_d0
    exe printf("normal %di ", l:indentEnd)
endfunction
nmap <silent>@< :call CommaBreak()<CR>

" Insert as many spaces as necessary before the current line to get the last
" character to land in the column right before the 'colorcolumn'.
function! AlignToEnd()
    " Calculate how many spaces need to be inserted at the start of the line.
    normal ^"_d0$
    let l:totalIndentCount = &cc - 1 - col('.')

    if l:totalIndentCount <= 0
        " This line is too long. Leave the line starting in column 1.
        return
    endif

    " Insert the spaces at the start of the line.
    normal 0
    exe printf("normal %di ", l:totalIndentCount)
    normal ^
endfunction
nmap <silent>gal :call AlignToEnd()<CR>

" Align the start of the current line with the start of the line below.
function! AlignWithBelow()
    normal j^

    let l:totalIndentCount = col('.') - 1

    " Insert the spaces at the start of the original line.
    normal k^"_d0
    exe printf("normal 0%di ", l:totalIndentCount)
    normal ^
endfunction
nmap <silent>gaj :call AlignWithBelow()<CR>

" Align the start of the current line with the start of the line above.
function! AlignWithAbove()
    normal k^

    let l:totalIndentCount = col('.') - 1

    " Insert the spaces at the start of the original line.
    normal j^"_d0
    exe printf("normal 0%di ", l:totalIndentCount)
    normal ^
endfunction
nmap <silent>gak :call AlignWithAbove()<CR>

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

    " Remove trailing '.t' or '.g' if applicable
    let fileBaseName = substitute(fileBaseName, '\.[tg]$', '', '')

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
        " Open the .h if this is a .cpp, .t.cpp, or .g.cpp
        exe printf('vsplit %s', fileBaseName . ".h")
    else
        exe printf('rightbelow vertical new %s', fileBaseName . ".cpp")
    endif
endfunction
command -nargs=* -complete=file Vsp call VsplitPair('<args>')

" open a [prefix].g.cpp (or [prefix].t.cpp, if it already exists) in a new tab
function! OpenTest()
    let fileBaseName = GetFileBaseName(@%)

    if filereadable(fileBaseName . ".t.cpp")
        exe printf('tabnew %s.t.cpp', fileBaseName)
    else
        exe printf('tabnew %s.g.cpp', fileBaseName)
    endif
endfunction
command -nargs=0 Test call OpenTest()

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

    " If we're in a git repo, find the top level of the repo or the lowest
    " level directory within the repo with a sentinel '.vimgrep' file.
    let searchDir = system('relativeDir="./"; git branch &>>/dev/null; while [[ $? -eq 0 && -z "$(ls .vimgrep 2>>/dev/null)" ]]; do relativeDir+="../"; cd ..; git branch &>>/dev/null; done; echo -n ${relativeDir%../}')

    let command = printf('grep -rIwn %s %s', currentWord, searchDir)

    exe printf('!echo \$ %s && %s', command, command)
endfunction
command -nargs=0 Grep call GrepCurrentWord()

" text insertions
command -nargs=0 Break exe "normal O<esc>d0i///////////////////////////////////////////////////////////////////////////////<esc>j"

set wildignore+=.git/*,*.pyc
for arch in [ 'amd64', 'solaris10-sparc', 'aix6-powerpc', 'feeds20-validate' ]
    exe "set wildignore+=*/build/" . arch
endfor

if filereadable(expand("~/.vim/environmentSpecific.vim"))
    source ~/.vim/environmentSpecific.vim
endif
