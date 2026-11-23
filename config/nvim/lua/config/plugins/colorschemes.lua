require('kanagawa').setup {
  transparent = true,
  overrides = function(colors)
    return { TelescopeBorder = { fg = colors.theme.ui.float.fg_border, bg = "NONE" } }
  end,
  colors = {
    theme = {
      all = {
        ui = { bg_gutter = 'none' },
      },
    },
  },
}
