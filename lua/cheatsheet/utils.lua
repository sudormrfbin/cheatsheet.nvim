-- cheatsheet.utils
local M = {}

-- taken from https://github.com/neovim/neovim/pull/13778
-- Given an array remove the duplicated items
-- @param array the array to dedupe
-- @return deduped array
M.dedupe_array = function(array)
    local result = {}
    local seen = {}

    for _, item in ipairs(array) do
        if not seen[item] then
            table.insert(result, item)
            seen[item] = true
        end
    end

    return result
end

-- Get the user's cheatsheet.txt located in config directory (~/.config/nvim)
M.get_user_cheatsheet = function()
    return vim.fn.stdpath("config") .. "/cheatsheet.txt"
end

-- Edit the user's cheatsheet in a new buffer
M.edit_user_cheatsheet = function()
    vim.api.nvim_command(":edit " .. M.get_user_cheatsheet())
end

-- Get the cheatsheet included with the plugin containing a generic vim cheatsheet
-- @return path to defautl cheatsheet
M.get_default_cheatsheet = function()
    return vim.api.nvim_get_runtime_file("doc/cheatsheet-default.txt", false)[1]
end

M.is_using_default_cheatsheet = function()
    local var_is_defined, use_default = pcall(
        vim.api.nvim_get_var, 'cheatsheet_use_default'
    )
    if var_is_defined and use_default then return true end
    return false

end

M.toggle_use_default_cheatsheet = function()
    vim.api.nvim_set_var(
        'cheatsheet_use_default', not M.is_using_default_cheatsheet()
    )
end

return M
