local M = {}

-- NOTE: Watch out for bugs in cheatsheet.get_cheatsheet_files if
-- defaults is modified in the future
local defaults = {
    -- Whether to show bundled cheatsheets

    -- For generic cheatsheets like default, unicode, nerd-fonts, etc
    -- bundled_cheatsheets = {
    --     enabled = {},
    --     disabled = {},
    -- },
    bundled_cheatsheets = true,
    -- For plugin specific cheatsheets
    -- bundled_plugin_cheatsheets = {
    --     enabled = {},
    --     disabled = {},
    -- }
    bundled_plugin_cheatsheets = true,
    -- For bundled plugin cheatsheets, do not show a sheet if you
    -- don't have the plugin installed (searches runtimepath for
    -- same directory name)
    include_only_installed_plugins = true,
}

M.options = {}

function M.setup(opts)
    opts = opts or {}
    for key, val in pairs(defaults) do
        if opts[key] == nil then opts[key] = val end
    end
    M.options = opts
end

M.setup()

return M
