###*
# @fileoverview Disallow the use of process.exit()
# @author Nicholas C. Zakas
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-process-exit'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-process-exit', rule,
  valid: ['Process.exit()', 'exit = process.exit', 'f(process.exit)']

  invalid: [
    code: 'process.exit(0)'
    errors: [
      message: "Don't use process.exit(); throw an error instead."
      type: 'CallExpression'
    ]
  ,
    code: 'process.exit(1)'
    errors: [
      message: "Don't use process.exit(); throw an error instead."
      type: 'CallExpression'
    ]
  ,
    code: 'f(process.exit(1))'
    errors: [
      message: "Don't use process.exit(); throw an error instead."
      type: 'CallExpression'
    ]
  ]
