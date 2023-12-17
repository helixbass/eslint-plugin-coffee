###*
# @fileoverview Tests for no-ex-assign rule.
# @author Stephen Murray <spmurrayzzz>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-ex-assign'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-ex-assign', rule,
  valid: [
    '''
      try
      catch e
        three = 2 + 1
   '''
    '''
      try
      catch {e}
        @something = 2
    '''
    '''
      ->
        try
        catch e
         return no
    '''
  ]
  invalid: [
    code: '''
      try
      catch e
        e = 10
    '''
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '''
      try
      catch ex
        ex = 10
    '''
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '''
      try
      catch ex
        [ex] = []
    '''
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '''
      try
      catch ex
        {x: ex = 0} = {}
    '''
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '''
      try
      catch {message}
        message = 10
    '''
    errors: [messageId: 'unexpected', type: 'Identifier']
  ]
