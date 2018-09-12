###*
# @fileoverview Tests for no-implicit-coercion rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-implicit-coercion'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'no-implicit-coercion', rule,
  valid: [
    'Boolean(foo)'
    'foo.indexOf(1) isnt -1'
    'Number(foo)'
    'parseInt(foo)'
    'parseFloat(foo)'
    'String(foo)'
    '!foo'
    '~foo'
    '-foo'
    '+1234'
    '-1234'
    '+Number(lol)'
    '-parseFloat(lol)'
    '2 * foo'
    '1 * 1234'
    '1 * Number(foo)'
    '1 * parseInt(foo)'
    '1 * parseFloat(foo)'
    'Number(foo) * 1'
    'parseInt(foo) * 1'
    'parseFloat(foo) * 1'
    '1 * 1234 * 678 * Number(foo)'
    '1 * 1234 * 678 * parseInt(foo)'
    '1234 * 1 * 678 * Number(foo)'
    '1234 * 1 * Number(foo) * Number(bar)'
    '1234 * 1 * Number(foo) * parseInt(bar)'
    '1234 * 1 * Number(foo) * parseFloat(bar)'
    '1234 * 1 * parseInt(foo) * parseFloat(bar)'
    '1234 * 1 * parseInt(foo) * Number(bar)'
    '1234 * 1 * parseFloat(foo) * Number(bar)'
    '1234 * Number(foo) * 1 * Number(bar)'
    '1234 * parseInt(foo) * 1 * Number(bar)'
    '1234 * parseFloat(foo) * 1 * parseInt(bar)'
    '1234 * parseFloat(foo) * 1 * Number(bar)'
    '1234*foo*1'
    '1234*1*foo'
    '1234*bar*1*foo'
    '1234*1*foo*bar'
    '1234*1*foo*Number(bar)'
    '1234*1*Number(foo)*bar'
    '1234*1*parseInt(foo)*bar'
    '0 + foo'
    '~foo.bar()'
    "foo + 'bar'"
  ,
    code: 'foo + "#{bar}"', parserOptions: ecmaVersion: 6
  ,
    code: '!!foo', options: [boolean: no]
  ,
    code: '~foo.indexOf(1)', options: [boolean: no]
  ,
    code: '+foo', options: [number: no]
  ,
    code: '1*foo', options: [number: no]
  ,
    code: '""+foo', options: [string: no]
  ,
    code: 'foo += ""', options: [string: no]
  ,
    code: 'a = !!foo', options: [boolean: yes, allow: ['!!']]
  ,
    code: 'a = ~foo.indexOf(1)', options: [boolean: yes, allow: ['~']]
  ,
    code: 'a = ~foo', options: [boolean: yes]
  ,
    code: 'a = 1 * foo', options: [boolean: yes, allow: ['*']]
  ,
    code: 'a = +foo', options: [boolean: yes, allow: ['+']]
  ,
    code: 'a = "" + foo'
    options: [boolean: yes, string: yes, allow: ['+']]
  ,
    # https://github.com/eslint/eslint/issues/7057
    "'' + 'foo'"
  ,
    code: "'' + 'foo'"
  ,
    code: '"" + "#{foo}"'
  ,
    "'foo' + ''"
  ,
    code: "'foo' + ''"
  ,
    code: '"#{foo}" + ""'
  ,
    "foo += 'bar'"
  ,
    code: 'foo += "#{bar}"'
  ,
    '+42'
  ]
  invalid: [
    code: '!!foo'
    output: 'Boolean(foo)'
    errors: [message: 'use `Boolean(foo)` instead.', type: 'UnaryExpression']
  ,
    code: '!!(foo + bar)'
    output: 'Boolean(foo + bar)'
    errors: [
      message: 'use `Boolean(foo + bar)` instead.', type: 'UnaryExpression'
    ]
  ,
    code: '~foo.indexOf(1)'
    output: null
    errors: [
      message: 'use `foo.indexOf(1) isnt -1` instead.', type: 'UnaryExpression'
    ]
  ,
    code: '~foo.bar.indexOf(2)'
    output: null
    errors: [
      message: 'use `foo.bar.indexOf(2) isnt -1` instead.'
      type: 'UnaryExpression'
    ]
  ,
    code: '+foo'
    output: 'Number(foo)'
    errors: [message: 'use `Number(foo)` instead.', type: 'UnaryExpression']
  ,
    code: '+foo.bar'
    output: 'Number(foo.bar)'
    errors: [
      message: 'use `Number(foo.bar)` instead.', type: 'UnaryExpression'
    ]
  ,
    code: '1*foo'
    output: 'Number(foo)'
    errors: [message: 'use `Number(foo)` instead.', type: 'BinaryExpression']
  ,
    code: 'foo*1'
    output: 'Number(foo)'
    errors: [message: 'use `Number(foo)` instead.', type: 'BinaryExpression']
  ,
    code: '1*foo.bar'
    output: 'Number(foo.bar)'
    errors: [
      message: 'use `Number(foo.bar)` instead.', type: 'BinaryExpression'
    ]
  ,
    code: '""+foo'
    output: 'String(foo)'
    errors: [message: 'use `String(foo)` instead.', type: 'BinaryExpression']
  ,
    code: 'foo+""'
    output: 'String(foo)'
    errors: [message: 'use `String(foo)` instead.', type: 'BinaryExpression']
  ,
    code: '""+foo.bar'
    output: 'String(foo.bar)'
    errors: [
      message: 'use `String(foo.bar)` instead.', type: 'BinaryExpression'
    ]
  ,
    code: 'foo.bar+""'
    output: 'String(foo.bar)'
    errors: [
      message: 'use `String(foo.bar)` instead.', type: 'BinaryExpression'
    ]
  ,
    code: 'foo += ""'
    output: 'foo = String(foo)'
    errors: [
      message: 'use `foo = String(foo)` instead.', type: 'AssignmentExpression'
    ]
  ,
    code: 'a = !!foo'
    output: 'a = Boolean(foo)'
    options: [boolean: yes, allow: ['~']]
    errors: [message: 'use `Boolean(foo)` instead.', type: 'UnaryExpression']
  ,
    code: 'a = ~foo.indexOf(1)'
    output: null
    options: [boolean: yes, allow: ['!!']]
    errors: [
      message: 'use `foo.indexOf(1) isnt -1` instead.', type: 'UnaryExpression'
    ]
  ,
    code: 'a = 1 * foo'
    output: 'a = Number(foo)'
    options: [boolean: yes, allow: ['+']]
    errors: [message: 'use `Number(foo)` instead.', type: 'BinaryExpression']
  ,
    code: 'a = +foo'
    output: 'a = Number(foo)'
    options: [boolean: yes, allow: ['*']]
    errors: [message: 'use `Number(foo)` instead.', type: 'UnaryExpression']
  ,
    code: 'a = "" + foo'
    output: 'a = String(foo)'
    options: [boolean: yes, allow: ['*']]
    errors: [message: 'use `String(foo)` instead.', type: 'BinaryExpression']
  ,
    code: 'typeof+foo'
    output: 'typeof Number(foo)'
    errors: [message: 'use `Number(foo)` instead.', type: 'UnaryExpression']
  ,
    code: 'typeof +foo'
    output: 'typeof Number(foo)'
    errors: [message: 'use `Number(foo)` instead.', type: 'UnaryExpression']
  ]
