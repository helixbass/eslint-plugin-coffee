###*
# @fileoverview Tests for max-nested-callbacks rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/max-nested-callbacks'
{RuleTester} = require 'eslint'
path = require 'path'

OPENING = 'foo(-> '
CLOSING = ')'

###*
# Generates a code string with the specified number of nested callbacks.
# @param {int} times The number of times to nest the callbacks.
# @returns {string} Code with the specified number of nested callbacks
# @private
###
nestFunctions = (times) ->
  openings = ''
  closings = ''

  i = 0
  while i < times
    openings += OPENING
    closings += CLOSING
    i++
  openings + closings

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------
ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'max-nested-callbacks', rule,
  valid: [
    code: 'foo -> bar thing, (data) ->', options: [3]
  ,
    code: '''
      foo = ->
      bar ->
        baz ->
          qux foo
    '''
    options: [2]
  ,
    code: 'fn ->, ->, ->', options: [2]
  ,
    nestFunctions 10
  ,
    # object property options
    code: 'foo -> bar thing, (data) ->'
    options: [max: 3]
  ]
  invalid: [
    code:
      'foo -> bar thing, (data) -> baz ->'
    options: [2]
    errors: [
      message: 'Too many nested callbacks (3). Maximum allowed is 2.'
      type: 'FunctionExpression'
    ]
  ,
    code:
      'foo -> if isTrue then bar (data) -> baz ->'
    options: [2]
    errors: [
      message: 'Too many nested callbacks (3). Maximum allowed is 2.'
      type: 'FunctionExpression'
    ]
  ,
    code: nestFunctions 11
    errors: [
      message: 'Too many nested callbacks (11). Maximum allowed is 10.'
      type: 'FunctionExpression'
    ]
  ,
    # object property options
    code:
      'foo -> bar thing, (data) -> baz ->'
    options: [max: 2]
    errors: [
      message: 'Too many nested callbacks (3). Maximum allowed is 2.'
      type: 'FunctionExpression'
    ]
  ]
