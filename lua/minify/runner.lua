local M = {}

function M.run(minifier, content)
  local command = vim.list_extend({ minifier.cmd }, minifier.args or {})
  local result = vim.system(command, { stdin = content, text = true }):wait()

  if result.code ~= 0 then
    return nil, result.stderr ~= '' and result.stderr or result.stdout
  end

  return result.stdout, nil
end

return M
