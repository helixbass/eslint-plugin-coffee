###*
# @fileoverview Tests for prefer-numeric-literals rule.
# @author Annie Zhang
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/prefer-numeric-literals'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'prefer-numeric-literals', rule,
  valid: [
    'parseInt(1)'
    'parseInt(1, 3)'
    'Number.parseInt(1)'
    'Number.parseInt(1, 3)'
    '0b111110111 is 503'
    '0o767 is 503'
    '0x1F7 is 503'
    'a[parseInt](1,2)'
    'parseInt(foo)'
    'parseInt(foo, 2)'
    'Number.parseInt(foo)'
    'Number.parseInt(foo, 2)'
  ]
  invalid: [
    code: 'parseInt("111110111", 2) is 503'
    output: '0b111110111 is 503'
    errors: [message: 'Use binary literals instead of parseInt().']
  ,
    code: 'parseInt("767", 8) is 503'
    output: '0o767 is 503'
    errors: [message: 'Use octal literals instead of parseInt().']
  ,
    code: 'parseInt("1F7", 16) is 255'
    output: '0x1F7 is 255'
    errors: [message: 'Use hexadecimal literals instead of parseInt().']
  ,
    code: 'Number.parseInt("111110111", 2) is 503'
    output: '0b111110111 is 503'
    errors: [message: 'Use binary literals instead of Number.parseInt().']
  ,
    code: 'Number.parseInt("767", 8) is 503'
    output: '0o767 is 503'
    errors: [message: 'Use octal literals instead of Number.parseInt().']
  ,
    code: 'Number.parseInt("1F7", 16) is 255'
    output: '0x1F7 is 255'
    errors: [message: 'Use hexadecimal literals instead of Number.parseInt().']
  ,
    code: "parseInt('7999', 8)"
    output: null # not fixed, unexpected 9 in parseInt string
    errors: [message: 'Use octal literals instead of parseInt().']
  ,
    code: "parseInt('1234', 2)"
    output: null # not fixed, invalid binary string
    errors: [message: 'Use binary literals instead of parseInt().']
  ,
    code: "parseInt('1234.5', 8)"
    output: null # not fixed, this isn't an integer
    errors: [message: 'Use octal literals instead of parseInt().']
  ,
    code: "parseInt('1️⃣3️⃣3️⃣7️⃣', 16)"
    output: null # not fixed, javascript doesn't support emoji literals
    errors: [message: 'Use hexadecimal literals instead of parseInt().']
  ,
    code: "Number.parseInt('7999', 8)"
    output: null # not fixed, unexpected 9 in parseInt string
    errors: [message: 'Use octal literals instead of Number.parseInt().']
  ,
    code: "Number.parseInt('1234', 2)"
    output: null # not fixed, invalid binary string
    errors: [message: 'Use binary literals instead of Number.parseInt().']
  ,
    code: "Number.parseInt('1234.5', 8)"
    output: null # not fixed, this isn't an integer
    errors: [message: 'Use octal literals instead of Number.parseInt().']
  ,
    code: "Number.parseInt('1️⃣3️⃣3️⃣7️⃣', 16)"
    output: null # not fixed, javascript doesn't support emoji literals
    errors: [message: 'Use hexadecimal literals instead of Number.parseInt().']
  ]
