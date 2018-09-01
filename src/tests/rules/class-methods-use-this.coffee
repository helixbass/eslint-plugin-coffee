###*
# @fileoverview Tests for class-methods-use-this rule.
# @author Patrick Williams
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/class-methods-use-this'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'class-methods-use-this', rule,
  valid: [
    code: '''
      class A
        constructor: ->
    '''
  ,
    code: '''
      class A
        foo: -> this
    '''
  ,
    code: '''
      class A
        foo: -> @
    '''
  ,
    code: '''
      class A
        foo: => @
    '''
  ,
    code: """
      class A
        foo: -> this.bar = 'bar'
    """
  ,
    code: """
      class A
        foo: -> @bar = 'bar'
    """
  ,
    code: '''
      class A
        foo: -> bar @
    '''
  ,
    code: '''
      class A extends B
        foo: -> super.foo()
    '''
  ,
    code: '''
      class A
        foo: -> return @ if yes
    '''
  ,
    code: '''
      class A
        @foo: ->
    '''
  ,
    code: 'a: ->'
  ,
    code: '''
      class A
        foo: -> => @
    '''
  ,
    code: '''
      class A
        foo: -> this
        bar: ->
    '''
    options: [exceptMethods: ['bar']]
  ]
  invalid: [
    code: '''
      class A
        foo: ->
    '''
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: =>
    '''
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: -> ###*this*###
    '''
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: ->
          a = -> this
    '''
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: -> 
          a = ->
            b = -> this
    '''
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: -> window.this
    '''
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: """
      class A
        foo: -> that.this = 'this'
    """
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: -> => undefined
    '''
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: ->
        bar: ->
    '''
    options: [exceptMethods: ['bar']]
    errors: [
      type: 'FunctionExpression'
      line: 2
      column: 5
      messageId: 'missingThis'
      data: name: 'foo'
    ]
  ,
    code: '''
      class A
        foo: ->
        hasOwnProperty: ->
    '''
    options: [exceptMethods: ['foo']]
    errors: [
      type: 'FunctionExpression'
      line: 3
      column: 16
      messageId: 'missingThis'
      data: name: 'hasOwnProperty'
    ]
  ]
