###*
# @fileoverview Disallow use of multiple spaces.
# @author Nicholas C. Zakas
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow multiple spaces'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-multi-spaces'

    fixable: 'whitespace'

    schema: [
      type: 'object'
      properties:
        exceptions:
          type: 'object'
          patternProperties:
            '^([A-Z][a-z]*)+$':
              type: 'boolean'
          additionalProperties: no
        ignoreEOLComments:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    options = context.options[0] or {}
    {ignoreEOLComments} = options
    exceptions = {Property: yes, ...options.exceptions}
    hasExceptions =
      Object.keys(exceptions).filter((key) -> exceptions[key]).length > 0

    ###*
    # Formats value of given comment token for error message by truncating its length.
    # @param {Token} token comment token
    # @returns {string} formatted value
    # @private
    ###
    formatReportedCommentValue = (token) ->
      valueLines = token.value.split '\n'
      value = valueLines[0]
      formattedValue = "#{value.slice 0, 12}..."

      if valueLines.length is 1 and value.length <= 12
        value
      else
        formattedValue

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    Program: ->
      sourceCode.tokensAndComments.forEach (
        leftToken
        leftIndex
        tokensAndComments
      ) ->
        return if leftIndex is tokensAndComments.length - 1
        rightToken = tokensAndComments[leftIndex + 1]

        # Ignore tokens that don't have 2 spaces between them or are on different lines
        return if (
          not sourceCode.text
          .slice(leftToken.range[1], rightToken.range[0])
          .includes('  ') or leftToken.loc.end.line < rightToken.loc.start.line
        )

        # Ignore comments that are the last token on their line if `ignoreEOLComments` is active.
        return if (
          ignoreEOLComments and
          astUtils.isCommentToken(rightToken) and
          (leftIndex is tokensAndComments.length - 2 or
            rightToken.loc.end.line <
              tokensAndComments[leftIndex + 2].loc.start.line)
        )

        # Ignore tokens that are in a node in the "exceptions" object
        if hasExceptions
          parentNode = sourceCode.getNodeByRangeIndex rightToken.range[0] - 1

          return if parentNode and exceptions[parentNode.type]

        if rightToken.type is 'Block'
          displayValue = "####{formatReportedCommentValue rightToken}###"
        else if rightToken.type is 'Line'
          displayValue = "##{formatReportedCommentValue rightToken}"
        else
          displayValue = rightToken.value

        context.report
          node: rightToken
          loc: rightToken.loc.start
          message: "Multiple spaces found before '{{displayValue}}'."
          data: {displayValue}
          fix: (fixer) ->
            fixer.replaceTextRange(
              [leftToken.range[1], rightToken.range[0]]
              ' '
            )
