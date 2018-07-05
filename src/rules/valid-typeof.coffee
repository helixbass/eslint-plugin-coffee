###*
# @fileoverview Ensures that the results of typeof are compared against a valid string
# @author Ian Christian Myers
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce comparing `typeof` expressions against valid strings'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/valid-typeof'

    schema: [
      type: 'object'
      properties: requireStringLiterals: type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    VALID_TYPES = [
      'symbol'
      'undefined'
      'object'
      'boolean'
      'number'
      'string'
      'function'
    ]
    OPERATORS = ['==', 'is', '!=', 'isnt']

    requireStringLiterals = context.options[0]?.requireStringLiterals

    ###*
    # Determines whether a node is a typeof expression.
    # @param {ASTNode} node The node
    # @returns {boolean} `true` if the node is a typeof expression
    ###
    isTypeofExpression = (node) ->
      node.type is 'UnaryExpression' and node.operator is 'typeof'

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    UnaryExpression: (node) ->
      if isTypeofExpression node
        parent = context.getAncestors().pop()

        if (
          parent.type is 'BinaryExpression' and
          OPERATORS.indexOf(parent.operator) isnt -1
        )
          sibling = if parent.left is node then parent.right else parent.left

          if (
            sibling.type is 'Literal' or
            (sibling.type is 'TemplateLiteral' and
              not sibling.expressions.length)
          )
            value =
              if sibling.type is 'Literal'
                sibling.value
              else
                sibling.quasis[0].value.cooked

            if VALID_TYPES.indexOf(value) is -1
              context.report
                node: sibling, message: 'Invalid typeof comparison value.'
          else if requireStringLiterals and not isTypeofExpression sibling
            context.report
              node: sibling
              message: 'Typeof comparisons should be to string literals.'
