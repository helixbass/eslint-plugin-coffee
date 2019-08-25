###*
# @fileoverview Tests for no-unsafe-finally
# @author Onur Temizkan
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-unsafe-finally'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-unsafe-finally', rule,
  valid: [
    """
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          console.log 'hola!'
    """
    """
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          console.log('hola!')
    """
    '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          a = (x) -> return x
    '''
    '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          a = (x) ->
            throw new Error() unless x
    '''
    '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          a = (x) ->
            while true
              if x
                break
              else
                continue
    '''
    '''
      foo = ->
        try
        finally
          while true
            break
    '''
    '''
      foo = ->
        try
        finally
          while true
            continue
    '''
    '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          bar = () =>
            throw new Error()
    '''
    '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          (x) => x
    '''
    """
      foo = ->
        try
          return 1
        finally
          class bar
            constructor: ->
            @ehm: ->
              return 'Hola!'
    """
  ]
  invalid: [
    code: '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          return 3
    '''
    errors: [
      message: 'Unsafe usage of ReturnStatement.'
      type: 'ReturnStatement'
      line: 7
      column: 5
    ]
  ,
    code: '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          if true
            return 3
          else
            return 2
    '''
    errors: [
      message: 'Unsafe usage of ReturnStatement.'
      type: 'ReturnStatement'
      line: 8
      column: 7
    ,
      message: 'Unsafe usage of ReturnStatement.'
      type: 'ReturnStatement'
      line: 10
      column: 7
    ]
  ,
    code: '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          return 3
    '''
    errors: [
      message: 'Unsafe usage of ReturnStatement.'
      type: 'ReturnStatement'
      line: 7
      column: 5
    ]
  ,
    code: '''
      foo = ->
        try
          1
        catch err
          2
        finally
          return (x) -> return y
    '''
    errors: [
      message: 'Unsafe usage of ReturnStatement.'
      type: 'ReturnStatement'
      line: 7
      column: 5
    ]
  ,
    code: '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          return { x: (c) -> return c }
    '''
    errors: [
      message: 'Unsafe usage of ReturnStatement.'
      type: 'ReturnStatement'
      line: 7
      column: 5
    ]
  ,
    code: '''
      foo = ->
        try
          return 1
        catch err
          return 2
        finally
          throw new Error()
    '''
    errors: [
      message: 'Unsafe usage of ThrowStatement.'
      type: 'ThrowStatement'
      line: 7
      column: 5
    ]
  ,
    code: '''
      foo = ->
        try
          foo()
        finally
          try
            bar()
          finally
            return
    '''
    errors: [
      message: 'Unsafe usage of ReturnStatement.'
      type: 'ReturnStatement'
      line: 8
      column: 7
    ]
  ,
    code: '''
      foo = ->
        while true
          try
          finally
            break
    '''
    errors: [
      message: 'Unsafe usage of BreakStatement.'
      type: 'BreakStatement'
      line: 5
      column: 7
    ]
  ,
    code: '''
      foo = ->
        while true
          try
          finally
            continue
    '''
    errors: [
      message: 'Unsafe usage of ContinueStatement.'
      type: 'ContinueStatement'
      line: 5
      column: 7
    ]
  ]
