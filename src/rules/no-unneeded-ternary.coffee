###*
# @fileoverview Rule to flag no-unneeded-ternary
# @author Gyandeep Singh
###

'use strict'

astUtils = require '../eslint-ast-utils'

# Operators that always result in a boolean value
BOOLEAN_OPERATORS = new Set [
  '=='
  'is'
  '!='
  'isnt'
  '>'
  '>='
  '<'
  '<='
  'in'
  'not in'
  'of'
  'not of'
  'instanceof'
]
OPERATOR_INVERSES =
  '==': '!='
  '!=': '=='
  is: 'isnt'
  isnt: 'is'

  # Operators like < and >= are not true inverses, since both will return false with NaN.

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow ternary operators when simpler alternatives exist'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-unneeded-ternary'

    schema: [
      type: 'object'
      properties:
        defaultAssignment:
          type: 'boolean'
      additionalProperties: no
    ]

    fixable: 'code'

  create: (context) ->
    options = context.options[0] or {}
    defaultAssignment = options.defaultAssignment isnt no
    sourceCode = context.getSourceCode()

    ###*
    # Test if the node is a boolean literal
    # @param {ASTNode} node - The node to report.
    # @returns {boolean} True if the its a boolean literal
    # @private
    ###
    isBooleanLiteral = (node) ->
      node and node.type is 'Literal' and typeof node.value is 'boolean'

    ###*
    # Creates an expression that represents the boolean inverse of the expression represented by the original node
    # @param {ASTNode} node A node representing an expression
    # @returns {string} A string representing an inverted expression
    ###
    invertExpression = (node) ->
      if (
        node.type is 'BinaryExpression' and
        Object.prototype.hasOwnProperty.call OPERATOR_INVERSES, node.operator
      )
        operatorToken = sourceCode.getFirstTokenBetween node.left, node.right, (
          token
        ) -> token.value is node.operator
        text = sourceCode.getText()

        return (
          text.slice(node.range[0], operatorToken.range[0]) +
          OPERATOR_INVERSES[node.operator] +
          text.slice operatorToken.range[1], node.range[1]
        )

      return "!(#{astUtils.getParenthesisedText sourceCode, node})" if (
        astUtils.getPrecedence(node) <
        astUtils.getPrecedence type: 'UnaryExpression'
      )
      if node.type is 'UnaryExpression' and node.operator is 'not'
        return "!!#{astUtils.getParenthesisedText sourceCode, node.argument}"
      "!#{astUtils.getParenthesisedText sourceCode, node}"

    ###*
    # Tests if a given node always evaluates to a boolean value
    # @param {ASTNode} node - An expression node
    # @returns {boolean} True if it is determined that the node will always evaluate to a boolean value
    ###
    isBooleanExpression = (node) ->
      (node.type is 'BinaryExpression' and
        BOOLEAN_OPERATORS.has(node.operator)) or
      (node.type is 'UnaryExpression' and node.operator in ['!', 'not'])

    getLoneExpression = (node) ->
      return node unless (
        node.type is 'BlockStatement' and
        node.body.length is 1 and
        node.body[0].type is 'ExpressionStatement'
      )
      node.body[0].expression

    justIdentifierName = (node) ->
      expression = getLoneExpression node
      return unless expression.type is 'Identifier'
      expression.name

    ###*
    # Test if the node matches the pattern id ? id : expression
    # @param {ASTNode} node - The ConditionalExpression to check.
    # @returns {boolean} True if the pattern is matched, and false otherwise
    # @private
    ###
    matchesDefaultAssignment = (node) ->
      return unless node.alternate
      return unless testIdentifierName = justIdentifierName node.test
      return unless (
        consequentIdentifierName = justIdentifierName node.consequent
      )
      testIdentifierName is consequentIdentifierName

    checkConditional = (node) ->
      if isBooleanLiteral(node.alternate) and isBooleanLiteral node.consequent
        context.report {
          node
          loc: node.consequent.loc.start
          message:
            'Unnecessary use of boolean literals in conditional expression.'
          fix: (fixer) ->
            # Replace `foo ? true : true` with just `true`, but don't replace `foo() ? true : true`
            return (
              if node.test.type is 'Identifier'
                fixer.replaceText node, node.consequent.name
              else
                null
            ) if node.consequent.value is node.alternate.value
            # Replace `foo() ? false : true` with `!(foo())`
            return fixer.replaceText node, invertExpression node.test if (
              (not node.inverted and node.alternate.value) or
              (node.inverted and not node.alternate.value)
            )

            # Replace `foo ? true : false` with `foo` if `foo` is guaranteed to be a boolean, or `!!foo` otherwise.

            fixer.replaceText node,
              if isBooleanExpression node.test
                astUtils.getParenthesisedText sourceCode, node.test
              else
                "!#{invertExpression node.test}"
        }
      else if not defaultAssignment and matchesDefaultAssignment node
        context.report {
          node
          loc: node.consequent.loc.start
          message:
            'Unnecessary use of conditional expression for default assignment.'
          fix: (fixer) ->
            alternate = getLoneExpression node.alternate
            nodeAlternate = astUtils.getParenthesisedText sourceCode, alternate

            if alternate.type in [
              'ConditionalExpression'
              'IfStatement'
              'YieldExpression'
            ]
              isAlternateParenthesised = astUtils.isParenthesised(
                sourceCode
                alternate
              )

              nodeAlternate =
                if isAlternateParenthesised
                  nodeAlternate
                else
                  "(#{nodeAlternate})"

            fixer.replaceText(
              node
              "#{astUtils.getParenthesisedText(
                sourceCode
                node.test
              )} or #{nodeAlternate}"
            )
        }

    ConditionalExpression: checkConditional
    IfStatement: checkConditional
