###*
# @fileoverview Tests for missing-err rule.
# @author Jamund Ferguson
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/handle-callback-err'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedErrorMessage = 'Expected error to be handled.'
expectedFunctionExpressionError =
  message: expectedErrorMessage, type: 'FunctionExpression'

ruleTester.run 'handle-callback-err', rule,
  valid: [
    'test = (error) ->'
    'test = (err) -> console.log(err)'
    "test = (err, data) -> if err then data = 'ERROR'"
    'test = (err) -> if err then ### do nothing ###'
    'test = (err) -> if !err then doSomethingHere() else ;'
    'test = (err, data) -> unless err then good() else bad()'
    'try ; catch err ;'
    '''
      getData (err, data) ->
        if err
          getMoreDataWith data, (err, moreData) ->
            if err then ;
            getEvenMoreDataWith moreData, (err, allOfTheThings) ->
              if err then ;
    '''
    'test = (err) -> if ! err then doSomethingHere()'
    '''
      test = (err, data) ->
        if data
          doSomething (err) -> console.error err
        else if err
          console.log err
    '''
    '''
      handler = (err, data) ->
        if data
          doSomethingWith data
        else if err
          console.log err
    '''
    '''
      handler = (err) ->
        logThisAction (err) ->
          if err then ;
        console.log err
    '''
    'userHandler = (err) -> process.nextTick -> if err then ;'
    '''
      help = ->
        userHandler = (err) ->
          tester = ->
            err
            process.nextTick -> err
    '''
    '''
      help = (done) ->
        err = new Error 'error'
        done()
    '''
    'test = (err) -> err'
    'test = (err) => !err'
    'test = (err) -> err.message'
  ,
    code: 'test = (error) -> if error then ### do nothing ###'
    options: ['error']
  ,
    code: 'test = (error) -> if error then ### do nothing ###'
    options: ['error']
  ,
    code: 'test = (error) -> if ! error then doSomethingHere()'
    options: ['error']
  ,
    code: 'test = (err) -> console.log err'
    options: ['^(err|error)$']
  ,
    code: 'test = (error) -> console.log(error)'
    options: ['^(err|error)$']
  ,
    code: 'test = (anyError) -> console.log(anyError)'
    options: ['^.+Error$']
  ,
    code: 'test = (any_error) -> console.log(anyError)'
    options: ['^.+Error$']
  ,
    code: 'test = (any_error) -> console.log(any_error)'
    options: ['^.+(e|E)rror$']
  ]
  invalid: [
    code: 'test = (err) ->', errors: [expectedFunctionExpressionError]
  ,
    code: 'test = (err, data) ->'
    errors: [expectedFunctionExpressionError]
  ,
    code: 'test = (err) -> errorLookingWord()'
    errors: [expectedFunctionExpressionError]
  ,
    code: 'test = (err) -> try ; catch err ;'
    errors: [expectedFunctionExpressionError]
  ,
    code: 'test = (err, callback) -> foo (err, callback) ->'
    errors: [expectedFunctionExpressionError, expectedFunctionExpressionError]
  ,
    code: 'test = (err) ->### if(err){} ###'
    errors: [expectedFunctionExpressionError]
  ,
    code:
      'test = (err) -> doSomethingHere (err) -> console.log err'
    errors: [expectedFunctionExpressionError]
  ,
    code: '''
        getData (err, data) ->
          getMoreDataWith data, (err, moreData) ->
            if err then ;
            getEvenMoreDataWith moreData, (err, allOfTheThings) ->
              if err then ;
      '''
    errors: [expectedFunctionExpressionError]
  ,
    code: '''
        getData (err, data) ->
          getMoreDataWith data, (err, moreData) ->
            getEvenMoreDataWith moreData, (err, allOfTheThings) ->
              if err then ;
      '''
    errors: [expectedFunctionExpressionError, expectedFunctionExpressionError]
  ,
    code:
      'userHandler = (err) -> logThisAction (err) -> if err then console.log err'
    errors: [expectedFunctionExpressionError]
  ,
    code: '''
        help = ->
          userHandler = (err) ->
            tester = (err) ->
              err
              process.nextTick -> err
      '''
    errors: [expectedFunctionExpressionError]
  ,
    code: 'test = (anyError) -> console.log(otherError)'
    options: ['^.+Error$']
    errors: [expectedFunctionExpressionError]
  ,
    code: 'test = (anyError) ->'
    options: ['^.+Error$']
    errors: [expectedFunctionExpressionError]
  ,
    code: 'test = (err) ->'
    options: ['^(err|error)$']
    errors: [expectedFunctionExpressionError]
  ]
