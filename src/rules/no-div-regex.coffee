###*
# @fileoverview Rule to check for ambiguous div operator in regexes
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow division operators explicitly at the beginning of regular expressions'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-div-regex'

    schema: []

    messages:
      unexpected: "A regular expression literal can be confused with '/='."

  create: (context) ->
    sourceCode = context.getSourceCode()

    Literal: (node) ->
      token = sourceCode.getFirstToken node

      if (
        token.type is 'RegularExpression' and
        token.value[1] is '=' and
        node.delimiter isnt '///'
      )
        context.report {node, messageId: 'unexpected'}
