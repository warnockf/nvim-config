call plug#begin()

" List your plugins here
Plug 'tpope/vim-sensible'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
" Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'neanias/everforest-nvim', { 'branch': 'main' }

call plug#end()

let mapleader = " "

" Ensure that y and x copy to the clipboard, but d does not
set clipboard=

nnoremap y "+y
nnoremap x "+x
nnoremap d "_d
nnoremap dd "_dd

vnoremap y "+y
vnoremap x "+x
vnoremap d "_d

nnoremap p "+p
nnoremap P "+P
vnoremap p "+p
vnoremap P "+P

" Find files using Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fw <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>e :NERDTreeFocus<CR>

" Move between windows with ctrl + h/j/k/l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move the cursor while in insert mode with ctrl + h/j/k/l
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

" Open terminal with leader + t and exit terminal mode with esc
nnoremap <leader>t :terminal<CR>
tnoremap <Esc> <C-\><C-n>

" Delete buffer with leader + x
" nnoremap <leader>q :bd!<CR>

" Comment out lines with leader + /
nnoremap <leader>/ :Commentary<CR>
vnoremap <leader>/ :Commentary<CR>

" Reload config with <leader>r
nnoremap <leader>r :source $MYVIMRC<CR>

" COC
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif


function! NextBuffer()
  let current_buf = bufnr('%')
  bnext
  " Skip NERDTree and terminal buffers
  while (exists('b:NERDTree') && b:NERDTree.isTabTree()) || &buftype == 'terminal'
    if bufnr('$') == current_buf
      break
    endif
    bnext
  endwhile
endfunction

function! PrevBuffer()
  let current_buf = bufnr('%')
  bprevious
  " Skip NERDTree and terminal buffers
  while (exists('b:NERDTree') && b:NERDTree.isTabTree()) || &buftype == 'terminal'
    if bufnr('$') == current_buf
      break
    endif
    bprevious
  endwhile
endfunction

" Function to sync NERDTree with the current buffer's file
function! SyncNERDTree()
    " Only proceed if the current buffer is not NERDTree or terminal
    if !IsSpecialBuffer(bufnr('%'))
        " Check if the current buffer has a valid file path
        if !empty(expand('%:p'))
            " Check if NERDTree is open
            if exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1
                " Switch to NERDTree window, find file, and switch back
                execute 'wincmd p'
                execute 'NERDTreeFind'
                wincmd p
            endif
        endif
    endif
endfunction

nnoremap <Tab> :call NextBuffer()<CR>
nnoremap <S-Tab> :call PrevBuffer()<CR>

" GoTo code navigation
nmap <silent><nowait> gd <Plug>(coc-definition)
nmap <silent><nowait> gy <Plug>(coc-type-definition)
nmap <silent><nowait> gi <Plug>(coc-implementation)
nmap <silent><nowait> gr <Plug>(coc-references)

" Show line numbers
set number
set relativenumber

colorscheme everforest

autocmd VimEnter * NERDTree
" let g:NERDTreeWinSize = 55

filetype plugin indent on

" Function to check if buffer is NERDTree or terminal
function! IsSpecialBuffer(bufnr)
    return getbufvar(a:bufnr, '&filetype') ==# 'nerdtree' || getbufvar(a:bufnr, '&buftype') ==# 'terminal'
endfunction

" Function to check if buffer is NERDTree or terminal
function! IsSpecialBuffer(bufnr)
    return getbufvar(a:bufnr, '&filetype') ==# 'nerdtree' || getbufvar(a:bufnr, '&buftype') ==# 'terminal'
endfunction

" Function to get next non-special, listed buffer or create a new one
function! GetNextNonSpecialBuffer()
    let l:current_buf = bufnr('%')
    let l:total_buffers = bufnr('$')
    let l:next_buf = l:current_buf + 1

    " Iterate through buffers starting from the next one
    while l:next_buf <= l:total_buffers
        if bufexists(l:next_buf) && buflisted(l:next_buf) && !IsSpecialBuffer(l:next_buf)
            return l:next_buf
        endif
        let l:next_buf += 1
    endwhile

    " Try from the beginning up to current buffer
    let l:next_buf = 1
    while l:next_buf < l:current_buf
        if bufexists(l:next_buf) && buflisted(l:next_buf) && !IsSpecialBuffer(l:next_buf)
            return l:next_buf
        endif
        let l:next_buf += 1
    endwhile

    " No suitable buffer found, create a new one
    execute 'enew'
    setlocal buflisted
    return bufnr('%')
endfunction

" Function to close current window and switch to next non-special buffer
function! CloseWindowAndSwitch()
    let l:current_buf = bufnr('%')
    let l:next_buf = GetNextNonSpecialBuffer()
    
    if l:next_buf > 0 && l:next_buf != l:current_buf
        execute 'buffer' l:next_buf
        execute 'bdelete!' l:current_buf
    else
        execute 'bdelete!' l:current_buf
    endif
endfunction

" Function to sync NERDTree with the current buffer's file
function! SyncNERDTree()
    " Only proceed if the current buffer is not NERDTree or terminal
    if !IsSpecialBuffer(bufnr('%'))
        " Check if the current buffer has a valid file path
        if !empty(expand('%:p'))
            " Check if NERDTree is open
            if exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1
                " Switch to NERDTree window, find file, and switch back
                " execute 'wincmd p'
                execute 'NERDTreeFind'
                wincmd p
            endif
        endif
    endif
endfunction

" Autocommand to sync NERDTree on buffer enter
augroup NERDTreeSync
    autocmd!
    autocmd BufEnter * call SyncNERDTree()
augroup END

" Map leader + q to close window and switch
nnoremap <leader>q :call CloseWindowAndSwitch()<CR>

nnoremap <leader>b :enew<CR>:setlocal buflisted<CR>
