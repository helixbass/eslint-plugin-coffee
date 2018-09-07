###*
# @fileoverview Tests for no-control-regex rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-control-regex'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-control-regex', rule,
  valid: [
    'regex = /x1f/'
    'regex = ///x1f///'
    "regex =#{/\\x1f/}"
    "regex = new RegExp('x1f')"
    "regex = RegExp('x1f')"
    "new RegExp('[')"
    "RegExp('[')"
    "new (->)('\\x1f')"
  ]
  invalid: [
    code: "regex = #{/\x1f/}"
    errors: [
      messageId: 'unexpected', data: {controlChars: '\\x1f'}, type: 'Literal'
    ] # eslint-disable-line no-control-regex
  ,
    code: "regex = //#{/\x1f/}//"
    errors: [
      messageId: 'unexpected', data: {controlChars: '\\x1f'}, type: 'Literal'
    ] # eslint-disable-line no-control-regex
  ,
    code: "regex = #{/\\\x1f\\x1e/}"
    errors: [
      messageId: 'unexpected', data: {controlChars: '\\x1f'}, type: 'Literal'
    ] # eslint-disable-line no-control-regex
  ,
    code: "regex = #{/\\\x1fFOO\\x00/}"
    errors: [
      messageId: 'unexpected', data: {controlChars: '\\x1f'}, type: 'Literal'
    ] # eslint-disable-line no-control-regex
  ,
    code: "regex = #{/FOO\\\x1fFOO\\x1f/}"
    errors: [
      messageId: 'unexpected', data: {controlChars: '\\x1f'}, type: 'Literal'
    ] # eslint-disable-line no-control-regex
  ,
    code: "regex = new RegExp('\\x1f\\x1e')"
    errors: [
      messageId: 'unexpected'
      data: controlChars: '\\x1f, \\x1e'
      type: 'Literal'
    ]
  ,
    code: "regex = new RegExp('\\x1fFOO\\x00')"
    errors: [
      messageId: 'unexpected'
      data: controlChars: '\\x1f, \\x00'
      type: 'Literal'
    ]
  ,
    code: "regex = new RegExp('FOO\\x1fFOO\\x1f')"
    errors: [
      messageId: 'unexpected'
      data: controlChars: '\\x1f, \\x1f'
      type: 'Literal'
    ]
  ,
    code: "regex = RegExp('\\x1f')"
    errors: [
      messageId: 'unexpected', data: {controlChars: '\\x1f'}, type: 'Literal'
    ]
  ,
    code: 'regex = /(?<a>\\x1f)/'
    errors: [
      messageId: 'unexpected', data: {controlChars: '\\x1f'}, type: 'Literal'
    ]
  ]
