###*
# @fileoverview Rule to define spacing before/after arrow function's arrow.
# @author Jxck
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

isArrowToken = (token) -> token?.value in ['=>', '->']

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce consistent spacing before and after the arrow in arrow functions'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/arrow-spacing'

    fixable: 'whitespace'

    schema: [
      type: 'object'
      properties:
        before:
          type: 'boolean'
        after:
          type: 'boolean'
      additionalProperties: no
    ]

    messages:
      expectedBefore: 'Missing space before arrow.'
      unexpectedBefore: 'Unexpected space before arrow.'

      expectedAfter: 'Missing space after arrow.'
      unexpectedAfter: 'Unexpected space after arrow.'

  create: (context) ->
    # merge rules with default
    rule = before: yes, after: yes
    option = context.options[0] or {}

    rule.before = option.before isnt no
    rule.after = option.after isnt no

    sourceCode = context.getSourceCode()

    ###*
    # Get tokens of arrow(`=>`) and before/after arrow.
    # @param {ASTNode} node The arrow function node.
    # @returns {Object} Tokens of arrow and before/after arrow.
    ###
    getTokens = (node) ->
      # AST currently includes arrow in body, so check there first
      firstBodyToken = sourceCode.getTokens(node.body)?[0]
      arrow =
        if isArrowToken firstBodyToken
          firstBodyToken
        else
          sourceCode.getTokenBefore node.body, isArrowToken

      {
        before: sourceCode.getTokenBefore arrow
        arrow
        after: sourceCode.getTokenAfter arrow
      }

    isIndented = (afterToken, arrowToken) ->
      '\n' in sourceCode.getText()[arrowToken.range[1]...afterToken.range[0]]

    ###*
    # Count spaces before/after arrow(`=>`) token.
    # @param {Object} tokens Tokens before/after arrow.
    # @returns {Object} count of space before/after arrow.
    ###
    countSpaces = (tokens) ->
      before =
        if tokens.before?.value is ')'
          tokens.arrow.range[0] - tokens.before.range[1]
        else
          'ignore'
      after =
        if (
          tokens.after and
          tokens.after.value not in ['.', ')', ','] and
          not isIndented tokens.after, tokens.arrow
        )
          tokens.after.range[0] - tokens.arrow.range[1]
        else
          'ignore'

      {before, after}

    ###*
    # Determines whether space(s) before after arrow(`=>`) is satisfy rule.
    # if before/after value is `true`, there should be space(s).
    # if before/after value is `false`, there should be no space.
    # @param {ASTNode} node The arrow function node.
    # @returns {void}
    ###
    spaces = (node) ->
      tokens = getTokens node
      countSpace = countSpaces tokens

      unless countSpace.before is 'ignore'
        if rule.before
          # should be space(s) before arrow
          if countSpace.before is 0
            context.report
              node: tokens.before
              messageId: 'expectedBefore'
              fix: (fixer) -> fixer.insertTextBefore tokens.arrow, ' '
        # should be no space before arrow
        else if countSpace.before > 0
          context.report
            node: tokens.before
            messageId: 'unexpectedBefore'
            fix: (fixer) ->
              fixer.removeRange [tokens.before.range[1], tokens.arrow.range[0]]

      unless countSpace.after is 'ignore'
        if rule.after
          # should be space(s) after arrow
          if countSpace.after is 0
            context.report
              node: tokens.after
              messageId: 'expectedAfter'
              fix: (fixer) -> fixer.insertTextAfter tokens.arrow, ' '
        # should be no space after arrow
        else if countSpace.after > 0
          context.report
            node: tokens.after
            messageId: 'unexpectedAfter'
            fix: (fixer) ->
              fixer.removeRange [tokens.arrow.range[1], tokens.after.range[0]]

    FunctionExpression: spaces
