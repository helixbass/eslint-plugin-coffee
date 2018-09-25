###*
# @fileoverview Rule to check for implicit objects
# @author Julian Rosse
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'forbid implicit calls'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/max-len'

    schema: [
      type: 'string'
      enum: ['never']
    ]

  create: (context) ->
    check = (node) ->
      return unless node.implicit
      context.report {
        node
        message: 'Use explicit parentheses around function call arguments'
      }

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    NewExpression: check
    CallExpression: check
