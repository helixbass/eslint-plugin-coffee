###*
# @fileoverview Tests for wrap-regex rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/wrap-regex'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'wrap-regex', rule,
  valid: [
    '(/foo/).test(bar)'
    '(/foo/ig).test(bar)'
    '/foo/'
    'f = 0'
    'a[/b/]'
    '///foo///.test(bar)'
    'x = ///foo///.test(bar)'
  ]
  invalid: [
    code: '/foo/.test(bar)'
    output: '(/foo/).test(bar)'
    errors: [
      message: 'Wrap the regexp literal in parens to disambiguate the slash.'
      type: 'Literal'
    ]
  ,
    code: '/foo/ig.test(bar)'
    output: '(/foo/ig).test(bar)'
    errors: [
      message: 'Wrap the regexp literal in parens to disambiguate the slash.'
      type: 'Literal'
    ]
  ,
    # https://github.com/eslint/eslint/issues/10573
    code: 'if(/foo/ig.test(bar)) then ;'
    output: 'if((/foo/ig).test(bar)) then ;'
    errors: [
      message: 'Wrap the regexp literal in parens to disambiguate the slash.'
      type: 'Literal'
    ]
  ]
