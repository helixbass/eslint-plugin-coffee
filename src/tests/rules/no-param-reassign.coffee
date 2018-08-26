###*
# @fileoverview Disallow reassignment of function parameters.
# @author Nat Burns
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-param-reassign'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-param-reassign', rule,
  valid: [
    '(a) -> b = a'
    "(a) -> a.prop = 'value'"
    '(a) -> a.b = 0'
    '(a) -> delete a.b'
    '(a) -> ++a.b'
    '(a) -> [a.b] = []'
  ,
    code: '(a) -> bar(a.b).c = 0', options: [props: yes]
  ,
    code: '(a) -> data[a.b] = 0', options: [props: yes]
  ,
    code: '(a) -> +a.b', options: [props: yes]
  ,
    code: '(a) -> a.b = 0'
    options: [props: yes, ignorePropertyModificationsFor: ['a']]
  ,
    code: '(a) -> ++a.b'
    options: [props: yes, ignorePropertyModificationsFor: ['a']]
  ,
    code: '(a) -> delete a.b'
    options: [props: yes, ignorePropertyModificationsFor: ['a']]
  ,
    code: '''
      (a, z) ->
        a.b = 0
        x.y = 0
    '''
    options: [props: yes, ignorePropertyModificationsFor: ['a', 'x']]
  ,
    code: '(a) -> a.b.c = 0'
    options: [props: yes, ignorePropertyModificationsFor: ['a']]
  ,
    code: '(a) -> { [a]: variable } = value'
    options: [props: yes]
  ,
    code: '(a) -> [...a.b] = obj'
    options: [props: no]
  ,
    code: '(a) -> {...a.b} = obj'
    options: [props: no]
  ]

  invalid: [
    code: '(bar) -> bar = 13'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> bar += 13'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    # code: '(bar) -> do -> bar = 13'
    code: '(bar) -> (-> bar = 13)()'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> ++bar'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> bar++'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> --bar'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> bar--'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '({bar}) -> bar = 13'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '([, {bar}]) -> bar = 13'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> {bar} = {}'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> {x: [, bar = 0]} = {}'
    errors: [message: "Assignment to function parameter 'bar'."]
  ,
    code: '(bar) -> bar.a = 0'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'bar'."]
  ,
    code: '(bar) -> bar.get(0).a = 0'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'bar'."]
  ,
    code: '(bar) -> delete bar.a'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'bar'."]
  ,
    code: '(bar) -> ++bar.a'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'bar'."]
  ,
    code: '(bar) -> [bar.a] = []'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'bar'."]
  ,
    code: '(bar) -> [bar.a] = []'
    options: [props: yes, ignorePropertyModificationsFor: ['a']]
    errors: [message: "Assignment to property of function parameter 'bar'."]
  ,
    code: '(bar) -> {foo: bar.a} = {}'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'bar'."]
  ,
    code: '(a) -> {a} = obj'
    options: [props: yes]
    errors: [message: "Assignment to function parameter 'a'."]
  ,
    code: '(a) -> [...a] = obj'
    errors: [message: "Assignment to function parameter 'a'."]
  ,
    code: '(a) -> {...a} = obj'
    errors: [message: "Assignment to function parameter 'a'."]
  ,
    code: '(a) -> [...a.b] = obj'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'a'."]
  ,
    code: '(a) -> {...a.b} = obj'
    options: [props: yes]
    errors: [message: "Assignment to property of function parameter 'a'."]
  ]
