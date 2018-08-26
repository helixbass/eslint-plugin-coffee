###*
# @fileoverview The rule should warn against code that tries to compare against -0.
# @author Aladdin-ADD <hh_2013@foxmail.com>
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow comparing against -0'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-compare-neg-zero'
    fixable: null
    schema: []
    messages:
      unexpected:
        "Do not use the '{{operator}}' operator to compare against -0."

  create: (context) ->
    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Checks a given node is -0
    #
    # @param {ASTNode} node - A node to check.
    # @returns {boolean} `true` if the node is -0.
    ###
    isNegZero = (node) ->
      node.type is 'UnaryExpression' and
      node.operator is '-' and
      node.argument.type is 'Literal' and
      node.argument.value is 0
    OPERATORS_TO_CHECK = new Set [
      '>'
      '>='
      '<'
      '<='
      '=='
      'is'
      '!='
      'isnt'
    ]

    BinaryExpression: (node) ->
      if OPERATORS_TO_CHECK.has node.operator
        if isNegZero(node.left) or isNegZero node.right
          context.report {
            node
            messageId: 'unexpected'
            data: operator: node.operator
          }
