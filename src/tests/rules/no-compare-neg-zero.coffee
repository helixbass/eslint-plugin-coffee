###*
# @fileoverview The rule should warn against code that tries to compare against -0.
# @author Aladdin-ADD<hh_2013@foxmail.com>
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-compare-neg-zero'

{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-compare-neg-zero', rule,
  valid: [
    'x is 0'
    '0 is x'
    'x == 0'
    '0 == x'
    "x is '0'"
    "'0' is x"
    "x == '0'"
    "'0' == x"
    "x is '-0'"
    "'-0' is x"
    "x == '-0'"
    "'-0' == x"
    'x is -1'
    '-1 is x'
    'x < 0'
    '0 < x'
    'x <= 0'
    '0 <= x'
    'x > 0'
    '0 > x'
    'x >= 0'
    '0 >= x'
    'x != 0'
    '0 != x'
    'x isnt 0'
    '0 isnt x'
    'Object.is(x, -0)'
  ]

  invalid: [
    code: 'x is -0'
    errors: [
      messageId: 'unexpected'
      data: operator: 'is'
      type: 'BinaryExpression'
    ]
  ,
    code: '-0 is x'
    errors: [
      messageId: 'unexpected'
      data: operator: 'is'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x == -0'
    errors: [
      messageId: 'unexpected'
      data: operator: '=='
      type: 'BinaryExpression'
    ]
  ,
    code: '-0 == x'
    errors: [
      messageId: 'unexpected'
      data: operator: '=='
      type: 'BinaryExpression'
    ]
  ,
    code: 'x > -0'
    errors: [
      messageId: 'unexpected'
      data: operator: '>'
      type: 'BinaryExpression'
    ]
  ,
    code: '-0 > x'
    errors: [
      messageId: 'unexpected'
      data: operator: '>'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x >= -0'
    errors: [
      messageId: 'unexpected'
      data: operator: '>='
      type: 'BinaryExpression'
    ]
  ,
    code: '-0 >= x'
    errors: [
      messageId: 'unexpected'
      data: operator: '>='
      type: 'BinaryExpression'
    ]
  ,
    code: 'x < -0'
    errors: [
      messageId: 'unexpected'
      data: operator: '<'
      type: 'BinaryExpression'
    ]
  ,
    code: '-0 < x'
    errors: [
      messageId: 'unexpected'
      data: operator: '<'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x <= -0'
    errors: [
      messageId: 'unexpected'
      data: operator: '<='
      type: 'BinaryExpression'
    ]
  ,
    code: '-0 <= x'
    errors: [
      messageId: 'unexpected'
      data: operator: '<='
      type: 'BinaryExpression'
    ]
  ]
