###*
# @fileoverview Tests for the no-new-object rule
# @author Matt DuVall <http://www.mattduvall.com/>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-new-object'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-new-object', rule,
  valid: ['foo = new foo.Object()']
  invalid: [
    code: 'foo = new Object()'
    errors: [
      message: 'The object literal notation {} is preferrable.'
      type: 'NewExpression'
    ]
  ]
