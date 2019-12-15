###*
# @fileoverview Disallows nesting string interpolations.
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-nested-interpolation'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###

ruleTester.run 'no-nested-interpolation', rule,
  valid: ['"Book by #{firstName.toUpperCase()} #{lastName.toUpperCase()}"']
  invalid: [
    code: 'str = "Book by #{"#{firstName} #{lastName}".toUpperCase()}"'
    errors: [
      messageId: 'dontNest'
      line: 1
      column: 18
    ]
  ,
    code: 'str1 = "string #{"interpolation #{"inception"}"}"'
    errors: [
      messageId: 'dontNest'
      line: 1
      column: 18
    ]
  ,
    code: 'str2 = "going #{"in #{"even #{"deeper"}"}"}"'
    errors: [
      messageId: 'dontNest'
      line: 1
      column: 17
    ,
      messageId: 'dontNest'
      line: 1
      column: 23
    ]
  ,
    code: 'str3 = "#{"multiple #{"warnings"}"} for #{"diff #{"nestings"}"}"'
    errors: [
      messageId: 'dontNest'
      line: 1
      column: 11
    ,
      messageId: 'dontNest'
      line: 1
      column: 43
    ]
  ,
    code: '''
      ///
        #{"a#{b}"}
      ///
    '''
    errors: [
      messageId: 'dontNest'
      line: 2
      column: 5
    ]
  ,
    code: '''
      """
        #{///
          a#{b}
        ///}
      """
    '''
    errors: [
      messageId: 'dontNest'
      line: 2
      column: 5
    ]
  ]
