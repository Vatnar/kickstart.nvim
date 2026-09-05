-- Load all custom plugins in a deterministic, dependency-safe order.
--
-- Each file here owns its own `vim.pack.add()` + `setup()` calls, mirroring
-- the file layout in lua/custom/plugins/*.lua. Order matters when a module
-- depends on another (e.g. ideavim-keymaps requires telescope.builtin).

local plugins = {
  'options',
  'keymaps',
  'ui',
  'telescope',
  'lsp',
  'conform',
  'blink',
  'treesitter',
  'ideavim-keymaps',
  'nerdtree',
}

for _, name in ipairs(plugins) do
  require('custom.plugins.' .. name)
end
