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
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

error = type: 'PassthroughLiteral'

ruleTester.run 'no-backticks', rule,
  valid: [
    'foo = ->'
    # eslint-disable-next-line coffee/no-template-curly-in-string
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
