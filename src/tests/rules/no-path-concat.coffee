###*
# @fileoverview Disallow string concatenation when using __dirname and __filename
# @author Nicholas C. Zakas
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-path-concat'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-path-concat', rule,
  valid: [
    'fullPath = dirname + "foo.js"'
    'fullPath = __dirname == "foo.js"'
    'if (fullPath is __dirname) then ;'
    'if (__dirname is fullPath) then ;'
  ]

  invalid: [
    code: 'fullPath = __dirname + "/foo.js"'
    errors: [
      message: 'Use path.join() or path.resolve() instead of + to create paths.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'fullPath = __filename + "/foo.js"'
    errors: [
      message: 'Use path.join() or path.resolve() instead of + to create paths.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'fullPath = "/foo.js" + __filename'
    errors: [
      message: 'Use path.join() or path.resolve() instead of + to create paths.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'fullPath = "/foo.js" + __dirname'
    errors: [
      message: 'Use path.join() or path.resolve() instead of + to create paths.'
      type: 'BinaryExpression'
    ]
  ]
