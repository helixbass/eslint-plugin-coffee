###*
# @fileoverview Prohibit implicit calls.
# @author Julian Rosse
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/implicit-call'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester.run 'implicit-call', rule,
  valid: [
    'f()'
    'f(a)'
    'do ->'
    '''
      f(
        a
        b
      )
    '''
    'new A'
    'new A()'
    'new A(b)'
  ,
    code: 'f()'
  ]
  invalid: [
    code: 'f a'
    errors: 1
  ,
    code: '''
      f
        a: 1
        b: 2
    '''
    errors: 1
  ,
    code: 'new A b'
    errors: 1
  ,
    code: 'f a'
    errors: 1
  ,
    code: '''
      ->
        f a for a in b
    '''
    errors: 1
  ]
