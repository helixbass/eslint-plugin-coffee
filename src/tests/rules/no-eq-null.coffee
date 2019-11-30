###*
# @fileoverview Tests for no-eq-null rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-eq-null'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-eq-null', rule,
  valid: ['if x is null then ;', 'if null is f() then ;']
  invalid: [
    code: 'if x == null then ;'
    errors: [messageId: 'unexpected', type: 'BinaryExpression']
  ,
    code: 'if x != null then ;'
    errors: [messageId: 'unexpected', type: 'BinaryExpression']
  ,
    code: 'while null == x then ;'
    errors: [messageId: 'unexpected', type: 'BinaryExpression']
  ]
