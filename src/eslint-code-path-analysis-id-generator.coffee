module.exports =
  try
    require 'eslint/lib/code-path-analysis/id-generator'
  catch
    require 'eslint/lib/linter/code-path-analysis/id-generator'
