-- packer settings
require "plugins"

-- auto execution of packer compiling
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})

-- import configuer
require "_telescope"
require "common"

