###*
# @fileoverview Tests for no-new-func rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-new-func'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-new-func', rule,
  valid: [
    'a = new _function("b", "c", "return b+c")'
    'a = _function("b", "c", "return b+c")'
  ]
  invalid: [
    code: 'a = new Function("b", "c", "return b+c")'
    errors: [
      message: 'The Function constructor is eval.', type: 'NewExpression'
    ]
  ,
    code: 'a = Function("b", "c", "return b+c")'
    errors: [
      message: 'The Function constructor is eval.', type: 'CallExpression'
    ]
  ]
