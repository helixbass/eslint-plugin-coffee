###*
# @fileoverview Comma style - enforces comma styles of two types: last and first
# @author Vignesh Anand aka vegetableman
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent comma style'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/comma-style'
    # fixable: 'code'
    schema: [
      enum: ['first', 'last']
    ,
      type: 'object'
      properties:
        exceptions:
          type: 'object'
          additionalProperties:
            type: 'boolean'
      additionalProperties: no
    ]
    messages:
      unexpectedLineBeforeAndAfterComma:
        "Bad line breaking before and after ','."
      expectedCommaFirst: "',' should be placed first."
      expectedCommaLast: "',' should be placed last."

  create: (context) ->
    style = context.options[0] or 'last'
    sourceCode = context.getSourceCode()
    exceptions =
      ArrayPattern: yes
      ArrowFunctionExpression: yes
      CallExpression: yes
      FunctionDeclaration: yes
      FunctionExpression: yes
      ImportDeclaration: yes
      ObjectPattern: yes
      NewExpression: yes

    if (
      context.options.length is 2 and
      Object::hasOwnProperty.call context.options[1], 'exceptions'
    )
      for own key, exception of context.options[1].exceptions
        exceptions[key] = exception

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    # ###*
    # # Modified text based on the style
    # # @param {string} styleType Style type
    # # @param {string} text Source code text
    # # @returns {string} modified text
    # # @private
    # ###
    # getReplacedText = (styleType, text) ->
    #   switch styleType
    #     when 'between'
    #       return ",#{text.replace '\n', ''}"

    #     when 'first'
    #       return "#{text},"

    #     when 'last'
    #       return ",#{text}"

    #     else
    #       return ''

    # ###*
    # # Determines the fixer function for a given style.
    # # @param {string} styleType comma style
    # # @param {ASTNode} previousItemToken The token to check.
    # # @param {ASTNode} commaToken The token to check.
    # # @param {ASTNode} currentItemToken The token to check.
    # # @returns {Function} Fixer function
    # # @private
    # ###
    # getFixerFunction = (
    #   styleType
    #   previousItemToken
    #   commaToken
    #   currentItemToken
    # ) ->
    #   text =
    #     sourceCode.text.slice(previousItemToken.range[1], commaToken.range[0]) +
    #     sourceCode.text.slice commaToken.range[1], currentItemToken.range[0]
    #   range = [previousItemToken.range[1], currentItemToken.range[0]]

    #   (fixer) -> fixer.replaceTextRange range, getReplacedText styleType, text

    ###*
    # Validates the spacing around single items in lists.
    # @param {Token} previousItemToken The last token from the previous item.
    # @param {Token} commaToken The token representing the comma.
    # @param {Token} currentItemToken The first token of the current item.
    # @param {Token} reportItem The item to use when reporting an error.
    # @returns {void}
    # @private
    ###
    validateCommaItemSpacing = (
      previousItemToken
      commaToken
      currentItemToken
      reportItem
    ) ->
      # if single line
      if (
        astUtils.isTokenOnSameLine(commaToken, currentItemToken) and
        astUtils.isTokenOnSameLine previousItemToken, commaToken
      )
        # do nothing.
      else if (
        not astUtils.isTokenOnSameLine(commaToken, currentItemToken) and
        not astUtils.isTokenOnSameLine previousItemToken, commaToken
      )
        # lone comma
        context.report
          node: reportItem
          loc:
            line: commaToken.loc.end.line
            column: commaToken.loc.start.column
          messageId: 'unexpectedLineBeforeAndAfterComma'
          # fix: getFixerFunction(
          #   'between'
          #   previousItemToken
          #   commaToken
          #   currentItemToken
          # )
      else if (
        style is 'first' and
        not astUtils.isTokenOnSameLine commaToken, currentItemToken
      )
        context.report
          node: reportItem
          messageId: 'expectedCommaFirst'
          # fix: getFixerFunction(
          #   style
          #   previousItemToken
          #   commaToken
          #   currentItemToken
          # )
      else if (
        style is 'last' and
        astUtils.isTokenOnSameLine commaToken, currentItemToken
      )
        context.report
          node: reportItem
          loc:
            line: commaToken.loc.end.line
            column: commaToken.loc.end.column
          messageId: 'expectedCommaLast'
          # fix: getFixerFunction(
          #   style
          #   previousItemToken
          #   commaToken
          #   currentItemToken
          # )

    ###*
    # Checks the comma placement with regards to a declaration/property/element
    # @param {ASTNode} node The binary expression node to check
    # @param {string} property The property of the node containing child nodes.
    # @private
    # @returns {void}
    ###
    validateComma = (node, property) ->
      items = node[property]
      arrayLiteral = node.type in ['ArrayExpression', 'ArrayPattern']

      if items.length > 1 or arrayLiteral
        # seed as opening [
        previousItemToken = sourceCode.getFirstToken node

        items.forEach (item) ->
          commaToken =
            if item then sourceCode.getTokenBefore item else previousItemToken
          currentItemToken =
            if item
              sourceCode.getFirstToken item
            else
              sourceCode.getTokenAfter commaToken
          reportItem = item or currentItemToken

          ###
          # This works by comparing three token locations:
          # - previousItemToken is the last token of the previous item
          # - commaToken is the location of the comma before the current item
          # - currentItemToken is the first token of the current item
          #
          # These values get switched around if item is undefined.
          # previousItemToken will refer to the last token not belonging
          # to the current item, which could be a comma or an opening
          # square bracket. currentItemToken could be a comma.
          #
          # All comparisons are done based on these tokens directly, so
          # they are always valid regardless of an undefined item.
          ###
          if astUtils.isCommaToken commaToken
            validateCommaItemSpacing(
              previousItemToken
              commaToken
              currentItemToken
              reportItem
            )

          if item
            tokenAfterItem = sourceCode.getTokenAfter(
              item
              astUtils.isNotClosingParenToken
            )

            previousItemToken ###:### =
              if tokenAfterItem
                sourceCode.getTokenBefore tokenAfterItem
              else
                sourceCode.ast.tokens[sourceCode.ast.tokens.length - 1]

        ###
        # Special case for array literals that have empty last items, such
        # as [ 1, 2, ]. These arrays only have two items show up in the
        # AST, so we need to look at the token to verify that there's no
        # dangling comma.
        ###
        if arrayLiteral
          lastToken = sourceCode.getLastToken node
          nextToLastToken = sourceCode.getTokenBefore lastToken

          if astUtils.isCommaToken nextToLastToken
            validateCommaItemSpacing(
              sourceCode.getTokenBefore nextToLastToken
              nextToLastToken
              lastToken
              lastToken
            )

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    nodes = {}

    unless exceptions.VariableDeclaration
      nodes.VariableDeclaration = (node) -> validateComma node, 'declarations'
    unless exceptions.ObjectExpression
      nodes.ObjectExpression = (node) -> validateComma node, 'properties'
    unless exceptions.ObjectPattern
      nodes.ObjectPattern = (node) -> validateComma node, 'properties'
    unless exceptions.ArrayExpression
      nodes.ArrayExpression = (node) -> validateComma node, 'elements'
    unless exceptions.ArrayPattern
      nodes.ArrayPattern = (node) -> validateComma node, 'elements'
    unless exceptions.FunctionDeclaration
      nodes.FunctionDeclaration = (node) -> validateComma node, 'params'
    unless exceptions.FunctionExpression
      nodes.FunctionExpression = (node) -> validateComma node, 'params'
    unless exceptions.ArrowFunctionExpression
      nodes.ArrowFunctionExpression = (node) -> validateComma node, 'params'
    unless exceptions.CallExpression
      nodes.CallExpression = (node) -> validateComma node, 'arguments'
    unless exceptions.ImportDeclaration
      nodes.ImportDeclaration = (node) -> validateComma node, 'specifiers'
    unless exceptions.NewExpression
      nodes.NewExpression = (node) -> validateComma node, 'arguments'

    nodes
