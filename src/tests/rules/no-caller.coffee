###*
# @fileoverview Tests for no-caller rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-caller'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-caller', rule,
  valid: [
    'x = arguments.length'
    'x = arguments'
    'x = arguments[0]'
    'x = arguments[caller]'
  ]
  invalid: [
    code: 'x = arguments.callee'
    errors: [
      messageId: 'unexpected', data: {prop: 'callee'}, type: 'MemberExpression'
    ]
  ,
    code: 'x = arguments.caller'
    errors: [
      messageId: 'unexpected', data: {prop: 'caller'}, type: 'MemberExpression'
    ]
  ]
