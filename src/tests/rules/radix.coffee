###*
# @fileoverview Tests for radix rule.
# @author James Allardice
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/radix'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'radix', rule,
  valid: [
    'parseInt("10", 10)'
    'parseInt("10", foo)'
    'Number.parseInt("10", foo)'
  ,
    code: 'parseInt("10", 10)'
    options: ['always']
  ,
    code: 'parseInt("10")'
    options: ['as-needed']
  ,
    code: 'parseInt("10", 8)'
    options: ['as-needed']
  ,
    code: 'parseInt("10", foo)'
    options: ['as-needed']
  ,
    'parseInt'
    'Number.foo()'
    'Number[parseInt]()'

    # Ignores if it's shadowed.
    '''
      parseInt = ->
      parseInt()
    '''
  ,
    code: '''
      parseInt = ->
      parseInt(foo)
    '''
    options: ['always']
  ,
    code: '''
      parseInt = ->
      parseInt foo, 10
    '''
    options: ['as-needed']
  ,
    '''
      Number = {}
      Number.parseInt()
    '''
  ,
    code: '''
      Number = {}
      Number.parseInt(foo)
    '''
    options: ['always']
  ,
    code: '''
      Number = {}
      Number.parseInt(foo, 10)
    '''
    options: ['as-needed']
  ]

  invalid: [
    code: 'parseInt()'
    options: ['as-needed']
    errors: [
      message: 'Missing parameters.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt()'
    errors: [
      message: 'Missing parameters.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt "10"'
    errors: [
      message: 'Missing radix parameter.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt("10", null)'
    errors: [
      message: 'Invalid radix parameter.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt("10", undefined)'
    errors: [
      message: 'Invalid radix parameter.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt "10", true'
    errors: [
      message: 'Invalid radix parameter.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt("10", "foo")'
    errors: [
      message: 'Invalid radix parameter.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt("10", "123")'
    errors: [
      message: 'Invalid radix parameter.'
      type: 'CallExpression'
    ]
  ,
    code: 'Number.parseInt()'
    errors: [
      message: 'Missing parameters.'
      type: 'CallExpression'
    ]
  ,
    code: 'Number.parseInt()'
    options: ['as-needed']
    errors: [
      message: 'Missing parameters.'
      type: 'CallExpression'
    ]
  ,
    code: 'Number.parseInt("10")'
    errors: [
      message: 'Missing radix parameter.'
      type: 'CallExpression'
    ]
  ,
    code: 'parseInt("10", 10)'
    options: ['as-needed']
    errors: [
      message: 'Redundant radix parameter.'
      type: 'CallExpression'
    ]
  ]
