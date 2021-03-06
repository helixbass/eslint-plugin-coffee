###*
# @fileoverview Tests for no-negated-condition rule.
# @author Alberto Rodríguez
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-negated-condition'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-negated-condition', rule,
  # Examples of code that should not trigger the rule
  valid: [
    'if (a) then ;'
    'if (a) then ; else ;'
  ,
    code: 'if (!a) then ;'
    options: [requireElse: yes]
  ,
    code: 'x if (!a)'
    options: [requireElse: yes]
  ,
    code: 'if (!a) then ; else if (b) then ;'
    options: [requireElse: yes]
  ,
    code: 'if (!a) then ; else if (b) then ; else ;'
    options: [requireElse: yes]
  ,
    'if (a == b) then ;'
    'if (a == b) then ; else ;'
  ,
    code: 'if (a != b) then ;'
    options: [requireElse: yes]
  ,
    code: 'if (a != b) then ; else if (b) then ;'
    options: [requireElse: yes]
  ,
    code: 'if (a != b) then ; else if (b) then ; else ;'
    options: [requireElse: yes]
  ,
    code: 'if (a isnt b) then ;'
    options: [requireElse: yes]
  ,
    'if (a is b) then ; else ;'
    '(if a then b else c)'
    'unless (a) then ;'
    'unless (a) then ; else ;'
  ,
    code: 'unless (!a) then ;'
    options: [requireElse: yes]
  ,
    code: 'x unless (!a)'
    options: [requireElse: yes]
  ,
    code: 'unless (!a) then ; else if (b) then ;'
    options: [requireElse: yes]
  ,
    code: 'unless (!a) then ; else if (b) then ; else ;'
    options: [requireElse: yes]
  ,
    'unless (a == b) then ;'
    'unless (a == b) then ; else ;'
  ,
    code: 'unless (a != b) then ;'
    options: [requireElse: yes]
  ,
    code: 'unless (a != b) then ; else if (b) then ;'
    options: [requireElse: yes]
  ,
    code: 'unless (a != b) then ; else if (b) then ; else ;'
    options: [requireElse: yes]
  ,
    code: 'unless (a isnt b) then ;'
    options: [requireElse: yes]
  ,
    'unless (a is b) then ; else ;'
    '(unless a then b else c)'
  ]

  # Examples of code that should trigger the rule
  invalid: [
    code: 'if (!a) then ; else ;'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (a != b) then ; else ;'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (a isnt b) then ; else ;'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: '(if !a then b else c)'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: '(if a != b then c else d)'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: '(if a isnt b then c else d)'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: 'if (!a) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (!a) then ; else if (b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (!a) then ; else if (b) then ; else ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (a != b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (a != b) then ; else if (b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (a != b) then ; else if (b) then ; else ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'if (a isnt b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'x if (a isnt b)'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: '(if (a isnt b) then c)'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: '(x if (a isnt b))'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: 'unless (!a) then ; else ;'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (a != b) then ; else ;'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (a isnt b) then ; else ;'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: '(unless !a then b else c)'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: '(unless a != b then c else d)'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: '(unless a isnt b then c else d)'
    options: [requireElse: yes]
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: 'unless (!a) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (!a) then ; else if (b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (!a) then ; else if (b) then ; else ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (a != b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (a != b) then ; else if (b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (a != b) then ; else if (b) then ; else ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'x unless (a isnt b)'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: 'unless (a isnt b) then ;'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'IfStatement'
    ]
  ,
    code: '(unless (a isnt b) then c)'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ,
    code: '(x unless (a isnt b))'
    errors: [
      message: 'Unexpected negated condition.'
      type: 'ConditionalExpression'
    ]
  ]
