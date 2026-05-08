local M = {}
local minify_config = require('minify.config')
local runner = require('minify.runner')

M.config = minify_config.defaults()

local filetype_aliases = {
  javascriptreact = 'javascript',
  typescriptreact = 'typescript',
}

local function notify(message, level, opts)
  if opts and opts.notify == false then
    return
  end
  vim.notify(message, level)
end

local function is_cmd_available(cmd)
  return vim.fn.executable(cmd) == 1
end

local function get_filetype()
  local ft = vim.bo.filetype
  return filetype_aliases[ft] or ft
end

local function run_minifier(minifier, content)
  return runner.run(minifier, content)
end

local function minify_range(start_line, end_line)
  local ft = get_filetype()
  local minifier = M.config.minifiers[ft]

  if not minifier then
    notify(
      string.format('No minifier configured for filetype: %s', ft),
      vim.log.levels.WARN,
      M.config
    )
    return
  end

  if not is_cmd_available(minifier.cmd) then
    notify(
      string.format(
        "'%s' not found. Install it with: npm install -g %s",
        minifier.cmd,
        minifier.cmd
      ),
      vim.log.levels.ERROR,
      M.config
    )
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local content = table.concat(lines, '\n')
  local result, err = run_minifier(minifier, content)

  if err then
    notify(
      string.format('Minification failed:\n%s', err),
      vim.log.levels.ERROR,
      M.config
    )
    return
  end

  result = result:gsub('\n$', '')
  local result_lines = vim.split(result, '\n', { plain = true })
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, result_lines)

  local num_result_lines = #result_lines
  vim.cmd(
    string.format(
      '%d,%dnormal! ==',
      start_line,
      start_line + num_result_lines - 1
    )
  )

  notify('Minified successfully!', vim.log.levels.INFO, M.config)
end

function M.minify()
  minify_range(1, vim.fn.line('$'))
end

function M.minify_command(opts)
  if opts.range == 2 then
    minify_range(opts.line1, opts.line2)
  else
    M.minify()
  end
end

function M.setup(opts)
  if M._initialized then
    return
  end
  M._initialized = true
  M.config = minify_config.merge(opts)

  vim.keymap.set('n', M.config.keymap, M.minify, {
    desc = 'Minify buffer',
  })
  vim.keymap.set({ 'v', 'x' }, M.config.keymap, ":'<,'>Minify<CR>", {
    desc = 'Minify selection',
  })
end

return M
