ExportMap = require './eslint-plugin-import-export-map'

module.exports = ->
  try
    ESLintPluginImportExportMap = require 'eslint-plugin-import/lib/ExportMap'
  catch
    throw new ReferenceError "Couldn't resolve eslint-plugin-import ExportMap"
  return if ESLintPluginImportExportMap.__monkeypatched
  ESLintPluginImportExportMap.default.parse = ExportMap.default.parse
  ESLintPluginImportExportMap.__monkeypatched = yes
