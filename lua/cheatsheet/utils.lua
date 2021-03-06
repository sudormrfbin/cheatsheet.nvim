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

M.has_value = function(tbl, value)
    for _, val in pairs(tbl) do if val == value then return true end end
    return false
end

-- Insert elements from `from_tbl` into `ins_tbl`. If `include` is a bool,
-- it controls appending everything in `from_tbl` to `ins_tbl`. If it is a
-- table, Use `pattern` to extract a match from an element in `from_tbl`
-- and insert only if match is present in `include.enabled` or not present
-- in `include.disabled`.
function M.filter_insert(ins_tbl, from_tbl, pattern, include)
    if include == false then return end

    if include == true then
        for _, element in ipairs(from_tbl) do
            table.insert(ins_tbl, element)
        end
        return
    end
    assert(type(include) == "table", "Invalid table format")

    if include.enabled ~= nil then
        for _, element in ipairs(from_tbl) do
            local match = element:match(pattern)
            if M.has_value(include.enabled, match) then
                table.insert(ins_tbl, element)
            end
        end
    elseif include.disabled ~= nil then
        for _, element in ipairs(from_tbl) do
            local match = element:match(pattern)
            if not M.has_value(include.disabled, match) then
                table.insert(ins_tbl, element)
            end
        end
    end
end

-- Get the user's cheatsheet.txt located in config directory (~/.config/nvim)
M.get_user_cheatsheet = function()
    return vim.fn.stdpath("config") .. "/cheatsheet.txt"
end

-- Edit the user's cheatsheet in a new buffer
M.edit_user_cheatsheet = function()
    vim.api.nvim_command(":edit " .. M.get_user_cheatsheet())
end

-- Get the list of cheatsheets bundled with this plugin,
-- from cheatsheets/. Does not include plugin cheatsheets.
-- @return Array of cheatsheet filepaths
M.get_bundled_cheatsheets = function()
    return vim.api.nvim_get_runtime_file("cheatsheets/cheatsheet-*.txt", true)
end

-- Get the list of plugin cheatsheets bundled with this plugin,
-- from cheatsheets/plugins/
-- @return Array of cheatsheet filepaths
M.get_bundled_plugin_cheatsheets = function()
    return vim.api.nvim_get_runtime_file(
        "cheatsheets/plugins/cheatsheet-*.txt", true
    )
end

return M
