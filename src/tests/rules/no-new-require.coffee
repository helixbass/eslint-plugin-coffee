###*
# @fileoverview Tests for no-new-require rule.
# @author Wil Moore III
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-new-require'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-new-require', rule,
  valid: [
    "appHeader = require('app-header')"
    "AppHeader = new (require('app-header'))"
    "AppHeader = new (require('headers').appHeader)"
  ]
  invalid: [
    code: "appHeader = new require('app-header')"
    errors: [
      message: 'Unexpected use of new with require.', type: 'NewExpression'
    ]
  ,
    code: "appHeader = new require('headers').appHeader"
    errors: [
      message: 'Unexpected use of new with require.', type: 'NewExpression'
    ]
  ]
