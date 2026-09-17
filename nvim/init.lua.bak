vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false

vim.opt.numberwidth = 3
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.wrap = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.mouse = "a"

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

vim.opt.cmdheight = 0
vim.opt.laststatus = 3

vim.g.mapleader = " "

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.cmd.colorscheme("habamax")
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
