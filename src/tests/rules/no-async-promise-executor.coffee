###*
# @fileoverview disallow using an async function as a Promise executor
# @author Teddy Katz
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-async-promise-executor'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-async-promise-executor', rule,
  valid: [
    'new Promise((resolve, reject) => {})'
    'new Promise(((resolve, reject) => {}), -> await 1)'
    'new Foo((resolve, reject) => await 1)'
  ]

  invalid: [
    code: 'new Promise((resolve, reject) -> await 1)'
    errors: [
      message: 'Promise executor functions should not be async.'
      line: 1
      column: 13
      endLine: 1
      endColumn: 41
    ]
  ,
    code: 'new Promise((resolve, reject) => await 1)'
    errors: [
      message: 'Promise executor functions should not be async.'
      line: 1
      column: 13
      endLine: 1
      endColumn: 41
    ]
  ,
    code: 'new Promise(((((() => await 1)))))'
    errors: [
      message: 'Promise executor functions should not be async.'
      line: 1
      column: 17
      endLine: 1
      endColumn: 30
    ]
  ]
