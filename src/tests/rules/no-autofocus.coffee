### eslint-env jest ###
###*
# @fileoverview Enforce autoFocus prop is not used.
# @author Ethan Cohen <@evcohen>
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/no-autofocus'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError =
  message:
    'The autoFocus prop should not be used, as it can reduce usability and accessibility for users.'
  type: 'JSXAttribute'

ignoreNonDOMSchema = [ignoreNonDOM: yes]

ruleTester.run 'no-autofocus', rule,
  valid: [
    code: '<div />'
  ,
    code: '<div autofocus />'
  ,
    code: '<input autofocus="true" />'
  ,
    code: '<Foo bar />'
  ,
    code: '<Foo autoFocus />', options: ignoreNonDOMSchema
  ,
    code: '<div><div autofocus /></div>', options: ignoreNonDOMSchema
  ].map parserOptionsMapper
  invalid: [
    code: '<div autoFocus />', errors: [expectedError]
  ,
    code: '<div autoFocus={true} />', errors: [expectedError]
  ,
    code: '<div autoFocus={false} />', errors: [expectedError]
  ,
    code: '<div autoFocus={undefined} />', errors: [expectedError]
  ,
    code: '<div autoFocus="true" />', errors: [expectedError]
  ,
    code: '<div autoFocus="false" />', errors: [expectedError]
  ,
    code: '<input autoFocus />', errors: [expectedError]
  ,
    code: '<Foo autoFocus />', errors: [expectedError]
  ].map parserOptionsMapper
