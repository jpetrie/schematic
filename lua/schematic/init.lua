local schematic = {
  options = {
    schematic_files = {"schematic.json"},

    on_activated = nil,
  },

  json_decode = vim.json.decode,
}

local active_project = nil

function schematic.project()
  return active_project
end

local Project = {}
function Project.new(name, root)
  local data = {
    name = name,
    root = root,
    metadata = {},
    configs = {},
    config = nil,
    targets = {},
    target = nil,
  }

  return setmetatable(data, {__index = Project})
end

function Project:set_config(name)
  for _, config in ipairs(self.configs) do
    if name == config.name then
      self.config = vim.deepcopy(config)
      break
    end
  end
end

function Project:set_target(name)
  for _, target in ipairs(self.targets) do
    if name == target.name then
      self.target = vim.deepcopy(target)
      self.target.path= string.gsub(self.target.path, "${config.directory}", self.config.directory)
      break
    end
  end
end

local function load(file)
  local root = vim.fs.dirname(file)
  local json = schematic.json_decode(vim.fn.join(vim.fn.readfile(file), ""))
  if json == nil then
    return nil
  end

  local project = Project.new(json.name, root)
  for _, definition in ipairs(json.configs) do
    local config = {
      name = definition.name,
      directory = project.root .. "/" .. definition.directory
    }

    table.insert(project.configs, config)
    if project.config == nil then
      project:set_config(config.name)
    end
  end

  for _, definition in ipairs(json.targets) do
    local target = {
      name = definition.name,
      path = definition.path,
    }

    table.insert(project.targets, target)
    if project.target == nil then
      project:set_target(target.name)
    end
  end

  return project
end

local function scan(directory)
  if #schematic.options.schematic_files == 0 then
    return nil
  end

  directory = directory or vim.uv.cwd()

  local files = vim.fs.find(schematic.options.schematic_files, {upward = true, path = directory, limit = 1})
  if #files == 0 then
    return nil
  end

  local file = files[1]
  return load(file)
end

local function command_config(command)
  if active_project ~= nil then
    active_project:set_config(command.args)
  end
end

local function command_target(command)
  if active_project ~= nil then
    active_project:set_target(command.args)
  end
end

function schematic.setup(options)
  schematic.options = vim.tbl_extend("keep", options, schematic.options)

  vim.api.nvim_create_autocmd({"VimEnter", "DirChanged"}, {callback = function()
    active_project = scan()
    if active_project ~= nil and schematic.options.on_activated ~= nil then
      schematic.options.on_activated(active_project)
    end
  end})

  vim.api.nvim_create_user_command("Config", command_config, {nargs = 1})
  vim.api.nvim_create_user_command("Target", command_target, {nargs = 1})
end

return schematic

