local M = {}

local default_config = {
  keymap = '<leader>min',
  notify = true,
  minifiers = {
    javascript = {
      cmd = 'terser',
      args = {
        '--mangle',
        '--compress',
        '--comments',
        'all',
      },
    },
    typescript = {
      cmd = 'terser',
      args = {
        '--mangle',
        '--compress',
      },
    },
  },
}

local function clone_defaults()
  return vim.deepcopy(default_config)
end

local function validate_minifier(name, minifier)
  if type(minifier.cmd) ~= 'string' or minifier.cmd == '' then
    error(string.format('minify.nvim: minifiers.%s.cmd must be a non-empty string', name))
  end

  if type(minifier.args) ~= 'table' then
    error(string.format('minify.nvim: minifiers.%s.args must be a list of strings', name))
  end

  for _, arg in ipairs(minifier.args) do
    if type(arg) ~= 'string' then
      error(string.format('minify.nvim: minifiers.%s.args must be a list of strings', name))
    end
  end
end

local function validate(config)
  if type(config.keymap) ~= 'string' or config.keymap == '' then
    error('minify.nvim: keymap must be a non-empty string')
  end

  if type(config.notify) ~= 'boolean' then
    error('minify.nvim: notify must be a boolean')
  end

  for name, minifier in pairs(config.minifiers) do
    validate_minifier(name, minifier)
  end

  return config
end

function M.defaults()
  return clone_defaults()
end

function M.merge(opts)
  local merged = vim.tbl_deep_extend('force', clone_defaults(), opts or {})
  return validate(merged)
end

return M
