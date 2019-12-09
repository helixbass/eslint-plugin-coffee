###*
# @fileoverview Prevent missing parentheses around multilines JSX
# @author Yannick Croissant
###
'use strict'

has = require 'has'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
jsxUtil = require '../util/react/jsx'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

DEFAULTS =
  assignment: 'parens'
  return: 'parens'
  arrow: 'parens'
  logical: 'ignore'
  prop: 'ignore'

MISSING_PARENS = 'Missing parentheses around multilines JSX'
PARENS_NEW_LINES = 'Parentheses around JSX should be on separate lines'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Prevent missing parentheses around multilines JSX'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-wrap-multilines'
    # fixable: 'code'

    schema: [
      type: 'object'
      # true/false are for backwards compatibility
      properties:
        assignment:
          enum: [yes, no, 'ignore', 'parens', 'parens-new-line']
        return:
          enum: [yes, no, 'ignore', 'parens', 'parens-new-line']
        arrow:
          enum: [yes, no, 'ignore', 'parens', 'parens-new-line']
        logical:
          enum: [yes, no, 'ignore', 'parens', 'parens-new-line']
        prop:
          enum: [yes, no, 'ignore', 'parens', 'parens-new-line']
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()

    getOption = (type) ->
      userOptions = context.options[0] or {}
      return userOptions[type] if has userOptions, type
      DEFAULTS[type]

    isEnabled = (type) ->
      option = getOption type
      option and option isnt 'ignore'

    isParenthesised = (node) ->
      previousToken = sourceCode.getTokenBefore node
      nextToken = sourceCode.getTokenAfter node

      previousToken and
        nextToken and
        previousToken.value is '(' and
        previousToken.range[1] <= node.range[0] and
        nextToken.value is ')' and
        nextToken.range[0] >= node.range[1]

    needsNewLines = (node) ->
      previousToken = sourceCode.getTokenBefore node
      nextToken = sourceCode.getTokenAfter node

      isParenthesised(node) and
        previousToken.loc.end.line is node.loc.start.line and
        node.loc.end.line is nextToken.loc.end.line

    isMultilines = (node) -> node.loc.start.line isnt node.loc.end.line

    report = (
      node
      message
      #fix
    ) ->
      context.report {
        node
        message
        # fix
      }

    trimTokenBeforeNewline = (node, tokenBefore) ->
      # if the token before the jsx is a bracket or curly brace
      # we don't want a space between the opening parentheses and the multiline jsx
      isBracket = tokenBefore.value in ['{', '[']
      "#{tokenBefore.value.trim()}#{if isBracket then '' else ' '}"

    check = (node, type) ->
      return if not node or not jsxUtil.isJSX node

      option = getOption type

      if (
        option in [yes, 'parens'] and
        not isParenthesised(node) and
        isMultilines node
      )
        report node, MISSING_PARENS, (fixer) ->
          fixer.replaceText node, "(#{sourceCode.getText node})"

      if option is 'parens-new-line' and isMultilines node
        unless isParenthesised node
          tokenBefore = sourceCode.getTokenBefore node, includeComments: yes
          tokenAfter = sourceCode.getTokenAfter node, includeComments: yes
          if tokenBefore.loc.end.line < node.loc.start.line
            # Strip newline after operator if parens newline is specified
            report node, MISSING_PARENS, (fixer) ->
              fixer.replaceTextRange(
                [tokenBefore.range[0], tokenAfter.range[0]]
                "#{trimTokenBeforeNewline(
                  node
                  tokenBefore
                )}(\n#{sourceCode.getText node}\n)"
              )
          else
            report node, MISSING_PARENS, (fixer) ->
              fixer.replaceText node, "(\n#{sourceCode.getText node}\n)"
        else if needsNewLines node
          report node, PARENS_NEW_LINES, (fixer) ->
            fixer.replaceText node, "\n#{sourceCode.getText node}\n"

    checkFunction = (node) ->
      arrowBody = node.body
      type = 'arrow'

      if isEnabled type
        unless arrowBody.type is 'BlockStatement'
          check arrowBody, type
        else if (
          arrowBody.body.length is 1 and
          arrowBody.body[0].type is 'ExpressionStatement'
        )
          check arrowBody.body[0].expression, type

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    AssignmentExpression: (node) ->
      type = 'assignment'
      return unless isEnabled type
      check node.right, type

    ReturnStatement: (node) ->
      type = 'return'
      if isEnabled type then check node.argument, type

    'ArrowFunctionExpression:exit': checkFunction
    'FunctionExpression:exit': checkFunction

    LogicalExpression: (node) ->
      type = 'logical'
      if isEnabled type then check node.right, type

    JSXAttribute: (node) ->
      type = 'prop'
      if isEnabled(type) and node.value?.type is 'JSXExpressionContainer'
        check node.value.expression, type
