###*
# @fileoverview Tests for no-sync.
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-sync'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-sync', rule,
  valid: [
    'foo = fs.foo.foo()'
  ,
    code: 'foo = fs.fooSync', options: [allowAtRootLevel: yes]
  ,
    code: 'if (true) then fs.fooSync()', options: [allowAtRootLevel: yes]
  ]
  invalid: [
    code: 'foo = fs.fooSync()'
    errors: [
      message: "Unexpected sync method: 'fooSync'.", type: 'MemberExpression'
    ]
  ,
    code: 'foo = fs.fooSync()'
    options: [allowAtRootLevel: no]
    errors: [
      message: "Unexpected sync method: 'fooSync'.", type: 'MemberExpression'
    ]
  ,
    code: 'fs.fooSync() if yes'
    errors: [
      message: "Unexpected sync method: 'fooSync'.", type: 'MemberExpression'
    ]
  ,
    code: 'foo = fs.fooSync'
    errors: [
      message: "Unexpected sync method: 'fooSync'.", type: 'MemberExpression'
    ]
  ,
    code: 'someFunction = -> fs.fooSync()'
    errors: [
      message: "Unexpected sync method: 'fooSync'.", type: 'MemberExpression'
    ]
  ,
    code: 'someFunction = -> fs.fooSync()'
    options: [allowAtRootLevel: yes]
    errors: [
      message: "Unexpected sync method: 'fooSync'.", type: 'MemberExpression'
    ]
  ,
    code: '-> fs.fooSync()'
    options: [allowAtRootLevel: yes]
    errors: [
      message: "Unexpected sync method: 'fooSync'.", type: 'MemberExpression'
    ]
  ]
