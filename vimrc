"" Kang Seonghoon's .vimrc file (2010-01-05)
"" This file is placed in the public domain.
"" Recent version of this file is always available at:
""     http://hg.mearie.org/private/settings-vim/
"" =========================================================

scripte utf-8
set nocp all&

" CUSTOMIZING by hodduc {{{ --------------------------------

" Force terminal to use 256color (to use powerline)
set term=xterm-256color
" Vim Bundle Installation

set nocompatible
filetype on
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

" UI integration
Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim'}
Bundle 'fholgado/minibufexpl.vim'
Bundle 'scrooloose/nerdtree'
Bundle 'ervandew/supertab'
Bundle 'mileszs/ack.vim'

" color schemes
Bundle 'molokai'
Bundle 'altercation/vim-colors-solarized'

" git integration
Bundle 'tpope/vim-fugitive'

let g:Powerline_symbols = 'fancy'

filetype plugin indent on

" CUSTOMIZING end }}} -------------------------------------

" UTILITY FUNCTIONS {{{ ------------------------------------
" maps key to the command in insert, normal, and (if vmap=1) visual mode
fu! s:Map(key, value, vmap)
	exe 'imap <silent> ' . a:key . ' <C-\><C-O>' . a:value
	exe 'nmap <silent> ' . a:key . ' ' . a:value
	if a:vmap | exe 'vmap <silent> ' . a:key . ' <Esc>' . a:value . 'gv' | endif
endf

" maps two keys to the command if needed. used for mac's Command key
fu! s:Map2(key1, key2, value, vmap)
	call s:Map(a:key1, a:value, a:vmap)
	if has("macunix") | call s:Map(a:key2, a:value, a:vmap) | endif
endf

" maps key to the function
fu! s:MapFunc(key, fname, vmap)
	call s:Map(a:key, ':call <SID>' . a:fname . '()<CR>', a:vmap)
endf

" creates the directory if not exists
fu! s:MakeDir(path)
	if glob(a:path) == ''
		try
			call mkdir(a:path, 'p')
		catch /^Vim(mkdir):/
		endtry
	endif
endf
" }}} ------------------------------------------------------

" TERMINAL {{{ ---------------------------------------------
if &term =~ "xterm"
	set t_Co=8
	if has("terminfo")
		let &t_Sf = "\<Esc>[3%p1%dm"
		let &t_Sb = "\<Esc>[4%p1%dm"
	else
		let &t_Sf = "\<Esc>[3%dm"
		let &t_Sb = "\<Esc>[4%dm"
	endif
endif

" terminal encoding (always use utf-8 if possible)
if !has("win32") || has("gui_running")
	set enc=utf-8 tenc=utf-8
	if has("win32")
		set tenc=cp949
		let $LANG = substitute($LANG, '\(\.[^.]\+\)\?$', '.utf-8', '')
	endif
endif
if &enc ==? "euc-kr"
	set enc=cp949
endif
" }}} ------------------------------------------------------

" EDITOR {{{ -----------------------------------------------
set nu ru sc wrap ls=2 lz                " -- appearance
set noet bs=2 ts=8 sw=8 sts=0            " -- tabstop
set noai nosi hls is ic cf ws scs magic  " -- search
set sol sel=inclusive mps+=<:>           " -- moving around
set ut=10 uc=200                         " -- swap control
set report=0 lpl wmnu                    " -- misc.

" encoding and file format
set fenc=utf-8 ff=unix ffs=unix,dos,mac
set fencs=utf-8,cp949,cp932,euc-jp,shift-jis,big5,latin2,ucs2-le

" list mode
set nolist lcs=extends:>,precedes:<
if &tenc ==? "utf-8"
	set lcs+=tab:»\ ,trail:·
else
	set lcs+=tab:\|\ 
endif
" }}} ------------------------------------------------------

" TEMPORARY/BACKUP DIRECTORY {{{ ---------------------------
set swf nobk bex=.bak
if exists("$HOME")
	" makes various files written into ~/.vim/ or ~/_vim/
	let s:home_dir = substitute($HOME, '[/\\]$', '', '')
	if has("win32")
		let s:home_dir = s:home_dir . '/_vim'
	else
		let s:home_dir = s:home_dir . '/.vim'
	endif
	if exists('*mkdir') && v:version >= 700
		" automatically create directories for first time
		call s:MakeDir(s:home_dir)
		call s:MakeDir(s:home_dir . '/tmp')
		call s:MakeDir(s:home_dir . '/backup')
	endif
	if isdirectory(s:home_dir)
		let &dir = s:home_dir . '/tmp,' . &dir
		let &bdir = s:home_dir . '/backup,' . &bdir
		let &vi = &vi . ',n' . s:home_dir . '/viminfo'
	endif
endif
" }}} ------------------------------------------------------

" KEY MAPPING {{{ ------------------------------------------
set wak=no                          " -- no alt menu mapping
set noto ttimeout tm=3000 ttm=100   " -- input timeout
let mapleader = '\'

" moving around and editing
map <MiddleMouse> <Nop>
map! <MiddleMouse> <Nop>
vmap <Tab> >gv
vmap <S-Tab> <gv
fu! s:HomeKey() " -- home key correction
	let l:column = col('.') | exe "norm ^"
	if l:column == col('.') | exe "norm 0" | endif
endf
call s:MapFunc('<Home>', 'HomeKey', 0)

" switching around buffer
map <F11> :bn<CR>
map <F12> :bN<CR>
if has("macunix")
	map <D-F11> :bn<CR>
	map <D-F12> :bN<CR>
endif

" make search appears in the middle of the screen
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

" immediate buffer configuration
map <silent> <Leader>n :let &nu = 1 - &nu<CR>
map <silent> <Leader>l :let &list = 1 - &list<CR>
map <silent> <Leader>p :let &paste = 1 - &paste<CR>
map <silent> <Leader>w :let &wrap = 1 - &wrap<CR>
nmap <silent> <Leader>1 :set ts=1 sw=1<CR>
nmap <silent> <Leader>2 :set ts=2 sw=2<CR>
nmap <silent> <Leader>4 :set ts=4 sw=4<CR>
nmap <silent> <Leader>8 :set ts=8 sw=8<CR>

" editing and applying .vimrc
if has("win32")
	nmap <silent> <Leader>R :so $HOME/_vimrc<CR>
	nmap <silent> <Leader>rc :e $HOME/_vimrc<CR>
else
	nmap <silent> <Leader>R :so $HOME/.vimrc<CR>
	nmap <silent> <Leader>rc :e $HOME/.vimrc<CR>
endif

" inserting matching quotes
fu! s:InputQuotes()
	if mode() == "R"
		exe "normal \<Esc>" | return ""   " -- beep
	elseif match(getline("."), '\%u2018\%'.col('.').'c\%u2019') < 0
		return "\u2018\u2019\<Insert>\<BS>\<Insert>"
	else
		return "\<Del>\<BS>\u201c\u201d\<Insert>\<BS>\<Insert>"
	endif
endf
imap <silent> <C-'> <C-R>=<SID>InputQuotes()<CR>

" misc. mapping
nmap <silent> <Leader>cd :cd %:p:h<CR>
nmap <silent> <Leader><Space> :noh<CR>
" }}} ------------------------------------------------------

" ABBRIVATION {{{ ------------------------------------------
if has("digraphs")
	dig +< 12296 >+ 12297 <+ 12298 +> 12299
endif
" }}} ------------------------------------------------------

" GUI {{{ --------------------------------------------------
if has("gui_running")
	set go+=c go-=t go-=m go-=T sel=inclusive
	set lines=40 co=100 lsp=0
	set mouse=a  " --TODO
	colo desert
	if has("transparency")
		set transp=5
	endif

	" font fix
	if has("win32")
		silent! set gfn=Raize:h10 gfw=DotumChe:h11 lsp=-1
		silent! set gfn=NanumGothicCoding:h10 gfw= lsp=0
	elseif has("macunix")
		silent! set macatsui gfn=Monaco:h12 gfw=AppleGothic\ Regular:h13
		silent! set gfn=NanumGothicCoding:h13 gfw= lsp=1
	endif

	" toggle menubar
	fu! s:MenuBar()
		if stridx(&go, 'm') == -1
			set go+=T go+=m
		else
			set go-=T go-=m
		endif
	endf
	call s:MapFunc('<M-F10>', 'MenuBar', 1)

	" toggle smaller and bigger font
	let s:fontenlarged = 0
	fu! s:FontSize()
		if s:fontenlarged
			let &gfn = substitute(&gfn, '\(:h\)\@<=\d\+', '\=submatch(0)/2', 'g')
			let &gfw = substitute(&gfw, '\(:h\)\@<=\d\+', '\=submatch(0)/2', 'g')
			exe ':winp ' . s:oldwinposx . ' ' . s:oldwinposy
			let &lines = s:oldlines | let &columns = s:oldcolumns
		else
			let s:oldwinposx = getwinposx() | let s:oldwinposy = getwinposy()
			let s:oldlines = &lines | let s:oldcolumns = &columns
			let &gfn = substitute(&gfn, '\(:h\)\@<=\d\+', '\=submatch(0)*2', 'g')
			let &gfw = substitute(&gfw, '\(:h\)\@<=\d\+', '\=submatch(0)*2', 'g')
		endif
		let s:fontenlarged = 1 - s:fontenlarged
	endf
	map <silent> <Leader>f :call <SID>FontSize()<CR>

	" launching console
	if has("win32")
		fu! s:Console(path)
			let l:path = iconv(a:path, &enc, &tenc)
			silent exe "! start /d \"" . a:path . "\""
		endf
	elseif has("macunix")
		fu! s:Console(path)
			let l:path = iconv(a:path, &enc, &tenc)
			silent !if ps x | grep -v grep | grep -q iTerm;
				\ then osascript -e 'tell application "iTerm"
					\ to tell the last terminal to launch session ""';
				\ else osascript -e 'tell application "iTerm" to activate';
				\ fi
			silent exe "!osascript -e 'tell application \"iTerm\" " .
				\ "to tell the last terminal to tell the last session " .
				\ "to write text \"cd '\\''" . a:path . "'\\''; clear\"'"
		endf
	else
		fu! s:Console(path)
			echoerr ".vimrc: " . mapleader . "C is not enabled here."
		endf
	endif
	nmap <silent> <Leader>C :call <SID>Console(expand("%:p:h"))<CR>
else
	" update terminal title
	set title titlestring=%{$USER}@%{hostname()}:\ %F\ (%l/%L)\ -\ VIM
endif

" share vim's own clipboard with system clipboard
if has("gui_running") || has("xterm_clipboard")
	set cb=unnamed
endif

" macvim specific
"   we cannot use has("gui_macvim") because normal vim also
"   requires this change.
if match($VIM, 'MacVim\.app') >= 0
	set imd
endif
" }}} ------------------------------------------------------

" SYNTAX {{{ -----------------------------------------------
syn enable
filet plugin indent on
let php_sync_method = 0
let html_wrong_comments = 1

" syntax extensions
fu! s:SyntaxExtHTML()
	" HTML CDATA section
	syn region htmlCdataSection matchgroup=htmlCdataDecl start=+<!\[CDATA\[+ end=+\]\]>+
	syn cluster htmlTop add=htmlCdataSection
	hi def link htmlCdataDecl htmlTag
endf
" }}} ------------------------------------------------------

" AUTOCMD {{{ ----------------------------------------------
if has("autocmd")
	aug vimrc
	au!

	" filetype-specific configurations
	au FileType python setl ts=8 sw=4 sts=4 et
	au Filetype text setl tw=80
	au FileType javascript,jsp setl cin
	au BufNewFile,BufRead *.phps,*.php3s setf php

	" syntax extensions (see prior section for definition)
	au Syntax html call s:SyntaxExtHTML()
	au Syntax * syn sync minlines=500 maxlines=1000

	" restore cursor position when the file has been read
	au BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\   exe "norm g`\"" |
		\ endif

	" fix window position for mac os x
	if has("gui_running") && has("macunix")
		au GUIEnter *
			\ if getwinposx() < 50 |
			\   exe ':winp 50 ' . (getwinposy() + 22) |
			\ endif
	endif

	" fix window size if window size has been changed
	if has("gui_running")
		fu! s:ResizeWindows()
			let l:nwins = winnr("$") | let l:num = 1
			let l:curtop = 0 | let l:curleft = 0
			let l:lines = &lines - &cmdheight
			let l:prevlines = s:prevlines - &cmdheight
			let l:cmd = ""
			while l:num < l:nwins
				if l:curleft == 0
					let l:adjtop = l:curtop * l:lines / l:prevlines
					let l:curtop = l:curtop + winheight(l:num) + 1
					if l:curtop < l:lines
						let l:adjheight = l:curtop * l:lines / l:prevlines - l:adjtop - 1
						let l:cmd = l:cmd . l:num . "resize " . l:adjheight . "|"
					endif
				endif
				let l:adjleft = l:curleft * &columns / s:prevcolumns
				let l:curleft = l:curleft + winwidth(l:num) + 1
				if l:curleft < &columns
					let l:adjwidth = l:curleft * &columns / s:prevcolumns - l:adjleft - 1
					let l:cmd = l:cmd . "vert " . l:num . "resize " . l:adjwidth . "|"
				else
					let l:curleft = 0
				endif
				let l:num = l:num + 1
			endw
			exe l:cmd
		endf
		fu! s:ResizeAllWindows()
			if v:version >= 700
				let l:tabnum = tabpagenr()
				tabdo call s:ResizeWindows()
				exe "norm " . l:tabnum . "gt"
			else
				call s:ResizeWindows()
			endif
			let s:prevlines = &lines | let s:prevcolumns = &columns
		endf
		au GUIEnter * let s:prevlines = &lines | let s:prevcolumns = &columns
		au VimResized * call s:ResizeAllWindows()
	endif

	aug END
endif
" }}} ------------------------------------------------------

" VIM7 SPECIFIC {{{ ----------------------------------------
if v:version >= 700
	" editor setting
	set nuw=6
	
	" omni completition
	set ofu=syntaxcomplete#Complete
	imap <C-Space> <C-X><C-N>

	" key mapping for tabpage
	call s:Map2('<C-Tab>', '<D-Down>', 'gt', 0)
	call s:Map2('<C-S-Tab>', '<D-Up>', 'gT', 0)
	let i = 1
	while i <= 10
		call s:Map2('<M-' . (i % 10) . '>', '<D-' . (i % 10) . '>', i . 'gt', 0)
		let i = i + 1
	endw
	call s:Map2('<M-n>', '<D-n>', ':tabnew<CR>', 0)
	call s:Map2('<M-w>', '<D-w>', ':tabclose<CR>', 0)

	" session management
	fu! s:SaveSession()
		let l:path = $HOME
		if isdirectory(l:path . '/Desktop')
			let l:path .= '/Desktop'
		endif
		let l:path = input('Where to save the session? ', l:path, 'dir')
		if l:path != ''
			let l:path .= '/session'
			if glob(l:path) != ''
				let l:suffix = 0
				while glob(l:path . '.' . l:suffix) != ''
					let l:suffix += 1
				endwhile
				let l:path .= '.' . l:suffix
			endif
			exe 'mks ' . l:path
			echo 'Saved the session: ' . l:path
		endif
	endf
	fu! s:RestoreSession()
		let l:path = $HOME
		if isdirectory(l:path . '/Desktop')
			let l:path .= '/Desktop'
		endif
		let l:path .= '/session'
		let l:path = input('What session to be recovered? ', l:path, 'file')
		if l:path != ''
			exe 'so ' . l:path
			echo 'Recovered the session: ' . l:path
		endif
	endf
	nmap <silent> <Leader>ss :call <SID>SaveSession()<CR>
	nmap <silent> <Leader>sr :call <SID>RestoreSession()<CR>

	" automatic session recovery
	fu! s:SearchSession()
		let l:tmpdirs = strpart(&dir, 0, stridx(&dir, ','))
		for i in split(globpath(l:tmpdirs, '**/*.sw?'), '\n')
			" vim swap file format is defined in src/memline.c. highlight is
			" that file name starts at offset 108, and at least up to 850
			" bytes are available for it. (some add. info is at end of it)
			let l:path = substitute(strpart(join(readfile(i, 'b', 512), "\n"),
										  \ 108, 512), '\n*$', '', '')
			exe 'tabnew' l:path
		endfo
	endf
	" TODO
	"call s:SearchSession()
endif
" }}} ------------------------------------------------------

" CUSTOMIZING by hodduc {{{ --------------------------------
set t_Co=256
colorscheme molokai
" CUSTOMIZING end }}} -------------------------------------

" end of configuration
finish

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODOS:
" - integrated ctags support
" - more filetype-specific configuration
" - more smooth ResizeAllWindows behavior in mac os x
"   (as MacVim generates VimResized event on *every* ticks)
" - bring SearchSession routine to the light
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"" vim: ts=4 sw=4 fdm=marker nofen
