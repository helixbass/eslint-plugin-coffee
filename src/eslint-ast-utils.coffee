module.exports =
  try
    require 'eslint/lib/ast-utils'
  catch
    require 'eslint/lib/util/ast-utils'
