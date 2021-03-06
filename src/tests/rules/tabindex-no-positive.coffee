### eslint-env jest ###
###*
# @fileoverview Enforce tabIndex value is not greater than zero.
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
rule = require 'eslint-plugin-jsx-a11y/lib/rules/tabindex-no-positive'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError =
  message: 'Avoid positive integer values for tabIndex.'
  type: 'JSXAttribute'

### eslint-disable coffee/no-template-curly-in-string ###

ruleTester.run 'tabindex-no-positive', rule,
  valid: [
    code: '<div />'
  ,
    code: '<div {...props} />'
  ,
    code: '<div id="main" />'
  ,
    code: '<div tabIndex={undefined} />'
  ,
    code: '<div tabIndex={"#{undefined}"} />'
  ,
    code: '<div tabIndex={"#{undefined}#{undefined}"} />'
  ,
    code: '<div tabIndex={0} />'
  ,
    code: '<div tabIndex={-1} />'
  ,
    code: '<div tabIndex={null} />'
  ,
    code: '<div tabIndex={bar()} />'
  ,
    code: '<div tabIndex={bar} />'
  ,
    code: '<div tabIndex={"foobar"} />'
  ,
    code: '<div tabIndex="0" />'
  ,
    code: '<div tabIndex="-1" />'
  ,
    code: '<div tabIndex="-5" />'
  ,
    code: '<div tabIndex="-5.5" />'
  ,
    code: '<div tabIndex={-5.5} />'
  ,
    code: '<div tabIndex={-5} />'
  ].map parserOptionsMapper

  invalid: [
    code: '<div tabIndex="1" />', errors: [expectedError]
  ,
    code: '<div tabIndex={1} />', errors: [expectedError]
  ,
    code: '<div tabIndex={"1"} />', errors: [expectedError]
  ,
    code: '<div tabIndex={1.589} />', errors: [expectedError]
  ].map parserOptionsMapper
