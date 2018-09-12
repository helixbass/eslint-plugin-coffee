###*
# @fileoverview restrict values that can be used as Promise rejection reasons
# @author Teddy Katz
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/prefer-promise-reject-errors'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'prefer-promise-reject-errors', rule,
  valid: [
    'Promise.resolve(5)'
    'Foo.reject(5)'
    'Promise.reject(foo)'
    'Promise.reject(foo.bar)'
    'Promise.reject(foo.bar())'
    'Promise.reject(new Error())'
    'Promise.reject(new TypeError)'
    "Promise.reject(new Error('foo'))"
    'new Foo((resolve, reject) => reject(5))'
    'new Promise (resolve, reject) -> (reject) -> reject 5'
    # '''
    #   new Promise (resolve, reject) ->
    #     if foo
    #       reject = somethingElse
    #       reject(5)
    # '''
    'new Promise((resolve, {apply}) -> apply(5))'
    'new Promise((resolve, reject) -> resolve(5, reject))'
    '-> Promise.reject await foo'
  ,
    code: 'Promise.reject()'
    options: [allowEmptyReject: yes]
  ,
    code: 'new Promise((resolve, reject) -> reject())'
    options: [allowEmptyReject: yes]
  ]

  invalid: [
    'Promise.reject(5)'
    "Promise.reject('foo')"
    'Promise.reject(!foo)'
    'Promise.reject()'
    'Promise.reject(undefined)'
    'Promise.reject({ foo: 1 })'
    'Promise.reject([1, 2, 3])'
  ,
    code: 'Promise.reject()'
    options: [allowEmptyReject: no]
  ,
    code: 'new Promise((resolve, reject) -> reject())'
    options: [allowEmptyReject: no]
  ,
    code: 'Promise.reject(undefined)'
    options: [allowEmptyReject: yes]
  ,
    "Promise.reject('foo', somethingElse)"
    'new Promise((resolve, reject) => reject(5))'
    'new Promise((resolve, reject) => reject())'
    'new Promise (y, n) -> n(5)'
    """
      new Promise (resolve, reject) =>
        fs.readFile 'foo.txt', (err, file) =>
          if err
            reject 'File not found'
          else resolve file
    """
    'new Promise(({foo, bar, baz}, reject) => reject(5))'
    'new Promise((reject, reject) -> reject(5))'
    'new Promise(({}, reject) -> reject(5))'
    'new Promise((resolve, reject, somethingElse = reject(5)) =>)'
  ].map (invalidCase) ->
    errors =
      errors: [
        message: 'Expected the Promise rejection reason to be an Error.'
        type: 'CallExpression'
      ]

    {
      ...errors
      ...(
        if typeof invalidCase is 'string'
          code: invalidCase
        else
          invalidCase
      )
    }
