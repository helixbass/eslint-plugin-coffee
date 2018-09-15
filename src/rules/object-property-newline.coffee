###*
# @fileoverview Rule to enforce placing object properties on separate lines.
# @author Vitor Balocco
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce placing object properties on separate lines'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/object-property-newline'

    schema: [
      type: 'object'
      properties:
        allowAllPropertiesOnSameLine:
          type: 'boolean'
        allowMultiplePropertiesPerLine:
          # Deprecated
          type: 'boolean'
      additionalProperties: no
    ]

    # fixable: 'whitespace'

  create: (context) ->
    allowSameLine =
      context.options[0] and
      (Boolean(context.options[0].allowAllPropertiesOnSameLine) or
        Boolean context.options[0].allowMultiplePropertiesPerLine) # Deprecated
    errorMessage =
      if allowSameLine
        "Object properties must go on a new line if they aren't all on the same line."
      else
        'Object properties must go on a new line.'

    sourceCode = context.getSourceCode()

    ObjectExpression: (node) ->
      return unless node.properties.length
      if allowSameLine
        if node.properties.length > 1
          firstTokenOfFirstProperty = sourceCode.getFirstToken(
            node.properties[0]
          )
          lastTokenOfLastProperty = sourceCode.getLastToken(
            node.properties[node.properties.length - 1]
          )

          # All keys and values are on the same line
          return if (
            firstTokenOfFirstProperty.loc.end.line is
            lastTokenOfLastProperty.loc.start.line
          )

      for i in [1...node.properties.length]
        lastTokenOfPreviousProperty = sourceCode.getLastToken(
          node.properties[i - 1]
        )
        firstTokenOfCurrentProperty = sourceCode.getFirstToken(
          node.properties[i]
        )

        if (
          lastTokenOfPreviousProperty.loc.end.line is
          firstTokenOfCurrentProperty.loc.start.line
        )
          context.report {
            node
            loc: firstTokenOfCurrentProperty.loc.start
            message: errorMessage
            # fix: (fixer) ->
            #   comma = sourceCode.getTokenBefore firstTokenOfCurrentProperty
            #   rangeAfterComma = [
            #     comma.range[1]
            #     firstTokenOfCurrentProperty.range[0]
            #   ]

            #   # Don't perform a fix if there are any comments between the comma and the next property.
            #   return null if sourceCode.text
            #   .slice(rangeAfterComma[0], rangeAfterComma[1])
            #   .trim()

            #   fixer.replaceTextRange rangeAfterComma, '\n'
          }
