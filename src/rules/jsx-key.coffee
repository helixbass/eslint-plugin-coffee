###*
# @fileoverview Report missing `key` props in iterators/collection literals.
# @author Ben Mosher
###
'use strict'

hasProp = require 'jsx-ast-utils/hasProp'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Report missing `key` props in iterators/collection literals'
      category: 'Possible Errors'
      recommended: yes
      url: docsUrl 'jsx-key'
    schema: []

  create: (context) ->
    checkIteratorElement = (node) ->
      if (
        node.type is 'JSXElement' and
        not hasProp node.openingElement.attributes, 'key'
      )
        context.report {
          node
          message: 'Missing "key" prop for element in iterator'
        }

    getReturnExpression = (body) ->
      for item in body
        return item.argument if item.type is 'ReturnStatement'
        return item.expression if item.expression?.returns
      null

    JSXElement: (node) ->
      return if hasProp node.openingElement.attributes, 'key'

      if node.parent.type is 'ArrayExpression'
        context.report {
          node
          message: 'Missing "key" prop for element in array'
        }

    # Array.prototype.map
    CallExpression: (node) ->
      return if node.callee and node.callee.type isnt 'MemberExpression'

      return if node.callee?.property and node.callee.property.name isnt 'map'

      fn = node.arguments[0]
      isFn = fn and fn.type is 'FunctionExpression'
      isArrFn = fn and fn.type is 'ArrowFunctionExpression'

      if isArrFn and fn.body.type is 'JSXElement'
        checkIteratorElement fn.body

      if isFn or isArrFn
        if fn.body.type is 'BlockStatement'
          returnExpression = getReturnExpression fn.body.body
          checkIteratorElement returnExpression if returnExpression
