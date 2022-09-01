# cheatsheet.nvim

A searchable cheatsheet for neovim from within the editor using
[Telescope](https://github.com/nvim-telescope/telescope.nvim) (fallback to
displaying in a floating window if Telescope is not installed) with command autofill,
bundled cheats for the editor, vim plugins, nerd-fonts, etc because hoomans suck at
remembering stuff:

![cheatsheet.nvim gif](https://user-images.githubusercontent.com/23398472/121174386-7a182c00-c877-11eb-979b-5d5e6f8267d8.gif)

<sup>Font: [mononoki](https://madmalik.github.io/mononoki/), Colorscheme: [onedark](https://github.com/joshdick/onedark.vim), [Dotfiles](https://github.com/sudormrfbin/dotfiles2)</sup>

## Table of Contents

* [Features](#features)
* [Quickstart](#quickstart)
* [Installation](#installation)
* [Usage](#usage)
    * [Auto Fill Commands From Telescope](#auto-fill-commands-from-telescope)
* [Bundled Cheatsheets](#bundled-cheatsheets)
* [Configuration](#configuration)
* [`cheatsheet.txt` File Format](#cheatsheettxt-file-format)
* [For Plugin Authors](#for-plugin-authors)
* [Acknowledgements](#acknowledgements)

## Features

- Telescope interface to quickly find what you're looking for
- Simple and portable [cheatsheet format](#cheatsheettxt-file-format) -- simple text file, no lua or vimscript involved
- [Fill out command line automatically](#auto-fill-commands-from-telescope) (without execution) if selected item in Telescope is a `:command`
- [Bundled cheatsheets](#bundled-cheatsheets) for:
    - nerd-fonts, box drawing characters, lua patterns, etc
    - other plugins like gitsigns, sandwich, easy-align, etc
- Enable bundled plugin cheatsheets only for plugins you have installed locally
- Use a `cheatsheet.txt` file from other installed plugins [if found in their directories](#for-plugin-authors)
- Copy cheats directly from Telescope interface

## Quickstart

1. Forget how to do `X`
2. Hit `<leader>?` to invoke cheatsheet telescope
3. Type in `X` and find forgotten mapping/command
4. No more ???
5. Profit !!

## Installation

Installing Telescope is not required, but *highly* recommended for
using this plugin effectively. `popup.nvim` and `plenary.nvim`
are used by Telescope.

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'sudormrfbin/cheatsheet.nvim'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('sudormrfbin/cheatsheet.nvim')

call dein#add('nvim-lua/popup.nvim')
call dein#add('nvim-lua/plenary.nvim')
call dein#add('nvim-telescope/telescope.nvim')
```
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'sudormrfbin/cheatsheet.nvim',

  requires = {
    {'nvim-telescope/telescope.nvim'},
    {'nvim-lua/popup.nvim'},
    {'nvim-lua/plenary.nvim'},
  }
}
```

Subscribe to the [Updates](https://github.com/sudormrfbin/cheatsheet.nvim/issues/1)
issue thread to be notified about new features.

## Usage

Use the `:Cheatsheet` command which automatically uses Telescope if installed
or falls back to showing all the cheatsheet files concatenated in a floating
window. A default mapping `<leader>?` is provided for `:Cheatsheet` 
(not bound if already in use). By default the `<leader>` key is `\`.

Your cheatsheet file is a simple text file with the name `cheatsheet.txt` found in
`~/.config/nvim/` (`~/AppData/Local/nvim/` if you're on Windows) alongside your
`init.vim`. Use the `:CheatsheetEdit` command to open it in a buffer to edit.

| Telescope mappings | Description                                 |
| ---                | ---                                         |
| `<C-E>`            | Edit user cheatsheet à la `:CheatsheetEdit` |
| `<C-Y>`            | Yank the cheatcode                          |
| `Enter`            | Fill in the command line; see below         |

#### Auto Fill Commands From Telescope

On `Enter`, if the current selection is a command, it will be filled
in the command line as if you had typed it (it won't be executed yet).
Note that it will *stop* filling the command line when it encounters a `{`
or `[`. So if the cheat is `:set textwidth={n}`, your commandline will
have `:set textwidth=` typed into it and the cursor at end.

> Since `cheatsheet.nvim` provides it's own commands,  it is not required to
> "load" `cheatsheet.nvim` with Telescope which is usually required for plugins
> using Telescope.

## Bundled Cheatsheets

These are the cheatsheets shipped with `cheatsheet.nvim` (PRs welcome!):

- [`default`](./cheatsheets/cheatsheet-default.txt) (vim builtin commands and mappings)
- [`nerd-fonts`](https://www.nerdfonts.com/) (useful for ricing paired with `<C-Y>` for copying the symbol)
- `unicode` (currently only has box drawing characters)
- `regex` (PCRE)
- `markdown` (not fully featured yet)

<details>
  <summary>Plugin cheatsheets (click to expand)</summary>


  Ideally plugin authors would [supply their own](#for-plugin-authors)
  `cheatsheet.txt`, but since that is not possible for every plugin, they are
  collected in [cheatsheets/plugins](./cheatsheets/plugins).

  - `auto-session`
  - `gitsigns.nvim`
  - `telescope.nvim`
  - `vim-easy-align`
  - `vim-sandwich`
  - `goto-preview`
  - `octo.nvim`

</details>

## Configuration

This is the default configuration:

```lua
require("cheatsheet").setup({
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

    -- Key mappings bound inside the telescope window
    telescope_mappings = {
        ['<CR>'] = require('cheatsheet.telescope.actions').select_or_fill_commandline,
        ['<A-CR>'] = require('cheatsheet.telescope.actions').select_or_execute,
        ['<C-Y>'] = require('cheatsheet.telescope.actions').copy_cheat_value,
        ['<C-E>'] = require('cheatsheet.telescope.actions').edit_user_cheatsheet,
    }
})
```

For example if you want to bind `Enter` to directly execute commands without
[autofilling](#auto-fill-commands-from-telescope) them
and instead want `Alt-Enter` to autofill, put this in your config:

```lua
require('cheatsheet').setup({
    telescope_mappings = {
        ['<CR>'] = require('cheatsheet.telescope.actions').select_or_execute,
        ['<A-CR>'] = require('cheatsheet.telescope.actions').select_or_fill_commandline,
    }
})
```

`bundled_cheatsheets` and `bundled_plugin_cheatsheets` can also be tables to
have more fine grained control for selective usage:

```lua
require("cheatsheet").setup({
    bundled_cheatsheets = {
        -- only show the default cheatsheet
        enabled = { "default" },
    },
    bundled_plugin_cheatsheets = {
        -- show cheatsheets for all plugins except gitsigns
        disabled = { "gitsigns.nvim" },
    }
})
```

## `cheatsheet.txt` File Format

- `#` starts a normal comment, blank lines are ignored.
- `##` starts a metadata comment for specifying sections and tags.

    `## section-name @tag1 @tag2`: here `section-name` is the name of a plugin
    or a simple name to group some cheats together. `tag1` and `tag2` are alternative
    names that you might later remember the section name with. For example the section
    name can be [`sandwich`](https://github.com/machakann/vim-sandwich) and the tag
    can be `@surround`.

- A cheat consists of a description and the key/command/anything separated by `|`

    ```
    Open cheatsheet | <leader>?
    Open cheatsheet in floating window | :CheatSheet!

    View mappings | :map [mapping]
    Set text width to {n} | :set tw={n}
    ```

    Like help files, anything in square brackets is `[optional]` and anything
    in curly brackets is `{required}` arguments. Some commands require a
    register or mark or number before them, and they are marked with `{r}`,
    `{m}`, `{n}`, etc. These are not hard and fast rules, simply conventions in
    the default cheatsheet -- you can of course ignore them when writing your
    own cheats (though if you want commands to be presented in the command line
    properly on pressing `Enter`, see the note about it in the Usage section.)

See this project's [cheatsheet](./cheatsheet.txt) and the
[default](./cheatsheets/cheatsheet-default.txt) included one for more examples.

## For Plugin Authors

You can put a `cheatsheet.txt` file in the root of your repo
([like](./cheatsheet.txt) in this repo) and it will be picked up automatically
and displayed on `:Cheatsheet`.  You don't have to add the file to your repo
*solely* to support searching it using `cheatsheet.nvim` -- the format is
simple enough to be opened and read normally and can serve as a great
quickstart for users.

## Add cheatsheets at runtime

You can use:
```
-- Add a cheat which will be shown alongside cheats loaded from cheatsheet files.
-- @param description: string
-- @param cheatcode: string
-- @param section: string
-- @param tags: array of alternative names for the section
M.add_cheat = function(description, cheatcode, section, tags)
```
to add cheatsheets dynamically at run time.

For example,
```
call v:lua.require("cheatsheet").add_cheat("Copy to system clipboard", "<leader>c", "default", [ "my" ])
```

## which-key.nvim integration

You can use
```
-- Create a mapping with description that will be added to cheatsheet.nvim and which-key.nvim.
-- @param map_command: string with a map command (see `:help :map-commands`)
-- @param description: string for both cheatsheet.nvim and which-key.nvim
-- @param section: string for cheatsheet.nvim
-- @param tags: array of alternative names for the section for cheatsheet.nvim
M.add_map = function(map_command, description, section, tags)
```
to create mappings with descriptions. The mapping command will be executed right 
away and the description will be added to both cheatsheet.nvim and which-key.nvim.

For example, add to your `.vimrc`:
```
function AddMap(command, description, ...)
    let section = get(a:, 1, 'default')
    let tags = get(a:, 2, [])
    call v:lua.require("cheatsheet").add_map(a:command, a:description, section, tags)
endfunction
```
and then
```
call AddMap("vnoremap <leader>c \"+y", "Copy to system clipboard")
```
Note that you have to use escapes for quotes and backslashes.

If you don't want to deal with escapes then you can use
```
-- Add description that will be added to cheatsheet.nvim and which-key.nvim.
-- @param mode: one char string for which-key
-- @param lhs: string with left hand side for mapping
-- @param description: string for both cheatsheet.nvim and which-key.nvim
-- @param section: string for cheatsheet.nvim
-- @param tags: array of alternative names for the section for cheatsheet.nvim
M.add_map_description = function(mode, lhs, description, section, tags)
```
to add only cheat description and use it like this:
```
vnoremap <leader>c "+y
call v:lua.require("cheatsheet").add_map_description("v", "<leader>c", "Copy to system clipboard")
```

## Acknowledgements

This plugin was inspired by (and borrowed some code and the default cheatsheat)
from [cheat40](https://github.com/lifepillar/vim-cheat40).
