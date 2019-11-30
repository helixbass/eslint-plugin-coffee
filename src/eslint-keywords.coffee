module.exports =
  try
    require 'eslint/lib/util/keywords'
  catch
    require 'eslint/lib/rules/utils/keywords'
