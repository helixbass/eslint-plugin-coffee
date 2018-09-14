###*
# @fileoverview enforce consistent line breaks inside function parentheses
# @author Teddy Katz
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
      description: 'enforce consistent line breaks inside function parentheses'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/function-paren-newline'
    # fixable: 'whitespace'
    schema: [
      oneOf: [
        enum: ['always', 'never', 'consistent', 'multiline']
      ,
        type: 'object'
        properties:
          minItems:
            type: 'integer'
            minimum: 0
        additionalProperties: no
      ]
    ]
    messages:
      expectedBefore: "Expected newline before ')'."
      expectedAfter: "Expected newline after '('."
      unexpectedBefore: "Unexpected newline before '('."
      unexpectedAfter: "Unexpected newline after ')'."

  create: (context) ->
    sourceCode = context.getSourceCode()
    rawOption = context.options[0] or 'multiline'
    multilineOption = rawOption is 'multiline'
    consistentOption = rawOption is 'consistent'
    if typeof rawOption is 'object'
      {minItems} = rawOption
    else if rawOption is 'always'
      minItems = 0
    else if rawOption is 'never'
      minItems = Infinity
    else
      minItems = null

    #----------------------------------------------------------------------
    # Helpers
    #----------------------------------------------------------------------

    ###*
    # Determines whether there should be newlines inside function parens
    # @param {ASTNode[]} elements The arguments or parameters in the list
    # @param {boolean} hasLeftNewline `true` if the left paren has a newline in the current code.
    # @returns {boolean} `true` if there should be newlines inside the function parens
    ###
    shouldHaveNewlines = (elements, hasLeftNewline) ->
      if multilineOption
        return elements.some (element, index) ->
          index isnt elements.length - 1 and
          element.loc.end.line isnt elements[index + 1].loc.start.line
      return hasLeftNewline if consistentOption
      elements.length >= minItems

    ###*
    # Validates a list of arguments or parameters
    # @param {Object} parens An object with keys `leftParen` for the left paren token, and `rightParen` for the right paren token
    # @param {ASTNode[]} elements The arguments or parameters in the list
    # @returns {void}
    ###
    validateParens = (parens, elements) ->
      {leftParen, rightParen} = parens
      return unless leftParen and rightParen
      tokenAfterLeftParen = sourceCode.getTokenAfter leftParen
      tokenBeforeRightParen = sourceCode.getTokenBefore rightParen
      hasLeftNewline = not astUtils.isTokenOnSameLine(
        leftParen
        tokenAfterLeftParen
      )
      hasRightNewline = not astUtils.isTokenOnSameLine(
        tokenBeforeRightParen
        rightParen
      )
      needsNewlines = shouldHaveNewlines elements, hasLeftNewline

      if hasLeftNewline and not needsNewlines
        context.report
          node: leftParen
          messageId: 'unexpectedAfter'
          # fix: (fixer) ->
          #   if sourceCode
          #     .getText()
          #     .slice leftParen.range[1], tokenAfterLeftParen.range[0]
          #     .trim()
          #     # If there is a comment between the ( and the first element, don't do a fix.
          #     null
          #   else
          #     fixer.removeRange [
          #       leftParen.range[1]
          #       tokenAfterLeftParen.range[0]
          #     ]
      else if not hasLeftNewline and needsNewlines
        context.report
          node: leftParen
          messageId: 'expectedAfter'
          # fix: (fixer) -> fixer.insertTextAfter leftParen, '\n'

      if hasRightNewline and not needsNewlines
        context.report
          node: rightParen
          messageId: 'unexpectedBefore'
          # fix: (fixer) ->
          #   if sourceCode
          #     .getText()
          #     .slice tokenBeforeRightParen.range[1], rightParen.range[0]
          #     .trim()
          #     # If there is a comment between the last element and the ), don't do a fix.
          #     null
          #   else
          #     fixer.removeRange [
          #       tokenBeforeRightParen.range[1]
          #       rightParen.range[0]
          #     ]
      else if not hasRightNewline and needsNewlines
        context.report
          node: rightParen
          messageId: 'expectedBefore'
          # fix: (fixer) -> fixer.insertTextBefore rightParen, '\n'

    ###*
    # Gets the left paren and right paren tokens of a node.
    # @param {ASTNode} node The node with parens
    # @returns {Object} An object with keys `leftParen` for the left paren token, and `rightParen` for the right paren token.
    # Can also return `null` if an expression has no parens (e.g. a NewExpression with no arguments, or an ArrowFunctionExpression
    # with a single parameter)
    ###
    getParenTokens = (node) ->
      return null if node.implicit
      switch node.type
        when 'NewExpression', 'CallExpression'
          # If the NewExpression does not have parens (e.g. `new Foo`), return null.
          return null if (
            node.type is 'NewExpression' and
            not node.arguments.length and
            not (
              astUtils.isOpeningParenToken(
                sourceCode.getLastToken node, skip: 1
              ) and astUtils.isClosingParenToken sourceCode.getLastToken node
            )
          )

          return
            leftParen: sourceCode.getTokenAfter(
              node.callee
              astUtils.isOpeningParenToken
            )
            rightParen: sourceCode.getLastToken node


        when 'FunctionDeclaration', 'FunctionExpression'
          leftParen = sourceCode.getFirstToken(
            node
            astUtils.isOpeningParenToken
          )
          return null unless leftParen
          rightParen =
            if node.params.length
              sourceCode.getTokenAfter(
                node.params[node.params.length - 1]
                astUtils.isClosingParenToken
              )
            else
              sourceCode.getTokenAfter leftParen

          return {leftParen, rightParen}

        when 'ArrowFunctionExpression'
          firstToken = sourceCode.getFirstToken node

          # If the ArrowFunctionExpression has a single param without parens, return null.
          return null unless astUtils.isOpeningParenToken firstToken

          return
            leftParen: firstToken
            rightParen: sourceCode.getTokenBefore(
              node.body
              astUtils.isClosingParenToken
            )


        else
          throw new TypeError "unexpected node with type #{node.type}"

    ###*
    # Validates the parentheses for a node
    # @param {ASTNode} node The node with parens
    # @returns {void}
    ###
    validateNode = (node) ->
      parens = getParenTokens node

      if parens
        validateParens parens,
          if astUtils.isFunction node then node.params else node.arguments

    #----------------------------------------------------------------------
    # Public
    #----------------------------------------------------------------------

    ArrowFunctionExpression: validateNode
    CallExpression: validateNode
    FunctionDeclaration: validateNode
    FunctionExpression: validateNode
    NewExpression: validateNode
