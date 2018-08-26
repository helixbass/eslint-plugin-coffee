###*
# @fileoverview Disallow sparse arrays
# @author Nicholas C. Zakas
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-sparse-arrays'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-sparse-arrays', rule,
  valid: ['a = [ 1, 2, ]']

  invalid: [
    code: 'a = [,]'
    errors: [
      message: 'Unexpected comma in middle of array.'
      type: 'ArrayExpression'
    ]
  ,
    code: 'a = [ 1,, 2]'
    errors: [
      message: 'Unexpected comma in middle of array.'
      type: 'ArrayExpression'
    ]
  ]
