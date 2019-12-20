###*
# @fileoverview Enforce return after a callback.
# @author Jamund Ferguson
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    type: 'suggestion'

    docs:
      description: 'require `return` statements after callbacks'
      category: 'Node.js and CommonJS'
      recommended: no
      url: 'https://eslint.org/docs/rules/callback-return'

    schema: [
      type: 'array'
      items: type: 'string'
    ]

    messages:
      missingReturn: 'Expected return with your callback function.'

  create: (context) ->
    callbacks = context.options[0] or ['callback', 'cb', 'next']
    sourceCode = context.getSourceCode()

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Find the closest parent matching a list of types.
    # @param {ASTNode} node The node whose parents we are searching
    # @param {Array} types The node types to match
    # @returns {ASTNode} The matched node or undefined.
    ###
    findClosestParentOfType = (node, types) ->
      return null unless node.parent
      return findClosestParentOfType node.parent, types if (
        types.indexOf(node.parent.type) is -1
      )
      node.parent

    ###*
    # Check to see if a node contains only identifers
    # @param {ASTNode} node The node to check
    # @returns {boolean} Whether or not the node contains only identifers
    ###
    containsOnlyIdentifiers = (node) ->
      return yes if node.type is 'Identifier'

      if node.type is 'MemberExpression'
        return yes if node.object.type is 'Identifier'
        return containsOnlyIdentifiers node.object if (
          node.object.type is 'MemberExpression'
        )

      no

    ###*
    # Check to see if a CallExpression is in our callback list.
    # @param {ASTNode} node The node to check against our callback names list.
    # @returns {boolean} Whether or not this function matches our callback name.
    ###
    isCallback = (node) ->
      containsOnlyIdentifiers(node.callee) and
      callbacks.indexOf(sourceCode.getText node.callee) > -1

    ###*
    # Determines whether or not the callback is part of a callback expression.
    # @param {ASTNode} node The callback node
    # @param {ASTNode} parentNode The expression node
    # @returns {boolean} Whether or not this is part of a callback expression
    ###
    isCallbackExpression = (node, parentNode) ->
      # ensure the parent node exists and is an expression
      return no if not parentNode or parentNode.type isnt 'ExpressionStatement'

      # cb()
      return yes if parentNode.expression is node

      # special case for cb && cb() and similar
      if parentNode.expression.type in ['BinaryExpression', 'LogicalExpression']
        return yes if parentNode.expression.right is node

      no

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    CallExpression: (node) ->
      return if node.returns

      # if we're not a callback we can return
      return unless isCallback node

      # find the closest block, return or loop
      closestBlock =
        findClosestParentOfType(
          node
          ['BlockStatement', 'ReturnStatement', 'ArrowFunctionExpression']
        ) or {}

      # if our parent is a return we know we're ok
      return if closestBlock.type is 'ReturnStatement'

      # arrow functions don't always have blocks and implicitly return
      return if closestBlock.type is 'ArrowFunctionExpression'

      # block statements are part of functions and most if statements
      if closestBlock.type is 'BlockStatement'
        # find the last item in the block
        lastItem = closestBlock.body[closestBlock.body.length - 1]

        # if the callback is the last thing in a block that might be ok
        if isCallbackExpression node, lastItem
          parentType = closestBlock.parent.type

          # but only if the block is part of a function
          return if parentType in [
            'FunctionExpression'
            'FunctionDeclaration'
            'ArrowFunctionExpression'
          ]

        # ending a block with a return is also ok
        if lastItem.type is 'ReturnStatement'
          # but only if the callback is immediately before
          return if isCallbackExpression(
            node
            closestBlock.body[closestBlock.body.length - 2]
          )

      # as long as you're the child of a function at this point you should be asked to return
      if findClosestParentOfType node, [
        'FunctionDeclaration'
        'FunctionExpression'
        'ArrowFunctionExpression'
      ]
        context.report {node, messageId: 'missingReturn'}
