###*
# @fileoverview Tests for no-loop-func rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-loop-func'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
expectedErrorMessage = "Don't make functions within a loop."

ruleTester.run 'no-loop-func', rule,
  valid: [
    "string = 'function a() {}'"
    '''
      for i in [0...l]
        ;
      a = -> i
    '''
    '''
      for i in [0...((-> i); l)]
        ;
    '''
    '''
      for x of xs.filter (x) -> x != upper
        ;
    '''
    '''
      for x from xs.filter (x) -> x != upper
        ;
    '''
    '''
      for x in xs.filter (x) -> x != upper
        ;
    '''
    # no refers to variables that declared on upper scope.
    '''
      for i in [0...l]
        ->
    '''
    '''
      for i of {}
        ->
    '''
    '''
      for i from {}
        ->
    '''
  ,
    code: '''
      a = 0
      for i in [0...l]
        -> a
    '''
  ,
    code: '''
      a = 0
      for i of {}
        -> -> a
    '''
  ]
  invalid: [
    code: '''
      for i in [0...l]
        -> i
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      for i of {}
        -> i
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      for i from {}
        -> i
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      for i in [0...l]
        a = -> i
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      for i in [0...l]
        a = -> i
        a()
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      while i
        -> i
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      until i
        -> i
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    # Warns functions which are using modified variables.
    code: '''
      a = null
      for i in [0...l]
        a = 1
        -> a
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      for i of {}
        -> a
        a = 1
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      for i from {}
        -> a
        a = 1
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      for i in [0...l]
        -> -> a
        a = 1
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      for i of {}
        -> -> a
        a = 1
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      for i from {}
        -> -> a
        a = 1
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      for i in [0...10]
        for x of xs.filter (x) -> x isnt i
          ;
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      for x from xs
        a = null
        for y from ys
          a = 1
          -> a
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      for x from xs
        for y from ys
          -> x
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      (-> x) for x from xs
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      for x from xs
        a = 1
        -> a
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      for x from xs
        -> a
        a = 1
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      foo ->
        a = 10
      for x from xs
        -> a
      foo()
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      a = null
      foo ->
        a = 10
        for x from xs
          -> a
      foo()
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ,
    code: '''
      result = {}
      for score of scores
        letters = scores[score]
        letters.split('').forEach (letter) =>
          result[letter] = score
      result.__default = 6
    '''
    errors: [message: expectedErrorMessage, type: 'FunctionExpression']
  ]
