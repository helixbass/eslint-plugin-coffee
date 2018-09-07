###*
# @fileoverview Tests for no-inner-declarations rule.
# @author Brandon Mills
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-inner-declarations'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-inner-declarations', rule,
  # Examples of code that should not trigger the rule
  valid: [
    'doSomething = ->'
    '''
      doSomething = ->
        somethingElse = ->
    '''
    '''
      (->
        doSomething = ->
      )()
    '''
    '''
      do ->
        doSomething = ->
    '''
    '''
      decl = (arg) ->
        fn = null
        if arg
          fn = ->
    '''
    '''
      x =
        doSomething: ->
          doSomethingElse = ->
    '''
    '''
      decl = (arg) ->
        fn = null
        if arg
          fn = ->
    '''
    '''
      if test
        foo = null
    '''
    '''
      doSomething = ->
        while test
          foo = null
    '''
  ,
    code: 'foo = null', options: ['both']
  ,
    code: 'foo = 42', options: ['both']
  ,
    code: '''
      doSomething = ->
        foo = null
    '''
    options: ['both']
  ,
    code: '''
      do ->
        foo = null
    '''
    options: ['both']
  ,
    code: '''
      foo =>
        bar = ->
    '''
  ,
    code: '''
      fn = =>
        foo = null
    '''
    options: ['both']
  ,
    code: '''
      x = {
        doSomething: ->
          foo = null
      }
    '''
    options: ['both']
  ,
    code: '''
      foo = baz = null
      if test
        [foo, {bar: baz} = {}] = null
    '''
    options: ['both']
  ,
    'b for b in c'
    '(a) ->'
  ]

  # Examples of code that should trigger the rule
  invalid: [
    code: '''
      if test
        fn = ->
    '''
    errors: [
      message: 'Move function declaration to program root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      if test
        x = 1
    '''
    options: ['both']
    errors: [
      message: 'Move variable declaration to program root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      if test
        doSomething = ->
    '''
    options: ['both']
    errors: [
      message: 'Move function declaration to program root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      doSomething = ->
        while test
          somethingElse = ->
    '''
    errors: [
      message: 'Move function declaration to function body root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      do ->
        if test
          doSomething = ->
    '''
    errors: [
      message: 'Move function declaration to function body root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      while test
        foo = null
    '''
    options: ['both']
    errors: [
      message: 'Move variable declaration to program root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      doSomething = ->
        if test
          foo = 42
    '''
    options: ['both']
    errors: [
      message: 'Move variable declaration to function body root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      do ->
        if test
          foo = null
    '''
    options: ['both']
    errors: [
      message: 'Move variable declaration to function body root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      if test
        {foo, bar} = null
    '''
    options: ['both']
    errors: [
      message: 'Move variable declaration to program root.'
      type: 'Identifier'
    ,
      message: 'Move variable declaration to program root.'
      type: 'Identifier'
    ]
  ,
    code: '''
      if test
        [foo, {bar: baz} = {}] = null
    '''
    options: ['both']
    errors: [
      message: 'Move variable declaration to program root.'
      type: 'Identifier'
    ,
      message: 'Move variable declaration to program root.'
      type: 'Identifier'
    ]
  ]
