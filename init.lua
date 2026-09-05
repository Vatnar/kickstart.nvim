--[[
=============================================================================
 Configuration bootstrap (kickstart-style, split into modular files)
=============================================================================

 init.lua only handles:
   1. Fast startup + leader keys (must run before plugins load)
   2. The vim.pack manager intro / build hooks
   3. Delegating to the modular files in lua/custom/plugins/*.lua

 Every named section (options, keymaps, ui, telescope, lsp, conform, blink,
 treesitter, ideavim-keymaps, nerdtree) now lives in its own file under
 `lua/custom/plugins/`, auto-loaded by `require 'custom.plugins'` below.
 Follow that same one-file-per-feature pattern when adding new plugins.
=============================================================================
--]]

do
  vim.loader.enable()

  -- Leader keys MUST be set before any plugins load
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true
end

-- ============================================================
-- vim.pack plugin manager: build hooks
-- ============================================================
do
  -- See `:help vim.pack`, `:help vim.pack-examples`.
  -- To inspect plugin state / pending updates:  :lua vim.pack.update(nil, { offline = true })
  -- To update plugins:                          :lua vim.pack.update()

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

require 'custom.plugins'

-- vim: ts=2 sts=2 sw=2 et
