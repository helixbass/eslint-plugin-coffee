###*
# @fileoverview Tests for no-div-regex rule.
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-div-regex'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-div-regex', rule,
  valid: ["f = -> /foo/ig.test('bar')", 'f = -> /\\=foo/', 'f = -> ///=foo///']
  invalid: [
    code: 'f = -> /=foo/'
    errors: [messageId: 'unexpected', type: 'Literal']
  ]
