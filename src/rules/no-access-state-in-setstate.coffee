###*
# @fileoverview Prevent usage of this.state within setState
# @author Rolf Erik Lekang, Jørgen Aaberg
###

'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
{isDeclarationAssignment} = require '../util/ast-utils'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Reports when this.state is accessed within setState'
      category: 'Possible Errors'
      recommended: no
      url: docsUrl 'no-access-state-in-setstate'

  create: (context) ->
    isSetStateCall = (node) ->
      node.type is 'CallExpression' and
      node.callee.property and
      node.callee.property.name is 'setState' and
      node.callee.object.type is 'ThisExpression'

    isFirstArgumentInSetStateCall = (current, node) ->
      return no unless isSetStateCall current
      while node and node.parent isnt current then node = node.parent
      current.arguments[0] is node

    # The methods array contains all methods or functions that are using this.state
    # or that are calling another method or function using this.state
    methods = []
    # The vars array contains all variables that contains this.state
    vars = []
    CallExpression: (node) ->
      # Appends all the methods that are calling another
      # method containing this.state to the methods array
      methods.map (method) ->
        if node.callee.name is method.methodName
          current = node.parent
          while current.type isnt 'Program'
            if current.type is 'MethodDefinition'
              methods.push
                methodName: current.key.name
                node: method.node
              break
            current = current.parent

      # Finding all CallExpressions that is inside a setState
      # to further check if they contains this.state
      current = node.parent
      while current.type isnt 'Program'
        if isFirstArgumentInSetStateCall current, node
          methodName = node.callee.name
          for method in methods
            if method.methodName is methodName
              context.report(
                method.node
                'Use callback in setState when referencing the previous state.'
              )

          break
        current = current.parent

    MemberExpression: (node) ->
      if node.property.name is 'state' and node.object.type is 'ThisExpression'
        current = node
        prev = null
        while current.type isnt 'Program'
          # Reporting if this.state is directly within this.setState
          if isFirstArgumentInSetStateCall current, node
            context.report(
              node
              'Use callback in setState when referencing the previous state.'
            )
            break

          # Storing all functions and methods that contains this.state
          if current.type is 'MethodDefinition'
            methods.push {
              methodName: current.key.name
              node
            }
            break
          else if current.type is 'FunctionExpression' and current.parent.key
            methods.push {
              methodName: current.parent.key.name
              node
            }
            break

          # Storing all variables containg this.state
          if current.type is 'VariableDeclarator'
            vars.push {
              node
              scope: context.getScope()
              variableName: current.id.name
            }
            break

          if (
            isDeclarationAssignment(current) and
            current.left.type is 'Identifier' and
            current.right is prev
          )
            vars.push {
              node
              scope: context.getScope()
              variableName: current.left.name
            }
            break

          prev = current
          current = current.parent

    Identifier: (node) ->
      # Checks if the identifier is a variable within an object
      current = node

      while current.parent.type is 'BinaryExpression'
        current = current.parent

      if current.parent.value is current or current.parent.object is current
        while current.type isnt 'Program'
          if isFirstArgumentInSetStateCall current, node
            vars
            .filter (v) ->
              v.scope is context.getScope() and v.variableName is node.name
            .map (v) ->
              context.report(
                v.node
                'Use callback in setState when referencing the previous state.'
              )
          current = current.parent

    ObjectPattern: (node) ->
      isDerivedFromThis =
        (node.parent.init and node.parent.init.type is 'ThisExpression') or
        (isDeclarationAssignment(node.parent) and
          node.parent.right.type is 'ThisExpression')
      node.properties.forEach (property) ->
        if property?.key and property.key.name is 'state' and isDerivedFromThis
          vars.push
            node: property.key
            scope: context.getScope()
            variableName: property.key.name
