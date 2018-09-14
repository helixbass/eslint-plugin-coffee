###*
# @fileoverview Rule to flag when regex literals are not wrapped in parens
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require parenthesis around regex literals'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/wrap-regex'

    schema: []

    fixable: 'code'
    messages:
      requireParens:
        'Wrap the regexp literal in parens to disambiguate the slash.'

  create: (context) ->
    sourceCode = context.getSourceCode()

    Literal: (node) ->
      token = sourceCode.getFirstToken node
      nodeType = token.type

      if nodeType is 'RegularExpression' and node.delimiter isnt '///'
        beforeToken = sourceCode.getTokenBefore node
        afterToken = sourceCode.getTokenAfter node
        ancestors = context.getAncestors()
        grandparent = ancestors[ancestors.length - 1]

        if (
          grandparent.type is 'MemberExpression' and
          grandparent.object is node and
          not (
            beforeToken and
            beforeToken.value is '(' and
            afterToken and
            afterToken.value is ')'
          )
        )
          context.report {
            node
            messageId: 'requireParens'
            fix: (fixer) ->
              fixer.replaceText node, "(#{sourceCode.getText node})"
          }
