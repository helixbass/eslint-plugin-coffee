{loadInternalEslintModule} = require './load-internal-eslint-module'

module.exports =
  try
    loadInternalEslintModule 'lib/code-path-analysis/id-generator'
  catch
    loadInternalEslintModule 'lib/linter/code-path-analysis/id-generator'
