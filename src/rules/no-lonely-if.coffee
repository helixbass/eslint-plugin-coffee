###*
# @fileoverview Rule to disallow if as the only statmenet in an else block
# @author Brandon Mills
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow `if` statements as the only statement in `else` blocks'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-lonely-if'

    schema: []

    # fixable: 'code'

  create: (context) ->
    sourceCode = context.getSourceCode()

    report = (node) ->
      context.report {
        node
        message: 'Unexpected if as the only statement in an else block.'
        # fix: (fixer) ->
        #   openingElseCurly = sourceCode.getFirstToken parent
        #   closingElseCurly = sourceCode.getLastToken parent
        #   elseKeyword = sourceCode.getTokenBefore openingElseCurly
        #   tokenAfterElseBlock = sourceCode.getTokenAfter closingElseCurly
        #   lastIfToken = sourceCode.getLastToken node.consequent
        #   sourceText = sourceCode.getText()

        #   # Don't fix if there are any non-whitespace characters interfering (e.g. comments)
        #   return null if (
        #     sourceText
        #       .slice(openingElseCurly.range[1], node.range[0])
        #       .trim() or
        #     sourceText.slice(node.range[1], closingElseCurly.range[0]).trim()
        #   )

        #   ###
        #   # If the `if` statement has no block, and is not followed by a semicolon, make sure that fixing
        #   # the issue would not change semantics due to ASI. If this would happen, don't do a fix.
        #   ###
        #   return null if (
        #     node.consequent.type isnt 'BlockStatement' and
        #     lastIfToken.value isnt ';' and
        #     tokenAfterElseBlock and
        #     (node.consequent.loc.end.line is
        #       tokenAfterElseBlock.loc.start.line or
        #       /^[([/+`-]/.test(tokenAfterElseBlock.value) or
        #       lastIfToken.value in ['++', '--'])
        #   )

        #   fixer.replaceTextRange(
        #     [openingElseCurly.range[0], closingElseCurly.range[1]]
        #     (
        #       if elseKeyword.range[1] is openingElseCurly.range[0]
        #         ' '
        #       else
        #         ''
        #     ) + sourceCode.getText node
        #   )
      }

    IfStatement: (node) ->
      ancestors = context.getAncestors()
      parent = ancestors.pop()
      grandparent = ancestors.pop()

      isLoneStatementInElseBlock =
        parent?.type is 'BlockStatement' and
        parent.body.length is 1 and
        grandparent?.type is 'IfStatement' and
        parent is grandparent.alternate

      if isLoneStatementInElseBlock
        report node
        return

      return unless parent?.type is 'IfStatement' and node is parent.alternate
      ifToken = sourceCode.getFirstToken node
      return unless ifToken.value is 'if'
      elseToken = sourceCode.getTokenBefore ifToken
      return unless elseToken.value is 'else'
      report node if ifToken.loc.start.line > elseToken.loc.start.line
