###*
# @fileoverview Tests for no-throw-literal rule.
# @author Dieter Oberkofler
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-throw-literal'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'no-throw-literal', rule,
  valid: [
    'throw new Error()'
    "throw new Error('error')"
    "throw Error('error')"
    '''
      e = new Error()
      throw e
    '''
    '''
      try
        throw new Error()
      catch e
        throw e
    '''
    'throw a' # Identifier
    'throw foo()' # CallExpression
    'throw new foo()' # NewExpression
    'throw foo.bar' # MemberExpression
    'throw foo[bar]' # MemberExpression
    'throw foo = new Error()' # AssignmentExpression
    'throw (1; 2; new Error())' # SequenceExpression
    "throw 'literal' && new Error()" # LogicalExpression (right)
    "throw new Error() || 'literal'" # LogicalExpression (left)
    "throw if foo then new Error() else 'literal'" # ConditionalExpression (consequent)
    "throw if foo then 'literal' else new Error()" # ConditionalExpression (alternate)
  ,
    code: 'throw tag"#{foo}"' # TaggedTemplateExpression
  ,
    code: '''
      ->
        index = 0
        throw yield index++
    ''' # YieldExpression
  ,
    code: '-> throw await bar' # AwaitExpression
  ]
  invalid: [
    code: "throw 'error'"
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    code: 'throw 0'
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    code: 'throw false'
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    code: 'throw null'
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    code: 'throw undefined'
    errors: [
      message: 'Do not throw undefined.'
      type: 'ThrowStatement'
    ]
  ,
    # String concatenation
    code: "throw 'a' + 'b'"
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    code: """
      b = new Error()
      throw 'a' + b
    """
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    # AssignmentExpression
    code: "throw foo = 'error'"
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    # SequenceExpression
    code: 'throw (new Error(); 1; 2; 3)'
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    # LogicalExpression
    code: "throw 'literal' and 'not an Error'"
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    # ConditionalExpression
    code: "throw if foo then 'not an Error' else 'literal'"
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ,
    # TemplateLiteral
    code: 'throw "#{err}"'
    errors: [
      message: 'Expected an error object to be thrown.'
      type: 'ThrowStatement'
    ]
  ]
