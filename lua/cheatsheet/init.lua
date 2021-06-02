-- plenary is only used for telescope specific code
local has_path, path = pcall(require, "plenary.path")

local M = {}

-- taken from https://github.com/neovim/neovim/pull/13778
-- Given an array remove the duplicated items
-- @param array the array to dedupe
-- @return deduped array
local function dedupe_array(array)
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

-- Get `cheatsheet.txt` files from any directory in runtimepath
-- @return array of filepaths
M.get_cheatsheet_files = function()
    local cheats = vim.api.nvim_get_runtime_file("cheatsheet.txt", true)
    -- https://github.com/neovim/neovim/issues/14294
    -- returned table may have duplicated entries
    return dedupe_array(cheats)
end

-- Aggregates cheats from cheatsheets and returns a structured repr.
-- Ignores comments and newlines (except for metadata comments).
-- @return array of {description, cheatcode, section, {tags}} for each cheat
M.get_cheats = function()
    if not has_path then error("plenary.nvim not installed") end

    local section_pat = '^##%s*(%S*)'
    local tags_pat = '^##.*@%S*'
    local cheatline_pat = '^([^#]-)%s*|%s*(.-)%s*$'

    local cheats = {}
    for _, cheatfile in ipairs(M.get_cheatsheet_files()) do
        local section = "Default"
        local tags = {}
        for _, line in ipairs(path.readlines(cheatfile)) do
            -- prase section if line is meatadata comment
            local maybe_section = line:match(section_pat)
            if maybe_section then
                section = maybe_section
                -- reset tags since a section refers to a new plugin
                tags = {}
            end

            -- parse tags
            if line:match(tags_pat) then
                tags = {}
                for tag in line:gmatch('@(%S*)') do
                    table.insert(tags, tag)
                end
            end

            -- parse normal cheatline
            local description, cheatcode = line:match(cheatline_pat)
            if description and cheatcode then
                table.insert(
                    cheats, {
                        section = section,
                        description = description,
                        tags = tags,
                        cheatcode = cheatcode,
                    }
                )
            end
        end
    end

    return cheats
end

-- Use a floating window to show cheatsheets in a syntax highlighted buffer
M.show_cheatsheet_float = function()
    -- handle to an unlisted scratch buffer
    local bufhandle = vim.api.nvim_create_buf(false, true)
    if bufhandle == 0 then error("cheatsheet: Could not open temp buffer") end

    -- taken from plenary.nvim for centering the floating window
    local width = math.floor(vim.o.columns * 0.7)
    local height = math.floor(vim.o.lines * 0.7)

    local top = math.floor(((vim.o.lines - height) / 2) - 1)
    local left = math.floor((vim.o.columns - width) / 2)

    local float_opts = {
        relative = 'editor',
        row = top,
        col = left,
        width = width,
        height = height,
        border = "single",
    }

    local winhandle = vim.api.nvim_open_win(bufhandle, true, float_opts)
    if winhandle == 0 then
        error("cheatsheet: Could not open floating window")
    end

    for _, cheatfile in ipairs(M.get_cheatsheet_files()) do
        vim.api.nvim_command("$read " .. cheatfile)
        -- add a newline after every concat (puts the expression '' at file end)
        vim.api.nvim_command("$put =''")
    end

    vim.api.nvim_buf_set_virtual_text(
        bufhandle, 0, 0,
            { { "Press [q] to close, [e] to edit your cheatsheet", "PreProc" } },
            {}
    )

    vim.bo.filetype = 'cheatsheet'
    vim.bo.buftype = 'nofile' -- do not consider buffer contents as a file
    vim.bo.modifiable = false
    vim.bo.buflisted = false -- do not show in :buffers
    vim.bo.swapfile = false
    vim.wo.number = false
    vim.wo.relativenumber = false

    vim.api.nvim_buf_set_keymap(
        0, 'n', 'q', ':close<CR>', { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        0, 'n', 'e', ':close<CR>:CheatsheetEdit<CR>',
            { noremap = true, silent = true }
    )
end

-- Use Telescope to show and filter cheatsheets
M.show_cheatsheet_telescope = function(opts)
    require('cheatsheet.telescope').pick_cheat(opts)
end

-- Use Telescope for displaying cheatsheets and if not installed, use the
-- builtin floating window method.
M.show_cheatsheet = function(opts)
    if pcall(require, 'telescope') then
        M.show_cheatsheet_telescope(opts)
    else
        M.show_cheatsheet_float()
    end
end

return M
