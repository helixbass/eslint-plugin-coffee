###*
# @fileoverview Tests for no-shadow rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-shadow'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-shadow', rule,
  valid: [
    '''
      a = 3
      b = (x) ->
        a++
        x + a
      setTimeout(
        -> b(a)
        0
      )
    '''
    '''
      do ->
        doSomething = ->
        doSomething()
    '''
    'class A'
    '''
      class A
        constructor: ->
          a = null
    '''
    '''
      do ->
        A = class A
    '''
    '''
      a = null
      a = null
    '''
    '''
      foo = (a) ->
      a = null
    '''
  ,
    code: '''
      foo = (a) ->
      a = ->
    '''
    options: [hoist: 'never']
  ,
    '''
      ->
        Object = 0
    '''
  ,
    code: '''
      ->
        top = 0
    '''
    env: browser: yes
  ,
    # ,
    #   code: '''
    #     Object = 0
    #   '''
    #   options: [builtinGlobals: yes]
    # ,
    #   code: '''
    #     top = 0
    #   '''
    #   env: browser: yes
    #   options: [builtinGlobals: yes]
    code: '''
      foo = (cb) ->
        ((cb) ->
          cb(42)
        )(cb)
    '''
    options: [allow: ['cb']]
  ,
    '''
      foo = (cb) ->
        do (cb) -> cb 42
    '''
    '''
      a = 3
      b = ->
        a = 10
        b = 0
      setTimeout(
        -> b()
        0
      )
    '''
    '''
      a = ->
        a = ->
    '''
    '''
      a = ->
        class a
    '''
    '''
      do ->
        a = ->
          class a
    '''
    '''
      do ->
        a = class
          constructor: ->
            class a
    '''
    '''
      class A
        constructor: ->
          A = null
    '''
    '''
      class A
        constructor: ->
          class A
    '''
    '''
      a class A
    '''
    '''
      exports.Rewriter = class Rewriter
    '''
  ]
  invalid: [
    code: '''
      x = 1
      a = (x) -> ++x
    '''
    errors: [
      message: "'x' is already declared in the upper scope."
      type: 'Identifier'
      line: 2
      column: 6
    ]
  ,
    code: '''
      foo = (a) ->
      a = null
    '''
    options: [hoist: 'all']
    errors: [
      message: "'a' is already declared in the upper scope.", type: 'Identifier'
    ]
  ,
    code: '''
      foo = (a) ->
      a = ->
    '''
    options: [hoist: 'all']
    errors: [
      message: "'a' is already declared in the upper scope.", type: 'Identifier'
    ]
  ,
    code: '''
      foo = (a) ->
      a = ->
    '''
    errors: [
      message: "'a' is already declared in the upper scope.", type: 'Identifier'
    ]
  ,
    code: '''
      do ->
        a = (a) ->
    '''
    errors: [
      message: "'a' is already declared in the upper scope.", type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        Object = 0
    '''
    options: [builtinGlobals: yes]
    errors: [
      message: "'Object' is already declared in the upper scope."
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        top = 0
    '''
    options: [builtinGlobals: yes]
    errors: [
      message: "'top' is already declared in the upper scope."
      type: 'Identifier'
    ]
    env: browser: yes
  ,
    code: '''
      Object = 0
    '''
    options: [builtinGlobals: yes]
    errors: [
      message: "'Object' is already declared in the upper scope."
      type: 'Identifier'
    ]
  ,
    code: '''
      top = 0
    '''
    options: [builtinGlobals: yes]
    errors: [
      message: "'top' is already declared in the upper scope."
      type: 'Identifier'
    ]
    env: browser: yes
  ,
    code: '''
      foo = (cb) ->
        ((cb) -> cb(42))(cb)
    '''
    errors: [
      message: "'cb' is already declared in the upper scope."
      type: 'Identifier'
      line: 2
      column: 5
    ]
  ]
