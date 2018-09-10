###*
# @fileoverview Tests for no-overwrite rule.
# @author Julian Rosse
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-overwrite'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

error = type: 'Identifier'

ruleTester.run 'no-overwrite', rule,
  valid: [
    'a = 1'
    'a = b = 2'
    '''
      a = null
      a = 1
    '''
    '''
      a = null
      a = -> 1
    '''
    '''
      a = null
      ->
        a = 1
    '''
    '''
      if x
        a = 1
      else
        a = 2
    '''
  ,
    code: '''
      if x
        a = 1
      else
        a = 2
    '''
    options: [sameScope: no]
  ,
    '''
      a = 1
      a = 2 unless b
    '''
    '''
      a = 1
      -> a++
    '''
    '''
      a = 1
      a++
    '''
    'class a'
    '''
      a = class a
    '''
    '''
      a = null
      a = null
    '''
    '''
      a = 1
      foo = (a) ->
    '''
    '''
      (a) ->
        (a) ->
    '''
    '''
      a = 1
      do (a) ->
    '''
    '''
      a = (a) ->
    '''
  ]
  invalid: [
    code: '''
      a = 1
      ->
        a = 2
    '''
    errors: [error]
  ,
    code: '''
      a = 1
      a = 2 unless b
    '''
    errors: [error]
    options: [sameScope: no]
  ,
    code: '''
      a = 1
      a = 2
    '''
    errors: [error]
    options: [sameScope: no]
  ,
    code: '''
      a = null
      a = 1
    '''
    errors: [error]
    options: [nullInitializers: no]
  ,
    code: '''
      a = null
      a = -> 1
    '''
    errors: [error]
    options: [nullInitializers: no]
  ,
    code: '''
      a = null
      ->
        a = 1
    '''
    errors: [error]
    options: [nullInitializers: no]
  ,
    code: '''
      class a
        constructor: ->
          a = null
    '''
    errors: [error]
  ,
    code: '''
      a = ->
        a = 10
    '''
    errors: [error]
  ,
    code: '''
      a = ->
        a = ->
    '''
    errors: [error]
  ,
    code: '''
      a = ->
        class a
    '''
    errors: [error]
  ,
    code: '''
      do ->
        a = class
          constructor: ->
            class a
    '''
    errors: [error]
  ,
    code: '''
      class a
        constructor: ->
          a = null
    '''
    errors: [error]
  ,
    code: '''
      class a
        constructor: ->
          class a
    '''
    errors: [error]
  ]
