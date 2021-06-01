local entry_display = require('telescope.pickers.entry_display')
local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

local cheatsheet= require('cheatsheet')

local M = {}

M.pick_cheat = function(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = 'Cheat',
        finder = finders.new_table{
            results = cheatsheet.get_cheats(),
            entry_maker = function(entry)
                local displayer = entry_display.create{
                    separator = "▏",
                    items = {
                        { width = 30},
                        {remaining = true},
                    },
                }

                local function make_display(ent)
                    return displayer {
                        {ent.value.description, "cheatDescription"},
                        {ent.value.cheatcode, "cheatCode"},
                    }
                end

                return {
                    value = entry,
                    -- the string that user sees as an item
                    display = make_display,
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

return M
