###*
# @fileoverview Tests for no-empty-function rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-empty-function'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ALLOW_OPTIONS = Object.freeze [
  'functions'
  'methods'
  # 'getters'
  # 'setters'
  'constructors'
]

###*
# Folds test items to `{valid: [], invalid: []}`.
# One item would be converted to 4 valid patterns and 8 invalid patterns.
#
# @param {{valid: object[], invalid: object[]}} patterns - The result.
# @param {{code: string, message: string, allow: string}} item - A test item.
# @returns {{valid: object[], invalid: object[]}} The result.
###
toValidInvalid = (patterns, item) ->
  # Valid Patterns
  patterns.valid.push
    code: item.code.replace('->', '-> bar()')
  ,
    code: item.code.replace('->', '-> ### empty ###')
  ,
    code: item.code.replace('->', '->\n      # empty\n')
  ,
    code: "#{item.code}\n# allow: #{item.allow}"
    options: [allow: [item.allow]]

  error = item.message or messageId: item.messageId, data: item.data

  # Invalid Patterns.
  patterns.invalid.push
    code: item.code
    errors: [error]
  ALLOW_OPTIONS.filter((allow) -> allow isnt item.allow).forEach (allow) ->
    # non related "allow" option has no effect.
    patterns.invalid.push
      code: "#{item.code}\n# allow: #{allow}"
      errors: [error]
      options: [allow: [allow]]

  patterns

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run(
  'no-empty-function'
  rule
  [
    code: 'foo = ->'
    messageId: 'unexpected'
    data: name: 'function'
    allow: 'functions'
  ,
    code: '''
      obj =
        foo: ->
    '''
    messageId: 'unexpected'
    data: name: "method 'foo'"
    allow: 'methods'
  ,
    code: '''
      class A
        foo: ->
    '''
    messageId: 'unexpected'
    data: name: "method 'foo'"
    allow: 'methods'
  ,
    code: '''
      class A
        @foo: ->
    '''
    messageId: 'unexpected'
    data: name: "static method 'foo'"
    allow: 'methods'
  ,
    code: '''
      A = class
        foo: ->
    '''
    messageId: 'unexpected'
    data: name: "method 'foo'"
    allow: 'methods'
  ,
    code: '''
      A = class
        @foo: ->
    '''
    messageId: 'unexpected'
    data: name: "static method 'foo'"
    allow: 'methods'
  ,
    # ,
    #   code: 'var obj = {get foo() {}};'
    #   messageId: 'unexpected'
    #   data: name: "getter 'foo'"
    #   allow: 'getters'
    # ,
    #   code: 'class A {get foo() {}}'
    #   messageId: 'unexpected'
    #   data: name: "getter 'foo'"
    #   allow: 'getters'
    # ,
    #   code: 'class A {static get foo() {}}'
    #   messageId: 'unexpected'
    #   data: name: "static getter 'foo'"
    #   allow: 'getters'
    # ,
    #   code: 'var A = class {get foo() {}};'
    #   messageId: 'unexpected'
    #   data: name: "getter 'foo'"
    #   allow: 'getters'
    # ,
    #   code: 'var A = class {static get foo() {}};'
    #   messageId: 'unexpected'
    #   data: name: "static getter 'foo'"
    #   allow: 'getters'
    # ,
    #   code: 'var obj = {set foo(value) {}};'
    #   messageId: 'unexpected'
    #   data: name: "setter 'foo'"
    #   allow: 'setters'
    # ,
    #   code: 'class A {set foo(value) {}}'
    #   messageId: 'unexpected'
    #   data: name: "setter 'foo'"
    #   allow: 'setters'
    # ,
    #   code: 'class A {static set foo(value) {}}'
    #   messageId: 'unexpected'
    #   data: name: "static setter 'foo'"
    #   allow: 'setters'
    # ,
    #   code: 'var A = class {set foo(value) {}};'
    #   messageId: 'unexpected'
    #   data: name: "setter 'foo'"
    #   allow: 'setters'
    # ,
    #   code: 'var A = class {static set foo(value) {}};'
    #   messageId: 'unexpected'
    #   data: name: "static setter 'foo'"
    #   allow: 'setters'
    code: '''
      class A
        constructor: ->
    '''
    messageId: 'unexpected'
    data: name: 'constructor'
    allow: 'constructors'
  ,
    code: '''
      A = class
        constructor: ->
    '''
    messageId: 'unexpected'
    data: name: 'constructor'
    allow: 'constructors'
  ].reduce toValidInvalid,
    valid: [code: 'foo = () => 0']
    invalid: []
)
