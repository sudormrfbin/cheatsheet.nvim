if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "cheatsheet"

syn clear
syn sync fromstart

syn match cheatComment /#.*$/
syn match cheatDescription /\v^[^\#][^|]*/ contained skipwhite nextgroup=cheatSeparator
syn match cheatSeparator '|' nextgroup=cheatCode skipwhite contained
syn match cheatCode '.*' contained
syn region cheatCodeRegion start=/|/ end=/$/ contains=cheatCode
syn region cheatLine start=/\v[^/#]/ end=/$/ keepend contains=cheatDescription,cheatSeparator,cheatCodeRegion

" highlights are defined in plugin file
