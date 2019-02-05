###*
# @fileoverview Disallows or enforces spaces inside of array brackets.
# @author Jamund Ferguson
###
'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent spacing inside array brackets'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/array-bracket-spacing'
    fixable: 'whitespace'
    schema: [
      enum: ['always', 'never']
    ,
      type: 'object'
      properties:
        singleValue:
          type: 'boolean'
        objectsInArrays:
          type: 'boolean'
        arraysInArrays:
          type: 'boolean'
      additionalProperties: no
    ]
    messages:
      unexpectedSpaceAfter: "There should be no space after '{{tokenValue}}'."
      unexpectedSpaceBefore: "There should be no space before '{{tokenValue}}'."
      missingSpaceAfter: "A space is required after '{{tokenValue}}'."
      missingSpaceBefore: "A space is required before '{{tokenValue}}'."
  create: (context) ->
    spaced = context.options[0] is 'always'
    sourceCode = context.getSourceCode()

    ###*
    # Determines whether an option is set, relative to the spacing option.
    # If spaced is "always", then check whether option is set to false.
    # If spaced is "never", then check whether option is set to true.
    # @param {Object} option - The option to exclude.
    # @returns {boolean} Whether or not the property is excluded.
    ###
    isOptionSet = (option) ->
      if context.options[1]
        context.options[1][option] is not spaced
      else
        no

    options = {
      spaced
      singleElementException: isOptionSet 'singleValue'
      objectsInArraysException: isOptionSet 'objectsInArrays'
      arraysInArraysException: isOptionSet 'arraysInArrays'
    }

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Reports that there shouldn't be a space after the first token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportNoBeginningSpace = (node, token) ->
      context.report {
        node
        loc: token.loc.start
        messageId: 'unexpectedSpaceAfter'
        data:
          tokenValue: token.value
        fix: (fixer) ->
          nextToken = sourceCode.getTokenAfter token

          fixer.removeRange [token.range[1], nextToken.range[0]]
      }

    ###*
    # Reports that there shouldn't be a space before the last token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportNoEndingSpace = (node, token) ->
      context.report {
        node
        loc: token.loc.start
        messageId: 'unexpectedSpaceBefore'
        data:
          tokenValue: token.value
        fix: (fixer) ->
          previousToken = sourceCode.getTokenBefore token

          fixer.removeRange [previousToken.range[1], token.range[0]]
      }

    ###*
    # Reports that there should be a space after the first token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportRequiredBeginningSpace = (node, token) ->
      context.report {
        node
        loc: token.loc.start
        messageId: 'missingSpaceAfter'
        data:
          tokenValue: token.value
        fix: (fixer) -> fixer.insertTextAfter token, ' '
      }

    ###*
    # Reports that there should be a space before the last token
    # @param {ASTNode} node - The node to report in the event of an error.
    # @param {Token} token - The token to use for the report.
    # @returns {void}
    ###
    reportRequiredEndingSpace = (node, token) ->
      context.report {
        node
        loc: token.loc.start
        messageId: 'missingSpaceBefore'
        data:
          tokenValue: token.value
        fix: (fixer) -> fixer.insertTextBefore token, ' '
      }

    ###*
    # Determines if a node is an object type
    # @param {ASTNode} node - The node to check.
    # @returns {boolean} Whether or not the node is an object type.
    ###
    isObjectType = (node) ->
      node and
      node.type in ['ObjectExpression', 'ObjectPattern'] and
      not node.implicit

    ###*
    # Determines if a node is an array type
    # @param {ASTNode} node - The node to check.
    # @returns {boolean} Whether or not the node is an array type.
    ###
    isArrayType = (node) ->
      node and node.type in ['ArrayExpression', 'ArrayPattern']

    ###*
    # Validates the spacing around array brackets
    # @param {ASTNode} node - The node we're checking for spacing
    # @returns {void}
    ###
    validateArraySpacing = (node) ->
      return if options.spaced and node.elements.length is 0

      first = sourceCode.getFirstToken node
      second = sourceCode.getFirstToken node, 1
      last =
        if node.typeAnnotation
          sourceCode.getTokenBefore node.typeAnnotation
        else
          sourceCode.getLastToken node
      penultimate = sourceCode.getTokenBefore last
      firstElement = node.elements[0]
      lastElement = node.elements[node.elements.length - 1]

      openingBracketMustBeSpaced =
        if (
          (options.objectsInArraysException and isObjectType(firstElement)) or
          (options.arraysInArraysException and isArrayType(firstElement)) or
          (options.singleElementException and node.elements.length is 1)
        )
          not options.spaced
        else
          options.spaced

      closingBracketMustBeSpaced =
        if (
          (options.objectsInArraysException and isObjectType(lastElement)) or
          (options.arraysInArraysException and isArrayType(lastElement)) or
          (options.singleElementException and node.elements.length is 1)
        )
          not options.spaced
        else
          options.spaced

      if astUtils.isTokenOnSameLine first, second
        if (
          openingBracketMustBeSpaced and
          not sourceCode.isSpaceBetweenTokens first, second
        )
          reportRequiredBeginningSpace node, first
        if (
          not openingBracketMustBeSpaced and
          sourceCode.isSpaceBetweenTokens first, second
        )
          reportNoBeginningSpace node, first

      if first isnt penultimate and astUtils.isTokenOnSameLine penultimate, last
        if (
          closingBracketMustBeSpaced and
          not sourceCode.isSpaceBetweenTokens penultimate, last
        )
          reportRequiredEndingSpace node, last
        if (
          not closingBracketMustBeSpaced and
          sourceCode.isSpaceBetweenTokens penultimate, last
        )
          reportNoEndingSpace node, last

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    ArrayPattern: validateArraySpacing
    ArrayExpression: validateArraySpacing
