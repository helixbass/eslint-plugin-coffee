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
      description: 'forbid implicit objects'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/max-len'

    schema: [
      type: 'string'
      enum: ['never']
    ,
      type: 'object'
      properties:
        allowOwnLine:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    {allowOwnLine} = context.options[1] ? {}

    sourceCode = context.getSourceCode()

    startsLine = (node) ->
      prevToken = sourceCode.getTokenBefore node
      return yes unless prevToken
      node.loc.start.line isnt prevToken.loc.start.line

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    ObjectExpression: (node) ->
      return unless node.implicit
      return if node.parent?.parent?.type is 'ClassBody'
      return if allowOwnLine and startsLine node
      context.report {
        node
        message: 'Use explicit curly braces around objects'
      }
