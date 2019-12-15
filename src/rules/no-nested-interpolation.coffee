###*
# @fileoverview Disallows nesting string interpolations.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Disallow nesting string interpolations'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/object-curly-spacing'

    schema: []
    messages:
      dontNest: 'Avoid nesting interpolated strings.'

  create: (context) ->
    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    'TemplateLiteral TemplateLiteral': (node) ->
      return unless node.expressions?.length

      context.report {
        node
        messageId: 'dontNest'
      }
