###*
# @fileoverview Rule to flag use constant conditions
# @author Christian Schulz <http://rndm.de>
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow constant expressions in conditions'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-constant-condition'

    schema: [
      type: 'object'
      properties:
        checkLoops:
          type: 'boolean'
      additionalProperties: no
    ]

    messages:
      unexpected: 'Unexpected constant condition.'

  create: (context) ->
    options = context.options[0] or {}
    checkLoops = options.checkLoops isnt no
    loopSetStack = []

    loopsInCurrentScope = new Set()

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Checks if a branch node of LogicalExpression short circuits the whole condition
    # @param {ASTNode} node The branch of main condition which needs to be checked
    # @param {string} operator The operator of the main LogicalExpression.
    # @returns {boolean} true when condition short circuits whole condition
    ###
    isLogicalIdentity = (node, operator) ->
      switch node.type
        when 'Literal'
          return (
            (operator in ['||', 'or'] and node.value is yes) or
            (operator in ['&&', 'and'] and node.value is no)
          )

        when 'UnaryExpression'
          return operator in ['&&', 'and'] and node.operator is 'void'

        when 'LogicalExpression'
          return (
            isLogicalIdentity(node.left, node.operator) or
            isLogicalIdentity node.right, node.operator
          )

        # no default
      no

    ###*
    # Checks if a node has a constant truthiness value.
    # @param {ASTNode} node The AST node to check.
    # @param {boolean} inBooleanPosition `false` if checking branch of a condition.
    #  `true` in all other cases
    # @returns {Bool} true when node's truthiness is constant
    # @private
    ###
    isConstant = (node, inBooleanPosition) ->
      switch node.type
        when 'Literal', 'ArrowFunctionExpression', 'FunctionExpression', 'ObjectExpression', 'ArrayExpression'
          return yes

        when 'UnaryExpression'
          return yes if node.operator is 'void'

          return (
            (node.operator is 'typeof' and inBooleanPosition) or
            isConstant node.argument, yes
          )

        when 'BinaryExpression'
          return (
            isConstant(node.left, no) and
            isConstant(node.right, no) and
            node.operator isnt 'of'
          )

        when 'LogicalExpression'
          isLeftConstant = isConstant node.left, inBooleanPosition
          isRightConstant = isConstant node.right, inBooleanPosition
          isLeftShortCircuit =
            isLeftConstant and isLogicalIdentity node.left, node.operator
          isRightShortCircuit =
            isRightConstant and isLogicalIdentity node.right, node.operator

          return (
            (isLeftConstant and isRightConstant) or
            isLeftShortCircuit or
            isRightShortCircuit
          )

        when 'AssignmentExpression'
          return (
            node.operator is '=' and isConstant node.right, inBooleanPosition
          )

        when 'SequenceExpression'
          return isConstant(
            node.expressions[node.expressions.length - 1]
            inBooleanPosition
          )

        # no default
      no

    ###*
    # Tracks when the given node contains a constant condition.
    # @param {ASTNode} node The AST node to check.
    # @returns {void}
    # @private
    ###
    trackConstantConditionLoop = (node) ->
      if node.test and isConstant node.test, yes
        loopsInCurrentScope.add node

    ###*
    # Reports when the set contains the given constant condition node
    # @param {ASTNode} node The AST node to check.
    # @returns {void}
    # @private
    ###
    checkConstantConditionLoopInSet = (node) ->
      if loopsInCurrentScope.has node
        loopsInCurrentScope.delete node
        context.report node: node.test, messageId: 'unexpected'

    ###*
    # Reports when the given node contains a constant condition.
    # @param {ASTNode} node The AST node to check.
    # @returns {void}
    # @private
    ###
    reportIfConstant = (node) ->
      if node.test and isConstant node.test, yes
        context.report node: node.test, messageId: 'unexpected'

    ###*
    # Stores current set of constant loops in loopSetStack temporarily
    # and uses a new set to track constant loops
    # @returns {void}
    # @private
    ###
    enterFunction = ->
      loopSetStack.push loopsInCurrentScope
      loopsInCurrentScope ###:### = new Set()

    ###*
    # Reports when the set still contains stored constant conditions
    # @param {ASTNode} node The AST node to check.
    # @returns {void}
    # @private
    ###
    exitFunction = -> loopsInCurrentScope ###:### = loopSetStack.pop()

    ###*
    # Checks node when checkLoops option is enabled
    # @param {ASTNode} node The AST node to check.
    # @returns {void}
    # @private
    ###
    checkLoop = (node) ->
      return if node.type is 'WhileStatement' and node.loop
      return unless checkLoops
      trackConstantConditionLoop node

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    ConditionalExpression: reportIfConstant
    IfStatement: reportIfConstant
    WhileStatement: checkLoop
    'WhileStatement:exit': checkConstantConditionLoopInSet
    DoWhileStatement: checkLoop
    'DoWhileStatement:exit': checkConstantConditionLoopInSet
    ForStatement: checkLoop
    'ForStatement > .test': (node) -> checkLoop node.parent
    'ForStatement:exit': checkConstantConditionLoopInSet
    FunctionDeclaration: enterFunction
    'FunctionDeclaration:exit': exitFunction
    FunctionExpression: enterFunction
    'FunctionExpression:exit': exitFunction
    YieldExpression: -> loopsInCurrentScope.clear()
