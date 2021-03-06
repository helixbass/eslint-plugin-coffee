###*
# @fileoverview disallow assignments that can lead to race conditions due to usage of `await` or `yield`
# @author Teddy Katz
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/require-atomic-updates'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

VARIABLE_ERROR =
  messageId: 'nonAtomicUpdate'
  data: value: 'foo'
  type: 'AssignmentExpression'

STATIC_PROPERTY_ERROR =
  messageId: 'nonAtomicUpdate'
  data: value: 'foo.bar'
  type: 'AssignmentExpression'

COMPUTED_PROPERTY_ERROR =
  messageId: 'nonAtomicUpdate'
  data: value: 'foo[bar].baz'
  type: 'AssignmentExpression'

ruleTester.run 'require-atomic-updates', rule,
  valid: [
    '''
      foo = null
      x = ->
        await y
        foo += bar
    '''
    '''
      foo = null
      x = ->
        await y
        foo = foo + bar
    '''
    '''
      foo = null
      x = ->
        foo = await bar + foo
    '''
    '''
      ->
        foo = null
        foo += await bar
    '''
    '''
      foo = null
      ->
        foo = (await result)(foo)
    '''
    '''
      foo = null
      ->
        foo = bar(await something, foo)
    '''
    '''
      ->
        foo = null
        foo += yield bar
    '''
    '''
      foo = {}
      ->
        foo.bar = await baz
    '''
    '''
      foo = []
      ->
        await y
        foo[x] += 1
    '''
    '''
      foo = null
      ->
        yield
        foo = bar + foo
    '''
    '''
      ->
        foo = null
        bar(() => baz += 1)
        foo += await amount
    '''
    '''
      foo = null
      ->
        foo = if condition then foo else await bar
    '''
  ]

  invalid: [
    code: '''
      foo = null
      -> foo += await amount
    '''
    errors: [messageId: 'nonAtomicUpdate', data: value: 'foo']
  ,
    code: '''
      foo = null
      ->
        while condition
          foo += await amount
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = foo + await amount
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = foo + (if bar then baz else await amount)
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = foo + (if bar then await amount else baz)
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = if condition then foo + await amount else somethingElse
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = (if condition then foo else await bar) + await bar
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo += bar + await amount
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      ->
        foo = null
        bar () => foo
        foo += await amount
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo += yield baz
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = bar(foo, await something)
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = {}
      -> foo.bar += await baz
    '''
    errors: [STATIC_PROPERTY_ERROR]
  ,
    code: '''
      foo = []
      -> foo[bar].baz += await result
    '''
    errors: [COMPUTED_PROPERTY_ERROR]
  ,
    code: '''
      foo = null
      -> foo = (yield foo) + await bar
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = foo + await result(foo)
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = await result(foo, await somethingElse)
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      ->
        foo = null
        yield -> foo += await bar
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = await foo + (yield bar)
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = null
      -> foo = bar + await foo
    '''
    errors: [VARIABLE_ERROR]
  ,
    code: '''
      foo = {}
      -> foo[bar].baz = await (foo.bar += await foo[bar].baz)
    '''
    errors: [COMPUTED_PROPERTY_ERROR, STATIC_PROPERTY_ERROR]
  ,
    code: '-> foo += await bar'
    errors: [VARIABLE_ERROR]
  ]
