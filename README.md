# Schematic
Schematic is a Neovim plugin that provides project configuration and target information, similar to that of IDEs like
Xcode or Visual Studio.

Schematic looks for a JSON file ("schematic.json" by default) in the project's directory and parses the contents, making
it available within Neovim via Lua, allowing you to further tailor Neovim's behavior to suit the specific project you're
working on. For example, you can use the information to filter the tasks to load in
[overseer.nvim](https://github.com/stevearc/overseer.nvim/), or which executable to pass to
[nvim-dap](https://github.com/mfussenegger/nvim-dap).

## Installation
Install via your plugin manager of choice. For example, using [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  "jpetrie/schematic",
  opts = {}
}
```

## Configuration
Schematic comes with the following default options. See `:help schematic` for more details.

```lua
{
  -- A list of file names to search for which will provide the project schematics.
  schematic_files = {"schematic.json"},
}
```

## Project Setup

