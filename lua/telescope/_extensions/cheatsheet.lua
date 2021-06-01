local telescope = require('telescope')
local pick_cheat = require('cheatsheet.telescope').pick_cheat

return telescope.register_extension { exports = { cheatsheet = pick_cheat } }

