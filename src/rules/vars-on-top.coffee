###*
# @fileoverview Rule to enforce var declarations are only at the top of a function.
# @author Danny Fritz
# @author Gyandeep Singh
###
'use strict'

boundaryNodeRegex = /Function/
#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'require `var` declarations be placed at the top of their containing scope'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/vars-on-top'

    schema: []

  create: (context) ->
    errorMessage = 'All declarations must be at the top of the function scope.'

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # @param {ASTNode} node - any node
    # @returns {boolean} whether the given node structurally represents a directive
    ###
    looksLikeDirective = (node) ->
      node.type is 'ExpressionStatement' and
      node.expression.type is 'Literal' and
      typeof node.expression.value is 'string'

    ###*
    # Check to see if its a ES6 import declaration
    # @param {ASTNode} node - any node
    # @returns {boolean} whether the given node represents a import declaration
    ###
    looksLikeImport = (node) ->
      node.type in [
        'ImportDeclaration'
        'ImportSpecifier'
        'ImportDefaultSpecifier'
        'ImportNamespaceSpecifier'
      ]

    containsDeclaration = (node) ->
      switch node.type
        when 'Identifier'
          node.declaration
        when 'ObjectPattern'
          for prop in node.properties
            return yes if containsDeclaration prop
          no
        when 'Property'
          containsDeclaration node.value
        when 'RestElement'
          containsDeclaration node.argument
        when 'ArrayPattern'
          for element in node.elements
            return yes if containsDeclaration element
          no
        when 'AssignmentPattern'
          containsDeclaration node.left

    isDeclarationAssignment = (node) ->
      return no unless node?.type is 'AssignmentExpression'
      containsDeclaration node.left

    ###*
    # Checks whether a given node is a variable declaration or not.
    #
    # @param {ASTNode} node - any node
    # @returns {boolean} `true` if the node is a variable declaration.
    ###
    isVariableDeclaration = (node) ->
      (node.type is 'ExpressionStatement' and
        isDeclarationAssignment(node.expression)) or
      (node.type is 'ExportNamedDeclaration' and
        isDeclarationAssignment node.declaration)

    ###*
    # Checks whether this variable is on top of the block body
    # @param {ASTNode} node - The node to check
    # @param {ASTNode[]} statements - collection of ASTNodes for the parent node block
    # @returns {boolean} True if var is on top otherwise false
    ###
    isVarOnTop = (node, statements) ->
      l = statements.length
      i = 0

      # skip over directives
      while i < l
        if (
          not looksLikeDirective(statements[i]) and
          not looksLikeImport statements[i]
        )
          break
        ++i

      while i < l
        return no unless isVariableDeclaration statements[i]
        return yes if statements[i] is node
        ++i

      no

    ###*
    # Checks whether variable is on top at the global level
    # @param {ASTNode} node - The node to check
    # @param {ASTNode} parent - Parent of the node
    # @returns {void}
    ###
    globalVarCheck = (node, assignment, parent) ->
      unless isVarOnTop assignment, parent.body
        context.report {node, message: errorMessage}

    ###*
    # Checks whether variable is on top at functional block scope level
    # @param {ASTNode} node - The node to check
    # @param {ASTNode} parent - Parent of the node
    # @param {ASTNode} grandParent - Parent of the node's parent
    # @returns {void}
    ###
    blockScopeVarCheck = (node, assignment, parent, grandParent) ->
      unless (
        assignment? and
        /Function/.test(grandParent.type) and
        parent.type is 'BlockStatement' and
        isVarOnTop assignment, parent.body
      )
        context.report {node, message: errorMessage}

    findEnclosingAssignment = (node) ->
      currentNode = node
      prevNode = null
      while currentNode
        return if boundaryNodeRegex.test node.type
        return if (
          currentNode.type is 'Property' and
          prevNode is currentNode.key and
          prevNode isnt currentNode.value
        )
        if currentNode.type is 'AssignmentExpression'
          if prevNode is currentNode.left
            return currentNode
          return

        prevNode = currentNode
        currentNode = currentNode.parent

    findEnclosingExpressionStatement = (assignmentNode) ->
      currentNode = assignmentNode
      currentNode = currentNode.parent while (
        currentNode.type is 'AssignmentExpression'
      )
      return currentNode if currentNode.type is 'ExpressionStatement'

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    'Identifier[declaration=true]': (node) ->
      enclosingAssignment = findEnclosingAssignment node
      return unless enclosingAssignment
      enclosingExpressionStatement = findEnclosingExpressionStatement(
        enclosingAssignment
      )

      if enclosingAssignment.parent.type is 'ExportNamedDeclaration'
        globalVarCheck(
          node
          enclosingAssignment.parent
          enclosingAssignment.parent.parent
        )
      else if enclosingExpressionStatement?.parent.type is 'Program'
        globalVarCheck(
          node
          enclosingExpressionStatement
          enclosingExpressionStatement.parent
        )
      else
        blockScopeVarCheck(
          node
          enclosingExpressionStatement
          enclosingExpressionStatement?.parent
          enclosingExpressionStatement?.parent.parent
        )
