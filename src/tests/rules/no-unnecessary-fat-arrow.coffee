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

error = type: 'FunctionExpression'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

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
  ]
