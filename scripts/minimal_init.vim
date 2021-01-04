" if has('win32')
"   set rtp+=.
"   set rtp+=..\plenary.nvim\
"   set rtp+=..\popup.nvim\

"   runtime! plugin\plenary.vim
"   runtime! plugin\telescope.vim
" else
set rtp+=.
set rtp+=../plenary.nvim/
set rtp+=../popup.nvim/

runtime! plugin/plenary.vim
runtime! plugin/telescope.vim
" endif
