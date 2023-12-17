###*
# @fileoverview Tests for jsx-quotes rule.
# @author Mathias Schreck <https://github.com/lo1tuma>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/jsx-quotes'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'jsx-quotes', rule,
  valid: [
    code: '<foo bar="baz" />'
  ,
    code: "<foo bar='\"' />"
  ,
    code: '<foo bar="\'" />'
    options: ['prefer-single']
  ,
    code: "<foo bar='baz' />"
    options: ['prefer-single']
  ,
    code: '<foo bar="baz">"</foo>'
  ,
    code: "<foo bar='baz'>'</foo>"
    options: ['prefer-single']
  ,
    code: "<foo bar={'baz'} />"
  ,
    code: '<foo bar={"baz"} />'
    options: ['prefer-single']
  ,
    code: '<foo bar={baz} />'
  ,
    code: '<foo bar />'
  ,
    code: "<foo bar='&quot;' />"
    options: ['prefer-single']
  ,
    code: '<foo bar="&quot;" />'
  ,
    code: "<foo bar='&#39;' />"
    options: ['prefer-single']
  ,
    code: '<foo bar="&#39;" />'
  ]
  invalid: [
    code: "<foo bar='baz' />"
    output: '<foo bar="baz" />'
    errors: [
      message: 'Unexpected usage of singlequote.'
      line: 1
      column: 10
      type: 'Literal'
    ]
  ,
    code: '<foo bar="baz" />'
    output: "<foo bar='baz' />"
    options: ['prefer-single']
    errors: [
      message: 'Unexpected usage of doublequote.'
      line: 1
      column: 10
      type: 'Literal'
    ]
  ,
    code: '<foo bar="&quot;" />'
    output: "<foo bar='&quot;' />"
    options: ['prefer-single']
    errors: [
      message: 'Unexpected usage of doublequote.'
      line: 1
      column: 10
      type: 'Literal'
    ]
  ,
    code: "<foo bar='&#39;' />"
    output: '<foo bar="&#39;" />'
    errors: [
      message: 'Unexpected usage of singlequote.'
      line: 1
      column: 10
      type: 'Literal'
    ]
  ]
