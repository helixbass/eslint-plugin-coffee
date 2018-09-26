###*
# @fileoverview Detects unused styles
# @author Tom Hastjarjanto
###

'use strict'

Components = require '../util/react/Components'
styleSheet = require '../util/react-native/stylesheet'
# styleSheet = require 'eslint-plugin-react-native/lib/util/stylesheet'

{StyleSheets, astHelpers} = styleSheet

module.exports = Components.detect (context, components) ->
  styleSheets = new StyleSheets()
  styleReferences = new Set()

  reportUnusedStyles = (unusedStyles) ->
    for own key, styles of unusedStyles
      styles.forEach (node) ->
        message = ['Unused style detected: ', key, '.', node.key.name].join ''

        context.report node, message

  checkAssignment = (node) ->
    if astHelpers.isStyleSheetDeclaration node
      styleSheetName = astHelpers.getStyleSheetName node
      styles = astHelpers.getStyleDeclarations node

      styleSheets.add styleSheetName, styles

  MemberExpression: (node) ->
    styleRef = astHelpers.getPotentialStyleReferenceFromMemberExpression node
    styleReferences.add styleRef if styleRef

  VariableDeclarator: checkAssignment
  AssignmentExpression: checkAssignment

  'Program:exit': ->
    list = components.list()
    if Object.keys(list).length > 0
      styleReferences.forEach (reference) -> styleSheets.markAsUsed reference
      reportUnusedStyles styleSheets.getUnusedReferences()

module.exports.schema = []
