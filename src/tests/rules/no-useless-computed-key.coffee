###*
# @fileoverview Tests for no-useless-computed-key rule.
# @author Burak Yigit Kaya
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-useless-computed-key'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-useless-computed-key', rule,
  valid: [
    "({ 'a': 0, b: -> })"
    '({ [x]: 0 });'
    '({ a: 0, [b]: -> })'
    "({ ['__proto__']: [] })"
  ]
  invalid: [
    code: "({ ['0']: 0 })"
    output: "({ '0': 0 })"
    errors: [
      message: "Unnecessarily computed property ['0'] found."
      type: 'Property'
    ]
  ,
    code: "({ ['0+1,234']: 0 })"
    output: "({ '0+1,234': 0 })"
    errors: [
      message: "Unnecessarily computed property ['0+1,234'] found."
      type: 'Property'
    ]
  ,
    code: '({ [0]: 0 })'
    output: '({ 0: 0 })'
    errors: [
      message: 'Unnecessarily computed property [0] found.'
      type: 'Property'
    ]
  ,
    code: "({ ['x']: 0 })"
    output: "({ 'x': 0 })"
    errors: [
      message: "Unnecessarily computed property ['x'] found."
      type: 'Property'
    ]
  ,
    code: "({ ['x']: -> })"
    output: "({ 'x': -> })"
    errors: [
      message: "Unnecessarily computed property ['x'] found."
      type: 'Property'
    ]
  ,
    code: "({ [### this comment prevents a fix ### 'x']: 0 })"
    output: null
    errors: [
      message: "Unnecessarily computed property ['x'] found."
      type: 'Property'
    ]
  ,
    code: "({ ['x' ### this comment also prevents a fix ###]: 0 })"
    output: null
    errors: [
      message: "Unnecessarily computed property ['x'] found."
      type: 'Property'
    ]
  ,
    code: "({ [('x')]: 0 })"
    output: "({ 'x': 0 })"
    errors: [
      message: "Unnecessarily computed property ['x'] found."
      type: 'Property'
    ]
  ]
