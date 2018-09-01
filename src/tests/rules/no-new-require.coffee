###*
# @fileoverview Tests for no-new-require rule.
# @author Wil Moore III
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-new-require'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

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
