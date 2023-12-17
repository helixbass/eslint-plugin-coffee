###*
# @fileoverview Tests for no-floating-decimal rule.
# @author James Allardice
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-floating-decimal'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-floating-decimal', rule,
  valid: ['x = 2.5', 'x = "2.5"']
  invalid: [
    code: 'x = .5'
    output: 'x = 0.5'
    errors: [
      message: 'A leading decimal point can be confused with a dot.'
      type: 'Literal'
    ]
  ,
    code: 'x = -.5'
    output: 'x = -0.5'
    errors: [
      message: 'A leading decimal point can be confused with a dot.'
      type: 'Literal'
    ]
  ,
    code: 'typeof.2'
    output: 'typeof 0.2'
    errors: [
      message: 'A leading decimal point can be confused with a dot.'
      type: 'Literal'
    ]
  ,
    code: '''
      for foo from.2
        ;
    '''
    output: '''
      for foo from 0.2
        ;
    '''
    errors: [
      message: 'A leading decimal point can be confused with a dot.'
      type: 'Literal'
    ]
  ]
