###*
# @fileoverview Enforce spacing between rest and spread operators and their expressions.
# @author Kai Cataldo
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce spacing between rest and spread operators and their expressions'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/rest-spread-spacing'
    fixable: 'whitespace'
    schema: [enum: ['always', 'never']]

  create: (context) ->
    sourceCode = context.getSourceCode()
    alwaysSpace = context.options[0] is 'always'

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Checks whitespace between rest/spread operators and their expressions
    # @param {ASTNode} node - The node to check
    # @returns {void}
    ###
    checkWhiteSpace = (node) ->
      {postfix} = node
      if postfix
        operator = sourceCode.getLastToken node
        prevToken = sourceCode.getTokenBefore operator
        hasWhitespace = sourceCode.isSpaceBetweenTokens prevToken, operator
      else
        operator = sourceCode.getFirstToken node
        nextToken = sourceCode.getTokenAfter operator
        hasWhitespace = sourceCode.isSpaceBetweenTokens operator, nextToken
      switch node.type
        when 'SpreadElement'
          type = 'spread'
          if node.parent.type is 'ObjectExpression' then type += ' property'
        when 'RestElement'
          type = 'rest'
          if node.parent.type is 'ObjectPattern' then type += ' property'
        when 'ExperimentalSpreadProperty'
          type = 'spread property'
        when 'ExperimentalRestProperty'
          type = 'rest property'
        else
          return

      if alwaysSpace and not hasWhitespace
        context.report {
          node
          loc:
            line: operator.loc.end.line
            column: operator.loc.end.column
          message: "Expected whitespace #{
            if postfix then 'before' else 'after'
          } {{type}} operator."
          data: {
            type
          }
          fix: (fixer) ->
            fixer.replaceTextRange(
              if postfix
                [prevToken.range[1], operator.range[0]]
              else
                [operator.range[1], nextToken.range[0]]
              ' '
            )
        }
      else if not alwaysSpace and hasWhitespace
        context.report {
          node
          loc:
            line: operator.loc.end.line
            column: operator.loc.end.column
          message: "Unexpected whitespace #{
            if postfix then 'before' else 'after'
          } {{type}} operator."
          data: {
            type
          }
          fix: (fixer) ->
            fixer.removeRange(
              if postfix
                [prevToken.range[1], operator.range[0]]
              else
                [operator.range[1], nextToken.range[0]]
            )
        }

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    SpreadElement: checkWhiteSpace
    RestElement: checkWhiteSpace
    ExperimentalSpreadProperty: checkWhiteSpace
    ExperimentalRestProperty: checkWhiteSpace
