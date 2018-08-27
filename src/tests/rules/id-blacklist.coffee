###*
# @fileoverview Tests for id-blacklist rule.
# @author Keith Cirkel
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/id-blacklist'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'id-blacklist', rule,
  valid: [
    code: 'foo = "bar"'
    options: ['bar']
  ,
    code: 'bar = "bar"'
    options: ['foo']
  ,
    code: 'foo = "bar"'
    options: ['f', 'fo', 'fooo', 'bar']
  ,
    code: 'foo = ->'
    options: ['bar']
  ,
    code: 'foo()'
    options: ['f', 'fo', 'fooo', 'bar']
  ,
    code: 'foo.bar()'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'baz']
  ,
    code: 'foo = bar.baz'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz']
  ,
    code: 'foo = bar.baz.bing'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: 'foo.bar.baz = bing.bong.bash'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: 'if (foo.bar) then ;'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: 'obj = { key: foo.bar }'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: 'arr = [foo.bar]'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: '[foo.bar]'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: '[foo.bar.nesting]'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: 'if (foo.bar is bar.baz) then [foo.bar]'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'barr', 'bazz', 'bingg']
  ,
    code: '''
      myArray = new Array()
      myDate = new Date()
    '''
    options: ['array', 'date', 'mydate', 'myarray', 'new', 'var']
  ,
    code: 'foo()'
    options: ['foo']
  ,
    code: 'foo.bar()'
    options: ['bar']
  ,
    code: 'foo.bar'
    options: ['bar']
  ]
  invalid: [
    code: 'foo = "bar"'
    options: ['foo']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'bar = "bar"'
    options: ['bar']
    errors: [
      message: "Identifier 'bar' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'foo = "bar"'
    options: ['f', 'fo', 'foo', 'bar']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'foo = ->'
    options: ['f', 'fo', 'foo', 'bar']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'foo.bar()'
    options: ['f', 'fo', 'foo', 'b', 'ba', 'baz']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'foo = bar.baz'
    options: ['f', 'fo', 'foo', 'b', 'ba', 'barr', 'bazz']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'foo = bar.baz'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'bar', 'bazz']
    errors: [
      message: "Identifier 'bar' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'if (foo.bar) then ;'
    options: ['f', 'fo', 'foo', 'b', 'ba', 'barr', 'bazz', 'bingg']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'obj = { key: foo.bar }'
    options: ['obj']
    errors: [
      message: "Identifier 'obj' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'obj = { key: foo.bar }'
    options: ['key']
    errors: [
      message: "Identifier 'key' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'obj = { key: foo.bar }'
    options: ['foo']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'arr = [foo.bar]'
    options: ['arr']
    errors: [
      message: "Identifier 'arr' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'arr = [foo.bar]'
    options: ['foo']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: '[foo.bar]'
    options: ['f', 'fo', 'foo', 'b', 'ba', 'barr', 'bazz', 'bingg']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'if (foo.bar is bar.baz) then [bing.baz]'
    options: ['f', 'fo', 'foo', 'b', 'ba', 'barr', 'bazz', 'bingg']
    errors: [
      message: "Identifier 'foo' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'if (foo.bar is bar.baz) then [foo.bar]'
    options: ['f', 'fo', 'fooo', 'b', 'ba', 'bar', 'bazz', 'bingg']
    errors: [
      message: "Identifier 'bar' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: '''
      myArray = new Array()
      myDate = new Date()
    '''
    options: ['array', 'date', 'myDate', 'myarray', 'new', 'var']
    errors: [
      message: "Identifier 'myDate' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: '''
      myArray = new Array()
      myDate = new Date()
    '''
    options: ['array', 'date', 'mydate', 'myArray', 'new', 'var']
    errors: [
      message: "Identifier 'myArray' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'foo.bar = 1'
    options: ['bar']
    errors: [
      message: "Identifier 'bar' is blacklisted."
      type: 'Identifier'
    ]
  ,
    code: 'foo.bar.baz = 1'
    options: ['bar', 'baz']
    errors: [
      message: "Identifier 'baz' is blacklisted."
      type: 'Identifier'
    ]
  ]
