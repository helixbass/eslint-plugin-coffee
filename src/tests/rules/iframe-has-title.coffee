### eslint-env jest ###
###*
# @fileoverview Enforce iframe elements have a title attribute.
# @author Ethan Cohen
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/iframe-has-title'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError =
  message: '<iframe> elements must have a unique title property.'
  type: 'JSXOpeningElement'

ruleTester.run 'html-has-lang', rule,
  valid: [
    code: '<div />'
  ,
    code: '<iframe title="Unique title" />'
  ,
    code: '<iframe title={foo} />'
  ,
    code: '<FooComponent />'
  ].map parserOptionsMapper
  invalid: [
    code: '<iframe />', errors: [expectedError]
  ,
    code: '<iframe {...props} />', errors: [expectedError]
  ,
    code: '<iframe title={undefined} />', errors: [expectedError]
  ,
    code: '<iframe title="" />', errors: [expectedError]
  ,
    code: '<iframe title={false} />', errors: [expectedError]
  ,
    code: '<iframe title={true} />', errors: [expectedError]
  ,
    code: "<iframe title={''} />", errors: [expectedError]
  ,
    code: '<iframe title={""} />', errors: [expectedError]
  ,
    code: '<iframe title={42} />', errors: [expectedError]
  ].map parserOptionsMapper
