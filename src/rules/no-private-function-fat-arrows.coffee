###*
# @fileoverview Disallows fat-arrow functions in executable class bodies.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Disallows fat-arrow functions in executable class bodies.'
      category: 'Possible Errors'
      recommended: no
      # url: 'https://eslint.org/docs/rules/object-curly-spacing'

    schema: []
    messages:
      noFatArrow: 'Fat arrows in executable class bodies have no effect.'

  create: (context) ->
    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    'ClassBody > ExpressionStatement > AssignmentExpression > ArrowFunctionExpression': (
      node
    ) ->
      context.report {
        node
        messageId: 'noFatArrow'
      }
