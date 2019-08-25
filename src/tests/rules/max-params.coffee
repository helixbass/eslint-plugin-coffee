###*
# @fileoverview Tests for max-params rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/max-params'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'max-params', rule,
  valid: [
    '(d, e, f) ->'
  ,
    code: 'test = (a, b, c) ->', options: [3]
  ,
    code: 'test = (a, b, c) =>'
    options: [3]
    parserOptions: ecmaVersion: 6
  ,
    code: 'test = (a, b, c) ->', options: [3]
  ,
    # object property options
    code: 'test = (a, b, c) ->', options: [max: 3]
  ]
  invalid: [
    code: 'test = (a, b, c, d) ->'
    options: [3]
    errors: [
      message: 'Function has too many parameters (4). Maximum allowed is 3.'
      type: 'FunctionExpression'
    ]
  ,
    code: '((a, b, c, d) ->)'
    options: [3]
    errors: [
      message: 'Function has too many parameters (4). Maximum allowed is 3.'
      type: 'FunctionExpression'
    ]
  ,
    code: 'test = (a, b, c) ->'
    options: [1]
    errors: [
      message:
        'Function has too many parameters (3). Maximum allowed is 1.'
      type: 'FunctionExpression'
    ]
  ,
    # object property options
    code: '(a, b, c) ->'
    options: [max: 2]
    errors: [
      message:
        'Function has too many parameters (3). Maximum allowed is 2.'
      type: 'FunctionExpression'
    ]
  ]
