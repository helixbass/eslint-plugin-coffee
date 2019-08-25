###*
# @fileoverview Tests for no-unmodified-loop-condition rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-unmodified-loop-condition'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-unmodified-loop-condition', rule,
  valid: [
    '''
      foo = 0
      while foo
        ++foo
    '''
    '''
      foo = 0
      ++foo while foo
    '''
    '''
      foo = 0
      ++foo until foo
    '''
    '''
      foo = 0
      while foo
        foo += 1
    '''
    '''
      foo = 0
      while foo++
        ;
    '''
    '''
      foo = 0
      while foo = next()
        ;
    '''
    '''
      foo = 0
      while ok foo
        ;
    '''
    '''
      foo = 0
      bar = 0
      while ++foo < bar
        ;
    '''
    '''
      foo = 0
      obj = {}
      while foo is obj.bar
        ;
    '''
    '''
      foo = 0
      f = {}
      bar = {}
      while foo is f bar
        ;
    '''
    '''
      foo = 0
      f = {}
      while foo is f()
        ;
    '''
    '''
      foo = 0
      tag = 0
      while foo is tag"abc"
        ;
    '''
    '''
      ->
        foo = 0
        while yield foo
          ;
    '''
    '''
      ->
        foo = 0
        while foo is (yield)
          ;
    '''
    '''
      foo = 0
      while foo.ok
        ;
    '''
    '''
      foo = 0
      while foo
        update()
      update = -> ++foo
    '''
    '''
      foo = 0
      bar = 9
      while foo < bar
        foo += 1
    '''
    '''
      foo = 0
      bar = 1
      baz = 2
      while (if foo then bar else baz)
        foo += 1
    '''
    '''
      foo = 0
      bar = 0
      while foo and bar
        ++foo
        ++bar
    '''
    '''
      foo = 0
      bar = 0
      while foo or bar
        ++foo
        ++bar
    '''
  ]
  invalid: [
    code: '''
      foo = 0
      while foo
        ;
      foo = 1
    '''
    errors: ["'foo' is not modified in this loop."]
  ,
    code: '''
      foo = 0
      while not foo
        ;
      foo = 1
    '''
    errors: ["'foo' is not modified in this loop."]
  ,
    code: '''
      foo = 0
      while foo != null
        ;
      foo = 1
    '''
    errors: ["'foo' is not modified in this loop."]
  ,
    code: '''
      foo = 0
      bar = 9
      while foo < bar
        ;
      foo = 1
    '''
    errors: [
      "'foo' is not modified in this loop."
      "'bar' is not modified in this loop."
    ]
  ,
    code: '''
      foo = 0
      bar = 0
      while foo and bar
        ++bar
      foo = 1
    '''
    errors: ["'foo' is not modified in this loop."]
  ,
    code: '''
      foo = 0
      bar = 0
      while foo and bar
        ++foo
      foo = 1
    '''
    errors: ["'bar' is not modified in this loop."]
  ,
    code: '''
      a = b = c = null
      while a < c and b < c
        ++a
      foo = 1
    '''
    errors: [
      "'b' is not modified in this loop."
      "'c' is not modified in this loop."
    ]
  ,
    code: '''
      foo = 0
      while (if foo then 1 else 0)
        ;
      foo = 1
    '''
    errors: ["'foo' is not modified in this loop."]
  ,
    code: '''
      foo = 0
      while foo
        update()
      update = (foo) -> ++foo
    '''
    errors: ["'foo' is not modified in this loop."]
  ]
