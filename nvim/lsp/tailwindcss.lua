return {
  settings = {
    tailwindCSS = {
      experimental = {
        -- Klassen auch in cn()/clsx()/cva()-Aufrufen und tw-Template-Literals erkennen.
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
