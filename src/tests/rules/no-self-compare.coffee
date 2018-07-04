###*
# @fileoverview Tests for no-self-compare rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-self-compare'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-self-compare', rule,
  valid: [
    'if x is y then ;'
    'if 1 is 2 then ;'
    'y=x*x'
    'foo.bar.baz == foo.bar.qux'
  ]
  invalid: [
    code: 'if x is x then ;'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if x isnt x then ;'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if x > x then ;'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: "if 'x' > 'x' then ;"
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'null while x is x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x is x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x isnt x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x == x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x != x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x > x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x < x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x >= x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'x <= x'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'foo.bar().baz.qux >= foo.bar().baz .qux'
    errors: [
      message: 'Comparing to itself is potentially pointless.'
      type: 'BinaryExpression'
    ]
  ]
