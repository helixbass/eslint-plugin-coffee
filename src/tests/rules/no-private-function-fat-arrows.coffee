###*
# @fileoverview Disallows fat-arrow functions in executable class bodies.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-private-function-fat-arrows'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-private-function-fat-arrows', rule,
  valid: [
    '''
      class Foo
        foo = ->
    '''
    '''
      class Foo
        foo: =>
    '''
    '''
      class Foo
        foo: ->
          bar = =>
    '''
  ]
  invalid: [
    code: '''
      class Foo
        foo = =>
    '''
    errors: [
      messageId: 'noFatArrow'
      line: 2
      column: 9
    ]
  ,
    code: '''
      class Bar
        foo = ->
          class
            bar2 = =>
    '''
    errors: [
      messageId: 'noFatArrow'
      line: 4
      column: 14
    ]
  ,
    code: '''
      class Bar
        foo = ->
          class
            foo = =>
    '''
    errors: [
      messageId: 'noFatArrow'
      line: 4
      column: 13
    ]
  ]
