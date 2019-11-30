module.exports =
  try
    require 'eslint/lib/code-path-analysis/debug-helpers'
  catch
    require 'eslint/lib/linter/code-path-analysis/debug-helpers'
