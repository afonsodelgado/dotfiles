if &compatible
    set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/afonsodelgado/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/Users/afonsodelgado/.cache/dein')
    call dein#begin('/Users/afonsodelgado/.cache/dein')

    " Let dein manage dein
    " Required:
    call dein#add('/Users/afonsodelgado/.cache/dein/repos/github.com/Shougo/dein.vim')

    " Add or remove your plugins here:
    call dein#add('Shougo/deoplete.nvim')
    if !has('nvim')
        call dein#add('roxma/nvim-yarp')
        call dein#add('roxma/vim-hug-neovim-rpc')
    endif

    call dein#add('scrooloose/nerdtree')
    call dein#add('scrooloose/nerdcommenter')
    call dein#add('airblade/vim-gitgutter')
    call dein#add('bling/vim-airline')
    call dein#add('pangloss/vim-javascript')
    call dein#add('easymotion/vim-easymotion')
    call dein#add('mxw/vim-jsx')
    call dein#add('ayu-theme/ayu-vim')
    call dein#add('w0rp/ale')
    call dein#add('ap/vim-css-color')
    call dein#add('carlitux/deoplete-ternjs')
    call dein#add('townk/vim-autoclose')
    call dein#add('alvan/vim-closetag')
    call dein#add('tpope/vim-fugitive')
    call dein#add('jparise/vim-graphql')
    call dein#add('styled-components/vim-styled-components')
    call dein#add('junegunn/fzf.vim')
    call dein#add('neovimhaskell/haskell-vim.git')
    call dein#add('arcticicestudio/nord-vim')
    call dein#add('kristiandupont/shades-of-teal')
    call dein#add('valloric/matchtagalways')
    call dein#add('terryma/vim-multiple-cursors')
    call dein#add('sheerun/vim-polyglot')
    call dein#add('trevordmiller/nova-vim')
    call dein#add('yuttie/comfortable-motion.vim')
    call dein#add('tpope/vim-surround')

    " Required:
    call dein#end()
    call dein#save_state()
endif

" Required:
filetype plugin indent on

let mapleader=","
inoremap jk <esc>

" Fix wrong autoindent on JSX / HTML tags
filetype indent off

" Enable syntax and real colors
set termguicolors 
syntax enable

" Enable mouse (scroll) and cursorline highlight
set mouse=a
set clipboard=unnamed
set cursorline
" set number

" Indentation stuff
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent

set smarttab
set incsearch
set hlsearch

set splitbelow
set splitright

set backspace=2
set backspace=indent,eol,start
set noswapfile

" Make closetags the same color than opentags on xml/html/jsx
highlight link xmlEndTag xmlTag

" Add Colorcolumn highlight at 100 chars
if exists('+colorcolumn')
    set colorcolumn=100
else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" Colorscheme settings
set background=dark
" colorscheme nova
colorscheme nord
let g:airline_theme='nord'

" NerdTree mappings
map <C-\> :NERDTreeToggle<CR>

" EasyMotion mappings
nmap s <Plug>(easymotion-overwin-f2)

" Vim FZF mappings
set rtp+=/usr/local/opt/fzf
" nnoremap <C-p> :FZF<CR>
nnoremap <C-p> :GFiles<CR>

" Ale fixers and mappings
let g:ale_fixers = {
            \ 'javascript': ['eslint']
            \ }
let g:ale_sign_column_always = 1
" let g:airline#extensions#ale#enabled = 1
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
nmap <leader>l <Plug>(ale_fix)

" Deoplete settings
let g:deoplete#enable_at_startup = 1

" Closetag settings
let g:closetag_filenames = '*.html,*.xhtml,*.phtml, *.js, *.jsx'

" Enable JSX inside JS filetype
let g:jsx_ext_required = 0

" NERDCommenter settings
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'start'

let g:mta_filetypes = {
    \ 'html' : 1,
    \ 'xml' : 1,
    \ 'js' : 1
    \}
