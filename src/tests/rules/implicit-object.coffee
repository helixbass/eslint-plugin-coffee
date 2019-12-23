###*
# @fileoverview Prohibit implicit objects.
# @author Julian Rosse
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/implicit-object'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester.run 'implicit-object', rule,
  valid: [
    '{a: 1}'
    '{b} = c'
    '({a}) ->'
    'f({a: 1})'
    'x = {@a}'
    '''
      {
        a: 1
        b: 2
      }
    '''
  ,
    code: '{a: 1}'
    options: ['never']
  ,
    '''
      class A
        b: 1
        c: ->
    '''
    '''
      r = class then 1:2
    '''
  ,
    code: '''
      y =
        'a': 'b'
        3:4
    '''
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      z.y =
        'x': 4
        3 : 0
    '''
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      list =
        count: 10
        items:
          for item in items
            if not item
              throw new Error 'Unexpected: falsy item in list!'

            name: item.Name
            age: item.Age
    '''
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      y = {
        'a': 'b'
        3:4
      }
    '''
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      class A
        b: ->
          c: 1
    '''
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      f
        a: b
    '''
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      f(
        a: b
      )
    '''
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      a: b
      c: d
    '''
    options: ['never', {allowOwnLine: yes}]
  ]
  invalid: [
    code: 'a: 1'
    errors: 1
  ,
    code: 'f a: 1, b: 2'
    errors: 1
  ,
    code: 'f a: 1, b: 2'
    errors: 1
    options: ['never', {allowOwnLine: yes}]
  ,
    code: '''
      f
        a: 1
    '''
    errors: 1
  ,
    code: '''
      x =
        a: 1
        b: 2
    '''
    errors: 1
    options: ['never']
  ,
    code: '''
      class A
        b: ->
          c: 1
    '''
    errors: 1
  ,
    code: '''
      a = 1: 2
    '''
    errors: 1
  ,
    code: '''
      y =
        'a': 'b'
        3:4
    '''
    errors: 1
  ,
    code: '''
      z.y =
        'x': 4
        3 : 0
    '''
    errors: 1
  ,
    code: '''
      list =
        count: 10
        items:
          for item in items
            if not item
              throw new Error 'Unexpected: falsy item in list!'

            name: item.Name
            age: item.Age
    '''
    errors: 2
  ]
