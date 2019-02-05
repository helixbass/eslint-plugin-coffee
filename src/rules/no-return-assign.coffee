###*
# @fileoverview Rule to flag when return statement contains assignment
# @author Ilya Volodin
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

SENTINEL_TYPE =
  /^(?:[a-zA-Z]+?Statement|ArrowFunctionExpression|FunctionExpression|ClassExpression)$/

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow assignment operators in `return` statements'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-return-assign'

    schema: [enum: ['except-parens', 'always']]

  create: (context) ->
    always = (context.options[0] or 'except-parens') isnt 'except-parens'
    sourceCode = context.getSourceCode()

    AssignmentExpression: (node) ->
      return if not always and astUtils.isParenthesised sourceCode, node

      currentChild = node
      {parent} = currentChild

      # Find ReturnStatement or ArrowFunctionExpression in ancestors.
      while parent and not SENTINEL_TYPE.test parent.type
        currentChild = parent
        {parent} = parent

      # Reports.
      if parent and parent.type is 'ReturnStatement'
        context.report
          node: parent
          message: 'Return statement should not contain assignment.'
      else if currentChild.returns
        context.report
          node: currentChild
          message: 'Implicit return statement should not contain assignment.'
      # else if (
      #   parent and
      #   parent.type is 'ArrowFunctionExpression' and
      #   parent.body is currentChild
      # )
      #   context.report
      #     node: parent
      #     message: 'Arrow function should not return assignment.'
