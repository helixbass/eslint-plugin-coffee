###*
# @fileoverview Check that the Unicode BOM can be required and disallowed
# @author Andrew Johnston <https:#github.com/ehjay>
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/unicode-bom'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'unicode-bom', rule,
  valid: [
    code: '\uFEFF a = 123'
    options: ['always']
  ,
    code: 'a = 123'
    options: ['never']
  ,
    code: 'a = 123 \uFEFF'
    options: ['never']
  ]

  invalid: [
    code: 'a = 123'
    output: '\uFEFFa = 123'
    options: ['always']
    errors: [
      message: 'Expected Unicode BOM (Byte Order Mark).', type: 'Program'
    ]
  ,
    code: " # here's a comment \na = 123"
    output: "\uFEFF # here's a comment \na = 123"
    options: ['always']
    errors: [
      message: 'Expected Unicode BOM (Byte Order Mark).', type: 'Program'
    ]
  ,
    code: '\uFEFF a = 123'
    output: ' a = 123'
    errors: [
      message: 'Unexpected Unicode BOM (Byte Order Mark).', type: 'Program'
    ]
  ,
    code: '\uFEFF a = 123'
    output: ' a = 123'
    options: ['never']
    errors: [
      message: 'Unexpected Unicode BOM (Byte Order Mark).', type: 'Program'
    ]
  ]
