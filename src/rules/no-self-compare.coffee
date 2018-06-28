###*
# @fileoverview Rule to flag comparison where left part is the same as the right
# part.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow comparisons where both sides are exactly the same'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-self-compare'

    schema: []

  create: (context) ->
    sourceCode = context.getSourceCode()

    ###*
    # Determines whether two nodes are composed of the same tokens.
    # @param {ASTNode} nodeA The first node
    # @param {ASTNode} nodeB The second node
    # @returns {boolean} true if the nodes have identical token representations
    ###
    hasSameTokens = (nodeA, nodeB) ->
      tokensA = sourceCode.getTokens nodeA
      tokensB = sourceCode.getTokens nodeB
      tokensA.length is tokensB.length and
        tokensA.every (token, index) ->
          token.type is tokensB[index].type and
          token.value is tokensB[index].value

    BinaryExpression: (node) ->
      operators = new Set ['is', '==', 'isnt', '!=', '>', '<', '>=', '<=']
      if operators.has(node.operator) and hasSameTokens node.left, node.right
        context.report {
          node
          message: 'Comparing to itself is potentially pointless.'
        }
