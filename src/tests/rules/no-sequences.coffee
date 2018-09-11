###*
# @fileoverview Tests for no-sequences rule
# @author Julian Rosse
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-sequences'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

error = message: "Don't use sequences"

ruleTester.run 'no-sequences', rule,
  valid: [
    '''
      a
      b
    '''
    '''
      a =
        if b
          c
          d
        else
          e
    '''
    '''
      if a
        ;
    '''
    '''
      while a
        ;
    '''
    '''
      for a in b
        ;
    '''
  ]
  invalid: [
    code: '''
      a; b
    '''
    errors: [error]
  ,
    code: '''
      (a; b)
    '''
    errors: [error]
  ,
    code: '''
      if (a; b)
        c
    '''
    errors: [error]
  ,
    code: '''
      (a; b)
    '''
    errors: [error]
  ,
    code: '''
      while (a; yes)
        a++
    '''
    errors: [error]
  ,
    code: '''
      do (a; b; ->)
    '''
    errors: [error]
  ]
