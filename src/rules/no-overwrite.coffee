###*
# @fileoverview Rule to flag reassigning variables.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require 'eslint/lib/ast-utils'
{isNullOrUndefined} = astUtils

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow reassignment of variables'
      category: 'Variables'
      recommended: no
      # url: 'https://eslint.org/docs/rules/no-shadow'

    schema: [
      type: 'object'
      properties:
        nullInitializers: type: 'boolean'
        sameScope: type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    nullInitializers = context.options[0]?.nullInitializers ? yes
    sameScope = context.options[0]?.sameScope ? yes
    sourceCode = context.getSourceCode()

    getDeclaration = (node) ->
      {name} = node
      scope = context.getScope()
      upper = scope
      {upper} = upper if node.parent.type is 'ClassDeclaration'
      while upper
        found = upper.set.get name
        if found
          return
            identifier: found.identifiers[0]
            scope: upper
            variable: found
        {upper} = upper

    isBeingAssignedTo = (node) ->
      prevNode = node
      currentNode = node.parent
      while currentNode
        switch currentNode.type
          when 'AssignmentExpression'
            return no unless currentNode.operator is '='
            if prevNode is currentNode.left
              return currentNode
            else
              return no
          when 'AssignmentPattern'
            return no unless prevNode is currentNode.left
          when 'ArrayPattern', 'ObjectPattern'
            ; # continue
          when 'Property'
            return no unless prevNode is currentNode.value
          when 'ClassDeclaration'
            return prevNode is currentNode.id
          when 'For'
            return prevNode in [currentNode.name, currentNode.index]
          else
            return no

        prevNode = currentNode
        currentNode = currentNode.parent

    hasPrecedingNonInitialAssignment = (node, variable) ->
      def = variable.defs?[0]
      return unless def?
      variable.references.some (reference) ->
        reference.writeExpr and
        reference.identifier isnt node and
        reference.identifier isnt def.node and
        reference.identifier.range[0] < node.range[0]

    isNullInitializer = (node) ->
      return no unless node?.type is 'Identifier'
      # TODO: more complex null initializers via destructuring assignment?
      # return no unless assignmentExpression = isBeingAssignedTo node
      return no unless node.parent.type is 'AssignmentExpression'
      isNullOrUndefined node.parent.right

    allowingCommentRegex = /^\s*:=?\s*$/

    identifierHasAllowingComment = (node) ->
      return unless node?.type is 'Identifier'
      return yes if sourceCode
        .getCommentsBefore node
        .some (comment) -> allowingCommentRegex.test comment.value
      return yes if sourceCode
        .getCommentsAfter node
        .some (comment) -> allowingCommentRegex.test comment.value
      no

    assignmentHasAllowingComment = (node) ->
      return unless node?.type is 'AssignmentExpression'
      equalsSign = sourceCode.getTokenAfter node.left
      return unless equalsSign?.value is '='
      sourceCode
        .getCommentsBefore equalsSign
        .some (comment) -> allowingCommentRegex.test comment.value

    checkIdentifier = (node) ->
      return if node.declaration
      return if identifierHasAllowingComment node
      return unless (assignmentExpression = isBeingAssignedTo node)
      return if assignmentHasAllowingComment assignmentExpression
      declaration = getDeclaration node
      return unless declaration?
      {scope, identifier, variable} = declaration
      if scope.variableScope is context.getScope().variableScope
        return if sameScope
      if (
        isNullInitializer(identifier) and
        not hasPrecedingNonInitialAssignment node, variable
      )
        return if nullInitializers
      context.report {
        node
        message: "Overwriting variable '#{node.name}' disallowed."
      }

    Identifier: checkIdentifier
