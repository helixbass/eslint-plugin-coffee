{loadInternalEslintModule} = require './load-internal-eslint-module'

module.exports =
  try
    loadInternalEslintModule 'lib/ast-utils'
  catch
    try
      loadInternalEslintModule 'lib/util/ast-utils'
    catch
      loadInternalEslintModule 'lib/rules/utils/ast-utils'
