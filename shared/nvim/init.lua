-- ==========================================
-- Core Options
-- ==========================================

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

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Interaction
vim.opt.mouse = "a"

-- Performance / responsiveness
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- UI
vim.opt.cmdheight = 0
vim.opt.laststatus = 3

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Files
vim.opt.backup = false
vim.opt.swapfile = false

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==========================================
-- Keymaps
-- ==========================================

local map = vim.keymap.set

-- Clear search highlighting
map("n", "<Esc>", "<cmd>nohlsearch<CR>", {
    desc = "Clear search highlight",
})

-- Window navigation
map("n", "<C-h>", "<C-w>h", {
    desc = "Move to left window",
})

map("n", "<C-j>", "<C-w>j", {
    desc = "Move to lower window",
})

map("n", "<C-k>", "<C-w>k", {
    desc = "Move to upper window",
})

map("n", "<C-l>", "<C-w>l", {
    desc = "Move to right window",
})

-- Move lines
map("n", "<A-j>", "<cmd>move .+1<CR>==", {
    desc = "Move line down",
})

map("n", "<A-k>", "<cmd>move .-2<CR>==", {
    desc = "Move line up",
})

map("i", "<A-j>", "<Esc><cmd>move .+1<CR>==gi", {
    desc = "Move line down",
})

map("i", "<A-k>", "<Esc><cmd>move .-2<CR>==gi", {
    desc = "Move line up",
})

map("v", "<A-j>", ":move '>+1<CR>gv=gv", {
    desc = "Move selection down",
})

map("v", "<A-k>", ":move '<-2<CR>gv=gv", {
    desc = "Move selection up",
})

-- Better visual indentation
map("v", "<", "<gv")
map("v", ">", ">gv")
-- capsloack --> f13 --> esc
map({"n", "i", "v", "c" }, "<C-space>", "<Esc>")

-- ==========================================
-- Lazy.nvim
-- ==========================================

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
