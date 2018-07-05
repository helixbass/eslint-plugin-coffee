###*
# @fileoverview Rule to flag comparisons to null without a type-checking
# operator.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow `null` comparisons without type-checking operators'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-eq-null'

    schema: []

    messages: unexpected: "Use 'is'/'isnt' to compare with null."

  create: (context) ->
    BinaryExpression: (node) ->
      badOperator = node.operator in ['==', '!=']

      if (
        (node.right.type is 'Literal' and
          node.right.raw is 'null' and
          badOperator) or
        (node.left.type is 'Literal' and
          node.left.raw is 'null' and
          badOperator)
      )
        context.report {node, messageId: 'unexpected'}
