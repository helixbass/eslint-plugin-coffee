###*
# @fileoverview Rule to enforce line breaks after each array element
# @author Jan Peer Stöcklmair <https://github.com/JPeer264>
###

'use strict'

astUtils = require '../eslint-ast-utils'
{hasIndentedLastLine} = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce line breaks after each array element'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/array-element-newline'
    # fixable: 'whitespace'
    schema: [
      oneOf: [
        enum: ['always', 'never', 'consistent']
      ,
        type: 'object'
        properties:
          multiline:
            type: 'boolean'
          minItems:
            type: ['integer', 'null']
            minimum: 0
        additionalProperties: no
      ]
    ]

    messages:
      unexpectedLineBreak: 'There should be no linebreak here.'
      missingLineBreak: 'There should be a linebreak after this element.'

  create: (context) ->
    sourceCode = context.getSourceCode()

    #----------------------------------------------------------------------
    # Helpers
    #----------------------------------------------------------------------

    ###*
    # Normalizes a given option value.
    #
    # @param {string|Object|undefined} providedOption - An option value to parse.
    # @returns {{multiline: boolean, minItems: number}} Normalized option object.
    ###
    normalizeOptionValue = (providedOption) ->
      consistent = no
      multiline = no
      option = providedOption or 'always'

      if not option or option is 'always' or option.minItems is 0
        minItems = 0
      else if option is 'never'
        minItems = Number.POSITIVE_INFINITY
      else if option is 'consistent'
        consistent = yes
        minItems = Number.POSITIVE_INFINITY
      else
        multiline = Boolean option.multiline
        minItems = option.minItems or Number.POSITIVE_INFINITY

      {consistent, multiline, minItems}

    ###*
    # Normalizes a given option value.
    #
    # @param {string|Object|undefined} options - An option value to parse.
    # @returns {{ArrayExpression: {multiline: boolean, minItems: number}, ArrayPattern: {multiline: boolean, minItems: number}}} Normalized option object.
    ###
    normalizeOptions = (options) ->
      value = normalizeOptionValue options

      ArrayExpression: value, ArrayPattern: value

    ###*
    # Reports that there shouldn't be a line break after the first token
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportNoLineBreak = (token) ->
      tokenBefore = sourceCode.getTokenBefore token, includeComments: yes

      context.report
        loc:
          start: tokenBefore.loc.end
          end: token.loc.start
        messageId: 'unexpectedLineBreak'
        # fix: (fixer) ->
        #   return null if astUtils.isCommentToken tokenBefore

        #   return fixer.replaceTextRange(
        #     [tokenBefore.range[1], token.range[0]]
        #     ' '
        #   ) unless astUtils.isTokenOnSameLine tokenBefore, token

        #   ###
        #   # This will check if the comma is on the same line as the next element
        #   # Following array:
        #   # [
        #   #     1
        #   #     , 2
        #   #     , 3
        #   # ]
        #   #
        #   # will be fixed to:
        #   # [
        #   #     1, 2, 3
        #   # ]
        #   ###
        #   twoTokensBefore = sourceCode.getTokenBefore tokenBefore,
        #     includeComments: yes

        #   return null if astUtils.isCommentToken twoTokensBefore

        #   fixer.replaceTextRange(
        #     [twoTokensBefore.range[1], tokenBefore.range[0]]
        #     ''
        #   )

    ###*
    # Reports that there should be a line break after the first token
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportRequiredLineBreak = (token) ->
      tokenBefore = sourceCode.getTokenBefore token, includeComments: yes

      context.report
        loc:
          start: tokenBefore.loc.end
          end: token.loc.start
        messageId: 'missingLineBreak'
        # fix: (fixer) ->
        #   fixer.replaceTextRange [tokenBefore.range[1], token.range[0]], '\n'

    getLastTokenOfPreviousElement = (element) ->
      sourceCode.getTokenBefore element,
        filter: (token) ->
          token.value isnt '(' and not astUtils.isCommaToken token

    getFirstTokenOfNextElement = (element) ->
      sourceCode.getTokenAfter element,
        filter: (token) ->
          token.value isnt ')' and not astUtils.isCommaToken token

    ###*
    # Reports a given node if it violated this rule.
    #
    # @param {ASTNode} node - A node to check. This is an ObjectExpression node or an ObjectPattern node.
    # @param {{multiline: boolean, minItems: number}} options - An option object.
    # @returns {void}
    ###
    check = (node) ->
      {elements} = node
      normalizedOptions = normalizeOptions context.options[0]
      options = normalizedOptions[node.type]

      elementBreak = no

      ###
      # MULTILINE: true
      # loop through every element and check
      # if at least one element has linebreaks inside
      # this ensures that following is not valid (due to elements are on the same line):
      #
      # [
      #      1,
      #      2,
      #      3
      # ]
      ###
      if options.multiline
        elementBreak =
          elements
          .filter (element) -> element isnt null
          .some (element) -> element.loc.start.line isnt element.loc.end.line

      linebreaksCount =
        elements
        .map (element, i) ->
          previousElement = elements[i - 1]

          return no if i is 0 or element is null or previousElement is null

          # commaToken = sourceCode.getFirstTokenBetween(
          #   previousElement
          #   element
          #   astUtils.isCommaToken
          # )
          # lastTokenOfPreviousElement = sourceCode.getTokenBefore commaToken
          # firstTokenOfCurrentElement = sourceCode.getTokenAfter commaToken
          lastTokenOfPreviousElement = getLastTokenOfPreviousElement element
          firstTokenOfCurrentElement = getFirstTokenOfNextElement(
            previousElement
          )

          not astUtils.isTokenOnSameLine(
            lastTokenOfPreviousElement
            firstTokenOfCurrentElement
          )
        .filter((isBreak) -> isBreak is yes).length

      needsLinebreaks =
        elements.length >= options.minItems or
        (options.multiline and elementBreak) or
        (options.consistent and
          linebreaksCount > 0 and
          linebreaksCount < node.elements.length)

      elements.forEach (element, i) ->
        previousElement = elements[i - 1]

        return if i is 0 or element is null or previousElement is null

        # commaToken = sourceCode.getFirstTokenBetween(
        #   previousElement
        #   element
        #   astUtils.isCommaToken
        # )
        # lastTokenOfPreviousElement = sourceCode.getTokenBefore commaToken
        # firstTokenOfCurrentElement = sourceCode.getTokenAfter commaToken
        lastTokenOfPreviousElement = getLastTokenOfPreviousElement element
        firstTokenOfCurrentElement = getFirstTokenOfNextElement previousElement

        if needsLinebreaks
          if astUtils.isTokenOnSameLine(
            lastTokenOfPreviousElement
            firstTokenOfCurrentElement
          )
            reportRequiredLineBreak firstTokenOfCurrentElement
        else unless astUtils.isTokenOnSameLine(
          lastTokenOfPreviousElement
          firstTokenOfCurrentElement
        )
          return if hasIndentedLastLine {node: element, sourceCode}
          reportNoLineBreak firstTokenOfCurrentElement

    #----------------------------------------------------------------------
    # Public
    #----------------------------------------------------------------------

    ArrayPattern: check
    ArrayExpression: check
