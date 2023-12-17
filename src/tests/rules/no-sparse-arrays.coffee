###*
# @fileoverview Disallow sparse arrays
# @author Nicholas C. Zakas
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-sparse-arrays'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

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
