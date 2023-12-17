###*
# @fileoverview Tests for no-delete-var rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-delete-var'
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
