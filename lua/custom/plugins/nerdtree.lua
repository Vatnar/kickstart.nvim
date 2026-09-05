-- NERDTree file tree (port of IdeaVim NERDTree)
local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'preservim/nerdtree' }

vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeAutoDeleteBuffer = 1

local function toggle_nerdtree()
  if vim.fn.exists 'g:NERDTree' == 1 and vim.fn.bufexists(vim.fn.bufnr 'NERD_tree_*') ~= 0 then
    vim.cmd 'NERDTreeToggle'
  else
    vim.cmd 'NERDTree'
  end
end

vim.keymap.set('n', '<leader>fb', toggle_nerdtree, { desc = 'Toggle NERD[F]ile [B]rowser / tree' })
vim.keymap.set('n', '<leader>ft', toggle_nerdtree, { desc = 'Toggle NERD[T]ree' })
