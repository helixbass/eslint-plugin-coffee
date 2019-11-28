###*
# @fileoverview Warn when using template string syntax in regular strings.
# @author Jeroen Engels
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-template-curly-in-string'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

message = 'Unexpected template string expression.'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'no-template-curly-in-string', rule,
  valid: [
    '"Hello, #{name}"'
    '"Hello, ${name}"'
    "'Hello, ${name}'"
    '"""Hello, #{name}"""'
    'templateFunction"Hello, #{name}"'
    'templateFunction"""Hello, #{name}"""'
    '"Hello, name"'
    '"""Hello, name"""'
    "'Hello, name'"
    "'''Hello, name'''"
    "'Hello, ' + name"
    '"Hello, #{index + 1}"'
    '"Hello, #{name + " foo"}"'
    '"Hello, #{name or "foo"}"'
    '"Hello, #{{foo: "bar"}.foo}"'
    "'#2'"
    '''
      '#{'
    '''
    "'#}'"
    "'{foo}'"
    '\'{foo: "bar"}\''
    'number = 3'
    '''
      """Hello, \#{name}"""
    '''
  ]
  invalid: [
    code: '''
      'Hello, #{name}'
    '''
    errors: [{message}]
  ,
    code: '''
      \'\'\'Hello, #{name}\'\'\'
    '''
    errors: [{message}]
  ,
    code: '''
      '#{greeting}, #{name}'
    '''
    errors: [{message}]
  ,
    code: '''
      'Hello, #{index + 1}'
    '''
    errors: [{message}]
  ,
    code: '''
      'Hello, #{name + " foo"}'
    '''
    errors: [{message}]
  ,
    code: '''
      'Hello, #{name || "foo"}'
    '''
    errors: [{message}]
  ,
    code: '''
      'Hello, #{{foo: "bar"}.foo}'
    '''
    errors: [{message}]
  ]
