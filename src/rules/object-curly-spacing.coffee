###*
# @fileoverview Disallows or enforces spaces inside of object literals.
# @author Jamund Ferguson
###
'use strict'

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent spacing inside braces'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/object-curly-spacing'

    fixable: 'whitespace'

    schema: [
      enum: ['always', 'never']
    ,
      type: 'object'
      properties:
        arraysInObjects:
          type: 'boolean'
        objectsInObjects:
          type: 'boolean'
      additionalProperties: no
    ]

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
      arraysInObjectsException: isOptionSet 'arraysInObjects'
      objectsInObjectsException: isOptionSet 'objectsInObjects'
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
        message: "There should be no space after '{{token}}'."
        data:
          token: token.value
        fix: (fixer) ->
          nextToken = context.getSourceCode().getTokenAfter token

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
        message: "There should be no space before '{{token}}'."
        data:
          token: token.value
        fix: (fixer) ->
          previousToken = context.getSourceCode().getTokenBefore token

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
        message: "A space is required after '{{token}}'."
        data:
          token: token.value
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
        message: "A space is required before '{{token}}'."
        data:
          token: token.value
        fix: (fixer) -> fixer.insertTextBefore token, ' '
      }

    ###*
    # Determines if spacing in curly braces is valid.
    # @param {ASTNode} node The AST node to check.
    # @param {Token} first The first token to check (should be the opening brace)
    # @param {Token} second The second token to check (should be first after the opening brace)
    # @param {Token} penultimate The penultimate token to check (should be last before closing brace)
    # @param {Token} last The last token to check (should be closing brace)
    # @returns {void}
    ###
    validateBraceSpacing = (node, first, second, penultimate, last) ->
      if astUtils.isTokenOnSameLine first, second
        firstSpaced = sourceCode.isSpaceBetweenTokens first, second

        if options.spaced and not firstSpaced
          reportRequiredBeginningSpace node, first
        if not options.spaced and firstSpaced
          reportNoBeginningSpace node, first

      if astUtils.isTokenOnSameLine penultimate, last
        shouldCheckPenultimate =
          (options.arraysInObjectsException and
            astUtils.isClosingBracketToken(penultimate)) or
          (options.objectsInObjectsException and
            astUtils.isClosingBraceToken penultimate)
        penultimateType =
          shouldCheckPenultimate and
          sourceCode.getNodeByRangeIndex(penultimate.range[0]).type

        closingCurlyBraceMustBeSpaced =
          if (
            (options.arraysInObjectsException and
              penultimateType is 'ArrayExpression') or
            (options.objectsInObjectsException and
              penultimateType in ['ObjectExpression', 'ObjectPattern'])
          )
            not options.spaced
          else
            options.spaced

        lastSpaced = sourceCode.isSpaceBetweenTokens penultimate, last

        if closingCurlyBraceMustBeSpaced and not lastSpaced
          reportRequiredEndingSpace node, last
        if not closingCurlyBraceMustBeSpaced and lastSpaced
          reportNoEndingSpace node, last

    ###*
    # Gets '}' token of an object node.
    #
    # Because the last token of object patterns might be a type annotation,
    # this traverses tokens preceded by the last property, then returns the
    # first '}' token.
    #
    # @param {ASTNode} node - The node to get. This node is an
    #      ObjectExpression or an ObjectPattern. And this node has one or
    #      more properties.
    # @returns {Token} '}' token.
    ###
    getClosingBraceOfObject = (node) ->
      lastProperty = node.properties[node.properties.length - 1]

      sourceCode.getTokenAfter lastProperty, astUtils.isClosingBraceToken

    ###*
    # Reports a given object node if spacing in curly braces is invalid.
    # @param {ASTNode} node - An ObjectExpression or ObjectPattern node to check.
    # @returns {void}
    ###
    checkForObject = (node) ->
      return if node.implicit
      return if node.properties.length is 0

      first = sourceCode.getFirstToken node
      last = getClosingBraceOfObject node
      second = sourceCode.getTokenAfter first
      penultimate = sourceCode.getTokenBefore last

      validateBraceSpacing node, first, second, penultimate, last

    ###*
    # Reports a given import node if spacing in curly braces is invalid.
    # @param {ASTNode} node - An ImportDeclaration node to check.
    # @returns {void}
    ###
    checkForImport = (node) ->
      return if node.specifiers.length is 0

      firstSpecifier = node.specifiers[0]
      lastSpecifier = node.specifiers[node.specifiers.length - 1]

      return unless lastSpecifier.type is 'ImportSpecifier'
      unless firstSpecifier.type is 'ImportSpecifier'
        firstSpecifier = node.specifiers[1]

      first = sourceCode.getTokenBefore firstSpecifier
      last = sourceCode.getTokenAfter lastSpecifier, astUtils.isNotCommaToken
      second = sourceCode.getTokenAfter first
      penultimate = sourceCode.getTokenBefore last

      validateBraceSpacing node, first, second, penultimate, last

    ###*
    # Reports a given export node if spacing in curly braces is invalid.
    # @param {ASTNode} node - An ExportNamedDeclaration node to check.
    # @returns {void}
    ###
    checkForExport = (node) ->
      return if node.specifiers.length is 0

      firstSpecifier = node.specifiers[0]
      lastSpecifier = node.specifiers[node.specifiers.length - 1]
      first = sourceCode.getTokenBefore firstSpecifier
      last = sourceCode.getTokenAfter lastSpecifier, astUtils.isNotCommaToken
      second = sourceCode.getTokenAfter first
      penultimate = sourceCode.getTokenBefore last

      validateBraceSpacing node, first, second, penultimate, last

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    # var {x} = y;
    ObjectPattern: checkForObject

    # var y = {x: 'y'}
    ObjectExpression: checkForObject

    # import {y} from 'x';
    ImportDeclaration: checkForImport

    # export {name} from 'yo';
    ExportNamedDeclaration: checkForExport
