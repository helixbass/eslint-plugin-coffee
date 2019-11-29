###*
# @fileoverview Rule to check use of parentheses in empty function param lists
# @author Julian Rosse
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'prefer or disallow parentheses in empty param lists'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/max-len'

    schema: [
      type: 'string'
      enum: ['never', 'always']
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    useParens = context.options[0] is 'always'

    check = (node) ->
      return if node.params.length
      hasParens = sourceCode.getFirstToken(node).value is '('
      if hasParens and not useParens
        context.report {
          node
          message: "Don't use parentheses for empty function parameter list"
        }
      else if not hasParens and useParens
        context.report {
          node
          message: 'Use empty parentheses for function parameter list'
        }

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    FunctionExpression: check
    ArrowFunctionExpression: check
