###*
# @fileoverview Enforces that an assignment as the body of a postfix comprehension is wrapped in parens.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

isSingleAssignmentBlock = (block) ->
  return no unless block?.type is 'BlockStatement'
  return no unless block.body.length is 1
  [singleStatement] = block.body
  return no unless singleStatement.type is 'ExpressionStatement'
  {expression} = singleStatement
  return no unless expression.type is 'AssignmentExpression'
  expression

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce parentheses around an assignment as the body of a postfix comprehension'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/object-curly-spacing'

    schema: []
    fixable: 'code'

    messages:
      missingParens:
        'Add parentheses around the assignment to avoid confusion about the comprehension’s structure.'

  create: (context) ->
    sourceCode = context.getSourceCode()

    isWrappedInParens = (expression) ->
      nextToken = sourceCode.getTokenAfter expression
      nextToken.value is ')'

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    For: ({postfix, body}) ->
      return unless postfix
      return unless assignment = isSingleAssignmentBlock body
      return if isWrappedInParens assignment
      context.report
        node: assignment
        messageId: 'missingParens'
        fix: (fixer) ->
          fixer.replaceText assignment, "(#{sourceCode.getText assignment})"
