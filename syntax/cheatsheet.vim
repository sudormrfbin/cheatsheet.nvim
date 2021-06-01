if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "cheatsheet"

syn clear
syn sync fromstart

syn region cheatComment start=/\v#[^#]/ end=/$/ keepend

"        ##          plugin-name  @tag @tag
"        ^^          ^^^^^^^^^^^  ^^^^
" metadata-comment     section    tag
syn match cheatMetadataSection /##\s\+\S\+/ms=s+2 skipwhite nextgroup=cheatMetadataTag contained
syn match cheatMetadataTag /@\S\+/ contained
syn region cheatMetadataComment start=/##/ end=/$/ keepend skipwhite contains=cheatMetadataSection,cheatMetadataTag

"      Some useful text       |       :Command
"      ^^^^^^^^^^^^^^^^       ^       ^^^^^^^^
"        description      separator   cheatcode
syn match cheatDescription /\v^[^\#][^|]*/ contained skipwhite nextgroup=cheatSeparator
syn match cheatSeparator '|' nextgroup=cheatCode skipwhite contained
syn match cheatCode '.*' contained
syn region cheatCodeRegion start=/|/ end=/$/ contains=cheatCode
syn region cheatLine start=/\v[^/#]/ end=/$/ keepend contains=cheatDescription,cheatSeparator,cheatCodeRegion

" highlights are defined in plugin file
