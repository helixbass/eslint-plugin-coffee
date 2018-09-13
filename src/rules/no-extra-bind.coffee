###*
# @fileoverview Rule to flag unnecessary bind calls
# @author Bence Dányi <bence@danyi.me>
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow unnecessary calls to `.bind()`'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-extra-bind'

    schema: []

    fixable: 'code'

    messages:
      unexpected: 'The function binding is unnecessary.'

  create: (context) ->
    scopeInfo = null

    ###*
    # Reports a given function node.
    #
    # @param {ASTNode} node - A node to report. This is a FunctionExpression or
    #      an ArrowFunctionExpression.
    # @returns {void}
    ###
    report = (node) ->
      context.report
        node: node.parent.parent
        messageId: 'unexpected'
        loc: node.parent.property.loc.start
        fix: (fixer) ->
          firstTokenToRemove = context
          .getSourceCode()
          .getFirstTokenBetween(
            node.parent.object
            node.parent.property
            astUtils.isNotClosingParenToken
          )

          fixer.removeRange [
            firstTokenToRemove.range[0]
            node.parent.parent.range[1]
          ]

    ###*
    # Checks whether or not a given function node is the callee of `.bind()`
    # method.
    #
    # e.g. `(function() {}.bind(foo))`
    #
    # @param {ASTNode} node - A node to report. This is a FunctionExpression or
    #      an ArrowFunctionExpression.
    # @returns {boolean} `true` if the node is the callee of `.bind()` method.
    ###
    isCalleeOfBindMethod = (node) ->
      {parent} = node
      grandparent = parent.parent

      grandparent and
        grandparent.type is 'CallExpression' and
        grandparent.callee is parent and
        grandparent.arguments.length is 1 and
        parent.type is 'MemberExpression' and
        parent.object is node and
        astUtils.getStaticPropertyName(parent) is 'bind'

    ###*
    # Adds a scope information object to the stack.
    #
    # @param {ASTNode} node - A node to add. This node is a FunctionExpression
    #      or a FunctionDeclaration node.
    # @returns {void}
    ###
    enterFunction = (node) ->
      scopeInfo =
        isBound: isCalleeOfBindMethod node
        thisFound: no
        upper: scopeInfo

    ###*
    # Reports a given arrow function if the function is callee of `.bind()`
    # method.
    #
    # @param {ASTNode} node - A node to report. This node is an
    #      ArrowFunctionExpression.
    # @returns {void}
    ###
    exitArrowFunction = (node) -> if isCalleeOfBindMethod node then report node

    ###*
    # Removes the scope information object from the top of the stack.
    # At the same time, this reports the function node if the function has
    # `.bind()` and the `this` keywords found.
    #
    # @param {ASTNode} node - A node to remove. This node is a
    #      FunctionExpression or a FunctionDeclaration node.
    # @returns {void}
    ###
    exitFunction = (node) ->
      return exitArrowFunction node if node.bound
      if scopeInfo.isBound and not scopeInfo.thisFound then report node

      scopeInfo ###:### = scopeInfo.upper

    ###*
    # Set the mark as the `this` keyword was found in this scope.
    #
    # @returns {void}
    ###
    markAsThisFound = -> if scopeInfo then scopeInfo.thisFound = yes

    'ArrowFunctionExpression:exit': exitArrowFunction
    FunctionDeclaration: enterFunction
    'FunctionDeclaration:exit': exitFunction
    FunctionExpression: enterFunction
    'FunctionExpression:exit': exitFunction
    ThisExpression: markAsThisFound
