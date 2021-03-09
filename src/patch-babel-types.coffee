require 'babel-types'

{
  default: defineType
  assertNodeType
  assertValueType
  chain
  assertEach
  VISITOR_KEYS
} = require 'babel-types/lib/definitions'

module.exports = ->
  return if VISITOR_KEYS.JSXFragment

  defineType 'JSXFragment',
    builder: ['openingFragment', 'closingFragment', 'children']
    visitor: ['openingFragment', 'children', 'closingFragment']
    aliases: ['JSX', 'Immutable', 'Expression']
    fields:
      openingFragment:
        validate: assertNodeType 'JSXOpeningFragment'
      closingFragment:
        validate: assertNodeType 'JSXClosingFragment'
      children:
        validate: chain(
          assertValueType 'array'
          assertEach(
            assertNodeType(
              'JSXText'
              'JSXExpressionContainer'
              'JSXSpreadChild'
              'JSXElement'
              'JSXFragment'
            )
          )
        )

  defineType 'JSXOpeningFragment', aliases: ['JSX', 'Immutable']

  defineType 'JSXClosingFragment', aliases: ['JSX', 'Immutable']
