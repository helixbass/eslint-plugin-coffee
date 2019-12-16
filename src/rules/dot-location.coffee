###*
# @fileoverview Validates newlines before and after dots
# @author Greg Cochard
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    type: 'layout'

    docs:
      description: 'enforce consistent newlines before and after dots'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/dot-location'

    schema: [enum: ['object', 'property']]

    fixable: 'code'

    messages:
      expectedDotAfterObject: 'Expected dot to be on same line as object.'
      expectedDotBeforeProperty: 'Expected dot to be on same line as property.'

  create: (context) ->
    config = context.options[0]

    # default to onObject if no preference is passed
    onObject = config is 'object' or not config

    sourceCode = context.getSourceCode()

    ###*
    # Reports if the dot between object and property is on the correct loccation.
    # @param {ASTNode} node The `MemberExpression` node.
    # @returns {void}
    ###
    checkDotLocation = (node) ->
      {property} = node
      dot = sourceCode.getTokenBefore property

      # `obj` expression can be parenthesized, but those paren tokens are not a part of the `obj` node.
      tokenBeforeDot = sourceCode.getTokenBefore dot

      textBeforeDot =
        sourceCode.getText().slice tokenBeforeDot.range[1], dot.range[0]
      textAfterDot = sourceCode.getText().slice dot.range[1], property.range[0]

      if onObject
        unless astUtils.isTokenOnSameLine tokenBeforeDot, dot
          neededTextAfterToken =
            if astUtils.isDecimalIntegerNumericToken tokenBeforeDot
              ' '
            else
              ''

          context.report {
            node
            loc: dot.loc
            messageId: 'expectedDotAfterObject'
            fix: (fixer) ->
              fixer.replaceTextRange(
                [tokenBeforeDot.range[1], property.range[0]]
                "#{neededTextAfterToken}.#{textBeforeDot}#{textAfterDot}"
              )
          }
      else unless astUtils.isTokenOnSameLine dot, property
        context.report {
          node
          loc: dot.loc
          messageId: 'expectedDotBeforeProperty'
          fix: (fixer) ->
            fixer.replaceTextRange(
              [tokenBeforeDot.range[1], property.range[0]]
              "#{textBeforeDot}#{textAfterDot}."
            )
        }

    ###*
    # Checks the spacing of the dot within a member expression.
    # @param {ASTNode} node The node to check.
    # @returns {void}
    ###
    checkNode = (node) ->
      return if node.computed
      return if (
        node.shorthand or
        (node.object.type is 'MemberExpression' and node.object.shorthand)
      )
      checkDotLocation node

    MemberExpression: checkNode
