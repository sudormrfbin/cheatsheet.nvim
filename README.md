# cheatsheet.nvim

A searchable cheatsheet for neovim from within the editor using
[Telescope](https://github.com/nvim-telescope/telescope.nvim)
(fallback to displaying in a floating window if Telescope is not
installed), because hoomans suck at remembering stuff:

![cheatsheet.nvim with Telescope](https://user-images.githubusercontent.com/23398472/120632733-e6191f80-c486-11eb-90d6-e26bacf83c20.png)

## Installation

Installing Telescope is not required, but *highly* recommended for
using cheatsheets this plugin effectively. `popup.nvim` and `plenary.nvim`
are used by Telescope.

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'sudormrfbin/cheatsheet.nvim'
" optional
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('sudormrfbin/cheatsheet.nvim')
" optional
call dein#add('nvim-lua/popup.nvim')
call dein#add('nvim-lua/plenary.nvim')
call dein#add('nvim-telescope/telescope.nvim')
```
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'sudormrfbin/cheatsheet.nvim',
  -- optional
  requires = {
    {'nvim-telescope/telescope.nvim'},
    {'nvim-lua/popup.nvim'},
    {'nvim-lua/plenary.nvim'},
  }
}
```

## Usage

Use the `:Cheatsheet` command which automatically uses Telescope if installed
or falls back to showing all the cheatsheet files concatenated in a floating
window. A default mapping `<leader>?` is provided for `:Cheatsheet` 
(not bound if alerady in use). By default the `<leader>` key is `\`.

Your cheatsheet file is a simple text file with the name `cheatsheet.txt` found in
`~/.config/nvim/` (`~/AppData/Local/nvim/` if you're on Windows) alongside your
`init.vim`. Use the `:CheatsheetEdit` command to open it in a buffer to edit.

A [builtin cheatsheet](./doc/cheatsheet-default.txt) lists most of the useful inbuilt vim mappings and commands,
useful for people still finding their way around the editor (and for others
wanting to scratch the occasional I've-been-using-vim-for-years-but-forgot-how-to-scroll-horizontally
itch). Disable it with `let g:cheatsheet_use_default = v:false`.

| Telescope mappings | Description                                 |
| ---                | ---                                         |
| `<C-E>`            | Edit user cheatsheet à la `:CheatsheetEdit` |
| `<C-D>`            | Toggle `g:cheatsheet_use_default`           |
| `Enter`            | Close the Telescope window                  |

Since `cheatsheet.nvim` provides it's own commands,  it is not required to
"load" `cheatsheet.nvim` with Telescope which is usually required for plugins
using Telescope.

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
    ```

See this project's [cheatsheet](./cheatsheet.txt) and the
[default](./doc/cheatsheet-default.txt) included one for more examples.

## For Plugin Authors

You can put a `cheatsheet.txt` file in the root of your repo (like in this repo)
and it will be picked up automatically and displayed on `:Cheatsheet`.

## Acknowledgements

This plugin was inspired by (and borrowed some code and the default cheatsheat)
from [cheat40](https://github.com/lifepillar/vim-cheat40).
