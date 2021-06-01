command -bar -nargs=0 CheatSheetFloat lua require'cheatsheet'.show_cheats_float()
command -bar -nargs=0 CheatSheetTelescope lua require'cheatsheet.telescope'.pick_cheat()

highlight default link cheatComment Comment
highlight default link cheatMetadataComment Comment
highlight default link cheatMetadataTag Include
highlight default link cheatMetadataSection Structure

highlight default link cheatDescription String
highlight default link cheatSeparator Keyword
highlight default link cheatCode Statement
