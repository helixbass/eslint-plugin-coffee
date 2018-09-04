###*
# @fileoverview Rule to flag for-in loops without if statements inside
# @author Nicholas C. Zakas
###

'use strict'

isIf = (node) ->
  return node if node.type is 'IfStatement'
  return node.expression if (
    node.type is 'ExpressionStatement' and
    node.expression.type is 'ConditionalExpression'
  )
  no

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require `for-in` loops to include an `if` statement'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/guard-for-in'

    schema: []

  create: (context) ->
    For: (node) ->
      {body, style, own} = node

      # only for-of
      return unless style is 'of'

      # `own` filters the prototype
      return if own

      # empty statement
      return if body.type is 'EmptyStatement'

      # if statement
      return if isIf body

      # empty block
      return if body.type is 'BlockStatement' and body.body.length is 0

      # block with just if statement
      return if (
        body.type is 'BlockStatement' and
        body.body.length is 1 and
        isIf body.body[0]
      )

      # block that starts with if statement
      if (
        body.type is 'BlockStatement' and
        body.body.length >= 1 and
        (ifNode = isIf body.body[0])
      )
        # ... whose consequent is a continue
        return if ifNode.consequent.type is 'ContinueStatement'

        # ... whose consequent is a block that contains only a continue
        return if (
          ifNode.consequent.type is 'BlockStatement' and
          ifNode.consequent.body.length is 1 and
          ifNode.consequent.body[0].type is 'ContinueStatement'
        )

      context.report {
        node
        message:
          'The body of a for-of should use "own" or be wrapped in an if statement to filter unwanted properties from the prototype.'
      }
