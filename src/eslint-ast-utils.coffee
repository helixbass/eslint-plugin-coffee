module.exports =
  try
    require 'eslint/lib/ast-utils'
  catch
    try
      require 'eslint/lib/util/ast-utils'
    catch
      require 'eslint/lib/rules/utils/ast-utils'
