return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        explorer = { hidden = true },
      },
    },
  },
  keys = {
    {
      "<leader>fa",
      function()
        Snacks.picker.files({ hidden = true, ignored = true, exclude = { "node_modules" } })
      end,
      desc = "Find Files (hidden + gitignored)",
    },
    {
      "<leader>sA",
      function()
        Snacks.picker.grep({ hidden = true, ignored = true, exclude = { "node_modules" } })
      end,
      desc = "Grep (hidden + gitignored)",
    },
  },
}
