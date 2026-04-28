require("neo-tree").setup({
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = true,
    popup_border_style = "rounded",
    default_component_configs = {
        indent = {
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
        },
        git_status = {
            symbols = {
                added     = "✚",
                modified  = "",
                deleted   = "✖",
                renamed   = "",
                untracked = "",
                ignored   = "",
                unstaged  = "",
                staged    = "",
                conflict  = "",
            },
        },
    },
    window = {
        position = "left",
        width = 42,
        mappings = {
            ["i"] = "open_split",
            ["I"] = "toggle_hidden",
            ["u"] = "navigate_up",
            ["C"] = "set_root",
        },
    },
    filesystem = {
        filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
                "__pycache__",
            },
            hide_by_pattern = {
                "*.pyc",
                "*.o", "*.O",
                "*.exe", "*.EXE",
            },
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
    },
})
