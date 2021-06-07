local utils = require('cheatsheet.utils')
local config = require('cheatsheet.config')
-- plenary is only used for telescope specific code
local has_path, path = pcall(require, "plenary.path")

local M = {}

M.setup = function(opts) config.setup(opts) end

-- Get `cheatsheet.txt` files from any directory in runtimepath
-- Inlcudes bundled cheatsheets if configured to do so.
-- @param *opts* config.optsa like table
-- @return array of filepaths
M.get_cheatsheet_files = function(opts)
    opts = opts or config.options

    -- Insert elements from `from_tbl` into `ins_tbl`. If `include` is a bool,
    -- it controls appending everything in `from_tbl` to `ins_tbl`. If it is a
    -- table, Use `pattern` to extract a match from an element in `from_tbl`
    -- and insert only if match is present in `include.enabled` or not present
    -- in `include.disabled`.
    local function filter_insert(ins_tbl, from_tbl, pattern, include)
        if include == false then return end

        if include == true then
            for _, file in ipairs(from_tbl) do
                table.insert(ins_tbl, file)
            end
            return
        end
        assert(type(include) == "table", "Invalid table format")

        if include.enabled ~= nil then
            for _, element in ipairs(from_tbl) do
                local match = element:match(pattern)
                if utils.has_value(include.enabled, match) then
                    table.insert(ins_tbl, element)
                end
            end
        elseif include.disabled ~= nil then
            for _, element in ipairs(from_tbl) do
                local match = element:match(pattern)
                print(match)
                if not utils.has_value(include.disabled, match) then
                    table.insert(ins_tbl, element)
                end
            end
        end
    end

    local cheats = vim.api.nvim_get_runtime_file("cheatsheet.txt", true)
    local bundled = utils.get_bundled_cheatsheets()
    local bundled_plugins = utils.get_bundled_plugin_cheatsheets()

    filter_insert(
        cheats, bundled, '.+/cheatsheets/cheatsheet%-(.+)%.txt',
            opts.bundled_cheatsheets
    )
    filter_insert(
        cheats, bundled_plugins, '.+/cheatsheets/plugins/cheatsheet%-(.+)%.txt',
            opts.bundled_plugin_cheatsheets
    )

    -- https://github.com/neovim/neovim/issues/14294
    -- returned table may have duplicated entries
    return utils.dedupe_array(cheats)
end

-- Aggregates cheats from cheatsheets and returns a structured repr.
-- Ignores comments and newlines (except for metadata comments).
-- @return array of {description, cheatcode, section, {tags}} for each cheat
M.get_cheats = function()
    assert(has_path, "plenary.nvim not installed")

    local section_pat = '^##%s*(%S*)'
    local tags_pat = '^##.*@%S*'
    local cheatline_pat = '^([^#]-)%s*|%s*(.-)%s*$'

    local cheats = {}
    for _, cheatfile in ipairs(M.get_cheatsheet_files()) do
        local section = "default"
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
    assert(bufhandle, "Could not open temp buffer")

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
    assert(winhandle, "Could not open floating window")

    for _, cheatfile in ipairs(M.get_cheatsheet_files()) do
        vim.api.nvim_command("$read " .. cheatfile)
        -- add a newline after every concat (puts the expression '' at file end)
        vim.api.nvim_command("$put =''")
    end
    vim.cmd("normal! gg0")

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
