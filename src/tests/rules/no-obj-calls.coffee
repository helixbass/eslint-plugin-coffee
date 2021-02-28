###*
# @fileoverview Tests for no-obj-calls rule.
# @author James Allardice
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-obj-calls'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-obj-calls', rule,
  valid: ['x = Math.random()']
  invalid: [
    code: 'x = Math()'
    errors: [message: "'Math' is not a function.", type: 'CallExpression']
  ,
    code: 'x = JSON()'
    errors: [message: "'JSON' is not a function.", type: 'CallExpression']
    # ,
    #   code: 'x = Reflect()'
    #   errors: [message: "'Reflect' is not a function.", type: 'CallExpression']
  ]
