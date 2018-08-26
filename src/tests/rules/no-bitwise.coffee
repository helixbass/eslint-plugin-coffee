###*
# @fileoverview Tests for no-bitwise rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-bitwise'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-bitwise', rule,
  valid: [
    'a + b'
    '!a'
    'a += b'
  ,
    code: '~[1, 2, 3].indexOf(1)', options: [allow: ['~']]
  ,
    code: '~1<<2 is -8', options: [allow: ['~', '<<']]
  ,
    code: '~1<<2 == -8', options: [allow: ['~', '<<']]
  ,
    code: 'a|0', options: [int32Hint: yes]
  ,
    code: 'a|0', options: [allow: ['|'], int32Hint: no]
  ]
  invalid: [
    code: 'a ^ b'
    errors: [
      messageId: 'unexpected', data: {operator: '^'}, type: 'BinaryExpression'
    ]
  ,
    code: 'a | b'
    errors: [
      messageId: 'unexpected', data: {operator: '|'}, type: 'BinaryExpression'
    ]
  ,
    code: 'a & b'
    errors: [
      messageId: 'unexpected', data: {operator: '&'}, type: 'BinaryExpression'
    ]
  ,
    code: 'a << b'
    errors: [
      messageId: 'unexpected', data: {operator: '<<'}, type: 'BinaryExpression'
    ]
  ,
    code: 'a >> b'
    errors: [
      messageId: 'unexpected', data: {operator: '>>'}, type: 'BinaryExpression'
    ]
  ,
    code: 'a >>> b'
    errors: [
      messageId: 'unexpected', data: {operator: '>>>'}, type: 'BinaryExpression'
    ]
  ,
    code: '~a'
    errors: [
      messageId: 'unexpected', data: {operator: '~'}, type: 'UnaryExpression'
    ]
  ,
    code: 'a ^= b'
    errors: [
      messageId: 'unexpected'
      data: operator: '^='
      type: 'AssignmentExpression'
    ]
  ,
    code: 'a |= b'
    errors: [
      messageId: 'unexpected'
      data: operator: '|='
      type: 'AssignmentExpression'
    ]
  ,
    code: 'a &= b'
    errors: [
      messageId: 'unexpected'
      data: operator: '&='
      type: 'AssignmentExpression'
    ]
  ,
    code: 'a <<= b'
    errors: [
      messageId: 'unexpected'
      data: operator: '<<='
      type: 'AssignmentExpression'
    ]
  ,
    code: 'a >>= b'
    errors: [
      messageId: 'unexpected'
      data: operator: '>>='
      type: 'AssignmentExpression'
    ]
  ,
    code: 'a >>>= b'
    errors: [
      messageId: 'unexpected'
      data: operator: '>>>='
      type: 'AssignmentExpression'
    ]
  ]
