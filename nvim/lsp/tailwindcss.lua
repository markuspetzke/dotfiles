return {
  settings = {
    tailwindCSS = {
      experimental = {
        -- Also detect classes in cn()/clsx()/cva() calls and tw template literals.
        classRegex = {
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "tw`([^`]*)", "([^`]*)" },
        },
      },
    },
  },
}
