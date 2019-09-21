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
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
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
      column: 10
    ]
  ,
    code: '###* \t comment test ###'
    errors: [
      message: ERROR_MESSAGE
      line: 1
      column: 6
    ]
  ,
    code: '''
      test = ->
        #\tsdfdsf
    '''
    errors: [
      message: ERROR_MESSAGE
      line: 2
      column: 4
    ]
  ,
    code: '''
      \ttest = ->
        #sdfdsf
    '''
    errors: [
      message: ERROR_MESSAGE
      line: 1
      column: 1
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
      column: 4
    ,
      message: ERROR_MESSAGE
      line: 3
      column: 1
    ]
  ]
