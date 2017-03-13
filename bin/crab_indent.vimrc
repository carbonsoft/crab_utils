if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
	set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible	" Use Vim defaults (much better!)

set bs=indent,eol,start		" allow backspacing over everything in insert mode

if &term=="xterm"
	set t_Co=256
	set t_Sb=[4%dm
	set t_Sf=[3%dm
endif

setlocal indentexpr=GetShIndent()
setlocal indentkeys+==then,=do,=else,=elif,=esac,=fi,=fin,=fil,=done
setlocal indentkeys-=:,0#


if has("syntax")
	syntax on
endif

if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

if has("autocmd")
	filetype plugin indent on
endif

set showmatch           " Show matching brackets.

"if filereadable("/etc/vim/vimrc.local")
"       source /etc/vim/vimrc.local
"endif

color ron

if exists("*GetShIndent")
	finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:indent_eof = -1
let s:indent_echo1 = -1
let s:indent_echo2 = -1

let s:indent_slash = -1

function GetShIndent()
	let prevnum = prevnonblank(v:lnum - 1)
	if prevnum == 0
		return 0
	endif

	let prevprevnum = prevnonblank(prevnum - 1)
	if  prevprevnum == 0
		prevprevnum = prevnum
	endif

	
	" Add a 'shiftwidth' after if, while, else, case, until, for, function()
	" Skip if the line also contains the closure for the above

	let curline = getline(v:lnum)
	let curind = indent(v:lnum)
	let prevind = indent(prevnum)
	let prevline = getline(prevnum)
	let prevprevind = indent(prevprevnum)
	let prevprevline = getline(prevprevnum)
	
	if prevline =~ '.*[<][<]EOF.*'
		let s:indent_eof = prevind
		return curind
	endif

	if s:indent_eof != -1 && prevline =~ 'EOF'
		let prevind = s:indent_eof
		let s:indent_eof = -1
	endif

	if s:indent_eof != -1
		return curind
	endif

	if prevline =~ 'echo "' && prevline !~ 'echo ".*"'
		let s:indent_echo1 = prevind
		return curind
	endif

	if s:indent_echo1 != -1  && ( prevline =~ '[^\\]"' || prevline =~ '^"' )
		let prevind = s:indent_echo1
		let s:indent_echo1 = -1
	endif

	if s:indent_echo1 != -1
		return curind
	endif


	if prevline =~ "echo '" && prevline !~ "echo '.*'"
		let s:indent_echo2 = prevind
		return curind
	endif

	if s:indent_echo2 != -1  && ( prevline =~ "[^\\]'" || prevline =~ "^'" )
		let prevind = s:indent_echo2
		let s:indent_echo2 = -1
	endif

	if s:indent_echo2 != -1
		return curind
	endif


	if prevline =~ '^\s*[ |]*\(if\|for\|while\|else\|elif\|until\)\>'
				\ || prevline =~ '^.*[|][ ]while'
				\ || (prevline =~ '^\s*case\>' && g:sh_indent_case_labels)
				\ || prevline =~ '^\s*\<\k\+\>\s*()\s*{'
				\ || prevline =~ '^\s*function\s*\<\k\+\>\s*()\s*{$'
				\ || prevline =~ '^\s*{$'
				\ || prevline =~ '^\s*#{$'
				\ || prevline =~ '^\s*[^() \t]\{1,\})'
				\ || prevline =~ '^\s*[ |]*($'
		if prevline !~ '\(esac\|fi\|done\)\>\s*$' && prevline !~ '}\s*$' && prevline !~ '^\s*)' && prevline !~ '^\s*a#[ #]'
			let prevind = prevind + &sw
			return prevind
		endif
	endif

	if prevline =~ '.*[^\\]$' && s:indent_slash == prevind
		let prevind = prevind - &sw
		let s:indent_slash = -1
	endif


	if prevline =~ ';;'
		let prevind = prevind - &sw
		return prevind
	endif
	" Subtract a 'shiftwidth' on a else, esac, fi, done
	" Retain the indentation level if line matches fin (for find)
	if (curline =~ '^\s*\(else\|elif\|fi\|done\)\>'
				\ || (curline =~ '^\s*esac\>' && g:sh_indent_case_labels)
				\ || curline =~ '^\s*)*}'
				\ || curline =~ '^\s*#}'
				\ || curline =~ '^\s*)'
				\ )
				\ && curline !~ '^\s*fi[ln]\>' && curline !~ '^\s*#[ #]'
		let prevind = prevind - &sw
	endif

	if prevline =~ '.*\\$' && s:indent_slash == -1
			\ && prevline !~ '^\s*#[ #]'
			\ && (prevprevline !~ '.*\\$' || prevprevline =~ '^\s*#[ #]' )
		let prevind = prevind + &sw
		let s:indent_slash = prevind
		return prevind
	endif

	return prevind
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

color ron
set nowrap
set nopaste
set ignorecase

color ron
:runtime! ftplugin/man.vim
set nobackup                            "не создавать файлы с резервной копией (filename.txt~)"
set history=50                          "сохранять 50 строк в истории командной строки
set ruler                               "постоянно показывать позицию курсора
set incsearch                           "показывать первое совпадение при наборе шаблона
set nohlsearch                          "подсветка найденного
set mouse=a                             "используем мышку
set autoindent                          "включаем умные отступы
set smartindent
set ai                                  "при начале новой строки, отступ копируется из предыдущей
set ignorecase                          "игнорируем регистр символов при поиске
"set background=dark                     "фон терминала - темный
"set ttyfast                             "коннект с терминалом быстрый
set visualbell                          "мигаем вместо пищания
set showmatch                           "показываем открывающие и закрывающие скобки
set shortmess+=tToOI                    "убираем заставку при старте
set rulerformat=%(%l,%c\ %p%%%)         "формат строки состояния строка х столбец, сколько прочитано файла в %
set wrap                                "не разрывать строку при подходе к краю экрана
set linebreak                           "переносы между видимыми на экране строками только между словами
set t_Co=256                            "включаем поддержку 256 цветов
set wildmenu                            "красивое автодополнение
set wcm=<Tab>                           "WTF? but all work
set autowrite                           "автоматом записывать изменения в файл при переходе к другому файлу
set encoding=utf8                       "кодировка по дефолту
set termencoding=utf8                   "Кодировка вывода на терминал
set fileencodings=utf8,cp1251,koi8r     "Возможные кодировки файлов (автоматическая перекодировка)
set showcmd showmode                    "показывать незавершенные команды и текущий режим
set autochdir                           "текущий каталог всегда совпадает с содержимым активного окна
"set stal=2                              "постоянно выводим строку с табами
"set tpm=100                             "максимальное количество открытых табов
set wak=yes                             "используем ALT как обычно, а не для вызова пункта мени
set noex                                "не читаем файл конфигурации из текущей директории
set ssop+=resize                        "сохраняем в сессии размер окон Vim'а
"set list                                "Отображаем табуляции и конечные пробелы...
set listchars=tab:→→,trail:⋅
