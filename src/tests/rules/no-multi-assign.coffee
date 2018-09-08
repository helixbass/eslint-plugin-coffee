###*
# @fileoverview Tests for no-multi-assign rule.
# @author Stewart Rand
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-multi-assign'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Fixtures
#------------------------------------------------------------------------------

###*
# Returns an error object at the specified line and column
# @private
# @param {int} line - line number
# @param {int} column - column number
# @param {string} type - Type of node
# @returns {Oject} Error object
###
errorAt = (line, column, type) ->
  {
    message: 'Unexpected chained assignment.'
    type
    line
    column
  }

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-multi-assign', rule,
  valid: [
    '''
      a = null
      b = null
      c = null
      d = 0
    '''
    '''
      a = 1
      b = 2
      c = 3
      d = 0
    '''
    'a = 1 + (if b is 10 then 5 else 4)'
    'a = 1; b = 2; c = 3'
  ]

  invalid: [
    code: 'a = b = c'
    errors: [errorAt 1, 5, 'AssignmentExpression']
  ,
    code: 'a = b = c = d'
    errors: [
      errorAt 1, 5, 'AssignmentExpression'
      errorAt 1, 9, 'AssignmentExpression'
    ]
  ,
    code: 'foo = bar = cee = 100'
    errors: [
      errorAt 1, 7, 'AssignmentExpression'
      errorAt 1, 13, 'AssignmentExpression'
    ]
  ,
    code: 'a=b=c=d=e'
    errors: [
      errorAt 1, 3, 'AssignmentExpression'
      errorAt 1, 5, 'AssignmentExpression'
      errorAt 1, 7, 'AssignmentExpression'
    ]
  ,
    code: 'a=b=c'
    errors: [errorAt 1, 3, 'AssignmentExpression']
  ,
    code: 'a = b = (((c)))'
    errors: [errorAt 1, 5, 'AssignmentExpression']
  ,
    code: 'a = b = (c)'
    errors: [errorAt 1, 5, 'AssignmentExpression']
  ,
    code: 'a = b = ( (c * 12) + 2)'
    errors: [errorAt 1, 5, 'AssignmentExpression']
  ,
    code: 'a =\nb =\n (c)'
    errors: [errorAt 2, 1, 'AssignmentExpression']
  ,
    code: "a = b = '=' + c + 'foo'"
    errors: [errorAt 1, 5, 'AssignmentExpression']
  ,
    code: 'a = b = 7 * 12 + 5'
    errors: [errorAt 1, 5, 'AssignmentExpression']
  ]
