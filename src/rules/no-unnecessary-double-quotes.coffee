###*
# @fileoverview Prevent usage of unnecessary double quotes.
# @author Julian Rosse
###
'use strict'

{isString} = require 'lodash'
{find} = require 'lodash/fp'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

looksLikeDirective = (node) ->
  node.type is 'ExpressionStatement' and
  node.expression.type is 'Literal' and
  typeof node.expression.value is 'string'

takeWhile = (predicate, list) ->
  for item, index in list
    return list.slice 0, index unless predicate item
  list.slice()

getDirectives = (node) ->
  takeWhile looksLikeDirective, node.body

isDirective = (node, ancestors) ->
  return no unless ancestors.length >= 2
  grandparent = ancestors[ancestors.length - 2]
  greatgrandparent = ancestors[ancestors.length - 3]

  grandparent.type is 'Program' or
    (grandparent.type is 'BlockStatement' and
      /Function/.test(greatgrandparent.type) and
      getDirectives(grandparent).indexOf(node.parent) >= 0)

isJsxAttributeValue = (node) ->
  node.parent.type is 'JSXAttribute'

module.exports =
  meta:
    docs:
      description: 'Prevent usage of unnecessary double quotes.'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/object-curly-spacing'

    schema: []
    messages:
      noDoubleQuotes: 'Prefer single quotes.'

  create: (context) ->
    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    Literal: (node) ->
      return unless isString node.value
      return if isJsxAttributeValue node
      return if isDirective node, context.getAncestors()
      return unless /^"/.test node.extra.raw
      return if /'/.test node.value
      context.report {
        node
        messageId: 'noDoubleQuotes'
      }

    TemplateLiteral: (node) ->
      {expressions, quote, quasis} = node
      return if expressions?.length
      return if /^'/.test quote
      return if find(({value}) -> /'/.test value?.raw) quasis
      context.report {
        node
        messageId: 'noDoubleQuotes'
      }
