### eslint-env jest ###
###*
# @fileoverview Enforce scope prop is only used on <th> elements.
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
rule = require 'eslint-plugin-jsx-a11y/lib/rules/scope'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError =
  message: 'The scope prop can only be used on <th> elements.'
  type: 'JSXAttribute'

ruleTester.run 'scope', rule,
  valid: [
    code: '<div />'
  ,
    code: '<div foo />'
  ,
    code: '<th scope />'
  ,
    code: '<th scope="row" />'
  ,
    code: '<th scope={foo} />'
  ,
    code: '<th scope={"col"} {...props} />'
  ,
    code: '<Foo scope="bar" {...props} />'
  ].map parserOptionsMapper
  invalid: [code: '<div scope />', errors: [expectedError]].map(
    parserOptionsMapper
  )
