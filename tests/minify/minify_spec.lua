describe('minify', function()
  local original_notify
  local original_keymap_set
  local original_executable
  local original_buf_get_lines
  local original_buf_set_lines
  local original_cmd
  local original_filetype
  local original_line
  local original_system
  local original_vim_system

  before_each(function()
    package.loaded['minify'] = nil
    original_notify = vim.notify
    original_keymap_set = vim.keymap.set
    original_executable = vim.fn.executable
    original_buf_get_lines = vim.api.nvim_buf_get_lines
    original_buf_set_lines = vim.api.nvim_buf_set_lines
    original_cmd = vim.cmd
    original_filetype = vim.bo.filetype
    original_line = vim.fn.line
    original_system = vim.fn.system
    original_vim_system = vim.system
  end)

  after_each(function()
    vim.notify = original_notify
    vim.keymap.set = original_keymap_set
    vim.fn.executable = original_executable
    vim.api.nvim_buf_get_lines = original_buf_get_lines
    vim.api.nvim_buf_set_lines = original_buf_set_lines
    vim.cmd = original_cmd
    vim.bo.filetype = original_filetype
    vim.fn.line = original_line
    vim.fn.system = original_system
    vim.system = original_vim_system
  end)

  it('merges user options on setup', function()
    local plugin = require('minify')
    vim.keymap.set = function() end

    plugin.setup({
      keymap = '<leader>mm',
      minifiers = {
        javascript = {
          cmd = 'esbuild',
          args = { '--minify' },
        },
      },
    })

    assert.are.equal('<leader>mm', plugin.config.keymap)
    assert.are.equal('esbuild', plugin.config.minifiers.javascript.cmd)
    assert.are.equal('terser', plugin.config.minifiers.typescript.cmd)
  end)

  it('does not notify when notify is disabled', function()
    local plugin = require('minify')
    local called = false

    vim.keymap.set = function() end
    vim.bo.filetype = 'unknown'
    vim.notify = function()
      called = true
    end

    plugin.setup({ notify = false })
    plugin.minify()

    assert.is_false(called)
  end)

  it('registers the configured keymap on setup', function()
    local plugin = require('minify')
    local calls = {}

    vim.keymap.set = function(mode, lhs, rhs, opts)
      table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
    end

    plugin.setup({ keymap = '<leader>mm' })

    assert.are.equal(2, #calls)
    assert.are.equal('n', calls[1].mode)
    assert.are.equal('<leader>mm', calls[1].lhs)
    assert.are.equal(plugin.minify, calls[1].rhs)
    assert.same({ 'v', 'x' }, calls[2].mode)
    assert.are.equal('<leader>mm', calls[2].lhs)
  end)

  it('warns when no minifier is configured for the current filetype', function()
    local plugin = require('minify')
    local notified_message
    local notified_level

    vim.keymap.set = function() end
    vim.bo.filetype = 'unknown'
    vim.notify = function(message, level)
      notified_message = message
      notified_level = level
    end

    plugin.setup({ notify = true })
    plugin.minify()

    assert.are.equal('No minifier configured for filetype: unknown', notified_message)
    assert.are.equal(vim.log.levels.WARN, notified_level)
  end)

  it('uses filetype aliases when dispatching minifiers', function()
    local plugin = require('minify')
    local written_lines

    vim.keymap.set = function() end
    vim.bo.filetype = 'javascriptreact'
    vim.fn.executable = function(cmd)
      return cmd == 'cat' and 1 or 0
    end
    vim.api.nvim_buf_get_lines = function()
      return { 'const x = 1;' }
    end
    vim.system = function()
      return {
        wait = function()
          return { code = 0, stdout = 'const x = 1;\n', stderr = '' }
        end,
      }
    end
    vim.api.nvim_buf_set_lines = function(_, _, _, _, lines)
      written_lines = lines
    end
    vim.cmd = function() end
    vim.fn.line = function(arg)
      if arg == '$' then
        return 1
      end
      return 1
    end

    plugin.setup({
      minifiers = {
        javascript = {
          cmd = 'cat',
          args = {},
        },
      },
    })
    plugin.minify()

    assert.same({ 'const x = 1;' }, written_lines)
  end)

  it('supports custom external programs', function()
    local plugin = require('minify')
    local written_lines

    vim.keymap.set = function() end
    vim.bo.filetype = 'typescript'
    vim.fn.executable = function(cmd)
      return cmd == 'cat' and 1 or 0
    end
    vim.api.nvim_buf_get_lines = function()
      return { 'let x: number = 1;' }
    end
    vim.system = function()
      return {
        wait = function()
          return { code = 0, stdout = 'let x: number = 1;\n', stderr = '' }
        end,
      }
    end
    vim.api.nvim_buf_set_lines = function(_, _, _, _, lines)
      written_lines = lines
    end
    vim.cmd = function() end
    vim.fn.line = function()
      return 1
    end

    plugin.setup({
      minifiers = {
        typescript = {
          cmd = 'cat',
          args = {},
        },
      },
    })
    plugin.minify()

    assert.same({ 'let x: number = 1;' }, written_lines)
  end)

  it('minifies only the selected range for the command form', function()
    local plugin = require('minify')
    local captured_start
    local captured_end

    vim.keymap.set = function() end
    vim.bo.filetype = 'javascript'
    vim.fn.executable = function()
      return 1
    end
    vim.api.nvim_buf_get_lines = function(_, start_line, end_line)
      captured_start = start_line
      captured_end = end_line
      return { 'const x = 1;' }
    end
    vim.system = function()
      return {
        wait = function()
          return { code = 0, stdout = 'const x=1;', stderr = '' }
        end,
      }
    end
    vim.api.nvim_buf_set_lines = function() end
    vim.cmd = function() end

    plugin.setup({})
    plugin.minify_command({ range = 2, line1 = 3, line2 = 5 })

    assert.are.equal(2, captured_start)
    assert.are.equal(5, captured_end)
  end)
end)
