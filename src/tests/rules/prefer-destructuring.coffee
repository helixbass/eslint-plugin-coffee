###*
# @fileoverview Prefer destructuring from arrays and objects
# @author Alex LaFroscia
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/prefer-destructuring'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'prefer-destructuring', rule,
  valid: [
    '[foo] = array'
    '{ foo } = object'
    'foo'
  ,
    # Ensure that the default behavior does not require desturcturing when renaming
    code: 'foo = object.bar'
    options: [object: yes]
  ,
    code: 'foo = object.bar'
    options: [{object: yes}, {enforceForRenamedProperties: no}]
  ,
    code: 'foo = object[bar]'
    options: [{object: yes}, {enforceForRenamedProperties: no}]
  ,
    code: '{ bar: foo } = object'
    options: [{object: yes}, {enforceForRenamedProperties: yes}]
  ,
    code: '{ [bar]: foo } = object'
    options: [{object: yes}, {enforceForRenamedProperties: yes}]
  ,
    code: 'foo = array[0]'
    options: [array: no]
  ,
    code: 'foo = object.foo'
    options: [object: no]
  ,
    code: "foo = object['foo']"
    options: [object: no]
  ,
    '({ foo } = object)'
  ,
    # Fix #8654
    code: 'foo = array[0]'
    options: [{array: no}, {enforceForRenamedProperties: yes}]
  ,
    '[foo] = array'
    'foo += array[0]'
    'foo += bar.foo'
    '''
      class Foo extends Bar
        @foo: -> 
          foo = super.foo
    '''
    'foo = bar[foo]'
    'foo = bar[foo]'
    'foo = object?.foo'
    "foo = object?['foo']"
  ]

  invalid: [
    code: 'foo = array[0]'
    errors: [message: 'Use array destructuring.']
  ,
    code: 'foo = object.foo'
    errors: [message: 'Use object destructuring.']
  ,
    code: 'foobar = object.bar'
    options: [{object: yes}, {enforceForRenamedProperties: yes}]
    errors: [message: 'Use object destructuring.']
  ,
    code: 'foo = object[bar]'
    options: [{object: yes}, {enforceForRenamedProperties: yes}]
    errors: [message: 'Use object destructuring.']
  ,
    code: "foo = object['foo']"
    errors: [message: 'Use object destructuring.']
  ,
    code: 'foo = array[0]'
    options: [{array: yes}, {enforceForRenamedProperties: yes}]
    errors: [message: 'Use array destructuring.']
  ,
    code: 'foo = array[0]'
    options: [array: yes]
    errors: [message: 'Use array destructuring.']
  ,
    code: '''
      class Foo extends Bar
        @foo: -> bar = super.foo.bar
    '''
    errors: [message: 'Use object destructuring.']
  ]
