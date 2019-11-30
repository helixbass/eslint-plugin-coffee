###*
# @fileoverview Tests for no-proto rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-proto'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-proto', rule,
  valid: ['a = test[__proto__]', '__proto__ = null']
  invalid: [
    code: 'a = test.__proto__'
    errors: [
      message: "The '__proto__' property is deprecated."
      type: 'MemberExpression'
    ]
  ,
    code: "a = test['__proto__']"
    errors: [
      message: "The '__proto__' property is deprecated."
      type: 'MemberExpression'
    ]
  ]
