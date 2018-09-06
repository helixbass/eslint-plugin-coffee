###*
# @fileoverview Tests for lines-between-class-members rule.
# @author 薛定谔的猫<hh_2013@foxmail.com>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/lines-between-class-members'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ALWAYS_MESSAGE = 'Expected blank line between class members.'
NEVER_MESSAGE = 'Unexpected blank line between class members.'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'lines-between-class-members', rule,
  valid: [
    'class foo'
    '''
      class foo
        constructor: ->
    '''

    '''
      class foo
        bar: ->
        
        baz: ->
    '''
    '''
      class foo
        bar: ->
        
        ###comments###
        baz: ->
    '''
    '''
      class foo
        bar: ->
        
        #comments
        baz: ->
    '''
    '''
      class foo
        bar: ->
        #comments
        
        baz: ->
    '''
    '''
      class A
        foo: -> # a comment
        
        bar: ->
    '''
    '''
      class A
        foo: ->
        ### a ### ### b ###

        bar: ->
    '''
    '''
      class A
        foo: -> ### a ###
        
        ### b ###
        bar: ->
    '''
  ,
    code: '''
      class foo
        bar: ->
        baz: ->
    '''
    options: ['never']
  ,
    code: '''
      class foo
        bar: ->
        ###comments###
        baz: ->
    '''
    options: ['never']
  ,
    code: '''
      class foo
        bar: ->
        #comments
        baz: ->
    '''
    options: ['never']
  ,
    code: '''
      class foo
        bar: ->
        ### comments

        ###
        baz: ->
    '''
    options: ['never']
  ,
    code: '''
      class foo
        bar: -> ### 
          comments
        ###
        baz: ->
    '''
    options: ['never']
  ,
    code: '''
      class foo
        bar: ->
        ### 
         comments
        ###
        baz: ->
    '''
    options: ['never']
  ,
    code: '''
      class foo
        bar: ->
        
        baz: ->
    '''
    options: ['always']
  ,
    code: '''
      class foo
        bar: ->
        
        ###comments###
        baz: ->
    '''
    options: ['always']
  ,
    code: '''
      class foo
        bar: ->
        
        #comments
        baz: ->
    '''
    options: ['always']
  ,
    code: '''
      class foo
        bar: ->
        baz: ->
    '''
    options: ['always', {exceptAfterSingleLine: yes}]
  ,
    code: '''
      class foo
        bar: ->

        baz: ->
    '''
    options: ['always', {exceptAfterSingleLine: yes}]
  ,
    code: '''
      class foo
        @a: 1
        b = 2
    '''
    options: ['always', {exceptAfterSingleLine: yes}]
  ,
    '''
      class foo
        @a: 1

        b = 2

        c = ->
          if d
            e

        f: g
    '''
  ]
  invalid: [
    code: '''
      class foo
        bar: ->
        baz: ->
    '''
    # output: '''
    #   class foo
    #     bar: ->

    #     baz: ->
    # '''
    options: ['always']
    errors: [message: ALWAYS_MESSAGE]
  ,
    code: '''
      class foo
        bar: ->

        baz: ->
    '''
    # output: '''
    #   class foo
    #     bar: ->
    #     baz: ->
    # '''
    options: ['never']
    errors: [message: NEVER_MESSAGE]
  ,
    code: '''
      class foo
        bar: ->
          a
        baz: ->
    '''
    # output: '''
    #   class foo
    #     bar: ->
    #       a

    #     baz: ->
    # '''
    options: ['always', {exceptAfterSingleLine: yes}]
    errors: [message: ALWAYS_MESSAGE]
  ,
    code: '''
      class foo
        @a: 1
        b = 2
    '''
    errors: [message: ALWAYS_MESSAGE]
  ,
    code: '''
      class foo
        c = ->
          if d
            e
        f: g
    '''
    errors: [message: ALWAYS_MESSAGE]
  ]
