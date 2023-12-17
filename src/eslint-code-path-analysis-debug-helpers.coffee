{loadInternalEslintModule} = require './load-internal-eslint-module'

module.exports =
  try
    loadInternalEslintModule 'lib/code-path-analysis/debug-helpers'
  catch
    loadInternalEslintModule 'lib/linter/code-path-analysis/debug-helpers'
