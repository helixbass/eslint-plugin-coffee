###*
# @fileoverview Rule that warns when identifier names are shorter or longer
# than the values provided in configuration.
# @author Burak Yigit Kaya aka BYK
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce minimum and maximum identifier lengths'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/id-length'

    schema: [
      type: 'object'
      properties:
        min:
          type: 'number'
        max:
          type: 'number'
        exceptions:
          type: 'array'
          uniqueItems: yes
          items:
            type: 'string'
        properties:
          enum: ['always', 'never']
      additionalProperties: no
    ]

  create: (context) ->
    options = context.options[0] or {}
    minLength = options.min ? 2
    maxLength = options.max ? Infinity
    properties = options.properties isnt 'never'
    exceptions = (if options.exceptions then options.exceptions else []).reduce(
      (obj, item) ->
        obj[item] = yes

        obj
      {}
    )

    isSupportedExpression = (node, parent) ->
      prevNode = node
      currentNode = parent
      while currentNode?
        switch currentNode.type
          when 'MemberExpression'
            return no unless prevNode is currentNode.property
            return no unless properties
            return no if currentNode.computed
            assigningToMemberExpression = yes
          when 'AssignmentPattern'
            return no unless prevNode is currentNode.left
          when 'ObjectPattern', 'ArrayPattern'
            ;
          when 'ObjectExpression'
            return currentNode.parent.type is 'AssignmentExpression'
          # when 'VariableDeclarator'
          #   (parent, node) -> parent.id is node
          when 'AssignmentExpression'
            return no unless prevNode is currentNode.left
            return yes if assigningToMemberExpression
            return yes if node.declaration
            return no
          when 'Property'
            if currentNode.parent.type is 'ObjectExpression'
              return no unless properties
            return no unless (
              prevNode is
              currentNode[
                if currentNode.parent.type is 'ObjectPattern'
                  'value'
                else
                  'key'
              ]
            )
          when 'ClassDeclaration', 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression'
            return prevNode is currentNode.id or prevNode in currentNode.params
          when 'MethodDefinition'
            return prevNode is currentNode.key and not currentNode.computed
          when 'CatchClause'
            return prevNode is currentNode.param
          when 'ImportDefaultSpecifier', 'RestElement'
            return yes
          else
            return yes if node.declaration
            return no

        prevNode = currentNode
        currentNode = currentNode.parent

    Identifier: (node) ->
      {name, parent} = node

      isShort = name.length < minLength
      isLong = name.length > maxLength

      return if not (isShort or isLong) or exceptions[name] # Nothing to report

      isValidExpression = isSupportedExpression node, parent

      context.report {
        node
        message:
          if isShort
            "Identifier name '{{name}}' is too short (< {{min}})."
          else
            "Identifier name '{{name}}' is too long (> {{max}})."
        data: {name, min: minLength, max: maxLength}
      } if isValidExpression
