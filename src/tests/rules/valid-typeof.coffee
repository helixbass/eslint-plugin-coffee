###*
# @fileoverview Ensures that the results of typeof are compared against a valid string
# @author Ian Christian Myers
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/valid-typeof'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'valid-typeof', rule,
  valid: [
    "typeof foo is 'string'"
    "typeof foo is 'object'"
    "typeof foo is 'function'"
    "typeof foo is 'undefined'"
    "typeof foo is 'boolean'"
    "typeof foo is 'number'"
    "'string' is typeof foo"
    "'object' is typeof foo"
    "'function' is typeof foo"
    "'undefined' is typeof foo"
    "'boolean' is typeof foo"
    "'number' is typeof foo"
    'typeof foo is typeof bar'
    'typeof foo is baz'
    'typeof foo isnt someType'
    'typeof bar != someType'
    'someType is typeof bar'
    'someType == typeof bar'
    "typeof foo == 'string'"
    "typeof(foo) is 'string'"
    "typeof(foo) isnt 'string'"
    "typeof(foo) == 'string'"
    "typeof(foo) != 'string'"
    "oddUse = typeof foo + 'thing'"
  ,
    code: "typeof foo is 'number'"
    options: [requireStringLiterals: yes]
  ,
    code: 'typeof foo is "number"'
    options: [requireStringLiterals: yes]
  ,
    code: "baz = typeof foo + 'thing'"
    options: [requireStringLiterals: yes]
  ,
    code: 'typeof foo is typeof bar'
    options: [requireStringLiterals: yes]
  ,
    code: 'typeof foo is "string"'
    options: [requireStringLiterals: yes]
  ,
    code: '"object" is typeof foo'
    options: [requireStringLiterals: yes]
  ,
    code: 'typeof foo is "str#{somethingElse}"'
  ]

  invalid: [
    code: "typeof foo is 'strnig'"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "'strnig' is typeof foo"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "if (typeof bar is 'umdefined') then ;"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "typeof foo isnt 'strnig'"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "'strnig' isnt typeof foo"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "if (typeof bar isnt 'umdefined') then ;"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "typeof foo != 'strnig'"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "'strnig' != typeof foo"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "if (typeof bar != 'umdefined') then ;"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "typeof foo == 'strnig'"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "'strnig' == typeof foo"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "if (typeof bar == 'umdefined') then ;"
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: "typeof foo == 'invalid string'"
    options: [requireStringLiterals: yes]
    errors: [message: 'Invalid typeof comparison value.', type: 'Literal']
  ,
    code: 'typeof foo == Object'
    options: [requireStringLiterals: yes]
    errors: [
      message: 'Typeof comparisons should be to string literals.'
      type: 'Identifier'
    ]
  ,
    code: 'typeof foo is undefined'
    options: [requireStringLiterals: yes]
    errors: [
      message: 'Typeof comparisons should be to string literals.'
      type: 'Identifier'
    ]
  ,
    code: 'undefined is typeof foo'
    options: [requireStringLiterals: yes]
    errors: [
      message: 'Typeof comparisons should be to string literals.'
      type: 'Identifier'
    ]
  ,
    code: 'undefined == typeof foo'
    options: [requireStringLiterals: yes]
    errors: [
      message: 'Typeof comparisons should be to string literals.'
      type: 'Identifier'
    ]
  ,
    code: 'typeof foo is "undefined#{foo}"'
    options: [requireStringLiterals: yes]
    errors: [
      message: 'Typeof comparisons should be to string literals.'
      type: 'TemplateLiteral'
    ]
  ,
    code: 'typeof foo is "#{string}"'
    options: [requireStringLiterals: yes]
    errors: [
      message: 'Typeof comparisons should be to string literals.'
      type: 'TemplateLiteral'
    ]
  ]
