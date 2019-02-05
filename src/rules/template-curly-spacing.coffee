###*
# @fileoverview Rule to enforce spacing around embedded expressions of template strings
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'

# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'require or disallow spacing around embedded expressions of template strings'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/template-curly-spacing'

    fixable: 'whitespace'

    schema: [enum: ['always', 'never']]

  create: (context) ->
    sourceCode = context.getSourceCode()
    always = context.options[0] is 'always'
    prefix = if always then 'Expected' else 'Unexpected'

    checkExpression = (node) ->
      firstToken = sourceCode.getFirstToken node
      openingCurlyToken = sourceCode.getTokenBefore firstToken
      return unless openingCurlyToken?.value is '#{'
      if (
        astUtils.isTokenOnSameLine(openingCurlyToken, firstToken) and
        sourceCode.isSpaceBetweenTokens(openingCurlyToken, firstToken) isnt
          always
      )
        context.report
          loc:
            line: openingCurlyToken.loc.end.line
            column: openingCurlyToken.loc.end.column - 2
          message: '{{prefix}} space(s) after \'#{\'.'
          data: {
            prefix
          }
          fix: (fixer) ->
            return fixer.insertTextAfter openingCurlyToken, ' ' if always
            fixer.removeRange [openingCurlyToken.range[1], firstToken.range[0]]

      lastToken = sourceCode.getLastToken node
      closingCurlyToken = sourceCode.getTokenAfter lastToken
      return unless closingCurlyToken?.value is '}'
      if (
        astUtils.isTokenOnSameLine(lastToken, closingCurlyToken) and
        sourceCode.isSpaceBetweenTokens(lastToken, closingCurlyToken) isnt
          always
      )
        context.report
          loc: closingCurlyToken.loc.start
          message: "{{prefix}} space(s) before '}'."
          data: {
            prefix
          }
          fix: (fixer) ->
            return fixer.insertTextBefore closingCurlyToken, ' ' if always
            fixer.removeRange [lastToken.range[1], closingCurlyToken.range[0]]

    TemplateLiteral: (node) ->
      return unless node.expressions?.length
      for expression in node.expressions
        checkExpression expression
