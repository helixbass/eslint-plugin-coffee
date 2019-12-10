###*
# @fileoverview Enforce style prop value is an object
# @author David Petersen
###
'use strict'

variableUtil = require '../util/react/variable'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Enforce style prop value is an object'
      category: ''
      recommended: no
      url: docsUrl 'style-prop-object'
    schema: []

  create: (context) ->
    ###*
    # @param {object} node An Identifier node
    ###
    isNonNullaryLiteral = (expression) ->
      expression.type is 'Literal' and expression.value isnt null

    ###*
    # @param {object} node A Identifier node
    ###
    checkIdentifiers = (node) ->
      variable =
        variableUtil
        .variablesInScope context
        .find (item) -> item.name is node.name

      if variable?.defs[0]?.node.init
        if isNonNullaryLiteral variable.defs[0].node.init
          context.report node, 'Style prop value must be an object'

      if variable?.defs[0]?.node.parent.right
        if isNonNullaryLiteral variable.defs[0].node.parent.right
          context.report node, 'Style prop value must be an object'

    CallExpression: (node) ->
      if (
        node.callee?.type is 'MemberExpression' and
        node.callee.property.name is 'createElement' and
        node.arguments.length > 1
      )
        if node.arguments[1].type is 'ObjectExpression'
          style = node.arguments[1].properties.find (property) ->
            property.key and
            property.key.name is 'style' and
            not property.computed
          if style
            if style.value.type is 'Identifier'
              checkIdentifiers style.value
            else if isNonNullaryLiteral style.value
              context.report style.value, 'Style prop value must be an object'

    JSXAttribute: (node) ->
      return if not node.value or node.name.name isnt 'style'

      if (
        node.value.type isnt 'JSXExpressionContainer' or
        isNonNullaryLiteral node.value.expression
      )
        context.report node, 'Style prop value must be an object'
      else if node.value.expression.type is 'Identifier'
        checkIdentifiers node.value.expression
