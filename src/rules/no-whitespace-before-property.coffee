###*
# @fileoverview Rule to disallow whitespace before properties
# @author Kai Cataldo
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------
isPrototypeShorthand = (node) ->
  node.object.type is 'MemberExpression' and node.object.shorthand

isTokenStartOnSameLine = (left, right) ->
  left.loc.start.line is right.loc.start.line

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    type: 'layout'

    docs:
      description: 'disallow whitespace before properties'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-whitespace-before-property'

    fixable: 'whitespace'
    schema: []

  create: (context) ->
    sourceCode = context.getSourceCode()

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Reports whitespace before property token
    # @param {ASTNode} node the node to report in the event of an error
    # @param {Token} leftToken the left token
    # @param {Token} rightToken the right token
    # @returns {void}
    # @private
    ###
    reportError = (node, leftToken, rightToken) ->
      replacementText =
        if node.computed
          ''
        else if isPrototypeShorthand node
          '::'
        else
          '.'

      context.report {
        node
        message: 'Unexpected whitespace before property {{propName}}.'
        data:
          propName: sourceCode.getText node.property
        fix: (fixer) ->
          ###
          # If the object is a number literal, fixing it to something like 5.toString() would cause a SyntaxError.
          # Don't fix this case.
          ###
          return null if (
            not node.computed and astUtils.isDecimalInteger node.object
          )
          fixer.replaceTextRange(
            [leftToken.range[1], rightToken.range[0]]
            replacementText
          )
      }

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    MemberExpression: (node) ->
      return if node.shorthand
      return if node.object.type is 'ThisExpression' and node.object.shorthand
      return unless astUtils.isTokenOnSameLine node.object, node.property
      return if (
        isPrototypeShorthand(node) and
        not isTokenStartOnSameLine node.object, node.property
      )

      if node.computed
        rightToken = sourceCode.getTokenBefore(
          node.property
          astUtils.isOpeningBracketToken
        )
        leftToken = sourceCode.getTokenBefore rightToken
      else
        rightToken = sourceCode.getFirstToken node.property
        leftToken = sourceCode.getTokenBefore rightToken, 1

      if sourceCode.isSpaceBetweenTokens leftToken, rightToken
        reportError node, leftToken, rightToken
