### eslint-env jest ###
###*
# @fileoverview Enforce anchor elements to contain accessible content.
# @author Lisa Ring & Niklas Holmberg
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/anchor-has-content'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError =
  message:
    'Anchors must have content and the content must be accessible by a screen reader.'
  type: 'JSXOpeningElement'

ruleTester.run 'anchor-has-content', rule,
  valid: [
    code: '<div />'
  ,
    code: '<a>Foo</a>'
  ,
    code: '<a><Bar /></a>'
  ,
    code: '<a>{foo}</a>'
  ,
    code: '<a>{foo.bar}</a>'
  ,
    code: '<a dangerouslySetInnerHTML={{ __html: "foo" }} />'
  ,
    code: '<a children={children} />'
  ].map parserOptionsMapper
  invalid: [
    code: '<a />', errors: [expectedError]
  ,
    code: '<a><Bar aria-hidden /></a>', errors: [expectedError]
  ,
    code: '<a>{undefined}</a>', errors: [expectedError]
  ].map parserOptionsMapper
