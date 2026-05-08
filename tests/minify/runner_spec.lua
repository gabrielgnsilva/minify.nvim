describe('minify runner', function()
  local original_system

  before_each(function()
    package.loaded['minify.runner'] = nil
    original_system = vim.system
  end)

  after_each(function()
    vim.system = original_system
  end)

  it('passes command args as a list and content as stdin', function()
    local runner = require('minify.runner')
    local received_command
    local received_input

    vim.system = function(command, opts)
      received_command = command
      received_input = opts.stdin
      return {
        wait = function()
          return { code = 0, stdout = 'const x=1;', stderr = '' }
        end,
      }
    end

    local result, err = runner.run({
      cmd = 'terser',
      args = { '--mangle', '--compress' },
    }, 'const x = 1;')

    assert.is_nil(err)
    assert.are.equal('const x=1;', result)
    assert.are.same({ 'terser', '--mangle', '--compress' }, received_command)
    assert.are.equal('const x = 1;', received_input)
  end)

  it('returns stderr output when execution fails', function()
    local runner = require('minify.runner')

    vim.system = function()
      return {
        wait = function()
          return { code = 1, stdout = '', stderr = 'boom' }
        end,
      }
    end

    local result, err = runner.run({ cmd = 'terser', args = {} }, 'const x = 1;')

    assert.is_nil(result)
    assert.are.equal('boom', err)
  end)
end)
