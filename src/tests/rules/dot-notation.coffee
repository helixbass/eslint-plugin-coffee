###*
# @fileoverview Tests for dot-notation rule.
# @author Josh Perez
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/dot-notation'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

###*
# Quote a string in "double quotes" because it’s painful
# with a double-quoted string literal
# @param   {string} str The string to quote
# @returns {string}     `"${str}"`
###
q = (str) -> "\"#{str}\""

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'dot-notation', rule,
  valid: [
    'a.b'
    'a.b.c'
    "a['12']"
    'a[b]'
    'a[0]'
  ,
    code: 'a.b.c', options: [allowKeywords: no]
  ,
    code: 'a.arguments', options: [allowKeywords: no]
  ,
    code: 'a.let', options: [allowKeywords: no]
  ,
    code: 'a.yield', options: [allowKeywords: no]
  ,
    code: 'a.eval', options: [allowKeywords: no]
  ,
    code: 'a[0]', options: [allowKeywords: no]
  ,
    code: "a['while']", options: [allowKeywords: no]
  ,
    code: "a['true']", options: [allowKeywords: no]
  ,
    code: "a['null']", options: [allowKeywords: no]
  ,
    code: 'a[true]', options: [allowKeywords: no]
  ,
    code: 'a[null]', options: [allowKeywords: no]
  ,
    code: 'a.true', options: [allowKeywords: yes]
  ,
    code: 'a.null', options: [allowKeywords: yes]
  ,
    code: "a['snake_case']", options: [allowPattern: '^[a-z]+(_[a-z]+)+$']
  ,
    code: "a['lots_of_snake_case']"
    options: [allowPattern: '^[a-z]+(_[a-z]+)+$']
  ,
    'a["time#{range}"]'
  ,
    code: 'a["""while"""]'
    options: [allowKeywords: no]
  ,
    'a["time range"]'
    'a.true'
    'a.null'
    'a[undefined]'
    'a[b()]'
  ]
  invalid: [
    code: 'a.true'
    output: 'a["true"]'
    options: [allowKeywords: no]
    errors: [messageId: 'useBrackets', data: key: 'true']
  ,
    code: "a['true']"
    output: 'a.true'
    errors: [messageId: 'useDot', data: key: q 'true']
  ,
    code: 'a["time"]'
    output: 'a.time'
    errors: [messageId: 'useDot', data: key: '"time"']
  ,
    code: 'a[null]'
    output: 'a.null'
    errors: [messageId: 'useDot', data: key: 'null']
  ,
    code: "a['b']"
    output: 'a.b'
    errors: [messageId: 'useDot', data: key: q 'b']
  ,
    code: "a.b['c']"
    output: 'a.b.c'
    errors: [messageId: 'useDot', data: key: q 'c']
  ,
    code: "a['_dangle']"
    output: 'a._dangle'
    options: [allowPattern: '^[a-z]+(_[a-z]+)+$']
    errors: [messageId: 'useDot', data: key: q '_dangle']
  ,
    code: "a['SHOUT_CASE']"
    output: 'a.SHOUT_CASE'
    options: [allowPattern: '^[a-z]+(_[a-z]+)+$']
    errors: [messageId: 'useDot', data: key: q 'SHOUT_CASE']
  ,
    code: '''
        getResource()
            .then(->)["catch"](->)
            .then(->)["catch"](->)
      '''
    output: '''
        getResource()
            .then(->).catch(->)
            .then(->).catch(->)
      '''
    errors: [
      messageId: 'useDot'
      data: key: q('catch')
      line: 2
      column: 15
    ,
      messageId: 'useDot'
      data: key: q('catch')
      line: 3
      column: 15
    ]
  ,
    # ,
    #   code:
    #     'foo\n' + '  .while'
    #   output:
    #     'foo\n' + '  ["while"]'
    #   options: [allowKeywords: no]
    #   errors: [messageId: 'useBrackets', data: key: 'while']
    code: "foo[ ### comment ### 'bar' ]"
    output: null # Not fixed due to comment
    errors: [messageId: 'useDot', data: key: q 'bar']
  ,
    code: "foo[ 'bar' ### comment ### ]"
    output: null # Not fixed due to comment
    errors: [messageId: 'useDot', data: key: q 'bar']
  ,
    code: "foo[    'bar'    ]"
    output: 'foo.bar'
    errors: [messageId: 'useDot', data: key: q 'bar']
  ,
    code: 'foo. ### comment ### while'
    output: null # Not fixed due to comment
    options: [allowKeywords: no]
    errors: [messageId: 'useBrackets', data: key: 'while']
  ,
    code: "foo[('bar')]"
    output: 'foo.bar'
    errors: [messageId: 'useDot', data: key: q 'bar']
  ,
    code: 'foo[(null)]'
    output: 'foo.null'
    errors: [messageId: 'useDot', data: key: 'null']
  ,
    code: "(foo)['bar']"
    output: '(foo).bar'
    errors: [messageId: 'useDot', data: key: q 'bar']
  ,
    code: "1['toString']"
    output: '1 .toString'
    errors: [messageId: 'useDot', data: key: q 'toString']
  ,
    code: "foo['bar']instanceof baz"
    output: 'foo.bar instanceof baz'
    errors: [messageId: 'useDot', data: key: q 'bar']
  ]
