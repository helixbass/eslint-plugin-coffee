###*
# @fileoverview Rule to disallow mixed binary operators.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'
{getPrecedence} = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ARITHMETIC_OPERATORS = ['+', '-', '*', '/', '%', '**']
BITWISE_OPERATORS = ['&', '|', '^', '~', '<<', '>>', '>>>']
COMPARISON_OPERATORS = ['==', '!=', 'is', 'isnt', '>', '>=', '<', '<=']
LOGICAL_OPERATORS = ['&&', '||', 'and', 'or', '?']
RELATIONAL_OPERATORS = ['in', 'instanceof', 'of', 'not in', 'not of']
ALL_OPERATORS = [].concat(
  ARITHMETIC_OPERATORS
  BITWISE_OPERATORS
  COMPARISON_OPERATORS
  LOGICAL_OPERATORS
  RELATIONAL_OPERATORS
)
DEFAULT_GROUPS = [
  ARITHMETIC_OPERATORS
  BITWISE_OPERATORS
  COMPARISON_OPERATORS
  LOGICAL_OPERATORS
  RELATIONAL_OPERATORS
]
TARGET_NODE_TYPE = /^(?:Binary|Logical)Expression$/

###*
# Normalizes options.
#
# @param {Object|undefined} options - A options object to normalize.
# @returns {Object} Normalized option object.
###
normalizeOptions = (options) ->
  hasGroups = options?.groups and options.groups.length > 0
  groups = if hasGroups then options.groups else DEFAULT_GROUPS
  allowSamePrecedence = options?.allowSamePrecedence isnt no

  {
    groups
    allowSamePrecedence
  }

###*
# Checks whether any group which includes both given operator exists or not.
#
# @param {Array.<string[]>} groups - A list of groups to check.
# @param {string} left - An operator.
# @param {string} right - Another operator.
# @returns {boolean} `true` if such group existed.
###
includesBothInAGroup = (groups, left, right) ->
  groups.some (group) ->
    group.indexOf(left) isnt -1 and group.indexOf(right) isnt -1

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow mixed binary operators'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-mixed-operators'
    schema: [
      type: 'object'
      properties:
        groups:
          type: 'array'
          items:
            type: 'array'
            items: enum: ALL_OPERATORS
            minItems: 2
            uniqueItems: yes
          uniqueItems: yes
        allowSamePrecedence:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    options = normalizeOptions context.options[0]

    ###*
    # Checks whether a given node should be ignored by options or not.
    #
    # @param {ASTNode} node - A node to check. This is a BinaryExpression
    #      node or a LogicalExpression node. This parent node is one of
    #      them, too.
    # @returns {boolean} `true` if the node should be ignored.
    ###
    shouldIgnore = (node) ->
      a = node
      b = node.parent

      not includesBothInAGroup(options.groups, a.operator, b.operator) or
        (options.allowSamePrecedence and getPrecedence(a) is getPrecedence b)

    ###*
    # Checks whether the operator of a given node is mixed with parent
    # node's operator or not.
    #
    # @param {ASTNode} node - A node to check. This is a BinaryExpression
    #      node or a LogicalExpression node. This parent node is one of
    #      them, too.
    # @returns {boolean} `true` if the node was mixed.
    ###
    isMixedWithParent = (node) ->
      node.operator isnt node.parent.operator and
      not astUtils.isParenthesised sourceCode, node

    ###*
    # Gets the operator token of a given node.
    #
    # @param {ASTNode} node - A node to check. This is a BinaryExpression
    #      node or a LogicalExpression node.
    # @returns {Token} The operator token of the node.
    ###
    getOperatorToken = (node) ->
      sourceCode.getTokenAfter node.left, astUtils.isNotClosingParenToken

    ###*
    # Reports both the operator of a given node and the operator of the
    # parent node.
    #
    # @param {ASTNode} node - A node to check. This is a BinaryExpression
    #      node or a LogicalExpression node. This parent node is one of
    #      them, too.
    # @returns {void}
    ###
    reportBothOperators = (node) ->
      {parent} = node
      left = if parent.left is node then node else parent
      right = unless parent.left is node then node else parent
      message = "Unexpected mix of '{{leftOperator}}' and '{{rightOperator}}'."
      data =
        leftOperator: left.operator
        rightOperator: right.operator

      context.report {
        node: left
        loc: getOperatorToken(left).loc.start
        message
        data
      }
      context.report {
        node: right
        loc: getOperatorToken(right).loc.start
        message
        data
      }

    ###*
    # Checks between the operator of this node and the operator of the
    # parent node.
    #
    # @param {ASTNode} node - A node to check.
    # @returns {void}
    ###
    check = (node) ->
      if (
        TARGET_NODE_TYPE.test(node.parent.type) and
        isMixedWithParent(node) and
        not shouldIgnore node
      )
        reportBothOperators node

    BinaryExpression: check
    LogicalExpression: check
