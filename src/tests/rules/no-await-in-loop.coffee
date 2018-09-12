###*
# @fileoverview Tests for no-await-in-loop.
# @author Nat Mote (nmote)
###

'use strict'

rule = require '../../rules/no-await-in-loop'
{RuleTester} = require 'eslint'

error = messageId: 'unexpectedAwait', type: 'AwaitExpression'

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-await-in-loop', rule,
  valid: [
    '''
      ->
        await bar
    '''
    '''
      ->
        for bar of await baz
          ;
    '''
    '''
      ->
        for bar from await baz
          ;
    '''
    '''
      ->
        for await bar from await baz
          ;
    '''

    # While loops
    '''
      ->
        loop
          foo = ->
            await bar
    '''

    # Blocked by a function expression
    '''
      ->
        while true
          y = -> await bar
    '''

    # Blocked by a class method
    '''
      ->
        while yes
          class Foo
            foo: -> await bar
    '''

    # Asynchronous iteration intentionally
    '''
      ->
        for await x from xs
          await f x
    '''
  ]
  invalid: [
    # While loops
    code: '''
      ->
        while baz
          await bar
    '''
    errors: [error]
  ,
    code: '''
      ->
        while await foo()
          ;
    '''
    errors: [error]
  ,
    code: '''
      ->
        while baz
          for await x from xs
            ;
    '''
    errors: [{...error, type: 'For'}]
  ,
    # For of loops
    code: '''
      ->
        for bar from baz
          await bar
    '''
    errors: [error]
  ,
    code: '''
      ->
        for bar of baz
          await bar
    '''
    errors: [error]
  ,
    # For in loops
    code: '''
      ->
        for bar in baz
          await bar
    '''
    errors: [error]
  ,
    # Deep in a loop body
    code: '''
      ->
        while yes
          if bar
            foo await bar
    '''
    errors: [error]
  ,
    # Deep in a loop condition
    code: '''
      ->
        while xyz or 5 > await x
          ;
    '''
    errors: [error]
  ,
    # In a nested loop of for-await-of
    code: '''
      ->
        for await x from xs
          while 1
            await f x
    '''
    errors: [error]
  ]
