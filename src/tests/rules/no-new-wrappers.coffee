###*
# @fileoverview Tests for no-new-wrappers rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-new-wrappers'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-new-wrappers', rule,
  valid: ['a = new Object()', "a = String('test'); b = String.fromCharCode(32)"]
  invalid: [
    code: "a = new String('hello')"
    errors: [
      message: 'Do not use String as a constructor.', type: 'NewExpression'
    ]
  ,
    code: 'a = new Number(10)'
    errors: [
      message: 'Do not use Number as a constructor.', type: 'NewExpression'
    ]
  ,
    code: 'a = new Boolean(false)'
    errors: [
      message: 'Do not use Boolean as a constructor.', type: 'NewExpression'
    ]
  ,
    code: 'a = new Math()'
    errors: [
      message: 'Do not use Math as a constructor.', type: 'NewExpression'
    ]
  ,
    code: 'a = new JSON({ myProp: 10 })'
    errors: [
      message: 'Do not use JSON as a constructor.', type: 'NewExpression'
    ]
  ]
