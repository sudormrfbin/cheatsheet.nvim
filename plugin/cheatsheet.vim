command -bar -nargs=0 Cheatsheet lua require'cheatsheet'.show_cheatsheet()
command -bar -nargs=0 CheatsheetEdit lua require'cheatsheet'.edit_user_cheatsheet()
command -bar -nargs=0 CheatsheetFloat lua require'cheatsheet'.show_cheatsheet_float()
command -bar -nargs=0 CheatsheetTelescope lua require'cheatsheet'.show_cheatsheet_telescope()

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
