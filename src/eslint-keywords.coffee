{loadInternalEslintModule} = require './load-internal-eslint-module'

module.exports =
  try
    loadInternalEslintModule 'lib/util/keywords'
  catch
    loadInternalEslintModule 'lib/rules/utils/keywords'
