###*
# @fileoverview No mixed linebreaks
# @author Erik Mueller
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/linebreak-style'
{RuleTester} = require 'eslint'
path = require 'path'

EXPECTED_LF_MSG = "Expected linebreaks to be 'LF' but found 'CRLF'."
EXPECTED_CRLF_MSG = "Expected linebreaks to be 'CRLF' but found 'LF'."

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'linebreak-style', rule,
  valid: [
    "a = 'a'\nb = 'b'\n\nfoo = (params) ->\n  ### do stuff ### \n  \n"
  ,
    code:
      "a = 'a'\nb = 'b'\n\nfoo = (params) ->\n  ### do stuff ### \n  \n"
    options: ['unix']
  ,
    code:
      "a = 'a'\r\nb = 'b'\r\n\r\nfoo = (params) ->\r\n  ### do stuff ### \r\n  \r\n"
    options: ['windows']
  ,
    code: "b = 'b'"
    options: ['unix']
  ,
    code: "b = 'b'"
    options: ['windows']
  ]

  invalid: [
    code: "a = 'a'\r\n"
    output: "a = 'a'\n"
    errors: [
      line: 1
      column: 8
      message: EXPECTED_LF_MSG
    ]
  ,
    code: "a = 'a'\r\n"
    output: "a = 'a'\n"
    options: ['unix']
    errors: [
      line: 1
      column: 8
      message: EXPECTED_LF_MSG
    ]
  ,
    code: "a = 'a'\n"
    output: "a = 'a'\r\n"
    options: ['windows']
    errors: [
      line: 1
      column: 8
      message: EXPECTED_CRLF_MSG
    ]
  ,
    code:
      "a = 'a'\nb = 'b'\n\nfoo = (params) ->\r\n  ### do stuff ### \n  \r\n"
    output:
      "a = 'a'\nb = 'b'\n\nfoo = (params) ->\n  ### do stuff ### \n  \n"
    errors: [
      line: 4
      column: 18
      message: EXPECTED_LF_MSG
    ,
      line: 6
      column: 3
      message: EXPECTED_LF_MSG
    ]
  ,
    code:
      "a = 'a'\r\nb = 'b'\r\n\nfoo = (params) ->\r\n  \n  ### do stuff ### \n  \r\n"
    output:
      "a = 'a'\r\nb = 'b'\r\n\r\nfoo = (params) ->\r\n  \r\n  ### do stuff ### \r\n  \r\n"
    options: ['windows']
    errors: [
      line: 3
      column: 1
      message: EXPECTED_CRLF_MSG
    ,
      line: 5
      column: 3
      message: EXPECTED_CRLF_MSG
    ,
      line: 6
      column: 20
      message: EXPECTED_CRLF_MSG
    ]
  ]
