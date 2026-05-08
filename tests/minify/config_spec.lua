describe('minify config', function()
  before_each(function()
    package.loaded['minify.config'] = nil
  end)

  it('returns a fresh merged config without mutating defaults', function()
    local config = require('minify.config')

    local merged = config.merge({
      keymap = '<leader>mm',
      minifiers = {
        javascript = {
          cmd = 'esbuild',
          args = { '--minify' },
        },
      },
    })

    local defaults = config.defaults()

    assert.are.equal('<leader>mm', merged.keymap)
    assert.are.equal('esbuild', merged.minifiers.javascript.cmd)
    assert.are.equal('<leader>min', defaults.keymap)
    assert.are.equal('terser', defaults.minifiers.javascript.cmd)
  end)

  it('rejects invalid keymaps', function()
    local config = require('minify.config')

    assert.has_error(function()
      config.merge({ keymap = '' })
    end, 'minify.nvim: keymap must be a non-empty string')
  end)

  it('rejects invalid notify values', function()
    local config = require('minify.config')

    assert.has_error(function()
      config.merge({ notify = 'yes' })
    end, 'minify.nvim: notify must be a boolean')
  end)

  it('rejects invalid minifier definitions', function()
    local config = require('minify.config')

    assert.has_error(function()
      config.merge({
        minifiers = {
          javascript = {
            cmd = '',
            args = { '--minify' },
          },
        },
      })
    end, 'minify.nvim: minifiers.javascript.cmd must be a non-empty string')

    assert.has_error(function()
      config.merge({
        minifiers = {
          javascript = {
            cmd = 'terser',
            args = 'bad',
          },
        },
      })
    end, 'minify.nvim: minifiers.javascript.args must be a list of strings')
  end)
end)
