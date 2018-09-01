###*
# @fileoverview Test enforcement of no inline comments rule.
# @author Greg Cochard
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-inline-comments'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
lineError =
  messsage: 'Unexpected comment inline with code.'
  type: 'Line'
blockError =
  messsage: 'Unexpected comment inline with code.'
  type: 'Block'

ruleTester.run 'no-inline-comments', rule,
  valid: [
    '# A valid comment before code\na = 1'
    'a = 2\n# A valid comment after code'
    '# A solitary comment'
    'a = 1 # eslint-disable-line some-rule'
    'a = 1 ### eslint-disable-line some-rule ###'
  ]

  invalid: [
    code: 'a = 1 ###A block comment inline after code###'
    errors: [blockError]
  ,
    code: '###A block comment inline before code### a = 2'
    errors: [blockError]
  ,
    code: 'a = 3 #A comment inline with code'
    errors: [lineError]
  ,
    code: 'a = 3 # someday use eslint-disable-line here'
    errors: [lineError]
  ]
