###*
# @fileoverview Rule to disallow a negated condition
# @author Alberto Rodríguez
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow negated conditions'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-negated-condition'

    schema: [
      type: 'object'
      properties:
        requireElse:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    {requireElse} = context.options[0] ? {}

    ###*
    # Determines if a given node is an if-else without a condition on the else
    # @param {ASTNode} node The node to check.
    # @returns {boolean} True if the node has an else without an if.
    # @private
    ###
    hasElseWithoutCondition = (node) ->
      node.alternate and node.alternate.type isnt 'IfStatement'

    ###*
    # Determines if a given node is a negated unary expression
    # @param {Object} test The test object to check.
    # @returns {boolean} True if the node is a negated unary expression.
    # @private
    ###
    isNegatedUnaryExpression = (test) ->
      test.type is 'UnaryExpression' and test.operator in ['!', 'not']

    ###*
    # Determines if a given node is a negated binary expression
    # @param {Test} test The test to check.
    # @returns {boolean} True if the node is a negated binary expression.
    # @private
    ###
    isNegatedBinaryExpression = (test) ->
      test.type is 'BinaryExpression' and test.operator in ['!=', 'isnt']

    ###*
    # Determines if a given node has a negated if expression
    # @param {ASTNode} node The node to check.
    # @returns {boolean} True if the node has a negated if expression.
    # @private
    ###
    isNegatedIf = (node) ->
      isNegatedUnaryExpression(node.test) or isNegatedBinaryExpression node.test

    checkNode = (node) ->
      return unless not requireElse or hasElseWithoutCondition node

      if isNegatedIf node
        context.report {node, message: 'Unexpected negated condition.'}

    IfStatement: checkNode
    ConditionalExpression: checkNode
