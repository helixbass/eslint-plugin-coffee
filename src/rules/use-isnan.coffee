###*
# @fileoverview Rule to flag comparisons to the value NaN
# @author James Allardice
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

comparisonOpRegex = ///
  ^
    [<>] =?
  | [!=]=
  | is
  | isnt
  $
///

module.exports =
  meta:
    docs:
      description: "require calls to `isNaN()` when checking for `NaN`"
      category: "Possible Errors"
      recommended: true
      url: "https://eslint.org/docs/rules/use-isnan"
    schema: []

  create: (context) ->
    BinaryExpression: (node) ->
      {operator, left, right} = node
      if comparisonOpRegex.test(operator) and (left.name is 'NaN' or right.name is 'NaN')
        context.report {node, message: 'Use the isNaN function to compare with NaN.'}
