###*
# @fileoverview Tests for no-cond-assign rule.
# @author Stephen Murray <spmurrayzzz>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-cond-assign'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-cond-assign', rule,
  valid: [
    '''
      x = 0
      if x == 0
        b = 1
    '''
    '''
      x = 0
      if x is 0
        b = 1
    '''
  ,
    code: '''
      x = 0
      if x == 0
        b = 1
    '''
    options: ['always']
  ,
    '''
      x = 5
      while x < 5
        x = x + 1
    '''
    '''
      if (someNode = someNode.parentNode) isnt null
        ;
    '''
  ,
    code: '''
      if (someNode = someNode.parentNode) isnt null
        ;
    '''
    options: ['except-parens']
  ,
    'if (a = b) then ;'
    'yes if (a = b)'
    'a = b if yes'
    'while (a = b) then ;'
    'if someNode or (someNode = parentNode) then ;'
    'while someNode || (someNode = parentNode) then ;'
  ,
    code: '''
      if ((node) -> node = parentNode)(someNode)
        ;
    '''
    options: ['except-parens']
  ,
    code: '''
      if ((node) -> node = parentNode)(someNode)
        ;
    '''
    options: ['always']
  ,
    code: '''
      if do (node = someNode) -> node = parentNode
        ;
    '''
    options: ['always']
  ,
    code: '''
      if (node) -> return node = parentNode
        ;
    '''
    options: ['except-parens']
  ,
    code: '''
      if (node) -> return node = parentNode
        ;
    '''
    options: ['always']
  ,
    code: 'x = 0', options: ['always']
  ,
    'b = if (x is 0) then 1 else 0'
  ]
  invalid: [
    code: '''
      if x = 0
        b = 1
    '''
    errors: [messageId: 'missing', type: 'IfStatement', line: 1, column: 4]
  ,
    code: '''
      while x = 0
        b = 1
    '''
    errors: [messageId: 'missing', type: 'WhileStatement']
  ,
    code: 'if someNode or (someNode = parentNode) then ;'
    options: ['always']
    errors: [
      messageId: 'unexpected'
      data: type: "an 'if' statement"
      type: 'IfStatement'
    ]
  ,
    code: 'while someNode || (someNode = parentNode) then ;'
    options: ['always']
    errors: [
      messageId: 'unexpected'
      data: type: "a 'while' statement"
      type: 'WhileStatement'
    ]
  ,
    code: 'if x = 0 then ;'
    options: ['always']
    errors: [
      messageId: 'unexpected'
      data: type: "an 'if' statement"
      type: 'IfStatement'
    ]
  ,
    code: 'yes while x = 0'
    options: ['always']
    errors: [
      messageId: 'unexpected'
      data: type: "a 'while' statement"
      type: 'WhileStatement'
    ]
  ,
    code: 'if (x = 0) then ;'
    options: ['always']
    errors: [
      messageId: 'unexpected'
      data: type: "an 'if' statement"
      type: 'IfStatement'
    ]
  ,
    code: 'while (x = 0) then ;'
    options: ['always']
    errors: [
      messageId: 'unexpected'
      data: type: "a 'while' statement"
      type: 'WhileStatement'
    ]
  ]
