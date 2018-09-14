###*
# @fileoverview enforce the location of arrow function bodies
# @author Sharmila Jesupaul
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------
module.exports =
  meta:
    docs:
      description: 'enforce the location of arrow function bodies'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/implicit-arrow-linebreak'
    fixable: 'whitespace'
    schema: [enum: ['beside', 'below']]

  create: (context) ->
    sourceCode = context.getSourceCode()

    #----------------------------------------------------------------------
    # Helpers
    #----------------------------------------------------------------------
    ###*
    # Gets the applicable preference for a particular keyword
    # @returns {string} The applicable option for the keyword, e.g. 'beside'
    ###
    getOption = -> context.options[0] or 'beside'

    ###*
    # Validates the location of an arrow function body
    # @param {ASTNode} node The arrow function body
    # @param {string} keywordName The applicable keyword name for the arrow function body
    # @returns {void}
    ###
    validateExpression = (node) ->
      return unless (
        node.body.type isnt 'BlockStatement' or
        (node.body.body.length is 1 and
          node.body.body[0].type is 'ExpressionStatement')
      )
      {body} = node
      body = body.body[0] if body.type is 'BlockStatement'
      option = getOption()

      tokenBefore = sourceCode.getTokenBefore body
      hasParens = tokenBefore.value is '('

      # return if node.type is 'BlockStatement'

      fixerTarget = body

      if hasParens
        # Gets the first token before the function body that is not an open paren
        tokenBefore = sourceCode.getTokenBefore body, (token) ->
          token.value isnt '('
        fixerTarget = sourceCode.getTokenAfter tokenBefore

      if (
        tokenBefore.loc.end.line is fixerTarget.loc.start.line and
        option is 'below'
      )
        context.report
          node: fixerTarget
          message: 'Expected a linebreak before this expression.'
          fix: (fixer) -> fixer.insertTextBefore fixerTarget, '\n'
      else if (
        tokenBefore.loc.end.line isnt fixerTarget.loc.start.line and
        option is 'beside'
      )
        context.report
          node: fixerTarget
          message: 'Expected no linebreak before this expression.'
          fix: (fixer) ->
            fixer.replaceTextRange(
              [tokenBefore.range[1], fixerTarget.range[0]]
              ' '
            )

    #----------------------------------------------------------------------
    # Public
    #----------------------------------------------------------------------
    FunctionExpression: validateExpression
