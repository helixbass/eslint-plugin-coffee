###*
# @fileoverview Tests for no-dupe-keys rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-dupe-keys'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-dupe-keys', rule,
  valid: [
    'foo = { __proto__: 1, two: 2}'
    'x = foo: 1, bar: 2'
    # '+{ get a() { }, set a(b) { } };'
    'x = { a: b, [a]: b }'
    'x = { a: b, ...c }'
    # ,
    #   code: 'var x = { get a() {}, set a (value) {} };'
    #   parserOptions: ecmaVersion: 6
    'x = a: 1, b: { a: 2 }'
    '{a, a} = obj'
  ]
  invalid: [
    code: "x = { a: b, ['a']: b }"
    errors: [
      messageId: 'unexpected', data: {name: 'a'}, type: 'ObjectExpression'
    ]
  ,
    code: 'x = { y: 1, y: 2 }'
    errors: [
      messageId: 'unexpected', data: {name: 'y'}, type: 'ObjectExpression'
    ]
  ,
    code: 'foo = { 0x1: 1, 1: 2};'
    errors: [
      messageId: 'unexpected', data: {name: '1'}, type: 'ObjectExpression'
    ]
  ,
    code: 'x = { "z": 1, z: 2 }'
    errors: [
      messageId: 'unexpected', data: {name: 'z'}, type: 'ObjectExpression'
    ]
  ,
    code: '''
      foo = {
        bar: 1
        bar: 1
      }
    '''
    errors: [messageId: 'unexpected', data: {name: 'bar'}, line: 3, column: 3]
    # ,
    #   code: 'var x = { a: 1, get a() {} };'
    #   parserOptions: ecmaVersion: 6
    #   errors: [
    #     messageId: 'unexpected', data: {name: 'a'}, type: 'ObjectExpression'
    #   ]
    # ,
    #   code: 'var x = { a: 1, set a(value) {} };'
    #   parserOptions: ecmaVersion: 6
    #   errors: [
    #     messageId: 'unexpected', data: {name: 'a'}, type: 'ObjectExpression'
    #   ]
    # ,
    #   code: 'var x = { a: 1, b: { a: 2 }, get b() {} };'
    #   parserOptions: ecmaVersion: 6
    #   errors: [
    #     messageId: 'unexpected', data: {name: 'b'}, type: 'ObjectExpression'
    #   ]
  ]
