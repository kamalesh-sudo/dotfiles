return {
    "akinsho/bufferline.nvim",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    opts = {
        options = {
            mode = "buffers",
            separator_style = "slant",

            diagnostics = "nvim_lsp",

            always_show_bufferline = true,

            show_buffer_close_icons = false,
            show_close_icon = false,

            offsets = {},
        },
    },
}
