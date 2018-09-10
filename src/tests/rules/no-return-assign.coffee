###*
# @fileoverview Tests for no-return-assign.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-return-assign'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

error =
  message: 'Return statement should not contain assignment.'
  type: 'ReturnStatement'
implicitError =
  message: 'Implicit return statement should not contain assignment.'
  type: 'AssignmentExpression'

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-return-assign', rule,
  valid: [
    "module.exports = {'a': 1}"
    'result = a * b'
    '''
      ->
        result = a * b
        return result
    '''
    '-> return (result = a * b)'
  ,
    code: '''
      ->
        result = a * b
        return result
    '''
    options: ['except-parens']
  ,
    code: '-> return (result = a * b)'
    options: ['except-parens']
  ,
    code: '-> (result = a * b)'
    options: ['except-parens']
  ,
    code: '''
      ->
        result = a * b
        return result
    '''
    options: ['always']
  ,
    code: '''
      ->
        return ->
          result = a * b
          null
    '''
    options: ['always']
  ,
    code: '=> return (result = a * b)'
    options: ['except-parens']
  ,
    code: '''
      =>
        result = a * b
        null
    '''
    options: ['except-parens']
  ,
    '''
      ->
        while yes
          return a if b
          c = d
    '''
    '''
      ->
        for a in b
          return c
          d = e
    '''
    '''
      class A
        constructor: ->
          @a = 1
    '''
  ]
  invalid: [
    code: '-> return result = a * b'
    errors: [error]
  ,
    code: '-> result = a * b'
    errors: [implicitError]
  ,
    code: '-> return result = (a * b)'
    errors: [error]
  ,
    code: '-> return result = a * b'
    options: ['except-parens']
    errors: [error]
  ,
    code: '-> return result = (a * b)'
    options: ['except-parens']
    errors: [error]
  ,
    code: '=> return result = a * b'
    errors: [error]
  ,
    code: '=> result = a * b'
    errors: ['Implicit return statement should not contain assignment.']
  ,
    code: '-> return result = a * b'
    options: ['always']
    errors: [error]
  ,
    code: '-> return (result = a * b)'
    options: ['always']
    errors: [error]
  ,
    code: '-> (result = a * b)'
    options: ['always']
    errors: [implicitError]
  ,
    code: '-> return result || (result = a * b)'
    options: ['always']
    errors: [error]
  ,
    code: '-> result || (result = a * b)'
    options: ['always']
    errors: [{...implicitError, type: 'LogicalExpression'}]
  ]
