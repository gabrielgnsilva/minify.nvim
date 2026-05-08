if vim.g.loaded_minify_plugin == 1 then
  return
end
vim.g.loaded_minify_plugin = 1

vim.api.nvim_create_user_command('Minify', function(opts)
  require('minify').minify_command(opts)
end, {
  desc = 'Minify current buffer or selection',
  range = true,
})
