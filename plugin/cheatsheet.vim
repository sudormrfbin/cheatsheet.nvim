command! -bar -bang Cheatsheet call s:Cheatsheet(<bang>0)
command! -bar CheatsheetEdit lua require'cheatsheet.utils'.edit_user_cheatsheet()

function! s:Cheatsheet(force_float)
  " bang command
  if a:force_float
    lua require('cheatsheet').show_cheatsheet_float()
  else
    lua require('cheatsheet').show_cheatsheet()
  endif
endfunction

if mapcheck("<leader>?", "n") == ""
  nnoremap <unique> <leader>? :<C-U>Cheatsheet<CR>
endif

highlight default link cheatComment Comment
highlight default link cheatMetadataComment Comment
highlight default link cheatMetadataTag Include
highlight default link cheatMetadataSection Structure

highlight default link cheatDescription String
highlight default link cheatSeparator Keyword
highlight default link cheatCode Statement
