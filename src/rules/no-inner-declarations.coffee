###*
# @fileoverview Rule to enforce declarations in program or function body root.
# @author Brandon Mills
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow variable or `function` declarations in nested blocks'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-inner-declarations'

    schema: [enum: ['functions', 'both']]

  create: (context) ->
    ###*
    # Find the nearest Program or Function ancestor node.
    # @returns {Object} Ancestor's type and distance from node.
    ###
    nearestBody = (enclosingExpressionStatement) ->
      ancestor = enclosingExpressionStatement.parent
      generation = 1

      while (
        ancestor?.type not in [
          'Program'
          'FunctionDeclaration'
          'FunctionExpression'
          'ArrowFunctionExpression'
        ]
      )
        generation += 1
        ancestor = ancestor.parent

      # Type of containing ancestor
      type: ancestor.type

      # Separation between ancestor and node
      distance: generation

    getEnclosingExpressionStatement = (assignmentExpression) ->
      ancestor = assignmentExpression.parent
      while ancestor?
        switch ancestor.type
          when 'BlockStatement'
            return
          when 'ExpressionStatement'
            return ancestor
        ancestor = ancestor.parent
      null

    getAssignmentExpression = (node) ->
      prevAncestor = node
      ancestor = node.parent
      while ancestor?
        switch ancestor.type
          when 'AssignmentExpression'
            return (ancestor if prevAncestor is ancestor.left)
          when 'FunctionExpression'
            return
          # when 'AssignmentPattern'
          #   return if prevAncestor is ancestor.right
          when 'Property'
            return if (
              ancestor.parent.type is 'ObjectPattern' and
              prevAncestor is ancestor.key
            )
        prevAncestor = ancestor
        ancestor = ancestor.parent
      null

    ###*
    # Ensure that a given node is at a program or function body's root.
    # @param {ASTNode} node Declaration node to check.
    # @returns {void}
    ###
    check = (node) ->
      return unless node.declaration
      isFunctionDeclaration =
        node.parent.type is 'AssignmentExpression' and
        node.parent.right.type is 'FunctionExpression'
      return unless isFunctionDeclaration or context.options[0] is 'both'
      return unless (assignmentExpression = getAssignmentExpression node)
      if (
        (enclosingExpressionStatement = getEnclosingExpressionStatement(
          assignmentExpression
        ))
      )
        body = nearestBody enclosingExpressionStatement
        valid =
          (body.type is 'Program' and body.distance is 1) or body.distance is 2
        return if valid

        context.report {
          node
          message: 'Move {{type}} declaration to {{body}} root.'
          data:
            type:
              if isFunctionDeclaration
                'function'
              else
                'variable'
            body: if body.type is 'Program' then 'program' else 'function body'
        }

    Identifier: check
