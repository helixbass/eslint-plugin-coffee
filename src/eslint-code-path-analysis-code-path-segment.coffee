{loadInternalEslintModule} = require './load-internal-eslint-module'

module.exports =
  try
    loadInternalEslintModule 'lib/code-path-analysis/code-path-segment'
  catch
    loadInternalEslintModule 'lib/linter/code-path-analysis/code-path-segment'
