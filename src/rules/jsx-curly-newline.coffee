###*
# @fileoverview enforce consistent line breaks inside jsx curly
###

'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

getNormalizedOption = (context) ->
  rawOption = context.options[0] or 'consistent'

  return {
    multiline: 'consistent'
    singleline: 'consistent'
  } if rawOption is 'consistent'

  return {
    multiline: 'forbid'
    singleline: 'forbid'
  } if rawOption is 'never'

  multiline: rawOption.multiline or 'consistent'
  singleline: rawOption.singleline or 'consistent'

module.exports =
  meta:
    type: 'layout'

    docs:
      description: 'enforce consistent line breaks inside jsx curly'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-curly-newline'

    # fixable: 'whitespace'

    schema: [
      oneOf: [
        enum: ['consistent', 'never']
      ,
        type: 'object'
        properties:
          singleline: enum: ['consistent', 'require', 'forbid']
          multiline: enum: ['consistent', 'require', 'forbid']
        additionalProperties: no
      ]
    ]

    messages:
      expectedBefore: "Expected newline before '}'."
      expectedAfter: "Expected newline after '{'."
      unexpectedBefore: "Unexpected newline before '{'."
      unexpectedAfter: "Unexpected newline after '}'."

  create: (context) ->
    sourceCode = context.getSourceCode()
    option = getNormalizedOption context

    # ----------------------------------------------------------------------
    # Helpers
    # ----------------------------------------------------------------------

    ###*
    # Determines whether two adjacent tokens are on the same line.
    # @param {Object} left - The left token object.
    # @param {Object} right - The right token object.
    # @returns {boolean} Whether or not the tokens are on the same line.
    ###
    isTokenOnSameLine = (left, right) ->
      left.loc.end.line is right.loc.start.line

    ###*
    # Determines whether there should be newlines inside curlys
    # @param {ASTNode} expression The expression contained in the curlys
    # @param {boolean} hasLeftNewline `true` if the left curly has a newline in the current code.
    # @returns {boolean} `true` if there should be newlines inside the function curlys
    ###
    shouldHaveNewlines = (expression, hasLeftNewline) ->
      isMultiline = expression.loc.start.line isnt expression.loc.end.line

      switch (if isMultiline then option.multiline else option.singleline)
        when 'forbid' then return no
        when 'require' then return yes
        else return hasLeftNewline

    ###*
    # Validates curlys
    # @param {Object} curlys An object with keys `leftParen` for the left paren token, and `rightParen` for the right paren token
    # @param {ASTNode} expression The expression inside the curly
    # @returns {void}
    ###
    validateCurlys = (curlys, expression) ->
      {leftCurly} = curlys
      {rightCurly} = curlys
      tokenAfterLeftCurly = sourceCode.getTokenAfter leftCurly
      tokenBeforeRightCurly = sourceCode.getTokenBefore rightCurly
      hasLeftNewline = not isTokenOnSameLine leftCurly, tokenAfterLeftCurly
      hasRightNewline = not isTokenOnSameLine tokenBeforeRightCurly, rightCurly
      needsNewlines = shouldHaveNewlines expression, hasLeftNewline

      if hasLeftNewline and not needsNewlines
        context.report
          node: leftCurly
          messageId: 'unexpectedAfter'
          # fix: (fixer) ->
          #   condition =
          #     sourceCode
          #     .getText()
          #     .slice leftCurly.range[1], tokenAfterLeftCurly.range[0]
          #     .trim()
          #   if condition
          #     null
          #   # If there is a comment between the { and the first element, don't do a fix.
          #   else
          #     fixer.removeRange [
          #       leftCurly.range[1]
          #       tokenAfterLeftCurly.range[0]
          #     ]
      else if not hasLeftNewline and needsNewlines
        context.report
          node: leftCurly
          messageId: 'expectedAfter'
          # fix: (fixer) -> fixer.insertTextAfter leftCurly, '\n'

      if hasRightNewline and not needsNewlines
        context.report
          node: rightCurly
          messageId: 'unexpectedBefore'
          # fix: (fixer) ->
          #   condition =
          #     sourceCode
          #     .getText()
          #     .slice tokenBeforeRightCurly.range[1], rightCurly.range[0]
          #     .trim()
          #   if condition
          #     null
          #   # If there is a comment between the last element and the }, don't do a fix.
          #   else
          #     fixer.removeRange [
          #       tokenBeforeRightCurly.range[1]
          #       rightCurly.range[0]
          #     ]
      else if not hasRightNewline and needsNewlines
        context.report
          node: rightCurly
          messageId: 'expectedBefore'
          # fix: (fixer) -> fixer.insertTextBefore rightCurly, '\n'

    # ----------------------------------------------------------------------
    # Public
    # ----------------------------------------------------------------------

    JSXExpressionContainer: (node) ->
      curlyTokens =
        leftCurly: sourceCode.getFirstToken node
        rightCurly: sourceCode.getLastToken node
      validateCurlys curlyTokens, node.expression
