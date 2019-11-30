module.exports =
  try
    require 'eslint/lib/code-path-analysis/code-path-segment'
  catch
    require 'eslint/lib/linter/code-path-analysis/code-path-segment'
