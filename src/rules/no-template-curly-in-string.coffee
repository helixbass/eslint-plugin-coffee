###*
# @fileoverview Warn when using template string syntax in regular strings
# @author Jeroen Engels
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow template literal placeholder syntax in regular strings'
      category: 'Possible Errors'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-template-curly-in-string'

    schema: []

  create: (context) ->
    regex = /#\{[^}]+\}/

    Literal: (node) ->
      if typeof node.value is 'string' and regex.test node.value
        context.report {
          node
          message: 'Unexpected template string expression.'
        }
