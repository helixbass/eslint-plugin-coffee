###*
# @fileoverview Rule to enforce that all class methods use 'this'.
# @author Patrick Williams
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce that class methods utilize `this`'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/class-methods-use-this'
    schema: [
      type: 'object'
      properties:
        exceptMethods:
          type: 'array'
          items:
            type: 'string'
      additionalProperties: no
    ]

    messages:
      missingThis: "Expected 'this' to be used by class method '{{name}}'."
  create: (context) ->
    config =
      if context.options[0] then Object.assign {}, context.options[0] else {}
    exceptMethods = new Set config.exceptMethods or []

    stack = []

    ###*
    # Initializes the current context to false and pushes it onto the stack.
    # These booleans represent whether 'this' has been used in the context.
    # @returns {void}
    # @private
    ###
    enterFunction = (node) ->
      return if not isInstanceMethod(node) and node.bound
      stack.push no

    ###*
    # Check if the node is an instance method
    # @param {ASTNode} node - node to check
    # @returns {boolean} True if its an instance method
    # @private
    ###
    isInstanceMethod = (node) ->
      not node.static and
      node.kind isnt 'constructor' and
      node.type is 'MethodDefinition'

    ###*
    # Check if the node is an instance method not excluded by config
    # @param {ASTNode} node - node to check
    # @returns {boolean} True if it is an instance method, and not excluded by config
    # @private
    ###
    isIncludedInstanceMethod = (node) ->
      isInstanceMethod(node) and not exceptMethods.has node.key.name

    ###*
    # Checks if we are leaving a function that is a method, and reports if 'this' has not been used.
    # Static methods and the constructor are exempt.
    # Then pops the context off the stack.
    # @param {ASTNode} node - A function node that was entered.
    # @returns {void}
    # @private
    ###
    exitFunction = (node) ->
      return if not isInstanceMethod(node) and node.bound
      methodUsesThis = stack.pop()

      if isIncludedInstanceMethod(node.parent) and not methodUsesThis
        context.report {
          node
          messageId: 'missingThis'
          data:
            name: node.parent.key.name
        }

    ###*
    # Mark the current context as having used 'this'.
    # @returns {void}
    # @private
    ###
    markThisUsed = -> if stack.length then stack[stack.length - 1] = yes

    FunctionDeclaration: enterFunction
    'FunctionDeclaration:exit': exitFunction
    FunctionExpression: enterFunction
    'FunctionExpression:exit': exitFunction
    ThisExpression: markThisUsed
    Super: markThisUsed
