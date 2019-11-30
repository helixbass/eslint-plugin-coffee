###*
# @fileoverview Rule to warn about using dot notation instead of square bracket notation when possible.
# @author Josh Perez
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

validIdentifier = /^[a-zA-Z_$][a-zA-Z0-9_$]*$/
keywords = require '../eslint-keywords'

module.exports =
  meta:
    docs:
      description: 'enforce dot notation whenever possible'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/dot-notation'

    schema: [
      type: 'object'
      properties:
        allowKeywords:
          type: 'boolean'
        allowPattern:
          type: 'string'
      additionalProperties: no
    ]

    fixable: 'code'

    messages:
      useDot: '[{{key}}] is better written in dot notation.'
      useBrackets: '.{{key}} is a syntax error.'

  create: (context) ->
    options = context.options[0] or {}
    allowKeywords =
      options.allowKeywords is undefined or !!options.allowKeywords
    sourceCode = context.getSourceCode()

    allowPattern = new RegExp options.allowPattern if options.allowPattern

    ###*
    # Check if the property is valid dot notation
    # @param {ASTNode} node The dot notation node
    # @param {string} value Value which is to be checked
    # @returns {void}
    ###
    checkComputedProperty = (node, value) ->
      if (
        validIdentifier.test(value) and
        (allowKeywords or keywords.indexOf(String value) is -1) and
        not allowPattern?.test value
      )
        formattedValue =
          if node.property.type is 'Literal'
            JSON.stringify value
          else
            "\"#{value}\""

        context.report
          node: node.property
          messageId: 'useDot'
          data:
            key: formattedValue
          fix: (fixer) ->
            leftBracket = sourceCode.getTokenAfter(
              node.object
              astUtils.isOpeningBracketToken
            )
            rightBracket = sourceCode.getLastToken node

            # Don't perform any fixes if there are comments inside the brackets.
            return null if sourceCode.getFirstTokenBetween(
              leftBracket
              rightBracket
              includeComments: yes, filter: astUtils.isCommentToken
            )

            tokenAfterProperty = sourceCode.getTokenAfter rightBracket
            needsSpaceAfterProperty =
              tokenAfterProperty and
              rightBracket.range[1] is tokenAfterProperty.range[0] and
              not astUtils.canTokensBeAdjacent String(value), tokenAfterProperty

            textBeforeDot =
              if astUtils.isDecimalInteger node.object
                ' '
              else
                ''
            textAfterProperty = if needsSpaceAfterProperty then ' ' else ''

            fixer.replaceTextRange(
              [leftBracket.range[0], rightBracket.range[1]]
              "#{textBeforeDot}.#{value}#{textAfterProperty}"
            )

    MemberExpression: (node) ->
      if node.computed and node.property.type is 'Literal'
        checkComputedProperty node, node.property.value
      if (
        node.computed and
        node.property.type is 'TemplateLiteral' and
        node.property.expressions.length is 0
      )
        # TODO: use cooked once exposed on AST?
        # checkComputedProperty node, node.property.quasis[0].value.cooked
        checkComputedProperty node, node.property.quasis[0].value.raw
      if (
        not allowKeywords and
        not node.computed and
        keywords.indexOf(String node.property.name) isnt -1
      )
        context.report
          node: node.property
          messageId: 'useBrackets'
          data:
            key: node.property.name
          fix: (fixer) ->
            dot = sourceCode.getTokenBefore node.property
            textAfterDot = sourceCode.text.slice(
              dot.range[1]
              node.property.range[0]
            )

            # Don't perform any fixes if there are comments between the dot and the property name.
            return null if textAfterDot.trim()

            # ###
            # # A statement that starts with `let[` is parsed as a destructuring variable declaration, not
            # # a MemberExpression.
            # ###
            # return null if (
            #   node.object.type is 'Identifier' and node.object.name is 'let'
            # )

            fixer.replaceTextRange(
              [dot.range[0], node.property.range[1]]
              "[#{textAfterDot}\"#{node.property.name}\"]"
            )
