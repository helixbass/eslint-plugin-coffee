###*
# @fileoverview Tests for `no-restricted-syntax` rule
# @author Burak Yigit Kaya
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-restricted-syntax'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-restricted-syntax', rule,
  valid: [
    # string format
    'doSomething()'
  ,
    code: 'foo = 42', options: ['ConditionalExpression']
  ,
    code: 'foo += 42', options: ['VariableDeclaration', 'FunctionExpression']
  ,
    code: 'foo', options: ['Identifier[name="bar"]']
  ,
    code: '{ foo: 1, bar: 2 }', options: ['Property > Literal.key']
  ,
    code: 'foo = (bar, baz) ->'
    options: ['FunctionExpression[params.length>2]']
  ,
    #  object format
    code: 'foo = 42', options: [selector: 'ConditionalExpression']
  ,
    code: '({ foo: 1, bar: 2 })'
    options: [selector: 'Property > Literal.key']
  ,
    code: '({ foo: 1, bar: 2 })'
    options: [
      selector: 'FunctionExpression[params.length>2]'
      message: 'custom error message.'
    ]
  ,
    # https://github.com/eslint/eslint/issues/8733
    code: 'console.log(/a/)', options: ['Literal[regex.flags=/./]']
  ]
  invalid: [
    # string format
    code: 'foo = 41'
    options: ['AssignmentExpression[left.declaration=true]']
    errors: [
      message:
        "Using 'AssignmentExpression[left.declaration=true]' is not allowed."
      type: 'AssignmentExpression'
    ]
  ,
    code: '''
      try
        voila()
      catch e
        oops()
    '''
    options: ['TryStatement', 'CallExpression', 'CatchClause']
    errors: [
      message: "Using 'TryStatement' is not allowed.", type: 'TryStatement'
    ,
      message: "Using 'CallExpression' is not allowed."
      type: 'CallExpression'
    ,
      message: "Using 'CatchClause' is not allowed.", type: 'CatchClause'
    ,
      message: "Using 'CallExpression' is not allowed."
      type: 'CallExpression'
    ]
  ,
    code: 'bar'
    options: ['Identifier[name="bar"]']
    errors: [
      message: 'Using \'Identifier[name="bar"]\' is not allowed.'
      type: 'Identifier'
    ]
  ,
    code: 'bar'
    options: ['Identifier', 'Identifier[name="bar"]']
    errors: [
      message: "Using 'Identifier' is not allowed.", type: 'Identifier'
    ,
      message: 'Using \'Identifier[name="bar"]\' is not allowed.'
      type: 'Identifier'
    ]
  ,
    code: '''
      () =>
        x
        y
    '''
    options: ['ArrowFunctionExpression > BlockStatement']
    errors: [
      message:
        "Using 'ArrowFunctionExpression > BlockStatement' is not allowed."
      type: 'BlockStatement'
    ]
  ,
    code: "({ foo: 1, 'bar': 2 })"
    options: ['Property > Literal.key']
    errors: [
      message: "Using 'Property > Literal.key' is not allowed.", type: 'Literal'
    ]
  ,
    code: 'foo = (bar, baz, qux) ->'
    options: ['FunctionExpression[params.length>2]']
    errors: [
      message: "Using 'FunctionExpression[params.length>2]' is not allowed."
      type: 'FunctionExpression'
    ]
  ,
    # object format
    code: 'foo = 41'
    options: [selector: 'AssignmentExpression[left.declaration=true]']
    errors: [
      message:
        "Using 'AssignmentExpression[left.declaration=true]' is not allowed."
      type: 'AssignmentExpression'
    ]
  ,
    code: 'foo = (bar, baz, qux) ->'
    options: [selector: 'FunctionExpression[params.length>2]']
    errors: [
      message: "Using 'FunctionExpression[params.length>2]' is not allowed."
      type: 'FunctionExpression'
    ]
  ,
    code: 'foo = (bar, baz, qux) ->'
    options: [
      selector: 'FunctionExpression[params.length>2]'
      message: 'custom error message.'
    ]
    errors: [message: 'custom error message.', type: 'FunctionExpression']
  ,
    # with object format, the custom message may contain the string '{{selector}}'
    code: 'foo = (bar, baz, qux) ->'
    options: [
      selector: 'FunctionExpression[params.length>2]'
      message: 'custom message with {{selector}}'
    ]
    errors: [
      message: 'custom message with {{selector}}', type: 'FunctionExpression'
    ]
  ,
    # https://github.com/eslint/eslint/issues/8733
    code: 'console.log(/a/i)'
    options: ['Literal[regex.flags=/./]']
    errors: [
      message: "Using 'Literal[regex.flags=/./]' is not allowed."
      type: 'Literal'
    ]
  ]
