ExportMap = require './eslint-plugin-import-export-map'

module.exports = ->
  try
    ESLintPluginImportExportMap = require 'eslint-plugin-import/lib/ExportMap'
  catch
    throw new ReferenceError "Couldn't resolve eslint-plugin-import ExportMap"
  return if ESLintPluginImportExportMap.__monkeypatched
  for key in [
    'parse'
    # 'get'
    # 'for'
  ]
    ESLintPluginImportExportMap.default[key] = ExportMap.default[key]
  ESLintPluginImportExportMap.__monkeypatched = yes
