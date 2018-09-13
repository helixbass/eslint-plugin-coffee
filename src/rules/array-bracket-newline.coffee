###*
# @fileoverview Rule to enforce linebreaks after open and before close array brackets
# @author Jan Peer Stöcklmair <https://github.com/JPeer264>
###

'use strict'

astUtils = require 'eslint/lib/ast-utils'
{hasIndentedLastLine} = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce linebreaks after opening and before closing array brackets'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/array-bracket-newline'
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
      unexpectedOpeningLinebreak: "There should be no linebreak after '['."
      unexpectedClosingLinebreak: "There should be no linebreak before ']'."
      missingOpeningLinebreak: "A linebreak is required after '['."
      missingClosingLinebreak: "A linebreak is required before ']'."

  create: (context) ->
    sourceCode = context.getSourceCode()

    #----------------------------------------------------------------------
    # Helpers
    #----------------------------------------------------------------------

    ###*
    # Normalizes a given option value.
    #
    # @param {string|Object|undefined} option - An option value to parse.
    # @returns {{multiline: boolean, minItems: number}} Normalized option object.
    ###
    normalizeOptionValue = (option) ->
      consistent = no
      multiline = no
      minItems = 0

      if option
        if option is 'consistent'
          consistent = yes
          minItems = Number.POSITIVE_INFINITY
        else if option is 'always' or option.minItems is 0
          minItems = 0
        else if option is 'never'
          minItems = Number.POSITIVE_INFINITY
        else
          multiline = Boolean option.multiline
          minItems = option.minItems or Number.POSITIVE_INFINITY
      else
        consistent = no
        multiline = yes
        minItems = Number.POSITIVE_INFINITY

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
    # Reports that there shouldn't be a linebreak after the first token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportNoBeginningLinebreak = (node, token) ->
      context.report {
        node
        loc: token.loc
        messageId: 'unexpectedOpeningLinebreak'
        # fix: (fixer) ->
        #   nextToken = sourceCode.getTokenAfter token, includeComments: yes

        #   return null if astUtils.isCommentToken nextToken

        #   fixer.removeRange [token.range[1], nextToken.range[0]]
      }

    ###*
    # Reports that there shouldn't be a linebreak before the last token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportNoEndingLinebreak = (node, token) ->
      context.report {
        node
        loc: token.loc
        messageId: 'unexpectedClosingLinebreak'
        # fix: (fixer) ->
        #   previousToken = sourceCode.getTokenBefore token, includeComments: yes

        #   return null if astUtils.isCommentToken previousToken

        #   fixer.removeRange [previousToken.range[1], token.range[0]]
      }

    ###*
    # Reports that there should be a linebreak after the first token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportRequiredBeginningLinebreak = (node, token) ->
      context.report {
        node
        loc: token.loc
        messageId: 'missingOpeningLinebreak'
        # fix: (fixer) -> fixer.insertTextAfter token, '\n'
      }

    ###*
    # Reports that there should be a linebreak before the last token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportRequiredEndingLinebreak = (node, token) ->
      context.report {
        node
        loc: token.loc
        messageId: 'missingClosingLinebreak'
        # fix: (fixer) -> fixer.insertTextBefore token, '\n'
      }

    # getIndentSize: ({node, openBracket}) ->
    #   openBracketLine = openBracket.loc.start.line
    #   currentMin = null
    #   for element in node.elements when node.loc.start.line > openBracketLine
    #     {column} = element.loc.start
    #     currentMin = column if not currentMin? or column < currentMin

    ###*
    # Reports a given node if it violated this rule.
    #
    # @param {ASTNode} node - A node to check. This is an ArrayExpression node or an ArrayPattern node.
    # @returns {void}
    ###
    check = (node) ->
      {elements} = node
      normalizedOptions = normalizeOptions context.options[0]
      options = normalizedOptions[node.type]
      openBracket = sourceCode.getFirstToken node
      closeBracket = sourceCode.getLastToken node
      firstIncComment = sourceCode.getTokenAfter openBracket,
        includeComments: yes
      lastIncComment = sourceCode.getTokenBefore closeBracket,
        includeComments: yes
      first = sourceCode.getTokenAfter openBracket
      last = sourceCode.getTokenBefore closeBracket
      # indentSize = getIndentSize {node, openBracket}
      lastElementHasIndentedBody = do ->
        return no unless elements.length
        lastElement = elements[elements.length - 1]
        return no unless lastElement.loc.start.line < lastElement.loc.end.line
        return yes if lastElement.loc.start.line is openBracket.loc.start.line
        hasIndentedLastLine {node: lastElement, sourceCode}

      needsLinebreaks =
        elements.length >= options.minItems or
        (options.multiline and
          elements.length > 0 and
          firstIncComment.loc.start.line isnt lastIncComment.loc.end.line) or
        (elements.length is 0 and
          firstIncComment.type is 'Block' and
          firstIncComment.loc.start.line isnt lastIncComment.loc.end.line and
          firstIncComment is lastIncComment) or
        (options.consistent and
          firstIncComment.loc.start.line isnt openBracket.loc.end.line)

      ###
      # Use tokens or comments to check multiline or not.
      # But use only tokens to check whether linebreaks are needed.
      # This allows:
      #     var arr = [ // eslint-disable-line foo
      #         'a'
      #     ]
      ###

      if needsLinebreaks
        if astUtils.isTokenOnSameLine openBracket, first
          reportRequiredBeginningLinebreak node, openBracket
        if astUtils.isTokenOnSameLine last, closeBracket
          reportRequiredEndingLinebreak node, closeBracket
      else
        unless astUtils.isTokenOnSameLine openBracket, first
          reportNoBeginningLinebreak node, openBracket
        if (
          not lastElementHasIndentedBody and
          not astUtils.isTokenOnSameLine last, closeBracket
        )
          reportNoEndingLinebreak node, closeBracket

    #----------------------------------------------------------------------
    # Public
    #----------------------------------------------------------------------

    ArrayPattern: check
    ArrayExpression: check
