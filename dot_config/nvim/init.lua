-- ============================================================
-- Leader
-- ============================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- ============================================================
-- Basic options
-- ============================================================

local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.showcmd = true
opt.showmatch = true

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.scrolloff = 4
opt.shortmess:remove("S") -- Show [x/y] search count

-- Indentation
opt.tabstop = 3
opt.shiftwidth = 3
opt.softtabstop = 3
opt.autoindent = true
opt.smartindent = true
opt.smarttab = true
opt.expandtab = true

-- Show whitespace
opt.list = true
opt.listchars = {
    tab = "▸ ",
    trail = "·",
}

-- UI
opt.laststatus = 2
opt.ruler = true
opt.colorcolumn = "80"
opt.wrap = false
opt.termguicolors = true

-- Tags
opt.tags = "./tags;/"

-- A few useful modern defaults
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.updatetime = 250

vim.cmd("syntax enable")

local restore_cursor_group =
    vim.api.nvim_create_augroup("RestoreCursor", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
    group = restore_cursor_group,

    callback = function(args)
        vim.api.nvim_create_autocmd("FileType", {
            buffer = args.buf,
            once = true,

            callback = function()
                local line = vim.fn.line([['"]])
                local last_line = vim.fn.line("$")
                local ft = vim.bo.filetype

                if
                    line >= 1
                    and line <= last_line
                    and not ft:match("commit")
                    and ft ~= "xxd"
                    and ft ~= "gitrebase"
                    and not vim.wo.diff
                then
                    vim.cmd([[normal! g`"]])
                end
            end,
        })
    end,
})

-- ============================================================
-- Some general key mappings
-- ============================================================

local map = vim.keymap.set

map({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

-- Resize vertical split
map("n", "<leader>]", "<cmd>vertical resize +10<CR>",
    { desc = "Increase split width" })

map("n", "<leader>[", "<cmd>vertical resize -10<CR>",
    { desc = "Decrease split width" })

-- Clear search highlights
map("n", "<C-h>", "<cmd>nohlsearch<CR>",
    { desc = "Clear search highlighting" })

-- Copy visual selection to the system clipboard
map("x", "<C-y>", '"+y',
    { desc = "Yank to system clipboard" })

-- Tab navigation
map("n", "<leader>h", "<cmd>tabprevious<CR>", {
    desc = "Previous tab",
})

map("n", "<leader>l", "<cmd>tabnext<CR>", {
    desc = "Next tab",
})

-- Jump directly to tabs 1–9
for i = 1, 9 do
    map("n", "<leader>" .. i, i .. "gt", {
        desc = "Go to tab " .. i,
    })
end

-- Leader-0 = last tab
map("n", "<leader>0", "<cmd>tablast<CR>", {
    desc = "Go to last tab",
})


-- ============================================================
-- Disable netrw because nvim-tree will replace it
-- ============================================================

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


-- ============================================================
-- lazy.nvim plugin manager
-- ============================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end

opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- --------------------------------------------------------
    -- Themes
    -- --------------------------------------------------------

    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "moon",
                dark_variant = "moon",
            })
        end,
    },

    {
        "nanotech/jellybeans.vim",
        lazy = false,
        priority = 1000,
    },

    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
    },

    {
        "sainnhe/everforest",
        lazy = false,
        priority = 1000,
    },

    -- --------------------------------------------------------
    -- Fuzzy finding / project search
    -- --------------------------------------------------------

    {
        "ibhagwan/fzf-lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {},
    },

    -- --------------------------------------------------------
    -- File explorer
    -- --------------------------------------------------------

    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            local api = require("nvim-tree.api")

            local function on_attach(bufnr)
                -- First install nvim-tree's normal/default mappings.
                api.config.mappings.default_on_attach(bufnr)

                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true,
                    }
                end

                -- NERDTree-style mappings
                vim.keymap.set(
                    "n",
                    "t",
                    api.node.open.tab,
                    opts("Open in new tab")
                )

                vim.keymap.set(
                    "n",
                    "s",
                    api.node.open.vertical,
                    opts("Open in vertical split")
                )

                vim.keymap.set(
                    "n",
                    "i",
                    api.node.open.horizontal,
                    opts("Open in horizontal split")
                )

                vim.keymap.set(
                    "n",
                    "<C-n>",
                    api.tree.reload,
                    opts("Refresh")
                )

                vim.keymap.set(
                    "n",
                    "<C-n>",
                    api.tree.reload,
                    opts("Refresh")
                )

                vim.keymap.set(
                    "n",
                    "<C-t>",
                    "<cmd>NvimTreeToggle<CR>",
                    opts("Toggle tree pane")
                )
            end

            require("nvim-tree").setup({
                on_attach = on_attach,

                view = {
                    width = 32,
                },

                renderer = {
                    group_empty = true,
                },
            })
        end,
    },

    -- --------------------------------------------------------
    -- Status line
    -- --------------------------------------------------------

    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            options = {
                theme = "auto",
            },
        },
    },

    -- --------------------------------------------------------
    -- Git gutter/signs
    -- --------------------------------------------------------

    {
        "lewis6991/gitsigns.nvim",
        opts = {},
    },

    -- --------------------------------------------------------
    -- Tree-sitter
    -- --------------------------------------------------------

    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")

            ts.install({
                "c",
                "cpp",
                "rust",
                "lua",
                "javascript",
                "typescript",
                "tsx",
                "html",
                "css",
                "json",
                "bash",
                "markdown",
                "markdown_inline",
                "yaml",
                "toml",
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "c",
                    "cpp",
                    "rust",
                    "lua",
                    "javascript",
                    "typescript",
                    "typescriptreact",
                    "html",
                    "css",
                    "json",
                    "bash",
                    "markdown",
                    "yaml",
                    "toml",
                },
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },

    -- --------------------------------------------------------
    -- Markdown Preview
    -- --------------------------------------------------------
   {
       "iamcco/markdown-preview.nvim",
       lazy = false,
       build = "cd app && npm install",

       init = function()
           vim.g.mkdp_filetypes = { "markdown" }
           vim.g.mkdp_echo_preview_url = 1
       end,
   },

    -- --------------------------------------------------------
    -- LSP configuration definitions
    -- --------------------------------------------------------

    {
        "neovim/nvim-lspconfig",
    },
})


-- ============================================================
-- Theme
-- ============================================================

-- Change this to:
--
--   "rose-pine"
--   "jellybeans"
--   "gruvbox"
--   "everforest"
--
local colorscheme = "rose-pine"

-- Everforest settings, used whenever you switch to it.
vim.g.everforest_background = "medium"
vim.g.everforest_enable_italic = 1

vim.cmd.colorscheme(colorscheme)


-- ============================================================
-- fzf-lua mappings
-- ============================================================

-- Ctrl-E: fuzzy-open a file
map("n", "<C-e>", function()
    require("fzf-lua").files()
end, { desc = "Find files" })

-- Space-g: search for text throughout the project
map("n", "<leader>g", function()
    require("fzf-lua").live_grep()
end, { desc = "Grep project" })

-- Space-G: live grep with glob filtering
map("n", "<leader>G", function()
    require("fzf-lua").live_grep_glob()
end, { desc = "Grep project with glob" })

-- Space-w: find occurrences of word under cursor throughout project
map("n", "<leader>f", function()
    require("fzf-lua").grep_cword()
end, { desc = "Grep word under cursor" })

-- Space-b: open buffer
map("n", "<leader>b", function()
    require("fzf-lua").buffers()
end, { desc = "Find buffer" })

-- Space-r: recently opened files
map("n", "<leader>r", function()
    require("fzf-lua").oldfiles()
end, { desc = "Recent files" })

-- Space-R: resume previous fuzzy search
map("n", "<leader>R", function()
    require("fzf-lua").resume()
end, { desc = "Resume fzf search" })


-- ============================================================
-- nvim-tree mappings
-- ============================================================

-- Preserve your old NERDTree-style mappings
map("n", "<C-n>", "<cmd>NvimTreeFocus<CR>",
    { desc = "Open/focus file tree" })

map("n", "<C-t>", "<cmd>NvimTreeToggle<CR>",
    { desc = "Toggle file tree" })


-- ============================================================
-- LSP mappings
-- ============================================================

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local lspmap = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, {
                buffer = event.buf,
                desc = desc,
            })
        end

        lspmap("gd", vim.lsp.buf.definition, "Go to definition")
        lspmap("gD", vim.lsp.buf.declaration, "Go to declaration")
        lspmap("K", vim.lsp.buf.hover, "Hover documentation")
        lspmap("gr", vim.lsp.buf.references, "Find references")
        lspmap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        lspmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    end,
})

-- ============================================================
-- MarkdownPreview mappings
-- ============================================================

map("n", "<leader>M", "<cmd>MarkdownPreviewToggle<CR>", {
   desc = "Toggle Markdown preview",
})

-- Enable language servers here AFTER installing their binaries.
--
-- Examples:
--
-- vim.lsp.enable({
--     "lua_ls",
--     "clangd",
--     "rust_analyzer",
--     "ts_ls",
-- })
