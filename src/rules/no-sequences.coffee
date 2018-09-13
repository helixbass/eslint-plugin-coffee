###*
# @fileoverview Rule to check for sequences using the semicolon operator
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow sequences using semicolons'
      # category: 'Best Practices'
      recommended: no
      # url: 'https://eslint.org/docs/rules/block-scoped-var'

    schema: []

  create: (context) ->
    sourceCode = context.getSourceCode()
    semiTokens = sourceCode.tokensAndComments.filter ({value}) -> value is ';'

    check = (node) ->
      return unless semiTokens.length
      body = node.body ? node.expressions
      return unless body?.length > 1

      semisInRange = []
      for semiToken in semiTokens
        break unless semiToken.range[1] < node.range[1]
        continue unless semiToken.range[0] > node.range[0]
        semisInRange.push semiToken
      return unless semisInRange.length

      currentSemiIndex = 0
      for index in [0...(body.length - 1)]
        expression = body[index]
        while (
          (currentSemi = semisInRange[currentSemiIndex]).range[0] <
          expression.range[0]
        )
          currentSemiIndex++
          return if currentSemiIndex >= semisInRange.length - 1
        continue unless currentSemi.range[0] >= expression.range[1]
        if currentSemi.range[1] <= body[index + 1].range[0]
          context.report
            node: currentSemi
            message: "Don't use sequences"
          return

    Program: check
    BlockStatement: check
    SequenceExpression: check
