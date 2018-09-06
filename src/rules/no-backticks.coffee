###*
# @fileoverview A rule to flag uses of backticks (embedded JS).
# @author Julian Rosse
###
'use strict'

module.exports =
  meta:
    docs:
      description: 'disallow backticks'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/max-lines-per-function'

    schema: []

  create: (context) ->
    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    PassthroughLiteral: (node) ->
      context.report {
        node
        message: "Don't use backticks"
      }
