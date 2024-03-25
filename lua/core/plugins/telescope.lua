local plugins = vim.g.config.plugins
local user_config = (vim.g.config.plugins.telescope or {})
local icons = require("utils.icons")
local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")
local telescopeConfig = require("telescope.config")
table.unpack = table.unpack or unpack -- 5.1 compatibility

---enable Telescope file_browser only if Lf is not set as file browser
local function enable_file_browser()
  return not plugins.lf.enable
end

local function file_browser_config()
  if enable_file_browser() then
    local fb_actions = require("telescope").extensions.file_browser.actions
    return {
      theme = "ivy",
      hijack_netrw = false,
      hidden = true,
      mappings = {
        i = {
          ["<c-n>"] = fb_actions.create,
          ["<c-r>"] = fb_actions.rename,
          -- ["<c-h>"] = actions.which_key,
          ["<c-h>"] = fb_actions.toggle_hidden,
          ["<c-x>"] = fb_actions.remove,
          ["<c-p>"] = fb_actions.move,
          ["<c-y>"] = fb_actions.copy,
          ["<c-a>"] = fb_actions.select_all,
        },
      },
    }
  end
  return {}
end

local default_config = {
  grep_hidden = true,
  fzf_native = false,
  show_untracked_files = false,
  keys = {
    -- Search stuff
    { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>ss", "<cmd>Telescope live_grep<cr>", desc = "Strings" },
    { "<leader>s?", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    { "<leader>sh", "<cmd>Telescope heading<cr>", desc = "Headings" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>sO", "<cmd>Telescope vim_options<cr>", desc = "Vim Options" },
    { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
    { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Word under cursor" },
    { "<leader>sS", "<cmd>Telescope symbols<cr>", desc = "Emoji" },
    { "<leader>s:", "<cmd>Telescope search_history<cr>", desc = "Search History" },
    { "<leader>s;", "<cmd>Telescope command_history<cr>", desc = "Command history" },
    {
      "<leader>sW",
      "<cmd>lua require'telescope.builtin'.grep_string{ shorten_path = true, word_match = '-w', only_sort_text = true, search = '' }<cr>",
      desc = "Word search",
    },
    -- Git
    { "<leader>gh", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
    { "<leader>gg", "<cmd>Telescope git_status<cr>", desc = "Status" },
    { "<leader>gm", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
    -- files
    { "<leader>fb", "<cmd>" .. require("utils.functions").file_browser() .. "<cr>", desc = "Filebrowser" },
    { "<leader>fz", "<cmd>Telescope zoxide list<cr>", desc = "Zoxide" },
    { "<leader>ff", "<cmd>" .. require("utils.functions").project_files() .. "<cr>", desc = "Open file" },
    { "<leader>fF", "<cmd>Telescope find_files<cr>", desc = "Open file (ignore git)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    -- misc
    { "<leader>mt", "<cmd>Telescope<cr>", desc = "Telescope" },
    -- Other
    { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Bufferlist" },
    { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
  },
  config_function = function(opts)
    local telescope = require("telescope")
    -- Make telescope look awesome with catppuccin
    if vim.g.config.theme.name == "catppuccin" then
      local colors = require("catppuccin.palettes").get_palette()
      local TelescopeColor = {
        TelescopeMatching = { fg = colors.pink },
        TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
        TelescopePromptPrefix = { bg = colors.mantle },
        TelescopePromptNormal = { bg = colors.mantle },
        TelescopeResultsNormal = { bg = colors.mantle },
        TelescopePreviewNormal = { bg = colors.mantle },
        TelescopePromptBorder = { bg = colors.mantle, fg = colors.surface0 },
        TelescopeResultsBorder = { bg = colors.mantle, fg = colors.surface0 },
        TelescopePreviewBorder = { bg = colors.mantle, fg = colors.surface0 },
        TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
        TelescopeResultsTitle = { fg = colors.mantle },
        TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
      }
      for hl, col in pairs(TelescopeColor) do
        vim.api.nvim_set_hl(0, hl, col)
      end
    end

    telescope.setup(opts)

    telescope.load_extension("projects")
    telescope.load_extension("zoxide")
    telescope.load_extension("heading")

    if plugins.noice.enable then
      telescope.load_extension("noice")
    end

    if plugins.telescope.fzf_native then
      telescope.load_extension("fzf")
    end

    if plugins.emoji.enable then
      telescope.load_extension("emoji")
    end

    if (plugins.ts_advanced_git_search or false) and plugins.ts_advanced_git_search.enabled then
      telescope.load_extension("advanced_git_search")
    end
  end,
  opts = {
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({}),
      },
      fzf = {},
      file_browser = file_browser_config(),
    },
    pickers = {
      find_files = {
        hidden = false,
      },
      oldfiles = {
        cwd_only = true,
      },
      buffers = {
        ignore_current_buffer = true,
        sort_lastused = true,
      },
      live_grep = {
        only_sort_text = true, -- grep for content and not file name/path
        mappings = {
          i = { ["<c-f>"] = require("telescope.actions").to_fuzzy_refine },
        },
      },
    },
    defaults = {
      file_ignore_patterns = {
        "%.7z",
        "%.avi",
        "%.JPEG",
        "%.JPG",
        "%.V",
        "%.RAF",
        "%.burp",
        "%.bz2",
        "%.cache",
        "%.class",
        "%.dll",
        "%.docx",
        "%.dylib",
        "%.epub",
        "%.exe",
        "%.flac",
        "%.ico",
        "%.ipynb",
        "%.jar",
        "%.jpeg",
        "%.jpg",
        "%.lock",
        "%.mkv",
        "%.mov",
        "%.mp4",
        "%.otf",
        "%.pdb",
        "%.pdf",
        "%.png",
        "%.rar",
        "%.sqlite3",
        "%.svg",
        "%.tar",
        "%.tar.gz",
        "%.ttf",
        "%.webp",
        "%.zip",
        ".git/",
        ".gradle/",
        ".idea/",
        ".vale/",
        ".vscode/",
        "__pycache__/*",
        "build/",
        "env/",
        "gradle/",
        "node_modules/",
        "smalljre_*/*",
        "target/",
        "vendor/*",
      },
      vimgrep_arguments = { table.unpack(telescopeConfig.values.vimgrep_arguments) },
      mappings = {
        i = {
          -- Close on first esc instead of going to normal mode
          -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
          ["<esc>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<PageUp>"] = actions.results_scrolling_up,
          ["<PageDown>"] = actions.results_scrolling_down,
          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.send_selected_to_qflist,
          ["<C-l>"] = actions.send_to_qflist,
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
          ["<cr>"] = actions.select_default,
          ["<c-v>"] = actions.select_vertical,
          ["<c-s>"] = actions.select_horizontal,
          ["<c-t>"] = actions.select_tab,
          ["<c-p>"] = action_layout.toggle_preview,
          ["<c-o>"] = action_layout.toggle_mirror,
          ["<c-h>"] = actions.which_key,
          ["<c-x>"] = actions.delete_buffer,
        },
      },
      prompt_prefix = table.concat({ icons.arrows.ChevronRight, " " }),
      selection_caret = icons.arrows.CurvedArrowRight,
      multi_icon = icons.arrows.Diamond,
      layout_strategy = "flex",
      results_title = false,
      layout_config = {
        prompt_position = "top",
      },
      winblend = 0, -- transparency
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      set_env = { ["COLORTERM"] = "truecolor" },
    },
  },
}

local config = vim.tbl_deep_extend("force", default_config, user_config)

if config.grep_hidden then
  table.insert(config.opts.defaults.vimgrep_arguments, "--hidden")
end

if config.fzf_native then
  table.insert(config.opts.extensions.fzf, {
    fuzzy = true, -- false will only do exact matching
    override_generic_sorter = true, -- override the generic sorter
    override_file_sorter = true, -- override the file sorter
    case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    -- the default case_mode is "smart_case"
  })
end

return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "jvgrootveld/telescope-zoxide",
    "crispgm/telescope-heading.nvim",
    "nvim-telescope/telescope-symbols.nvim",
    {
      "nvim-telescope/telescope-file-browser.nvim",
      enabled = enable_file_browser(),
    },
    { "nvim-telescope/telescope-fzf-native.nvim", enabled = config.fzf_native, build = "make" },
  },
  keys = config.keys,
  opts = config.opts,
  config = function(_, opts)
    config.config_function(opts)
  end,
}
