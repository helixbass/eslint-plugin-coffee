###*
# @fileoverview Tests for no-delete-var rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-delete-var'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-delete-var', rule,
  valid: ['delete x.prop']
  invalid: [
    code: 'delete x', errors: [messageId: 'unexpected', type: 'UnaryExpression']
  ]
