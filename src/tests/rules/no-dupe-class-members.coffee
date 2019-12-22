###*
# @fileoverview Tests for no-dupe-class-members rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-dupe-class-members'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###

ruleTester.run 'no-dupe-class-members', rule,
  valid: [
    '''
      class A
        foo: ->
        bar: ->
    '''
    '''
      class A
        @foo: ->
        foo: ->
    '''
    '''
      class A
        foo: ->
      class B
        foo: ->
    '''
    '''
      class A
        [foo]: ->
        foo: ->
    '''
    '''
      class A
        'foo': ->
        'bar': ->
        baz: ->
    '''
    '''
      class A
        1: ->
        2: ->
    '''
    '''
      class B extends Base
        "#{'method'}": -> super?()
        "#{'noMethod'}": -> super?() ? super['method']()
    '''
  ]
  invalid: [
    code: '''
      class A
        foo: ->
        foo: ->
    '''
    errors: [
      type: 'MethodDefinition'
      line: 3
      column: 3
      messageId: 'unexpected'
      data: name: 'foo'
    ]
  ,
    code: '''
      !class A
        foo: ->
        foo: ->
    '''
    errors: [
      type: 'MethodDefinition'
      line: 3
      column: 3
      messageId: 'unexpected'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        'foo': ->
        'foo': ->
    '''
    errors: [
      type: 'MethodDefinition'
      line: 3
      column: 3
      messageId: 'unexpected'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        10: ->
        1e1: ->
    '''
    errors: [
      type: 'MethodDefinition'
      line: 3
      column: 3
      messageId: 'unexpected'
      data: name: '10'
    ]
  ,
    code: '''
      class A
        foo: ->
        foo: ->
        foo: ->
    '''
    errors: [
      type: 'MethodDefinition'
      line: 3
      column: 3
      messageId: 'unexpected'
      data: name: 'foo'
    ,
      type: 'MethodDefinition'
      line: 4
      column: 3
      messageId: 'unexpected'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        @foo: ->
        @foo: ->
    '''
    errors: [
      type: 'MethodDefinition'
      line: 3
      column: 3
      messageId: 'unexpected'
      data: name: 'foo'
    ]
  ]
