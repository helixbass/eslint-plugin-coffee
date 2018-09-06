###*
# @fileoverview This rule shoud require or disallow spaces before or after unary operations.
# @author Marcin Kumorek
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent spacing before or after unary operators'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/space-unary-ops'

    fixable: 'whitespace'

    schema: [
      type: 'object'
      properties:
        words:
          type: 'boolean'
        nonwords:
          type: 'boolean'
        overrides:
          type: 'object'
          additionalProperties:
            type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    options = (context.options and
      Array.isArray(context.options) and
      context.options[0]) or words: yes, nonwords: no

    sourceCode = context.getSourceCode()

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Check if the node is the first "!" in a "!!" convert to Boolean expression
    # @param {ASTnode} node AST node
    # @returns {boolean} Whether or not the node is first "!" in "!!"
    ###
    isFirstBangInBangBangExpression = (node) ->
      node and
      node.type is 'UnaryExpression' and
      node.argument.operator is '!' and
      node.argument and
      node.argument.type is 'UnaryExpression' and
      node.argument.operator is '!'

    ###*
    # Checks if an override exists for a given operator.
    # @param {string} operator Operator
    # @returns {boolean} Whether or not an override has been provided for the operator
    ###
    overrideExistsForOperator = (operator) ->
      options.overrides and
      Object.prototype.hasOwnProperty.call options.overrides, operator

    ###*
    # Gets the value that the override was set to for this operator
    # @param {string} operator Operator
    # @returns {boolean} Whether or not an override enforces a space with this operator
    ###
    overrideEnforcesSpaces = (operator) -> options.overrides[operator]

    ###*
    # Verify Unary Word Operator has spaces after the word operator
    # @param {ASTnode} node AST node
    # @param {Object} firstToken first token from the AST node
    # @param {Object} secondToken second token from the AST node
    # @param {string} word The word to be used for reporting
    # @returns {void}
    ###
    verifyWordHasSpaces = (node, firstToken, secondToken, word) ->
      if secondToken.range[0] is firstToken.range[1]
        context.report {
          node
          message:
            "Unary word operator '{{word}}' must be followed by whitespace."
          data: {
            word
          }
          fix: (fixer) -> fixer.insertTextAfter firstToken, ' '
        }

    ###*
    # Verify Unary Word Operator doesn't have spaces after the word operator
    # @param {ASTnode} node AST node
    # @param {Object} firstToken first token from the AST node
    # @param {Object} secondToken second token from the AST node
    # @param {string} word The word to be used for reporting
    # @returns {void}
    ###
    verifyWordDoesntHaveSpaces = (node, firstToken, secondToken, word) ->
      if astUtils.canTokensBeAdjacent firstToken, secondToken
        if secondToken.range[0] > firstToken.range[1]
          context.report {
            node
            message: "Unexpected space after unary word operator '{{word}}'."
            data: {
              word
            }
            fix: (fixer) ->
              fixer.removeRange [firstToken.range[1], secondToken.range[0]]
          }

    ###*
    # Check Unary Word Operators for spaces after the word operator
    # @param {ASTnode} node AST node
    # @param {Object} firstToken first token from the AST node
    # @param {Object} secondToken second token from the AST node
    # @param {string} word The word to be used for reporting
    # @returns {void}
    ###
    checkUnaryWordOperatorForSpaces = (node, firstToken, secondToken, word) ->
      if overrideExistsForOperator word
        if overrideEnforcesSpaces word
          verifyWordHasSpaces node, firstToken, secondToken, word
        else
          verifyWordDoesntHaveSpaces node, firstToken, secondToken, word
      else if options.words
        verifyWordHasSpaces node, firstToken, secondToken, word
      else
        verifyWordDoesntHaveSpaces node, firstToken, secondToken, word

    ###*
    # Verifies YieldExpressions satisfy spacing requirements
    # @param {ASTnode} node AST node
    # @returns {void}
    ###
    checkForSpacesAfterYield = (node) ->
      tokens = sourceCode.getFirstTokens node, 3
      word = 'yield'

      return if not node.argument or node.delegate

      checkUnaryWordOperatorForSpaces node, tokens[0], tokens[1], word

    ###*
    # Verifies AwaitExpressions satisfy spacing requirements
    # @param {ASTNode} node AwaitExpression AST node
    # @returns {void}
    ###
    checkForSpacesAfterAwait = (node) ->
      tokens = sourceCode.getFirstTokens node, 3

      checkUnaryWordOperatorForSpaces node, tokens[0], tokens[1], 'await'

    ###*
    # Verifies UnaryExpression, UpdateExpression and NewExpression have spaces before or after the operator
    # @param {ASTnode} node AST node
    # @param {Object} firstToken First token in the expression
    # @param {Object} secondToken Second token in the expression
    # @returns {void}
    ###
    verifyNonWordsHaveSpaces = (node, firstToken, secondToken) ->
      if node.prefix
        return if isFirstBangInBangBangExpression node
        if firstToken.range[1] is secondToken.range[0]
          context.report {
            node
            message:
              "Unary operator '{{operator}}' must be followed by whitespace."
            data:
              operator: firstToken.value
            fix: (fixer) -> fixer.insertTextAfter firstToken, ' '
          }
      else if firstToken.range[1] is secondToken.range[0]
        context.report {
          node
          message: "Space is required before unary expressions '{{token}}'."
          data:
            token: secondToken.value
          fix: (fixer) -> fixer.insertTextBefore secondToken, ' '
        }

    ###*
    # Verifies UnaryExpression, UpdateExpression and NewExpression don't have spaces before or after the operator
    # @param {ASTnode} node AST node
    # @param {Object} firstToken First token in the expression
    # @param {Object} secondToken Second token in the expression
    # @returns {void}
    ###
    verifyNonWordsDontHaveSpaces = (node, firstToken, secondToken) ->
      if node.prefix
        if secondToken.range[0] > firstToken.range[1]
          context.report {
            node
            message: "Unexpected space after unary operator '{{operator}}'."
            data:
              operator: firstToken.value
            fix: (fixer) ->
              return fixer.removeRange [
                firstToken.range[1]
                secondToken.range[0]
              ] if astUtils.canTokensBeAdjacent firstToken, secondToken
              null
          }
      else if secondToken.range[0] > firstToken.range[1]
        context.report {
          node
          message: "Unexpected space before unary operator '{{operator}}'."
          data:
            operator: secondToken.value
          fix: (fixer) ->
            fixer.removeRange [firstToken.range[1], secondToken.range[0]]
        }

    ###*
    # Verifies UnaryExpression, UpdateExpression and NewExpression satisfy spacing requirements
    # @param {ASTnode} node AST node
    # @returns {void}
    ###
    checkForSpaces = (node) ->
      return if node.type is 'UpdateExpression' and not node.prefix
      tokens = sourceCode.getFirstTokens node, 2
      firstToken = tokens[0]
      secondToken = tokens[1]

      if (
        (node.type is 'NewExpression' or node.prefix) and
        firstToken.type is 'Keyword'
      )
        checkUnaryWordOperatorForSpaces(
          node
          firstToken
          secondToken
          firstToken.value
        )
        return

      operator = if node.prefix then tokens[0].value else tokens[1].value

      if overrideExistsForOperator operator
        if overrideEnforcesSpaces operator
          verifyNonWordsHaveSpaces node, firstToken, secondToken
        else
          verifyNonWordsDontHaveSpaces node, firstToken, secondToken
      else if options.nonwords
        verifyNonWordsHaveSpaces node, firstToken, secondToken
      else
        verifyNonWordsDontHaveSpaces node, firstToken, secondToken

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    UnaryExpression: checkForSpaces
    UpdateExpression: checkForSpaces
    NewExpression: checkForSpaces
    YieldExpression: checkForSpacesAfterYield
    AwaitExpression: checkForSpacesAfterAwait
