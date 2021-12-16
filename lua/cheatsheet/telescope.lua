local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')

local config = require('telescope.config').values
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
M.pick_cheat = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}

    pickers.new(
        telescope_opts, {
            prompt_title = 'Cheat',
            finder = finders.new_table {
                results = cheatsheet.get_cheats(opts),
                entry_maker = function(entry)
                    -- Calculate the width of each column dynamically so that both
                    -- the description and cheatcode is readable on small terminals too.
                    -- This whole logic can be avoided if the cheatcode is shown first and
                    -- a small width for the respective cheatcode column is used.
                    -- But the cheatcode is what we *don't* know and the description is
                    -- what we already know. So show description first for better UX.

                    -- * config.width was deprecated in favor of config.layout_config.width
                    -- https://github.com/nvim-telescope/telescope.nvim/commit/5a53ec5c2fdab10ca8775d3979b1a85e63d57953
                    -- * config.layout_config was changed to move width and height to individual layout_strategy configs
                    -- https://github.com/nvim-telescope/telescope.nvim/pull/1039/files#diff-4936325bfc521d7cffc09fe0156becd4a4ba2ed169431c94bd63669fe0cc1a2aL79-L80
                    local cols = vim.o.columns
                    local width = config.width
                        or config.layout_config.width
                        or config.layout_config[config.layout_strategy].width
                        or cols
                    local tel_win_width
                    -- width = 80 -> column width, width = 0.7 -> ratio
                    if width > 1 then
                        tel_win_width = width
                    else
                        tel_win_width = math.floor(cols * width)
                    end
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
                            vim.api.nvim_exec(command, true)
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
                    'i', '<C-r>', function()
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
            sorter = config.generic_sorter(telescope_opts),
        }
    ):find()
end

return M
