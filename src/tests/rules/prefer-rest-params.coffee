###*
# @fileoverview Tests for prefer-rest-params rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/prefer-rest-params'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'prefer-rest-params', rule,
  valid: [
    'arguments'
    '(...args) -> args'
    '-> arguments.length'
    '-> arguments.callee'
  ]
  invalid: [
    code: '-> arguments'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ,
    code: '-> arguments[0]'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ,
    code: '-> arguments[1]'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ,
    code: '-> arguments[Symbol.iterator]'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ]
