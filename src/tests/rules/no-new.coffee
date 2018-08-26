###*
# @fileoverview Tests for no-new rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-new'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-new', rule,
  valid: [
    'a = new Date()'
    '''
      a = null
      a = no if a is new Date()
    '''
  ]
  invalid: [
    code: 'new Date()'
    errors: [
      message: "Do not use 'new' for side effects.", type: 'ExpressionStatement'
    ]
  ]
