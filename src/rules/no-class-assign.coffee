###*
# @fileoverview A rule to disallow modifying variables of class declarations
# @author Toru Nagashima
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow reassigning class members'
      category: 'ECMAScript 6'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-class-assign'

    schema: []

    messages:
      class: "'{{name}}' is a class."

  create: (context) ->
    report = (node) ->
      context.report {
        node
        messageId: 'class'
        data: name: node.name
      }

    ###*
    # Finds and reports references that are non initializer and writable.
    # @param {Variable} variable - A variable to check.
    # @returns {void}
    ###
    checkVariable = (variable) ->
      astUtils
      .getModifyingReferences variable.references
      .forEach (reference) ->
        report reference.identifier

    ###*
    # Finds and reports references that are non initializer and writable.
    # @param {ASTNode} node - A ClassDeclaration/ClassExpression node to check.
    # @returns {void}
    ###
    checkForClass = (node) ->
      context.getDeclaredVariables(node).forEach checkVariable
      if (
        node.id?.type is 'Identifier' and
        not node.id?.declaration and
        not (
          node.parent.type is 'AssignmentExpression' and
          node.parent.left.type is 'Identifier' and
          node.parent.left.name is node.id.name
        )
      )
        clashingDefinition =
          context.getScope().upper.set.get(node.id.name)?.defs?[0]?.node
        report clashingDefinition if clashingDefinition?

    ClassDeclaration: checkForClass
    ClassExpression: checkForClass
