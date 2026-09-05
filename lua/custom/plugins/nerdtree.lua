-- NERDTree file tree (port of IdeaVim NERDTree)
local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'preservim/nerdtree' }

vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeAutoDeleteBuffer = 1

-- Toggle the tree; if you're already inside it, this puts you back in the file,
-- and vice-versa. Window navigation (<leader>vh/vl or <C-w>h/l) also moves
-- between the tree and your file since NERDTree opens as a split.
vim.keymap.set('n', '<leader>fb', '<Cmd>NERDTreeToggle<CR>', { desc = 'Toggle NERD[F]ile [B]rowser / tree' })
vim.keymap.set('n', '<leader>ft', '<Cmd>NERDTreeToggle<CR>', { desc = 'Toggle NERD[T]ree' })
-- Reveal the current file in the tree
vim.keymap.set('n', '<leader>ff', '<Cmd>NERDTreeFind<CR>', { desc = 'NERDTree [F]ind current file' })