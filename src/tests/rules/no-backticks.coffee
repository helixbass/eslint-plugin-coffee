###*
# @fileoverview Tests for no-backticks rule.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------
rule = require '../../rules/no-backticks'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

error = type: 'PassthroughLiteral'

ruleTester.run 'no-backticks', rule,
  valid: [
    'foo = ->'
    '''
      "a#{b}`c`"
    '''
    '''
      '`a`'
    '''
    '''
      <div>{### comment ###}</div>
    '''
  ]

  invalid: [
    code: '`a`'
    errors: [error]
  ,
    code: 'foo = `a`'
    errors: [error]
  ,
    code: '''
      class A
        `get b() {}`
    '''
    errors: [error]
  ]
