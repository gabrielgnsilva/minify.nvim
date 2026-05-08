# minify.nvim

Simple Neovim plugin to minify the current buffer or a visual selection using external CLI tools.

## Features

- Minify the whole current buffer
- Minify a selected range
- Works with any filetype configured in `opts.minifiers`
- Ships with defaults for:
  - `javascript`
  - `typescript`
  - `javascriptreact` → `javascript`
  - `typescriptreact` → `typescript`

## Plugin structure

- `plugin/minify.lua` registers the `:Minify` command
- `lua/minify.lua` exposes `setup(opts)`, `minify()`, and `minify_command()`
- `lua/minify/config.lua` owns defaults, merging, and config validation
- `lua/minify/runner.lua` executes minifiers safely with stdin

## Requirements

- Neovim 0.10+
- An external minifier installed for the filetypes you want to support

Default configuration expects:

- `terser`

## Installation

### lazy.nvim

```lua
{
  'gabrielgnsilva/minify.nvim',
  cmd = 'Minify',
  keys = '<leader>min',
  opts = {},
}
```

## Default configuration

```lua
{
  keymap = '<leader>min',
  notify = true,
  minifiers = {
    javascript = {
      cmd = 'terser',
      args = { '--mangle', '--compress', '--comments', 'all' },
    },
    typescript = {
      cmd = 'terser',
      args = { '--mangle', '--compress' },
    },
  },
}
```

## Usage

### Commands

- `:Minify` → minify the whole current buffer
- `:'<,'>Minify` → minify the current visual selection

The command is registered automatically by the plugin.

### Keymaps

By default:

- Normal mode: `<leader>min`
- Visual mode: `<leader>min`

## Configuration examples

### Change the keymap

```lua
opts = {
  keymap = '<leader>mm',
}
```

### Disable notifications

```lua
opts = {
  notify = false,
}
```

### Use another tool for JavaScript

```lua
opts = {
  minifiers = {
    javascript = {
      cmd = 'esbuild',
      args = { '--minify' },
    },
  },
}
```

### Add support for CSS

```lua
opts = {
  minifiers = {
    css = {
      cmd = 'lightningcss',
      args = { '--minify' },
    },
  },
}
```

### Add support for JSON

```lua
opts = {
  minifiers = {
    json = {
      cmd = 'jq',
      args = { '-c' },
    },
  },
}
```

## How filetypes work

The plugin uses `vim.bo.filetype` and looks up a matching entry in `opts.minifiers`.

That means you can support any filetype, as long as you configure a minifier for it.

Current built-in aliases:

- `javascriptreact` → `javascript`
- `typescriptreact` → `typescript`

## Notes

- This plugin does not ship with minifiers. You must install the CLI tools yourself.
- If the current filetype has no configured minifier, the plugin warns and does nothing.
- If the configured executable is missing, the plugin warns with the expected install command.
- Setup validates the keymap, notify flag, and configured minifier definitions early.

## Testing

From the plugin directory:

```bash
make test
```

## Release process

See [RELEASE.md](./RELEASE.md) for the release checklist and tag strategy.
