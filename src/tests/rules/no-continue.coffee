###*
# @fileoverview Tests for no-continue rule.
# @author Borislav Zhivkov
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-continue'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-continue', rule,
  valid: [
    '''
      sum = 0
      for i in [0...10]
        if i > 5
          sum += i
    '''
    '''
      sum = 0
      i = 0
      while i < 10
        if i > 5
          sum += i
        i++
    '''
  ]

  invalid: [
    code: '''
      sum = 0
      for i in [0...10]
        if i <= 5
          continue
        sum += i
    '''
    errors: [
      messageId: 'unexpected'
      type: 'ContinueStatement'
    ]
  ,
    code: '''
      sum = 0
      i = 0
      while i < 10
        if i <= 5
          i++
          continue
        sum += i
        i++
    '''
    errors: [
      messageId: 'unexpected'
      type: 'ContinueStatement'
    ]
  ]
