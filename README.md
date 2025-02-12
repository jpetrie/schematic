# Schematic
Schematic is a Neovim plugin that provides structured projects (with configuration and target information) similar to
that of IDEs like Xcode or Visual Studio.

Schematic looks for a JSON file ("schematic.json" by default) to identify the root of a project, and parses that file
for configuration target information. The loaded information is made available within Neovim, allowing you to further
tailor Neovim's behavior to suit. For example, you can use the information to create build tasks using
[overseer.nvim](https://github.com/stevearc/overseer.nvim/), or to configure
[nvim-dap](https://github.com/mfussenegger/nvim-dap) for debugging.

## Installation
Install via your plugin manager of choice. For example, using [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  "jpetrie/schematic",
  opts = {
    -- A function called when a project is activated; called with the project's table.
    on_activated = function(project) ... end,
  },
}
```

## Configuration
Schematic comes with the following default options. See `:help schematic` for more details.

```lua
{
  -- A list of file names to search for which will provide the project schematics.
  schematic_files = {"schematic.json"},

  hooks = {
    clean = function(project)
      -- Code to execute when the 'clean' task is invoked.
    end,
    build = function(project)
      -- Code to execute when the 'build' task is invoked.
    end,
    run = function(project)
      -- Code to execute when the 'run' task is invoked.
    end,
  },

  -- A function called when a project is activated; called with the project's table.
  on_activated = nil,
}
```

## Schematic Files

A Schematic JSON file looks like:

```json
{
  "name": "My Project",
  "tasks":
  {
    "clean": "make clean",
    "build": "make ${target.name}"
  },
  "configs": [
    {
      "name": "Debug",
      "directory": "build/debug"
    },
  ],
  "targets": [
    {
      "name": "My App",
      "path": "${config.directory}/myapp"
    },
  ]
}
```

Within targets and tasks, placeholders (such as `${target.name}` or `${config.directory}`) can be used; they will
resolve to the appropriate values when Schematic sets a target as active.

## Projects

A project table created by Schematic has the following structure:

```lua
{
  name = "My Project",
  root = "path/to/myproject"
  metadata = {
      -- An empty table you can insert arbitrary key-value data into.
  },

  tasks = {
    clean = "make clean",
    build = "make ${target.name}",
  },

  configs = {
      { name = "Debug" directory = "build/debug" },
  },
  config = {
      -- A copy of the active configuration from the configs list.
  }

  targets = {
    { name = "My App" path = "{$config.directory}/myapp" },
  },
  target = {
      -- A copy of the active target from the targets list, with placeholders resolved.
  }
}
```

