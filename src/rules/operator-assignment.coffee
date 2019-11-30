###*
# @fileoverview Rule to replace assignment expressions with operator assignment
# @author Brandon Mills
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'
utils = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether an operator is commutative and has an operator assignment
# shorthand form.
# @param   {string}  operator Operator to check.
# @returns {boolean}          True if the operator is commutative and has a
#     shorthand form.
###
isCommutativeOperatorWithShorthand = (operator) ->
  ['*', '&', '^', '|'].indexOf(operator) >= 0

###*
# Checks whether an operator is not commuatative and has an operator assignment
# shorthand form.
# @param   {string}  operator Operator to check.
# @returns {boolean}          True if the operator is not commuatative and has
#     a shorthand form.
###
isNonCommutativeOperatorWithShorthand = (operator) ->
  [
    '+'
    '-'
    '/'
    '%'
    '<<'
    '>>'
    '>>>'
    '**'
    'and'
    'or'
    '&&'
    '||'
    '?'
  ].indexOf(operator) >= 0

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

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
      ###
      # x[0] = x[0]
      # x[y] = x[y]
      # x.y = x.y
      ###
      return same(a.object, b.object) and same a.property, b.property

    else
      return no

###*
# Determines if the left side of a node can be safely fixed (i.e. if it activates the same getters/setters and)
# toString calls regardless of whether assignment shorthand is used)
# @param {ASTNode} node The node on the left side of the expression
# @returns {boolean} `true` if the node can be fixed
###
canBeFixed = (node) ->
  node.type is 'Identifier' or
  (node.type is 'MemberExpression' and
    node.object.type is 'Identifier' and
    (not node.computed or node.property.type is 'Literal'))

module.exports =
  meta:
    docs:
      description:
        'require or disallow assignment operator shorthand where possible'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/operator-assignment'

    schema: [enum: ['always', 'never']]

    fixable: 'code'

  create: (context) ->
    sourceCode = context.getSourceCode()

    ###*
    # Returns the operator token of an AssignmentExpression or BinaryExpression
    # @param {ASTNode} node An AssignmentExpression or BinaryExpression node
    # @returns {Token} The operator token in the node
    ###
    getOperatorToken = (node) ->
      sourceCode.getFirstTokenBetween node.left, node.right, (token) ->
        token.value is node.operator

    ###*
    # Ensures that an assignment uses the shorthand form where possible.
    # @param   {ASTNode} node An AssignmentExpression node.
    # @returns {void}
    ###
    verify = (node) ->
      return if (
        node.operator isnt '=' or
        node.right.type not in ['BinaryExpression', 'LogicalExpression']
      )

      {left, right: expr} = node
      {operator} = expr

      if (
        isCommutativeOperatorWithShorthand(operator) or
        isNonCommutativeOperatorWithShorthand operator
      )
        if same left, expr.left
          context.report {
            node
            message: 'Assignment can be replaced with operator assignment.'
            fix: (fixer) ->
              if canBeFixed left
                equalsToken = getOperatorToken node
                operatorToken = getOperatorToken expr
                leftText = sourceCode
                .getText()
                .slice node.range[0], equalsToken.range[0]
                rightText = sourceCode
                .getText()
                .slice operatorToken.range[1], node.right.range[1]

                return fixer.replaceText(
                  node
                  "#{leftText}#{expr.operator}=#{rightText}"
                )
              null
          }
        else if (
          same(left, expr.right) and isCommutativeOperatorWithShorthand operator
        )
          ###
          # This case can't be fixed safely.
          # If `a` and `b` both have custom valueOf() behavior, then fixing `a = b * a` to `a *= b` would
          # change the execution order of the valueOf() functions.
          ###
          context.report {
            node
            message: 'Assignment can be replaced with operator assignment.'
          }

    ###*
    # Warns if an assignment expression uses operator assignment shorthand.
    # @param   {ASTNode} node An AssignmentExpression node.
    # @returns {void}
    ###
    prohibit = (node) ->
      unless node.operator is '='
        context.report {
          node
          message: 'Unexpected operator assignment shorthand.'
          fix: (fixer) ->
            if canBeFixed node.left
              operatorToken = getOperatorToken node
              leftText = sourceCode
              .getText()
              .slice node.range[0], operatorToken.range[0]
              newOperator = node.operator.slice 0, -1
              # If this change would modify precedence (e.g. `foo *= bar + 1` => `foo = foo * (bar + 1)`), parenthesize the right side.
              if (
                utils.getPrecedence(node.right) <=
                  utils.getPrecedence(
                    type:
                      switch newOperator
                        when '||', 'or', '&&', 'and', '?'
                          'LogicalExpression'
                        else
                          'BinaryExpression'
                    operator: newOperator
                  ) and not astUtils.isParenthesised sourceCode, node.right
              )
                rightText = "#{sourceCode.text.slice(
                  operatorToken.range[1]
                  node.right.range[0]
                )}(#{sourceCode.getText node.right})"
              else
                rightText = sourceCode.text.slice(
                  operatorToken.range[1]
                  node.range[1]
                )

              return fixer.replaceText(
                node
                "#{leftText}= #{leftText}#{newOperator}#{rightText}"
              )
            null
        }

    AssignmentExpression:
      unless context.options[0] is 'never'
        verify
      else
        prohibit
