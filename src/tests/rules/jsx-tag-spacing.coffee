###*
# @fileoverview Tests for jsx-tag-spacing
# @author Diogo Franco (Kovensky)
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require '../../rules/jsx-tag-spacing'
{RuleTester} = require 'eslint'

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# generate options object that disables checks other than the tested one

beforeSelfClosingOptions = (option) -> [
  beforeSelfClosing: option
  beforeClosing: 'allow'
]

beforeClosingOptions = (option) -> [
  beforeSelfClosing: 'allow'
  beforeClosing: option
]

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-tag-spacing', rule,
  valid: [
    code: '<App />'
  ,
    code: '<App />'
    options: beforeSelfClosingOptions 'always'
  ,
    code: '<App foo />'
    options: beforeSelfClosingOptions 'always'
  ,
    code: '<App foo={bar} />'
    options: beforeSelfClosingOptions 'always'
  ,
    code: '<App {...props} />'
    options: beforeSelfClosingOptions 'always'
  ,
    code: '<App></App>'
    options: beforeSelfClosingOptions 'always'
  ,
    code: ['<App', '  foo={bar}', '/>'].join '\n'
    options: beforeSelfClosingOptions 'always'
  ,
    code: '<App/>'
    options: beforeSelfClosingOptions 'never'
  ,
    code: '<App foo/>'
    options: beforeSelfClosingOptions 'never'
  ,
    code: '<App foo={bar}/>'
    options: beforeSelfClosingOptions 'never'
  ,
    code: '<App {...props}/>'
    options: beforeSelfClosingOptions 'never'
  ,
    code: '<App></App>'
    options: beforeSelfClosingOptions 'never'
  ,
    code: ['<App', '  foo={bar}', '/>'].join '\n'
    options: beforeSelfClosingOptions 'never'
  ,
    code: '<App />'
    options: beforeClosingOptions 'never'
  ,
    code: '<App></App>'
    options: beforeClosingOptions 'never'
  ,
    # ,
    #   code: ['<App', 'foo="bar"', '>', '</App>'].join '\n'
    #   options: beforeClosingOptions 'never'
    code: ['<App', '   foo="bar"', '>', '</App>'].join '\n'
    options: beforeClosingOptions 'never'
  ,
    # ,
    #   code: '<App ></App >'
    #   options: beforeClosingOptions 'always'
    code: '<App ></App>'
    options: beforeClosingOptions 'always'
  ,
    # ,
    #   code: ['<App', 'foo="bar"', '>', '</App >'].join '\n'
    #   options: beforeClosingOptions 'always'
    code: ['<App', '    foo="bar"', '>', '</App>'].join '\n'
    options: beforeClosingOptions 'always'
  ,
    code: '<App/>'
    options: [
      beforeSelfClosing: 'never'
      beforeClosing: 'never'
    ]
  ,
    code: '<App />'
    options: [
      beforeSelfClosing: 'always'
      beforeClosing: 'always'
    ]
  ]

  invalid: [
    code: '<App/>'
    output: '<App />'
    options: beforeSelfClosingOptions 'always'
    errors: [message: 'A space is required before closing bracket']
  ,
    code: '<App foo/>'
    output: '<App foo />'
    options: beforeSelfClosingOptions 'always'
    errors: [message: 'A space is required before closing bracket']
  ,
    code: '<App foo={bar}/>'
    output: '<App foo={bar} />'
    options: beforeSelfClosingOptions 'always'
    errors: [message: 'A space is required before closing bracket']
  ,
    code: '<App {...props}/>'
    output: '<App {...props} />'
    options: beforeSelfClosingOptions 'always'
    errors: [message: 'A space is required before closing bracket']
  ,
    code: '<App />'
    output: '<App/>'
    options: beforeSelfClosingOptions 'never'
    errors: [message: 'A space is forbidden before closing bracket']
  ,
    code: '<App foo />'
    output: '<App foo/>'
    options: beforeSelfClosingOptions 'never'
    errors: [message: 'A space is forbidden before closing bracket']
  ,
    code: '<App foo={bar} />'
    output: '<App foo={bar}/>'
    options: beforeSelfClosingOptions 'never'
    errors: [message: 'A space is forbidden before closing bracket']
  ,
    code: '<App {...props} />'
    output: '<App {...props}/>'
    options: beforeSelfClosingOptions 'never'
    errors: [message: 'A space is forbidden before closing bracket']
  ,
    code: '<App ></App>'
    output: '<App></App>'
    errors: [message: 'A space is forbidden before closing bracket']
    options: beforeClosingOptions 'never'
    # ,
    #   code: '<App></App >'
    #   output: '<App></App>'
    #   errors: [message: 'A space is forbidden before closing bracket']
    #   options: beforeClosingOptions 'never'
    # ,
    #   code: ['<App', 'foo="bar"', '>', '</App >'].join '\n'
    #   output: ['<App', 'foo="bar"', '>', '</App>'].join '\n'
    #   errors: [message: 'A space is forbidden before closing bracket']
    #   options: beforeClosingOptions 'never'
    # ,
    #   code: '<App></App >'
    #   output: '<App ></App >'
    #   errors: [message: 'Whitespace is required before closing bracket']
    #   options: beforeClosingOptions 'always'
    # ,
    #   code: ['<App', 'foo="bar"', '>', '</App>'].join '\n'
    #   output: ['<App', 'foo="bar"', '>', '</App >'].join '\n'
    #   errors: [message: 'Whitespace is required before closing bracket']
    #   options: beforeClosingOptions 'always'
  ]
