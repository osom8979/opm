-- GitSigns highlight colors
vim.api.nvim_set_hl(0, 'GitSignsAdd',          { fg = '#9ece6a' })
vim.api.nvim_set_hl(0, 'GitSignsChange',       { fg = '#7aa2f7' })
vim.api.nvim_set_hl(0, 'GitSignsDelete',       { fg = '#db4b4b' })
vim.api.nvim_set_hl(0, 'GitSignsTopdelete',    { fg = '#db4b4b' })
vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { fg = '#db4b4b' })
vim.api.nvim_set_hl(0, 'GitSignsUntracked',    { fg = '#9ece6a' })

-- Staged signs
vim.api.nvim_set_hl(0, 'GitSignsStagedAdd',          { fg = '#4e6b42' })
vim.api.nvim_set_hl(0, 'GitSignsStagedChange',       { fg = '#4a6599' })
vim.api.nvim_set_hl(0, 'GitSignsStagedDelete',       { fg = '#8b3535' })
vim.api.nvim_set_hl(0, 'GitSignsStagedTopdelete',    { fg = '#8b3535' })
vim.api.nvim_set_hl(0, 'GitSignsStagedChangedelete', { fg = '#8b3535' })

require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  blame_formatter = nil, -- Use default
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
