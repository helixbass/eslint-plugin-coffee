###*
# @fileoverview This rule should warn about unnecessary usage of fat arrows.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'warn about unnecessary usage of fat arrows'
      category: 'Best Practices'
      recommended: yes
      # url: 'https://eslint.org/docs/rules/space-unary-ops'

    schema: []

  create: (context) ->
    stack = []

    markUsed = (node) ->
      return unless stack.length
      [..., current] = stack
      current.push node

    enterFunction = (node) ->
      markUsed node if node.bound
      stack.push []

    exitFunction = (node) ->
      uses = stack.pop()
      return unless node.bound
      return if uses.length
      context.report {
        node
        message: "Prefer '->' for functions that don't use 'this'/'@'"
      }

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    FunctionExpression: enterFunction
    'FunctionExpression:exit': exitFunction
    ThisExpression: markUsed
