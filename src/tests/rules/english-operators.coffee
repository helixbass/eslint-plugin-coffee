###*
# @fileoverview This rule should require or disallow usage of "English" operators.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/english-operators'
{RuleTester} = require 'eslint'

error = (op, {args} = {}) ->
  {
    type:
      switch op
        when '!', 'not'
          'UnaryExpression'
        when '&&', '||', 'and', 'or'
          'LogicalExpression'
        else
          'BinaryExpression'
    ...args
  }

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'english-operators', rule,
  valid: [
    'a and b'
    'a or b'
    'a is b'
    'a isnt b'
    'not a'
    '!!a'
    '"&&"'
    '# &&'
    'a + b'
  ,
    code: 'a && b'
    options: ['never']
  ,
    code: 'a || b'
    options: ['never']
  ,
    code: 'a == b'
    options: ['never']
  ,
    code: 'a != b'
    options: ['never']
  ,
    code: '!a'
    options: ['never']
  ,
    code: '!!a'
    options: ['never']
  ]

  invalid: [
    code: 'a && b'
    errors: [error '&&', message: "Prefer the usage of 'and' over '&&'"]
  ,
    code: 'a && b || c'
    errors: [error('&&'), error('||')]
  ,
    code: 'a == b'
    errors: [error '==']
  ,
    code: 'a != b'
    errors: [error '!=']
  ,
    code: '!a'
    errors: [error '!']
  ,
    code: 'a and b'
    options: ['never']
    errors: [error 'and']
  ,
    code: 'a or b'
    options: ['never']
    errors: [error 'or']
  ,
    code: 'a is b'
    options: ['never']
    errors: [error 'is']
  ,
    code: 'a isnt b'
    options: ['never']
    errors: [error 'isnt']
  ,
    code: 'not a'
    options: ['never']
    errors: [error 'not']
  ]
