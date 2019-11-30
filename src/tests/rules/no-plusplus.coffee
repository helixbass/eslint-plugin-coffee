###*
# @fileoverview Tests for no-plusplus.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-plusplus'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-plusplus', rule,
  valid: [
    '''
      foo = 0
      foo=+1
    '''
  ,
    # With "allowForLoopAfterthoughts" allowed
    code: '''
      foo = 0
      foo=+1
    '''
    options: [allowForLoopAfterthoughts: yes]
  ]

  invalid: [
    code: '''
      foo = 0
      foo++
    '''
    errors: [message: "Unary operator '++' used.", type: 'UpdateExpression']
  ,
    code: '''
      foo = 0
      foo--
    '''
    errors: [message: "Unary operator '--' used.", type: 'UpdateExpression']
  ,
    # With "allowForLoopAfterthoughts" allowed
    code: '''
      foo = 0
      foo++
    '''
    options: [allowForLoopAfterthoughts: yes]
    errors: [message: "Unary operator '++' used.", type: 'UpdateExpression']
  ,
    code: '''
      for i in [0...l]
        v++
    '''
    options: [allowForLoopAfterthoughts: yes]
    errors: [message: "Unary operator '++' used.", type: 'UpdateExpression']
  ]
