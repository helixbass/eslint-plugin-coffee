###*
# @fileoverview This rule shoud require or disallow usage of "English" operators.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

ENGLISH_OPERATORS =
  not: '!'
  and: '&&'
  or: '||'
  is: '=='
  isnt: '!='

NON_ENGLISH_OPERATORS =
  '!': 'not'
  '&&': 'and'
  '||': 'or'
  '==': 'is'
  '!=': 'isnt'

isBang = ({operator}) ->
  operator is '!'
isDoubleBang = (node) ->
  return no unless isBang node
  return yes if isBang node.parent
  return yes if isBang node.argument
  no

getMessage = ({useEnglish, operator}) ->
  "Prefer the usage of '#{
    (if useEnglish then NON_ENGLISH_OPERATORS else ENGLISH_OPERATORS)[operator]
  }' over '#{operator}'"

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent usage of English operators'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/space-unary-ops'

    schema: [enum: ['always', 'never']]

  create: (context) ->
    useEnglish = context.options?[0] isnt 'never'

    checkOp = (node) ->
      return if (
        node.operator of (
          if useEnglish
            ENGLISH_OPERATORS
          else
            NON_ENGLISH_OPERATORS
        )
      )
      return if isDoubleBang node

      context.report {
        node
        message: getMessage {useEnglish, operator: node.operator}
      }

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    UnaryExpression: checkOp
    BinaryExpression: checkOp
    LogicalExpression: checkOp
