###*
# @fileoverview Rule to disallow negating the left operand of relational operators
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether the given operator is a relational operator or not.
#
# @param {string} op - The operator type to check.
# @returns {boolean} `true` if the operator is a relational operator.
###
isRelationalOperator = (op) ->
  op in ['in', 'not in', 'of', 'not of', 'instanceof', 'not instanceof']

###*
# Checks whether the given node is a logical negation expression or not.
#
# @param {ASTNode} node - The node to check.
# @returns {boolean} `true` if the node is a logical negation expression.
###
isNegation = (node) ->
  node.type is 'UnaryExpression' and node.operator in ['!', 'not']

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow negating the left operand of relational operators'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-unsafe-negation'
    schema: []
    # fixable: 'code'

  create: (context) ->
    sourceCode = context.getSourceCode()

    BinaryExpression: (node) ->
      if (
        isRelationalOperator(node.operator) and
        isNegation(node.left) and
        not astUtils.isParenthesised sourceCode, node.left
      )
        context.report {
          node
          loc: node.left.loc
          message:
            "Unexpected negating the left operand of '{{operator}}' operator."
          data: node

          # fix: (fixer) ->
          #   negationToken = sourceCode.getFirstToken node.left
          #   fixRange = [
          #     if (
          #       node.left.operator is 'not' and
          #       /^\s+/.test sourceCode.getText()[negationToken.range[1]..]
          #     )
          #       negationToken.range[1] + 1
          #     else
          #       negationToken.range[1]
          #     node.range[1]
          #   ]
          #   text = sourceCode.text.slice fixRange[0], fixRange[1]

          #   fixer.replaceTextRange fixRange, "(#{text})"
        }
