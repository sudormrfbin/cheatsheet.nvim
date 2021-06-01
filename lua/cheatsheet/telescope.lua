local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')

local conf = require('telescope.config').values
local config = require('telescope.config')
local utils = require('telescope.utils')
local entry_display = require('telescope.pickers.entry_display')

local cheatsheet = require('cheatsheet')

local M = {}

M.pick_cheat = function(opts)
    opts = opts or {}

    pickers.new(
        opts, {
            prompt_title = 'Cheat',
            finder = finders.new_table {
                results = cheatsheet.get_cheats(),
                entry_maker = function(entry)
                    -- Calculate the width of each column dynamically so that both
                    -- the description and cheatcode is readable on small terminals too.
                    -- This whole logic can be avoided if the cheatcode is shown first and
                    -- a small width for the respective cheatcode column is used.
                    -- But the cheatcode is what we *don't* know and the description is
                    -- what we already know. So show description first for better UX.
                    local width = utils.get_default(opts.results_width, config.values.results_width)
                    local cols = vim.o.columns
                    local tel_win_width = math.floor(cols * width)
                    local cheatcode_width = math.floor(cols * 0.25)

                    -- NOTE: the width calculating logic is not exact, but approx enough
                    local displayer = entry_display.create {
                        separator = " ▏",
                        items = {
                            { width = tel_win_width -  cheatcode_width}, -- description
                            { remaining = true } -- cheatcode
                        },
                    }

                    local function make_display(ent)
                        return displayer {
                            -- text, highlight group
                            { ent.value.description, "cheatDescription" },
                            { ent.value.cheatcode, "cheatCode" },
                        }
                    end

                    return {
                        value = entry,
                        -- generate the string that user sees as an item
                        display = make_display,
                        -- queries are matched against ordinal
                        ordinal = entry.description .. ' ' .. entry.cheatcode,
                    }
                end,
            },
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(
                    function()
                        -- local selection = action_state.get_selected_entry()
                        -- close telescope on Enter
                        actions.close(prompt_bufnr)
                    end
                )
                return true
            end,
            sorter = conf.generic_sorter(opts),
        }
    ):find()
end

return M
