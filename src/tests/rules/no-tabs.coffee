###*
# @fileoverview Tests for no-tabs rule
# @author Gyandeep Singh
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-tabs'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ERROR_MESSAGE = 'Unexpected tab character.'

ruleTester.run 'no-tabs', rule,
  valid: [
    '''
      test = ->
    '''
    '''
      test = ->
        #   sdfdsf
    '''
  ]
  invalid: [
    code: 'test = ->\t'
    errors: [
      message: ERROR_MESSAGE
      line: 1
      column: 11
    ]
  ,
    code: '###* \t comment test ###'
    errors: [
      message: ERROR_MESSAGE
      line: 1
      column: 7
    ]
  ,
    code: '''
      test = ->
        #\tsdfdsf
    '''
    errors: [
      message: ERROR_MESSAGE
      line: 2
      column: 5
    ]
  ,
    code: '''
      \ttest = ->
        #sdfdsf
    '''
    errors: [
      message: ERROR_MESSAGE
      line: 1
      column: 2
    ]
  ,
    code: '''
      test = ->
        #\tsdfdsf
      \t
    '''
    errors: [
      message: ERROR_MESSAGE
      line: 2
      column: 5
    ,
      message: ERROR_MESSAGE
      line: 3
      column: 2
    ]
  ]