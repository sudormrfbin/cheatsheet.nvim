local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

local cheatsheet= require('cheatsheet')

local function pick_cheat(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = 'Cheat',
        finder = finders.new_table{
            results = cheatsheet.get_cheats(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    -- the string that user sees as an item
                    display = entry.description .. ' | ' .. entry.cheatcode,
                    -- queries are matched against ordinal
                    ordinal = entry.description .. ' ' .. entry.cheatcode,
                }
            end,
        },
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                -- local selection = action_state.get_selected_entry()
                -- close telescope on Enter
                actions.close(prompt_bufnr)
            end)
            return true
        end,
        sorter = conf.generic_sorter(opts)
    }):find()
end

return telescope.register_extension{
    exports = {
        cheatsheet = pick_cheat,
    },
}

