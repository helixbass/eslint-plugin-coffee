###*
# @fileoverview Rule to flag statements that use magic numbers (adapted from https://github.com/danielstjules/buddy.js)
# @author Vincent Lemeunier
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow magic numbers'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-magic-numbers'

    schema: [
      type: 'object'
      properties:
        detectObjects: type: 'boolean'
        ignore:
          type: 'array'
          items: type: 'number'
          uniqueItems: yes
        ignoreArrayIndexes: type: 'boolean'
      additionalProperties: no
    ]
    messages:
      useConst: "Number constants declarations must use 'const'."
      noMagic: 'No magic number: {{raw}}.'

  create: (context) ->
    config = context.options[0] or {}
    detectObjects = !!config.detectObjects
    ignore = config.ignore or []
    ignoreArrayIndexes = !!config.ignoreArrayIndexes

    ###*
    # Returns whether the node is number literal
    # @param {Node} node - the node literal being evaluated
    # @returns {boolean} true if the node is a number literal
    ###
    isNumber = (node) -> typeof node.value is 'number'

    ###*
    # Returns whether the number should be ignored
    # @param {number} num - the number
    # @returns {boolean} true if the number should be ignored
    ###
    shouldIgnoreNumber = (num) -> ignore.indexOf(num) isnt -1

    ###*
    # Returns whether the number should be ignored when used as a radix within parseInt() or Number.parseInt()
    # @param {ASTNode} parent - the non-"UnaryExpression" parent
    # @param {ASTNode} node - the node literal being evaluated
    # @returns {boolean} true if the number should be ignored
    ###
    shouldIgnoreParseInt = (parent, node) ->
      parent.type is 'CallExpression' and
      node is parent.arguments[1] and
      (parent.callee.name is 'parseInt' or
        (parent.callee.type is 'MemberExpression' and
          parent.callee.object.name is 'Number' and
          parent.callee.property.name is 'parseInt'))

    ###*
    # Returns whether the number should be ignored when used to define a JSX prop
    # @param {ASTNode} parent - the non-"UnaryExpression" parent
    # @returns {boolean} true if the number should be ignored
    ###
    shouldIgnoreJSXNumbers = (parent) -> parent.type.indexOf('JSX') is 0

    ###*
    # Returns whether the number should be ignored when used as an array index with enabled 'ignoreArrayIndexes' option.
    # @param {ASTNode} parent - the non-"UnaryExpression" parent.
    # @returns {boolean} true if the number should be ignored
    ###
    shouldIgnoreArrayIndexes = (parent) ->
      parent.type is 'MemberExpression' and ignoreArrayIndexes

    Literal: (node) ->
      okTypes =
        if detectObjects
          []
        else
          ['ObjectExpression', 'Property', 'AssignmentExpression']

      return unless isNumber node

      # For negative magic numbers: update the value and parent node
      if node.parent.type is 'UnaryExpression' and node.parent.operator is '-'
        fullNumberNode = node.parent
        {parent} = fullNumberNode
        value = -node.value
        raw = "-#{node.raw}"
      else
        fullNumberNode = node
        {parent, value, raw} = node

      return if (
        shouldIgnoreNumber(value) or
        shouldIgnoreParseInt(parent, fullNumberNode) or
        shouldIgnoreArrayIndexes(parent) or
        shouldIgnoreJSXNumbers parent
      )

      isAssignment =
        parent.type is 'AssignmentExpression' and
        parent.left.type is 'Identifier'

      return if isAssignment and parent.left.declaration
      if okTypes.indexOf(parent.type) is -1 or isAssignment
        context.report
          node: fullNumberNode
          messageId: 'noMagic'
          data: {raw}
