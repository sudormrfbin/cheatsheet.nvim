local t_actions = require('telescope.actions')
local t_actions_state = require('telescope.actions.state')
local utils = require('cheatsheet.utils')

-- @param execute: Whether to execute a command or type it in
local function select_current_item(prompt_bufnr, execute)
    local selection = t_actions_state.get_selected_entry()
    local section = selection.value.section
    local description = selection.value.description
    local cheat = selection.value.cheatcode

    t_actions.close(prompt_bufnr)

    if string.len(cheat) == 0 then
        print("Cheatsheet: No command could be executed")
        return
    end

    if execute then
        if cheat:find(":") then
            -- Extract command from cheat, eg:
            -- ":%bdelete" -> No change
            -- ":set hls!" -> No change
            -- ":edit [file]" -> ":edit "
            -- ":set shiftwidth={n}" -> ":set shiftwidth="
            local command = cheat:match("^:[^%[%{]+")
            if command == cheat then
                vim.api.nvim_command(cheat)
            else
                vim.api.nvim_feedkeys(command, "n", true)
            end
        else
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(cheat, true, true, true)
                , "x", false)
        end
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

local M = {}

function M.edit_user_cheatsheet(prompt_bufnr)
    t_actions.close(prompt_bufnr)
    utils.edit_user_cheatsheet()
end

function M.copy_cheat_value(prompt_bufnr)
    t_actions.close(prompt_bufnr)
    local selection = t_actions_state.get_selected_entry()
    local cheatcode = selection.value.cheatcode
    vim.fn.setreg("0", cheatcode)
    vim.api.nvim_echo(
        { { "Yanked ", "" }, { cheatcode, "cheatCode" } },
            false, {}
    )
end

function M.select_or_execute(prompt_bufnr)
    select_current_item(prompt_bufnr, true)
end

function M.select_or_fill_commandline(prompt_bufnr)
    select_current_item(prompt_bufnr, false)
end

return M
