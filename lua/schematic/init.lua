local schematic = {
  options = {
    schematic_files = {"schematic.json"},

    on_project_loaded = nil,
  },

  json_decode = vim.json.decode
}

local active_project = nil
local projects = {}

local function complete_config_name(leading)
  local results = {}
  if active_project ~= nil then
    for _, config in ipairs(active_project.configs) do
      if vim.startswith(config.name, leading) then
        table.insert(results, config.name)
      end
    end

    table.sort(results)
  end

  return results
end

local function complete_target_name(leading)
  local results = {}
  if active_project ~= nil then
    for _, target in ipairs(active_project.targets) do
      if vim.startswith(target.name, leading) then
        table.insert(results, target.name)
      end
    end

    table.sort(results)
  end

  return results
end

function schematic.load(directory)
  if #schematic.options.schematic_files == 0 then
    return nil
  end

  directory = directory or vim.loop.cwd()
  local schematic_files = vim.fs.find(schematic.options.schematic_files, {upward = true, path = directory, limit = 1})
  if #schematic_files > 0 then
    local root = vim.fs.dirname(schematic_files[1])
    if projects[root] ~= nil then
      return projects[root]
    end

    local text = vim.fn.join(vim.fn.readfile(schematic_files[1]), "")
    local json = schematic.json_decode(text)
    if json == nil then
      return nil
    end

    local result = {
      name = json.name,
      root = root,
    }

    result.configs = {}
    result.active_config = 0
    for _, spec in ipairs(json.configs) do
      local config = {
        name = spec.name,
        directory = result.root .. "/" .. spec.directory
      }

      table.insert(result.configs, config)
      if result.active_config == 0 then
        result.active_config = 1
      end
    end

    result.targets = {}
    result.active_target = 0
    for _, spec in ipairs(json.targets) do
      local target = {
        name = spec.name,
        path = spec.path,
      }

      table.insert(result.targets, target)
      if result.active_target == 0 then
        result.active_target = 1
      end
    end

    projects[root] = result

    if schematic.options.on_project_loaded ~= nil then
      schematic.options.on_project_loaded(result)
    end

    return result
  end

  return nil
end

function schematic.project()
  return active_project
end

function schematic.config()
  if active_project ~= nil and active_project.active_config > 0 then
    return active_project.configs[active_project.active_config]
  end

  return nil
end

function schematic.target()
  if active_project ~= nil and active_project.active_target > 0 then
    local result = vim.deepcopy(active_project.targets[active_project.active_target])
    result.path = string.gsub(result.path, "${config.directory}", schematic.config().directory)
    return result
  end

  return nil
end

function schematic.set_config(name)
  if active_project ~= nil then
    for index, config in ipairs(active_project.configs) do
      if name == config.name then
        active_project.active_config = index
        break
      end
    end
  end
end

function schematic.set_target(name)
  if active_project ~= nil then
    for index, target in ipairs(active_project.targets) do
      if name == target.name then
        active_project.active_target = index
        break
      end
    end
  end
end

local function rescan()
  active_project = schematic.load(vim.loop.cwd())
end

function schematic.setup(options)
  schematic.options = vim.tbl_extend("keep", options, schematic.options)
  vim.api.nvim_create_autocmd({"VimEnter", "DirChanged"}, {callback = rescan})

  vim.api.nvim_create_user_command("Config", function(command) schematic.set_config(command.args) end, {nargs = 1, complete = complete_config_name})
  vim.api.nvim_create_user_command("Target", function(command) schematic.set_target(command.args) end, {nargs = 1, complete = complete_target_name})
end

return schematic

