###*
# @fileoverview Tests for the no-new-object rule
# @author Matt DuVall <http://www.mattduvall.com/>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-new-object'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-new-object', rule,
  valid: ['foo = new foo.Object()']
  invalid: [
    code: 'foo = new Object()'
    errors: [
      message: 'The object literal notation {} is preferrable.'
      type: 'NewExpression'
    ]
  ]
