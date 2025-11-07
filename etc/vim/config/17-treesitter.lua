require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "c",
        "c_sharp",
        -- "cmake",
        "cpp",
        -- "css",
        -- "cuda",
        -- "dart",
        -- "diff",
        -- "dockerfile",
        -- "gdscript",
        -- "gitattribute",
        -- "gitconfig",
        -- "gitignore",
        -- "glsl",
        "go",
        -- "html",
        -- "http",
        -- "ini",
        -- "java",
        -- "javascript",
        -- "jsdoc",
        -- "json",
        -- "kotlin",
        -- "latex",
        -- "llvm",
        -- "lua",
        -- "make",
        -- "markdown",
        -- "perl",
        -- "php",
        "python",
        -- "query",
        -- "regex",
        -- "rst",
        -- "rust",
        -- "scala",
        -- "scss",
        -- "sql",
        -- "swift",
        -- "toml",
        -- "typescript",
        -- "vim",
        -- "vimdoc",
        -- "vue",
        -- "yaml",
    },
    sync_install = true,
    auto_install = true,
    ignore_install = {""},

    -- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers",
    -- Remember to run `vim.opt.runtimepath:append("/some/path/to/store/parsers")!`

    highlight = {
        enable = true,
        disable = function(lang, buf)
            local max_filesize = 10 * 1024 * 1024 -- 10 MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}
