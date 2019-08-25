###*
# @fileoverview Tests for guard-for-in rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/guard-for-in'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'guard-for-in', rule,
  valid: [
    '''
      for x of o
        ;
    '''
    '''
      for x of o
        if x
          f()
    '''
    '''
      f() for own x of o
    '''
    '''
      for x of o
        if x
          f()
    '''
    'x for x in y'
    'x for x from y'
    '''
      for x of o
        continue if x
        f()
    '''
    '''
      for x of o
        if x
          continue
        f()
    '''
  ]
  invalid: [
    code: '''
      for x of o
        if x
          f()
          continue
        g()
    '''
    errors: [
      message:
        'The body of a for-of should use "own" or be wrapped in an if statement to filter unwanted properties from the prototype.'
      type: 'For'
    ]
  ,
    code: '''
      for x of o
        if x
          continue
          f()
        g()
    '''
    errors: [
      message:
        'The body of a for-of should use "own" or be wrapped in an if statement to filter unwanted properties from the prototype.'
      type: 'For'
    ]
  ,
    code: '''
      for x of o
        if x
          f()
        g()
    '''
    errors: [
      message:
        'The body of a for-of should use "own" or be wrapped in an if statement to filter unwanted properties from the prototype.'
      type: 'For'
    ]
  ,
    code: '''
      for x of o
        foo()
    '''
    errors: [
      message:
        'The body of a for-of should use "own" or be wrapped in an if statement to filter unwanted properties from the prototype.'
      type: 'For'
    ]
  ,
    code: 'foo() for x of o'
    errors: [
      message:
        'The body of a for-of should use "own" or be wrapped in an if statement to filter unwanted properties from the prototype.'
      type: 'For'
    ]
  ]
