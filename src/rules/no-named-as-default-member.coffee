###*
# @fileoverview Rule to warn about potentially confused use of name exports
# @author Desmond Brand
# @copyright 2016 Desmond Brand. All rights reserved.
# See LICENSE in root directory for full license.
###
{default: Exports} = require '../eslint-plugin-import-export-map'
{
  default: importDeclaration
} = require 'eslint-plugin-import/lib/importDeclaration'
{default: docsUrl} = require 'eslint-plugin-import/lib/docsUrl'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    type: 'suggestion'
    docs:
      url: docsUrl 'no-named-as-default-member'

  create: (context) ->
    fileImports = new Map()
    allPropertyLookups = new Map()

    handleImportDefault = (node) ->
      declaration = importDeclaration context
      exportMap = Exports.get declaration.source.value, context
      return unless exportMap?

      if exportMap.errors.length
        exportMap.reportErrors context, declaration
        return

      fileImports.set node.local.name, {
        exportMap
        sourcePath: declaration.source.value
      }

    storePropertyLookup = (objectName, propName, node) ->
      lookups = allPropertyLookups.get(objectName) or []
      lookups.push {node, propName}
      allPropertyLookups.set objectName, lookups

    handlePropLookup = (node) ->
      objectName = node.object.name
      propName = node.property.name
      storePropertyLookup objectName, propName, node

    handleDestructuringAssignment = (node) ->
      if node.type is 'AssignmentExpression'
        {left: id, right: init} = node
      else
        {id, init} = node
      isDestructure = id.type is 'ObjectPattern' and init?.type is 'Identifier'
      return unless isDestructure

      objectName = init.name
      for {key} from id.properties
        continue unless key? # true for rest properties
        storePropertyLookup objectName, key.name, key

    handleProgramExit = ->
      allPropertyLookups.forEach (lookups, objectName) ->
        fileImport = fileImports.get objectName
        return unless fileImport?

        for {propName, node} from lookups
          # the default import can have a "default" property
          if propName is 'default' then continue
          unless fileImport.exportMap.namespace.has propName then continue

          context.report {
            node
            message:
              "Caution: `#{objectName}` also has a named export " +
              "`#{propName}`. Check if you meant to write " +
              "`import {#{propName}} from '#{fileImport.sourcePath}'` " +
              'instead.'
          }

    ImportDefaultSpecifier: handleImportDefault
    MemberExpression: handlePropLookup
    VariableDeclarator: handleDestructuringAssignment
    AssignmentExpression: handleDestructuringAssignment
    'Program:exit': handleProgramExit
