###*
# @fileoverview This rule should require or disallow usage of specific boolean keywords.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

TRUE_KEYWORDS = ['true', 'yes', 'on']
FALSE_KEYWORDS = ['false', 'no', 'off']
ALL_KEYWORDS = [...TRUE_KEYWORDS, ...FALSE_KEYWORDS]

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent usage of English operators'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/space-unary-ops'

    schema: [
      oneOf: [
        type: 'object'
        properties:
          allow:
            type: 'array'
            items: [enum: ALL_KEYWORDS]
            minItems: 2
        additionalProperties: no
      ,
        type: 'object'
        properties:
          disallow:
            type: 'array'
            items: [enum: ALL_KEYWORDS]
            minItems: 1
        additionalProperties: no
      ]
    ]

    messages:
      'unexpected-fixable': "Prefer '{{ replacement }}' to '{{ unexpected }}'"
      unexpected: "Don't use '{{ unexpected }}'"

    fixable: 'code'

  create: (context) ->
    # TODO: why isn't oneOf flagging an empty options as a schema error (eg when using plugin:coffee/all)?
    return {} unless context.options[0]?
    {allow, disallow} = context.options[0]

    getReplacement = (trueOrFalse) ->
      allKeywords = if trueOrFalse then TRUE_KEYWORDS else FALSE_KEYWORDS
      allowedKeywords =
        if allow?
          allKeywords.filter((keyword) -> keyword in allow)
        else
          allKeywords.filter((keyword) -> keyword not in disallow)
      return unless allowedKeywords.length is 1
      [replacement] = allowedKeywords
      replacement

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    Literal: (node) ->
      return unless node.value in [true, false]
      {name} = node
      return if allow? and name in allow
      return if disallow? and name not in disallow

      replacement = getReplacement name in TRUE_KEYWORDS

      return context.report {
        node
        messageId: 'unexpected-fixable'
        data: {
          unexpected: name
          replacement
        }
        fix: (fixer) ->
          fixer.replaceText node, replacement
      } if replacement

      context.report {
        node
        messageId: 'unexpected'
        data:
          unexpected: name
      }
