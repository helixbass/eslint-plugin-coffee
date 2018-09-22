###*
# @fileoverview Validates whitespace in and around the JSX opening and closing brackets
# @author Diogo Franco (Kovensky)
###
'use strict'

getTokenBeforeClosingBracket = require(
  'eslint-plugin-react/lib/util/getTokenBeforeClosingBracket'
)
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Validators
# ------------------------------------------------------------------------------

validateBeforeSelfClosing = (context, node, option) ->
  sourceCode = context.getSourceCode()

  NEVER_MESSAGE = 'A space is forbidden before closing bracket'
  ALWAYS_MESSAGE = 'A space is required before closing bracket'

  leftToken = getTokenBeforeClosingBracket node
  closingSlash = sourceCode.getTokenAfter leftToken

  return unless leftToken.loc.end.line is closingSlash.loc.start.line

  if (
    option is 'always' and
    not sourceCode.isSpaceBetweenTokens leftToken, closingSlash
  )
    context.report {
      node
      loc: closingSlash.loc.start
      message: ALWAYS_MESSAGE
      fix: (fixer) -> fixer.insertTextBefore closingSlash, ' '
    }
  else if (
    option is 'never' and
    sourceCode.isSpaceBetweenTokens leftToken, closingSlash
  )
    context.report {
      node
      loc: closingSlash.loc.start
      message: NEVER_MESSAGE
      fix: (fixer) ->
        previousToken = sourceCode.getTokenBefore closingSlash
        fixer.removeRange [previousToken.range[1], closingSlash.range[0]]
    }

validateBeforeClosing = (context, node, option) ->
  # Don't enforce this rule for self closing tags
  unless node.selfClosing
    sourceCode = context.getSourceCode()

    NEVER_MESSAGE = 'A space is forbidden before closing bracket'
    ALWAYS_MESSAGE = 'Whitespace is required before closing bracket'

    lastTokens = sourceCode.getLastTokens node, 2
    closingToken = lastTokens[1]
    leftToken = lastTokens[0]

    return unless leftToken.loc.start.line is closingToken.loc.start.line

    adjacent = not sourceCode.isSpaceBetweenTokens leftToken, closingToken

    if option is 'never' and not adjacent
      context.report {
        node
        loc:
          start: leftToken.loc.end
          end: closingToken.loc.start
        message: NEVER_MESSAGE
        fix: (fixer) ->
          fixer.removeRange [leftToken.range[1], closingToken.range[0]]
      }
    else if option is 'always' and adjacent
      context.report {
        node
        loc:
          start: leftToken.loc.end
          end: closingToken.loc.start
        message: ALWAYS_MESSAGE
        fix: (fixer) -> fixer.insertTextBefore closingToken, ' '
      }

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

optionDefaults =
  beforeSelfClosing: 'always'
  beforeClosing: 'allow'

module.exports =
  meta:
    docs:
      description:
        'Validate whitespace in and around the JSX opening and closing brackets'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-tag-spacing'
    fixable: 'whitespace'
    schema: [
      type: 'object'
      properties:
        beforeSelfClosing:
          enum: ['always', 'never', 'allow']
        beforeClosing:
          enum: ['always', 'never', 'allow']
      default: optionDefaults
      additionalProperties: no
    ]
  create: (context) ->
    options = {...optionDefaults, ...context.options[0]}

    JSXOpeningElement: (node) ->
      if options.beforeSelfClosing isnt 'allow' and node.selfClosing
        validateBeforeSelfClosing context, node, options.beforeSelfClosing
      unless options.beforeClosing is 'allow'
        validateBeforeClosing context, node, options.beforeClosing
    # JSXClosingElement: (node) ->
    #   unless options.beforeClosing is 'allow'
    #     validateBeforeClosing context, node, options.beforeClosing
