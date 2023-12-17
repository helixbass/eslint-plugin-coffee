###*
# @fileoverview Tests for prefer-rest-params rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/prefer-rest-params'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'prefer-rest-params', rule,
  valid: [
    'arguments'
    '(...args) -> args'
    '-> arguments.length'
    '-> arguments.callee'
  ]
  invalid: [
    code: '-> arguments'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ,
    code: '-> arguments[0]'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ,
    code: '-> arguments[1]'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ,
    code: '-> arguments[Symbol.iterator]'
    errors: [
      type: 'Identifier'
      message: "Use the rest parameters instead of 'arguments'."
    ]
  ]
