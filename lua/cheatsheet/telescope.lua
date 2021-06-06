local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')

local conf = require('telescope.config').values
local config = require('telescope.config')
local telescope_utils = require('telescope.utils')
local entry_display = require('telescope.pickers.entry_display')

local cheatsheet = require('cheatsheet')
local utils = require('cheatsheet.utils')

local M = {}

-- Filter through cheats using Telescope
-- Highlight groups:
--     cheatMetadataSection, cheatDescription, cheatCode
-- Mappings:
--     <C-E> - Edit user cheatsheet in new buffer
--     <C-D> - Toggle including the default cheatsheat
--     <C-Y> - Yank the cheatcode
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
                    local width = telescope_utils.get_default(
                        opts.results_width, config.values.results_width
                    )
                    local cols = vim.o.columns
                    local tel_win_width = math.floor(cols * width)
                    local cheatcode_width = math.floor(cols * 0.25)
                    local section_width = 10

                    -- NOTE: the width calculating logic is not exact, but approx enough
                    local displayer = entry_display.create {
                        separator = " ▏",
                        items = {
                            { width = section_width }, -- section
                            {
                                width = tel_win_width - cheatcode_width
                                    - section_width,
                            }, -- description
                            { remaining = true }, -- cheatcode
                        },
                    }

                    local function make_display(ent)
                        return displayer {
                            -- text, highlight group
                            { ent.value.section, "cheatMetadataSection" },
                            { ent.value.description, "cheatDescription" },
                            { ent.value.cheatcode, "cheatCode" },
                        }
                    end

                    local tags = table.concat(entry.tags, ' ')

                    return {
                        value = entry,
                        -- generate the string that user sees as an item
                        display = make_display,
                        -- queries are matched against ordinal
                        ordinal = string.format(
                            '%s %s %s %s', entry.section, entry.description,
                                tags, entry.cheatcode
                        ),
                    }
                end,
            },
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        local selection = actions_state.get_selected_entry()
                        local section = selection.value.section
                        local description = selection.value.description
                        local cheat = selection.value.cheatcode

                        actions.close(prompt_bufnr)

                        if string.len(cheat) == 1 then
                            print("Cheatsheet: No command could be executed")
                            return
                        end

                        -- Extract command from cheat, eg:
                        -- ":%bdelete" -> No change
                        -- ":set hls!" -> No change
                        -- ":edit [file]" -> ":edit "
                        -- ":set shiftwidth={n}" -> ":set shiftwidth="
                        local command = cheat:match("^:[^%[%{]+")
                        if command ~= nil then
                            vim.api.nvim_feedkeys(command, "n", true)
                        else
                            vim.api.nvim_echo(
                                { -- text, highlight group
                                    { "Cheatsheet [", "" },
                                    { section, "cheatMetadataSection" },
                                    { "]: Press ", "" }, { cheat, "cheatCode" },
                                    { " to ", "" },
                                    { description:lower(), "cheatDescription" },
                                }, false, {}
                            )
                        end
                    end
                )
                map(
                    'i', '<C-E>', function()
                        actions.close(prompt_bufnr)
                        utils.edit_user_cheatsheet()
                    end
                )
                map(
                    'i', '<C-D>', function()
                        -- _close with keepinsert=true to support opening another
                        -- telescope window (here same window) from current one
                        actions._close(prompt_bufnr, true)
                        utils.toggle_use_default_cheatsheet()
                        M.pick_cheat()
                    end
                )
                map(
                    'i', '<C-Y>', function()
                        actions.close(prompt_bufnr)
                        local selection = actions_state.get_selected_entry()
                        local cheatcode = selection.value.cheatcode
                        vim.fn.setreg("0", cheatcode)
                        vim.api.nvim_echo(
                            { { "Yanked ", "" }, { cheatcode, "cheatCode" } },
                                false, {}
                        )
                    end
                )
                return true
            end,
            sorter = conf.generic_sorter(opts),
        }
    ):find()
end

return M
