###*
# @fileoverview This rule should warn about unnecessary usage of fat arrows.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-unnecessary-fat-arrow'
{RuleTester} = require 'eslint'
path = require 'path'

error = type: 'ArrowFunctionExpression'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-unnecessary-fat-arrow', rule,
  valid: [
    '=> @'
    '=> this'
    '(@b) =>'
    '=> => @'
    '''
      =>
        a = -> b
        @
    '''
    '=> @b for c in d'
    '->'
    '-> @'
    '''
      class A
        b: ({@c}) =>
    '''
  ]

  invalid: [
    code: '=>'
    errors: [error]
  ,
    code: '=> => b'
    errors: [error]
  ,
    code: '=> -> b'
    errors: [error]
  ,
    code: '=> -> @'
    errors: [error]
  ,
    code: '''
      class A
        b: () =>
    '''
    errors: [type: 'FunctionExpression']
  ]
