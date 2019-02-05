###*
# @fileoverview Operator linebreak - enforces operator linebreak style of two types: after and before
# @author Benoît Zugmeyer
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent linebreak style for operators'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/operator-linebreak'

    schema: [
      enum: ['after', 'before', 'none', null]
    ,
      type: 'object'
      properties:
        overrides:
          type: 'object'
          properties:
            anyOf:
              type: 'string'
              enum: ['after', 'before', 'none', 'ignore']
      additionalProperties: no
    ]

    # fixable: 'code'

  create: (context) ->
    # usedDefaultGlobal = not context.options[0]
    globalStyle = context.options[0] or 'after'
    options = context.options[1] or {}
    styleOverrides = if options.overrides then {...options.overrides} else {}

    # if usedDefaultGlobal and not styleOverrides['?']
    #   styleOverrides['?'] = 'before'

    # if usedDefaultGlobal and not styleOverrides[':']
    #   styleOverrides[':'] = 'before'

    sourceCode = context.getSourceCode()

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    # ###*
    # # Gets a fixer function to fix rule issues
    # # @param {Token} operatorToken The operator token of an expression
    # # @param {string} desiredStyle The style for the rule. One of 'before', 'after', 'none'
    # # @returns {Function} A fixer function
    # ###
    # getFixer = (operatorToken, desiredStyle) -> (fixer) ->
    #   tokenBefore = sourceCode.getTokenBefore operatorToken
    #   tokenAfter = sourceCode.getTokenAfter operatorToken
    #   textBefore = sourceCode.text.slice(
    #     tokenBefore.range[1]
    #     operatorToken.range[0]
    #   )
    #   textAfter = sourceCode.text.slice(
    #     operatorToken.range[1]
    #     tokenAfter.range[0]
    #   )
    #   hasLinebreakBefore = not astUtils.isTokenOnSameLine(
    #     tokenBefore
    #     operatorToken
    #   )
    #   hasLinebreakAfter = not astUtils.isTokenOnSameLine(
    #     operatorToken
    #     tokenAfter
    #   )
    #   if hasLinebreakBefore isnt hasLinebreakAfter and desiredStyle isnt 'none'
    #     # If there is a comment before and after the operator, don't do a fix.
    #     return null if (
    #       sourceCode.getTokenBefore(operatorToken, includeComments: yes) isnt
    #         tokenBefore and
    #       sourceCode.getTokenAfter(operatorToken, includeComments: yes) isnt
    #         tokenAfter
    #     )

    #     ###
    #     # If there is only one linebreak and it's on the wrong side of the operator, swap the text before and after the operator.
    #     # foo &&
    #     #           bar
    #     # would get fixed to
    #     # foo
    #     #        && bar
    #     ###
    #     newTextBefore = textAfter
    #     newTextAfter = textBefore
    #   else
    #     LINEBREAK_REGEX = astUtils.createGlobalLinebreakMatcher()

    #     # Otherwise, if no linebreak is desired and no comments interfere, replace the linebreaks with empty strings.
    #     newTextBefore =
    #       if desiredStyle is 'before' or textBefore.trim()
    #         textBefore
    #       else
    #         textBefore.replace LINEBREAK_REGEX, ''
    #     newTextAfter =
    #       if desiredStyle is 'after' or textAfter.trim()
    #         textAfter
    #       else
    #         textAfter.replace LINEBREAK_REGEX, ''

    #     # If there was no change (due to interfering comments), don't output a fix.
    #     return null if newTextBefore is textBefore and newTextAfter is textAfter

    #   if (
    #     newTextAfter is '' and
    #     tokenAfter.type is 'Punctuator' and
    #     '+-'.includes(operatorToken.value) and
    #     tokenAfter.value is operatorToken.value
    #   )
    #     # To avoid accidentally creating a ++ or -- operator, insert a space if the operator is a +/- and the following token is a unary +/-.
    #     newTextAfter += ' '

    #   fixer.replaceTextRange(
    #     [tokenBefore.range[1], tokenAfter.range[0]]
    #     newTextBefore + operatorToken.value + newTextAfter
    #   )

    ###*
    # Checks the operator placement
    # @param {ASTNode} node The node to check
    # @param {ASTNode} leftSide The node that comes before the operator in `node`
    # @private
    # @returns {void}
    ###
    validateNode = (node, leftSide) ->
      ###
      # When the left part of a binary expression is a single expression wrapped in
      # parentheses (ex: `(a) + b`), leftToken will be the last token of the expression
      # and operatorToken will be the closing parenthesis.
      # The leftToken should be the last closing parenthesis, and the operatorToken
      # should be the token right after that.
      ###
      operatorToken = sourceCode.getTokenAfter(
        leftSide
        astUtils.isNotClosingParenToken
      )
      leftToken = sourceCode.getTokenBefore operatorToken
      rightToken = sourceCode.getTokenAfter operatorToken
      operator = operatorToken.value
      operatorStyleOverride = styleOverrides[operator]
      style = operatorStyleOverride or globalStyle
      # fix = getFixer operatorToken, style

      # if single line
      if (
        astUtils.isTokenOnSameLine(leftToken, operatorToken) and
        astUtils.isTokenOnSameLine operatorToken, rightToken
      )
        # do nothing.
      else if (
        operatorStyleOverride isnt 'ignore' and
        not astUtils.isTokenOnSameLine(leftToken, operatorToken) and
        not astUtils.isTokenOnSameLine operatorToken, rightToken
      )
        # lone operator
        context.report {
          node
          loc:
            line: operatorToken.loc.end.line
            column: operatorToken.loc.end.column
          message: "Bad line breaking before and after '{{operator}}'."
          data: {
            operator
          }
          # fix
        }
      else if (
        style is 'before' and
        astUtils.isTokenOnSameLine leftToken, operatorToken
      )
        context.report {
          node
          loc:
            line: operatorToken.loc.end.line
            column: operatorToken.loc.end.column
          message:
            "'{{operator}}' should be placed at the beginning of the line."
          data: {
            operator
          }
          # fix
        }
      else if (
        style is 'after' and
        astUtils.isTokenOnSameLine operatorToken, rightToken
      )
        context.report {
          node
          loc:
            line: operatorToken.loc.end.line
            column: operatorToken.loc.end.column
          message: "'{{operator}}' should be placed at the end of the line."
          data: {
            operator
          }
          # fix
        }
      else if style is 'none'
        context.report {
          node
          loc:
            line: operatorToken.loc.end.line
            column: operatorToken.loc.end.column
          message:
            "There should be no line break before or after '{{operator}}'."
          data: {
            operator
          }
          # fix
        }

    ###*
    # Validates a binary expression using `validateNode`
    # @param {BinaryExpression|LogicalExpression|AssignmentExpression} node node to be validated
    # @returns {void}
    ###
    validateBinaryExpression = (node) -> validateNode node, node.left

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    BinaryExpression: validateBinaryExpression
    LogicalExpression: validateBinaryExpression
    AssignmentExpression: validateBinaryExpression
    VariableDeclarator: (node) -> if node.init then validateNode node, node.id
