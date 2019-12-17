###*
# @fileoverview This rule enforces consistent usage of prefix or postfix `...`
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: "use postfix or prefix spread dots '...'"
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/space-unary-ops'

    schema: [enum: ['postfix', 'prefix']]

  create: (context) ->
    usePostfix = context.options?[0] is 'postfix'

    check = (node) ->
      return unless node.argument
      if node.postfix and not usePostfix
        context.report {
          node
          message: "Use the prefix form of '...'"
        }
      else if not node.postfix and usePostfix
        context.report {
          node
          message: "Use the postfix form of '...'"
        }

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    SpreadElement: check
    RestElement: check
    ExperimentalSpreadProperty: check
    ExperimentalRestProperty: check
    JSXSpreadAttribute: check
