###*
# @fileoverview Counts the cyclomatic complexity of each function of the script. See http://en.wikipedia.org/wiki/Cyclomatic_complexity.
# Counts the number of if, conditional, for, whilte, try, switch/case,
# @author Patrick Brosset
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

lodash = require 'lodash'

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce a maximum cyclomatic complexity allowed in a program'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/complexity'

    schema: [
      oneOf: [
        type: 'integer'
        minimum: 0
      ,
        type: 'object'
        properties:
          maximum:
            type: 'integer'
            minimum: 0
          max:
            type: 'integer'
            minimum: 0
        additionalProperties: no
      ]
    ]

    messages:
      complex: '{{name}} has a complexity of {{complexity}}.'

  create: (context) ->
    option = context.options[0]
    THRESHOLD = 20

    if (
      typeof option is 'object' and
      Object.prototype.hasOwnProperty.call(option, 'maximum') and
      typeof option.maximum is 'number'
    )
      THRESHOLD = option.maximum
    if (
      typeof option is 'object' and
      Object.prototype.hasOwnProperty.call(option, 'max') and
      typeof option.max is 'number'
    )
      THRESHOLD = option.max
    if typeof option is 'number' then THRESHOLD = option

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    # Using a stack to store complexity (handling nested functions)
    fns = []

    ###*
    # When parsing a new function, store it in our function stack
    # @returns {void}
    # @private
    ###
    startFunction = -> fns.push 1

    ###*
    # Evaluate the node at the end of function
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    endFunction = (node) ->
      name = lodash.upperFirst astUtils.getFunctionNameWithKind node
      complexity = fns.pop()

      if complexity > THRESHOLD
        context.report {
          node
          messageId: 'complex'
          data: {name, complexity}
        }

    ###*
    # Increase the complexity of the function in context
    # @returns {void}
    # @private
    ###
    increaseComplexity = -> if fns.length then fns[fns.length - 1]++

    ###*
    # Increase the switch complexity in context
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    increaseSwitchComplexity = (node) ->
      # Avoiding `default`
      if node.test then increaseComplexity()

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    FunctionDeclaration: startFunction
    FunctionExpression: startFunction
    ArrowFunctionExpression: startFunction
    'FunctionDeclaration:exit': endFunction
    'FunctionExpression:exit': endFunction
    'ArrowFunctionExpression:exit': endFunction

    CatchClause: increaseComplexity
    ConditionalExpression: increaseComplexity
    LogicalExpression: increaseComplexity
    ForStatement: increaseComplexity
    ForInStatement: increaseComplexity
    ForOfStatement: increaseComplexity
    For: increaseComplexity
    IfStatement: increaseComplexity
    SwitchCase: increaseSwitchComplexity
    WhileStatement: increaseComplexity
    DoWhileStatement: increaseComplexity
