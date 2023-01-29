local utils = require('cheatsheet.utils')
local config = require('cheatsheet.config')
local filter_insert = utils.filter_insert
-- plenary is only used for telescope specific code
local has_path, path = pcall(require, "plenary.path")

local M = {}

M.setup = function(opts) config.setup(opts) end

-- Includes the user's `cheatsheet.txt` file.
-- Includes `cheatsheet.txt` files from any directory in runtimepath if configured to do so.
-- Includes bundled cheatsheets if configured to do so.
-- @param *opts* config.options like table
-- @return array of filepaths
M.get_cheatsheet_files = function(opts)
    opts = opts or config.options

    -- see include argument of utils.filter_insert
    local plugin_include = {}
    if opts.include_only_installed_plugins then
        local rtp_dirs = {}
        for _, dir in pairs(vim.api.nvim_list_runtime_paths()) do
            table.insert(rtp_dirs, dir:match(".+/(.+)"))
        end
        plugin_include = { enabled = rtp_dirs }
    else
        plugin_include = true
    end

    local cheatsheet_name_pat = '.+/cheatsheets/cheatsheet%-(.+)%.txt'
    local cheatsheet_plugin_name_pat =
        '.+/cheatsheets/plugins/cheatsheet%-(.+)%.txt'

    local bundled_plugins = {}
    filter_insert(
        bundled_plugins, utils.get_bundled_plugin_cheatsheets(),
            cheatsheet_plugin_name_pat, plugin_include
    )

    -- Includes user's cheatsheet.
    local cheats = { utils.get_user_cheatsheet() }

    -- Includes rtp cheatsheets (if configured to do so).
    local rtp_cheatsheets = vim.api.nvim_get_runtime_file("cheatsheet.txt", true)
    filter_insert(cheats, rtp_cheatsheets, cheatsheet_name_pat, opts.rtp_cheatsheets)

    -- Includes bundled cheatsheets (if configured to do so).
    local bundled_cheatsheets = utils.get_bundled_cheatsheets()
    filter_insert(cheats, bundled_cheatsheets, cheatsheet_name_pat, opts.bundled_cheatsheets)

    filter_insert(
        cheats, bundled_plugins, cheatsheet_plugin_name_pat,
            opts.bundled_plugin_cheatsheets
    )

    -- https://github.com/neovim/neovim/issues/14294
    -- returned table may have duplicated entries
    return utils.dedupe_array(cheats)
end

-- For storing cheats that are added programmatically.
-- array of {description, cheatcode, section, {tags}}
M._loaded_cheats = {}

-- Add a cheat which will be shown alongside cheats loaded from cheatsheet files.
-- @param description: string
-- @param cheatcode: string
-- @param section: string
-- @param tags: array of alternative names for the section
-- TODO: Cheats added this way are not shown in the floating window, only telescope
M.add_cheat = function(description, cheatcode, section, tags)
    section = section or "default"
    tags = tags or {}
    table.insert(
        M._loaded_cheats, {
            section = section,
            description = description,
            tags = tags,
            cheatcode = cheatcode,
        }
    )
end

-- Aggregates cheats from cheatsheets and returns a structured repr.
-- Also included cheats from _loaded_cheats.
-- Ignores comments and newlines (except for metadata comments).
-- @return array of {description, cheatcode, section, {tags}} for each cheat
M.get_cheats = function(opts)
    assert(has_path, "plenary.nvim not installed")

    local section_pat = '^##%s*(%S*)'
    local tags_pat = '^##.*@%S*'
    local cheatline_pat = '^([^#]-)%s*|%s*(.-)%s*$'

    local cheats = {}
    for _, cheatfile in ipairs(M.get_cheatsheet_files(opts)) do
        local section = "default"
        local tags = {}
        for _, line in ipairs(path.readlines(cheatfile)) do
            -- parse section if line is metadata comment
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

    filter_insert(cheats, M._loaded_cheats, nil, true)
    return cheats
end

-- Use a floating window to show cheatsheets in a syntax highlighted buffer
-- NOTE: Does *not* show cheats added using `add_cheats` yet (TODO)
M.show_cheatsheet_float = function(opts)
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

    for _, cheatfile in ipairs(M.get_cheatsheet_files(opts)) do
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
M.show_cheatsheet_telescope = function(opts, telescope_opts)
    require('cheatsheet.telescope').pick_cheat(telescope_opts, opts)
end

-- Use Telescope for displaying cheatsheets and if not installed, use the
-- builtin floating window method.
M.show_cheatsheet = function(opts, telescope_opts)
    if pcall(require, 'telescope') then
        M.show_cheatsheet_telescope(opts, telescope_opts)
    else
        M.show_cheatsheet_float(opts)
    end
end

return M
