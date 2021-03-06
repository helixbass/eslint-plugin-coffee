###*
# @fileoverview Tests for no-class-assign rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-class-assign'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-class-assign', rule,
  valid: [
    '''
      class A
      foo A
    '''
    '''
      A = class A
      foo A
    '''
    '''
      class A
        b: (A) -> A = 0
    '''

    # ignores non class.
    '''
      x = 0
      x = 1
    '''
    '''
      x = ->
      x = 1
    '''
    'foo = (x) -> x = 1'
    '''
      try
      catch x
        x = 1
    '''
  ]
  invalid: [
    code: '''
      class A
      A = 0
    '''
    errors: [messageId: 'class', data: {name: 'A'}, type: 'Identifier']
  ,
    code: '''
      class A
      {A} = 0
    '''
    errors: [messageId: 'class', data: {name: 'A'}, type: 'Identifier']
  ,
    code: '''
      class A
      {b: A = 0} = {}
    '''
    errors: [messageId: 'class', data: {name: 'A'}, type: 'Identifier']
  ,
    code: '''
      A = 0
      class A
    '''
    errors: [messageId: 'class', data: {name: 'A'}, type: 'Identifier']
  ,
    code: '''
      class A
        b: -> A = 0
    '''
    errors: [messageId: 'class', data: {name: 'A'}, type: 'Identifier']
  ,
    code: '''
      A = class A
        b: -> A = 0
    '''
    errors: [messageId: 'class', data: {name: 'A'}, type: 'Identifier']
  ,
    code: '''
      class A
      A = 0
      A = 1
    '''
    errors: [
      messageId: 'class'
      data: name: 'A'
      type: 'Identifier'
      line: 2
      column: 1
    ,
      messageId: 'class'
      data: name: 'A'
      type: 'Identifier'
      line: 3
      column: 1
    ]
  ,
    code: '''
      class A
      class A
    '''
    errors: [messageId: 'class', data: {name: 'A'}, type: 'ClassDeclaration']
  ]
