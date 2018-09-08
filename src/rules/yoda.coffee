###*
# @fileoverview Rule to require or disallow yoda comparisons
# @author Nicholas C. Zakas
###
'use strict'

#--------------------------------------------------------------------------
# Requirements
#--------------------------------------------------------------------------

astUtils = require 'eslint/lib/ast-utils'

#--------------------------------------------------------------------------
# Helpers
#--------------------------------------------------------------------------

###*
# Determines whether an operator is a comparison operator.
# @param {string} operator The operator to check.
# @returns {boolean} Whether or not it is a comparison operator.
###
isComparisonOperator = (operator) -> /^(==|is|!=|isnt|<|>|<=|>=)$/.test operator

###*
# Determines whether an operator is an equality operator.
# @param {string} operator The operator to check.
# @returns {boolean} Whether or not it is an equality operator.
###
isEqualityOperator = (operator) -> /^(==|is)$/.test operator

###*
# Determines whether an operator is one used in a range test.
# Allowed operators are `<` and `<=`.
# @param {string} operator The operator to check.
# @returns {boolean} Whether the operator is used in range tests.
###
isRangeTestOperator = (operator) -> ['<', '<='].indexOf(operator) >= 0

###*
# Determines whether a non-Literal node is a negative number that should be
# treated as if it were a single Literal node.
# @param {ASTNode} node Node to test.
# @returns {boolean} True if the node is a negative number that looks like a
#                    real literal and should be treated as such.
###
looksLikeLiteral = (node) ->
  node.type is 'UnaryExpression' and
  node.operator is '-' and
  node.prefix and
  node.argument.type is 'Literal' and
  typeof node.argument.value is 'number'

###*
# Attempts to derive a Literal node from nodes that are treated like literals.
# @param {ASTNode} node Node to normalize.
# @param {number} [defaultValue] The default value to be returned if the node
#                                is not a Literal.
# @returns {ASTNode} One of the following options.
#  1. The original node if the node is already a Literal
#  2. A normalized Literal node with the negative number as the value if the
#     node represents a negative number literal.
#  3. The Literal node which has the `defaultValue` argument if it exists.
#  4. Otherwise `null`.
###
getNormalizedLiteral = (node, defaultValue) ->
  return node if node.type is 'Literal'

  return {
    type: 'Literal'
    value: -node.argument.value
    raw: "-#{node.argument.value}"
  } if looksLikeLiteral node

  return {
    type: 'Literal'
    value: defaultValue
    raw: String defaultValue
  } if defaultValue

  null

###*
# Checks whether two expressions reference the same value. For example:
#     a = a
#     a.b = a.b
#     a[0] = a[0]
#     a['b'] = a['b']
# @param   {ASTNode} a Left side of the comparison.
# @param   {ASTNode} b Right side of the comparison.
# @returns {boolean}   True if both sides match and reference the same value.
###
same = (a, b) ->
  return no unless a.type is b.type

  switch a.type
    when 'Identifier'
      return a.name is b.name
    when 'Literal'
      return a.value is b.value
    when 'MemberExpression'
      nameA = astUtils.getStaticPropertyName a

      # x.y = x["y"]
      return (
        same(a.object, b.object) and nameA is astUtils.getStaticPropertyName b
      ) if nameA

      ###
      # x[0] = x[0]
      # x[y] = x[y]
      # x.y = x.y
      ###
      return (
        a.computed is b.computed and
        same(a.object, b.object) and
        same a.property, b.property
      )
    when 'ThisExpression'
      return yes
    else
      return no

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require or disallow "Yoda" conditions'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/yoda'

    schema: [
      enum: ['always', 'never']
    ,
      type: 'object'
      properties:
        exceptRange: type: 'boolean'
        onlyEquality: type: 'boolean'
      additionalProperties: no
    ]

    # fixable: 'code'

  create: (context) ->
    # Default to "never" (!always) if no option
    always = context.options[0] is 'always'
    exceptRange = context.options[1]?.exceptRange
    onlyEquality = context.options[1]?.onlyEquality

    sourceCode = context.getSourceCode()

    ###*
    # Determines whether node represents a range test.
    # A range test is a "between" test like `(0 <= x && x < 1)` or an "outside"
    # test like `(x < 0 || 1 <= x)`. It must be wrapped in parentheses, and
    # both operators must be `<` or `<=`. Finally, the literal on the left side
    # must be less than or equal to the literal on the right side so that the
    # test makes any sense.
    # @param {ASTNode} node LogicalExpression node to test.
    # @returns {boolean} Whether node is a range test.
    ###
    isRangeTest = (node) ->
      {left, right} = node

      ###*
      # Determines whether node is of the form `0 <= x && x < 1`.
      # @returns {boolean} Whether node is a "between" range test.
      ###
      isBetweenTest = ->
        node.operator in ['&&', 'and'] and
        (leftLiteral = getNormalizedLiteral(left.left)) and
        (rightLiteral = getNormalizedLiteral(
          right.right
          Number.POSITIVE_INFINITY
        )) and
        leftLiteral.value <= rightLiteral.value and
        same left.right, right.left

      ###*
      # Determines whether node is of the form `x < 0 || 1 <= x`.
      # @returns {boolean} Whether node is an "outside" range test.
      ###
      isOutsideTest = ->
        node.operator in ['||', 'or'] and
        (leftLiteral = getNormalizedLiteral(
          left.right
          Number.NEGATIVE_INFINITY
        )) and
        (rightLiteral = getNormalizedLiteral(right.left)) and
        leftLiteral.value <= rightLiteral.value and
        same left.left, right.right

      ###*
      # Determines whether node is wrapped in parentheses.
      # @returns {boolean} Whether node is preceded immediately by an open
      #                    paren token and followed immediately by a close
      #                    paren token.
      ###
      isParenWrapped = -> astUtils.isParenthesised sourceCode, node

      node.type is 'LogicalExpression' and
        left.type is 'BinaryExpression' and
        right.type is 'BinaryExpression' and
        isRangeTestOperator(left.operator) and
        isRangeTestOperator(right.operator) and
        (isBetweenTest() or isOutsideTest()) and
        isParenWrapped()

    OPERATOR_FLIP_MAP =
      is: 'is'
      isnt: 'isnt'
      '==': '=='
      '!=': '!='
      '<': '>'
      '>': '<'
      '<=': '>='
      '>=': '<='

    ###*
    # Returns a string representation of a BinaryExpression node with its sides/operator flipped around.
    # @param {ASTNode} node The BinaryExpression node
    # @returns {string} A string representation of the node with the sides and operator flipped
    ###
    # eslint-disable-next-line coffee/no-unused-vars
    getFlippedString = (node) ->
      operatorToken = sourceCode.getFirstTokenBetween node.left, node.right, (
        token
      ) -> token.value is node.operator
      textBeforeOperator = sourceCode
        .getText()
        .slice(
          sourceCode.getTokenBefore(operatorToken).range[1]
          operatorToken.range[0]
        )
      textAfterOperator = sourceCode
        .getText()
        .slice(
          operatorToken.range[1]
          sourceCode.getTokenAfter(operatorToken).range[0]
        )
      leftText = sourceCode
        .getText()
        .slice node.range[0], sourceCode.getTokenBefore(operatorToken).range[1]
      rightText = sourceCode
        .getText()
        .slice sourceCode.getTokenAfter(operatorToken).range[0], node.range[1]

      rightText +
        textBeforeOperator +
        OPERATOR_FLIP_MAP[operatorToken.value] +
        textAfterOperator +
        leftText

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    BinaryExpression: (node) ->
      expectedLiteral = if always then node.left else node.right
      expectedNonLiteral = if always then node.right else node.left

      # If `expectedLiteral` is not a literal, and `expectedNonLiteral` is a literal, raise an error.
      if (
        (expectedNonLiteral.type is 'Literal' or
          looksLikeLiteral(expectedNonLiteral)) and
        not (
          expectedLiteral.type is 'Literal' or looksLikeLiteral(expectedLiteral)
        ) and
        not (not isEqualityOperator(node.operator) and onlyEquality) and
        isComparisonOperator(node.operator) and
        not (exceptRange and isRangeTest context.getAncestors().pop())
      )
        context.report {
          node
          message:
            'Expected literal to be on the {{expectedSide}} side of {{operator}}.'
          data:
            operator: node.operator
            expectedSide: if always then 'left' else 'right'
            # fix: (fixer) -> fixer.replaceText node, getFlippedString node
        }
