-- ===============================================
-- 			              COLORS
-- ===============================================

vim.opt.termguicolors = true
vim.cmd.colorscheme("lunaperche")

-- ===============================================
-- 			              OPTIONS
-- ===============================================
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

options = {
	number = true,
	relativenumber = true,
	cursorline = true,
	wrap = false,
	scrolloff = 10,
	sidescrolloff = 10,

	tabstop = 2,
	shiftwidth = 2,
	softtabstop = 2,
	expandtab = true,
	smartindent = true,
	autoindent = true,

	ignorecase = true,
	smartcase = true,
	hlsearch = true,
	incsearch = true,

	signcolumn = "yes",
	colorcolumn = "100",
	showmatch = true,
	cmdheight = 1,
	completeopt = "menuone,noinsert,noselect",
	showmode = false,
	pumheight = 10,
	pumblend = 10,
	winblend = 0,
	conceallevel = 0,
	concealcursor = "",
	lazyredraw = true,
	synmaxcol = 300,
	fillchars = { eob = " " },

	backup = false,
	writebackup = false,
	swapfile = false,
	undofile = true,
	undodir = undodir,
	updatetime = 300,
	timeoutlen = 500,
	ttimeoutlen = 0,
	autoread = true,
	autowrite = false,

	hidden = true,
	errorbells = false,
	backspace = "indent,eol,start",
	autochdir = false,
	iskeyword = vim.opt.iskeyword + "-",
	selection = "inclusive",
	mouse = "a",
	clipboard = "unnamedplus",
	modifiable = true,
	encoding = "utf-8",

	guicursor = table.concat(
		{
			"n-v-c:block",
			"i-ci-ve:block",
			"r-cr:hor20",
			"o:50",
			"a:blinkwait700-blinkoff400-blinkon250-Cursor/Cursor",
			"sm:block-blinkwait175-blinkof150-blinkon175",
		}, ","
	),


	foldmethod = "expr",
	foldexpr = "v:lua.vim.treesitter.foldexpr()",
	foldlevel = 99,

	splitbelow = true,
	splitright = true,

	wildmenu = true,
	wildmode = "longest:full,full",
	diffopt = vim.opt.diffopt + "linematch:60",
	redrawtime = 10000,
	maxmempattern = 20000,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- ===============================================
--                  STATUSLINE
-- ===============================================

-- git branch function with caching and Nerd font icon
local cached_branch = ""
local last_check = 0
local function git_branch()
  local now = vim.loop.now()
  if now - last_check > 5000 then
    cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
    last_check = now
  end
  if cached_branch ~= "" then
    return " \u{e725} " .. cached_branch .. " "
  end
  return ""
end

-- file type with nerd font icon
local function file_type()
  local ft = vim.bo.filetype
  local icons = {
    lua = "\u{e620} ", -- nf-dev-lua
    python = "\u{e73c} ", -- nf-dev-python
    javascript = "\u{e74e} ", -- ... and so on
    javascriptreact = "\u{e7ba}",
    typescriptreact = "\u{e7ba}",
    html = "\u{e736}",
    css = "\u{e749}",
    scss = "\u{e749}",
    json = "\u{e60b}",
    markdown = "\u{e73e}",
    vim = "\u{e62b}",
    sh = "\u{f489}",
    bash = "\u{f489}",
    zsh = "\u{f489}",
    rust = "\u{e7a8}",
    go = "\u{e724}",
    c = "\u{e61e}",
    cpp = "\u{e61d}",
    java = "\u{e738}",
    php = "\u{e73d}",
    ruby = "\u{e739}",
    swift = "\u{e755}",
    kotlin = "\u{e634}",
    dart = "\u{e798}",
    elixir = "\u{e62d}",
    haskell = "\u{e777}",
    sql = "\u{e706}",
    yaml = "\u{f481}",
    toml = "\u{e615}",
    xml = "\u{f05c}",
    dockerfile = "\u{f308}",
    gitcommit = "\u{f418}",
    gitconfig = "\u{f1d3}",
    vue = "\u{fd42}",
    svelte = "\u{e697}",
    astro = "\u{e697}",
    zig = "\u{e8af}",
  }

  if ft == "" then
    return " \u{f15b} "
  end

  return ((icons[ft] or " \u{f15b} ") .. ft)
end

-- file size with nerd font icon
local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand("%"))
  if size < 0 then
    return ""
  end
  local size_str
  if size < 1024 then
    size_str = size .. "B"
  elseif size > 1024 then
    size_str = string.format("%.1fK", size / 1024)
  else
    size_str = string.format("%.1fM", size / 1024 / 1024)
  end
  return " \u{f016} " .. size_str .. " "
end

-- mode indicators with nerd font icons
local function mode_icon()
  local mode = vim.fn.mode()
  local modes = {
    n = " \u{f121}  NORMAL",
    i = " \u{f11c}  INSERT",
    v = " \u{f0168}  VISUAL",
    V = " \u{f0168}  V-LINE",
    ["\22"] = " \u{f0168}  V-BLOCK",
    c = " \u{f120}  COMMAND",
    s = " \u{f0c5}  SELECT",
    S = " \u{f0c5}  S-LINE",
    ["\19"] = " \u{f0c5}  S-BLOCK",
    R = " \u{f044}  REPLACE",
    r = " \u{f044}  REPLACE",
    ["!"] = " \u{f489}  SHELL",
    t = " \u{f120}  TERMINAL",
  }
  return modes[mode] or (" \u{f059}  " .. mode)
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- change status line based on window focus
local function setup_dynamic_statusline()
  vim.api.nvim_create_autocmd({"WinEnter", "BufEnter" }, {
    callback = function()
      vim.opt_local.statusline = table.concat({
        " ",
        "%#StatusLineBold#",
        "%{v:lua.mode_icon()}",
        "%#StatusLine#",
        " \u{e0b1} %f %h%m%r",
        "%{v:lua.git_branch()}",
        " \u{e0b1} ",
        "%{v:lua.file_type()}",
        " \u{e0b1} ",
        "%{v:lua.file_size()}",
        "%=",
        " \u{f017} %l:%c  %P ",
        })
      end,
    })
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    callback = function()
      vim.opt_local.statusline = "  %f %h%m%r \u{e0b1} %{v:lua.file_type()} %= %l:%c  %P "
    end,
  })
end

setup_dynamic_statusline()

-- ===============================================
--                  KEPMAPS
-- ===============================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function set_keymaps(maps)
  for mode, mode_maps in pairs(maps) do
    for lhs, rhs_data in pairs(mode_maps) do
      local rhs = rhs_data[1]
      local opts = rhs_data[2] or {}

      local modes = vim.split(mode, ",")
      vim.keymap.set(modes, lhs, rhs, opts)
    end
  end
end

local maps = {
  n = {
    -- better movement in wrapped text
    ["j"] = {
      function() return vim.v.count == 0 and "gj" or "j" end,
      { expr = true, silent = true, desc = "Down (wrap-aware)" },
    },
    ["k"] = {
      function() return vim.v.count == 0 and "gk" or "k" end,
      { expr = true, silent = true, desc = "Up (wrap-aware)" },
    },

    ["<leader>c"] = { ":nohlsearch<CR>", { desc = "Clear search highlights" } },

    ["n"] = { "nzzzv", { desc = "Next search result (centered)" } },
    ["N"] = { "Nzzzv", { desc = "Previous search result (centered)" } },
    ["<C-d>"] = { "<C-d>zz", { desc = "Half page down (centered)" } },
    ["<C-u>"] = { "<C-u>zz", { desc = "Half page up (centered)" } },

    ["<leader>bn"] = { ":bnext<CR>", { desc = "Next buffer" } },
    ["<leader>bp"] = { ":bprevious<CR>", { desc = "Previous buffer" } },

    ["<C-h>"] = { "<C-w>h", { desc = "Move to left window" } },
    ["<C-j>"] = { "<C-w>j", { desc = "Move to bottom window" } },
    ["<C-k>"] = { "<C-w>k", { desc = "Move to top window" } },
    ["<C-l>"] = { "<C-w>l", { desc = "Move to right window" } },

    ["<leader>sv"] = { ":vsplit<CR>", { desc = "Split window vertically" } },
    ["<leader>sh"] = { ":split<CR>", { desc = "Split window horizontally" } },

    ["<C-Up>"] = { ":resize +2<CR>", { desc = "Increase window height" } },
    ["<C-Down>"] = { ":resize -2<CR>", { desc = "Decrease window height" } },
    ["<C-Left>"] = { ":vertical resize -2<CR>", { desc = "Decrease window width" } },
    ["<C-Right>"] = { ":vertical resize +2<CR>", { desc = "Increase window width" } },

    ["<A-j>"] = { ":m .+1<CR>==", { desc = "Move line down" } },
    ["<A-k>"] = { ":m .-2<CR>==", { desc = "Move line up" } },

    ["J"] = { "mzJ`z", { desc = "Join lines and keep cursor position" } },

    ["<leader>pa"] = {
      function()
        local path = vim.fn.expand("%:p")
        vim.fn.setreg("+", path)
        print("file:", path)
      end,
      { desc = "Copy full file path" },
    },

    ["<leader>td"] = {
      function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
      { desc = "Toggle diagnostics" },
    },

    ["<leader>e"] = {
      function() require("nvim-tree.api").tree.toggle() end,
      { desc = "Toggle NvimTree" },
    },

    ["<leader>ff"] = { 
      function() require("fzf-lua").files() end,
      { desc = "FZF Files" }, 
    },
    ["<leader>fg"] = {
      function() require("fzf-lua").live_grep() end,
      { desc = "FZF Live Grep" },
    },
    ["<leader>fb"] = {
      function() require("fzf-lua").buffers() end,
      { desc = "FZF Buffers" },
    },
    ["<leader>fh"] = {
      function() require("fzf-lua").help_tags() end,
      { desc = "FZF Help tags" },
    },
    ["<leader>fx"] = {
      function() require("fzf-lua").diagnostics_document() end,
      { desc = "FZF Diagnostics Document" },
    },
    ["<leader>fX"] = {
      function() require("fzf-lua").diagnostics_workspace() end,
      { desc = "FZF Diagnostics Workspace" },
    },

    ["]h"] = {
      function() require("gitsigns").next_hunk() end,
      { desc = "Next git hunk" },
    },
    ["[h"] = {
      function() require("gitsigns").prev_hunk() end,
      { desc = "Prev git hunk" },
    },
    ["<leader>hs"] = {
      function() require("gitsigns").stage_hunk() end,
      { desc = "Stage hunk" },
    },
    ["<leader>hr"] = {
      function() require("gitsigns").reset_hunk() end,
      { desc = "Reset hunk"},
    },
    ["<leader>hp"] = {
      function() require("gitsigns").preview_hunk() end,
      { desc = "Preview hunk" },
    },
    ["<leader>hb"] = {
      function() require("gitsigns").blame_line() end,
      { desc = "Blame line" },
    },
    ["<leader>hB"] = {
      function() require("gitsigns").toggle_current_line_blame() end,
      { desc = "Toggle inline blame" },
    },
    ["<leader>hd"] = {
      function() require("gitsigns").diffthis() end,
      { desc = "Diff this" },
    },


  },

  v = {
    ["<A-k>"] = { ":m '<-2<CR>gv=gv", { desc = "Move selection up" } },
    ["<A-j>"] = { ":m '>+1<CR>gv=gv", { desc = "Move selection down" } },

    ["<"] = { "<gv", { desc = "Indent left and reselect" } },
    [">"] = { ">gv", { desc = "Indent right and reselect" } },
  },

  x = {
    ["<leader>p"] = { '"_dP', { desc = "Paste without yanking" } },
  },

  ["n,v"] = {
    ["<leader>x"] = { '"_d', { desc = "Delete without yanking" } },
  },
}

set_keymaps(maps)

-- ===============================================
--                  AUTOCMDS
-- ===============================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Format on save (ONLY real file buffers, ONLY when efm is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua",
		"*.py",
		"*.go",
		"*.js",
		"*.jsx",
		"*.ts",
		"*.tsx",
		"*.json",
		"*.css",
		"*.scss",
		"*.html",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.c",
		"*.cpp",
		"*.h",
		"*.hpp",
	},
	callback = function(args)
		-- avoid formatting non-file buffers (helps prevent weird write prompts)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		if not vim.bo[args.buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c.name == "efm" then
				has_efm = true
				break
			end
		end
		if not has_efm then
			return
		end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ===============================================
--                  PLUGINS
-- ===============================================

vim.pack.add({
  "https://www.github.com/echasnovski/mini.nvim",
  "https://www.github.com/ibhagwan/fzf-lua",
  "https://www.github.com/nvim-tree/nvim-tree.lua",
  "https://www.github.com/lewis6991/gitsigns.nvim",
})

local function packadd(name)
  vim.cmd("packadd " .. name)
end

packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("gitsigns.nvim")
-- ===============================================
--                  PLUGIN CONFIGS
-- ===============================================

require("nvim-tree").setup({
  view = { width = 35 },
  filters = { dotfiles = false },
  renderer = { group_empty = true },
})

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

require("gitsigns").setup({
  signs = {
    add = { text = "\u{2590}" },
    change = { text = "\u{2590}" },
    delete = { text = "\u{2590}" },
    topdelete = { text = "\u{25e6}" },
    changedelete = { text = "\u{25cf}" },
    untracked = { text = "\u{25cb}" },
  },
  signcolumn = true,
  current_line_blame = false,
})
