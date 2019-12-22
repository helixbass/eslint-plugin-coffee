###*
# @fileoverview Enforces that the first letter of a class name is capitalized
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/capitalized-class-names'
{RuleTester} = require 'eslint'
{isString} = require 'lodash'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'capitalized-class-names', rule,
  valid: [
    'class Animal'
    'class Wolf extends Animal'
    'class BurmesePython extends Animal'
    'class ELO extends Band'
    'class Eiffel65 extends Band'
    'class nested.Name'
    'class deeply.nested.Name'
    '''
      class A
        class @B
    '''
    'class _Private'
    'class'
    'x = class X'
  ]
  invalid: [
    'class animal'
    'class a.b'
    'class a[B].c'
    '''
      class A
        class @b
    '''
    'class Animals.boa'
  ,
    code: 'X = class x'
    errors: [
      message: 'Class names should be capitalized.'
      type: 'ClassExpression'
    ]
  ].map (code) ->
    return code unless isString code
    {
      code
      errors: [
        message: 'Class names should be capitalized.'
        type: 'ClassDeclaration'
      ]
    }
