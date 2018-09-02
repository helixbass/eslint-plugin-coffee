###*
# @fileoverview Prefer destructuring from arrays and objects
# @author Alex LaFroscia
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require destructuring from arrays and/or objects'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/prefer-destructuring'
    schema: [
      ###
      # old support {array: Boolean, object: Boolean}
      # new support {VariableDeclarator: {}, AssignmentExpression: {}}
      ###
      type: 'object'
      properties:
        array:
          type: 'boolean'
        object:
          type: 'boolean'
      additionalProperties: no
    ,
      type: 'object'
      properties:
        enforceForRenamedProperties:
          type: 'boolean'
      additionalProperties: no
    ]
  create: (context) ->
    enabledTypes = context.options[0] ? array: yes, object: yes
    enforceForRenamedProperties =
      context.options[1]?.enforceForRenamedProperties

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # @param {string} nodeType "AssignmentExpression" or "VariableDeclarator"
    # @param {string} destructuringType "array" or "object"
    # @returns {boolean} `true` if the destructuring type should be checked for the given node
    ###
    shouldCheck = (destructuringType) ->
      enabledTypes[destructuringType]

    ###*
    # Determines if the given node is accessing an array index
    #
    # This is used to differentiate array index access from object property
    # access.
    #
    # @param {ASTNode} node the node to evaluate
    # @returns {boolean} whether or not the node is an integer
    ###
    isArrayIndexAccess = (node) -> Number.isInteger node.property.value

    ###*
    # Report that the given node should use destructuring
    #
    # @param {ASTNode} reportNode the node to report
    # @param {string} type the type of destructuring that should have been done
    # @returns {void}
    ###
    report = (reportNode, type) ->
      context.report
        node: reportNode, message: 'Use {{type}} destructuring.', data: {type}

    ###*
    # Check that the `prefer-destructuring` rules are followed based on the
    # given left- and right-hand side of the assignment.
    #
    # Pulled out into a separate method so that VariableDeclarators and
    # AssignmentExpressions can share the same verification logic.
    #
    # @param {ASTNode} leftNode the left-hand side of the assignment
    # @param {ASTNode} rightNode the right-hand side of the assignment
    # @param {ASTNode} reportNode the node to report the error on
    # @returns {void}
    ###
    performCheck = (leftNode, rightNode, reportNode) ->
      return if (
        rightNode.type isnt 'MemberExpression' or
        rightNode.object.type is 'Super' or
        rightNode.optional
      )

      if isArrayIndexAccess rightNode
        if shouldCheck 'array' then report reportNode, 'array'
        return

      return unless shouldCheck 'object'

      if enforceForRenamedProperties
        report reportNode, 'object'
        return

      {property} = rightNode

      if (
        (property.type is 'Literal' and leftNode.name is property.value) or
        (property.type is 'Identifier' and
          leftNode.name is property.name and
          not rightNode.computed)
      )
        report reportNode, 'object'

    ###*
    # Run the `prefer-destructuring` check on an AssignmentExpression
    #
    # @param {ASTNode} node the AssignmentExpression node
    # @returns {void}
    ###
    checkAssigmentExpression = (node) ->
      if node.operator is '=' then performCheck node.left, node.right, node

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    AssignmentExpression: checkAssigmentExpression
