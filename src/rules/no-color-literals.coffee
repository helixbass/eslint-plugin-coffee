###*
# @fileoverview Detects color literals
# @author Aaron Greenwald
###

'use strict'

util = require 'util'
Components = require '../util/react/Components'
{StyleSheets, astHelpers} = require '../util/react-native/stylesheet'

module.exports = Components.detect (context) ->
  styleSheets = new StyleSheets()

  reportColorLiterals = (colorLiterals) ->
    if colorLiterals
      colorLiterals.forEach (style) ->
        if style
          expression = util.inspect style.expression
          context.report
            node: style.node
            message: 'Color literal: {{expression}}'
            data: {expression}

  checkAssignment = (node) ->
    if astHelpers.isStyleSheetDeclaration node
      styles = astHelpers.getStyleDeclarations node

      if styles
        styles.forEach (style) ->
          literals = astHelpers.collectColorLiterals style.value, context
          styleSheets.addColorLiterals literals

  VariableDeclarator: checkAssignment
  AssignmentExpression: checkAssignment

  JSXAttribute: (node) ->
    if astHelpers.isStyleAttribute node
      literals = astHelpers.collectColorLiterals node.value, context
      styleSheets.addColorLiterals literals

  'Program:exit': -> reportColorLiterals styleSheets.getColorLiterals()

module.exports.schema = []
