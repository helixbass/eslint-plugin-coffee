###*
# @fileoverview disallow unncessary concatenation of literals or template literals
# @author Henry Zhu
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-useless-concat'

{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-useless-concat', rule,
  valid: [
    'a = 1 + 1'
    "a = 1 * '2'"
    'a = 1 - 2'
    'a = foo + bar'
    "a = 'foo' + bar"
    "foo = 'foo' +\n 'bar'"

    # https://github.com/eslint/eslint/issues/3575
    "string = (number + 1) + 'px'"
    "'a' + 1"
    "1 + '1'"
    "'1' + 1"
    '(1 + +2) + "b"'
  ]

  invalid: [
    code: "'a' + 'b'"
    errors: [message: 'Unexpected string concatenation of literals.']
  ,
    code: "foo + 'a' + 'b'"
    errors: [message: 'Unexpected string concatenation of literals.']
  ,
    code: "'a' + 'b' + 'c'"
    errors: [
      message: 'Unexpected string concatenation of literals.'
      line: 1
      column: 5
    ,
      message: 'Unexpected string concatenation of literals.'
      line: 1
      column: 11
    ]
  ,
    code: "(foo + 'a') + ('b' + 'c')"
    errors: [
      column: 13, message: 'Unexpected string concatenation of literals.'
    ,
      column: 20, message: 'Unexpected string concatenation of literals.'
    ]
  ]
