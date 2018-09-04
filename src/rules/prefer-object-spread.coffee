###*
# @fileoverview Prefers object spread property over Object.assign
# @author Sharmila Jesupaul
# See LICENSE file in root directory for full license.
###

'use strict'

{CALL, ReferenceTracker} = require 'eslint-utils'

###*
# Helper that checks if the Object.assign call has array spread
# @param {ASTNode} node - The node that the rule warns on
# @returns {boolean} - Returns true if the Object.assign call has array spread
###
hasArraySpread = (node) ->
  node.arguments.some (arg) -> arg.type is 'SpreadElement'

module.exports =
  meta:
    docs:
      description:
        'disallow using Object.assign with an object literal as the first argument and prefer the use of object spread instead.'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/prefer-object-spread'
    schema: []
    messages:
      useSpreadMessage:
        'Use an object spread instead of `Object.assign` eg: `{ ...foo }`'
      useLiteralMessage:
        'Use an object literal instead of `Object.assign`. eg: `{ foo: bar }`'

  create: (context) ->
    Program: ->
      scope = context.getScope()
      tracker = new ReferenceTracker scope
      trackMap =
        Object:
          assign: [CALL]: yes

      # Iterate all calls of `Object.assign` (only of the global variable `Object`).
      for {node} from tracker.iterateGlobalReferences trackMap
        if (
          node.arguments.length >= 1 and
          node.arguments[0].type is 'ObjectExpression' and
          not hasArraySpread node
        )
          messageId =
            if node.arguments.length is 1
              'useLiteralMessage'
            else
              'useSpreadMessage'

          context.report {node, messageId}
