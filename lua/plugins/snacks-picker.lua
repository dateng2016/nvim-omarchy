return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          -- Allow Find Files (and the file source used by Smart Find Files)
          -- to include files excluded by .gitignore.
          files = {
            ignored = true,
          },
        },
      },
    },
  },
}
