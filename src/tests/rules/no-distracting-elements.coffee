### eslint-env jest ###
###*
# @fileoverview Enforce distracting elements are not used.
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
rule = require 'eslint-plugin-jsx-a11y/lib/rules/no-distracting-elements'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError = (element) ->
  message: "Do not use <#{element}> elements as they can create visual accessibility issues and are deprecated."
  type: 'JSXOpeningElement'

ruleTester.run 'no-marquee', rule,
  valid: [
    code: '<div />'
  ,
    code: '<Marquee />'
  ,
    code: '<div marquee />'
  ,
    code: '<Blink />'
  ,
    code: '<div blink />'
  ].map parserOptionsMapper
  invalid: [
    code: '<marquee />', errors: [expectedError 'marquee']
  ,
    code: '<marquee {...props} />', errors: [expectedError 'marquee']
  ,
    code: '<marquee lang={undefined} />', errors: [expectedError 'marquee']
  ,
    code: '<blink />', errors: [expectedError 'blink']
  ,
    code: '<blink {...props} />', errors: [expectedError 'blink']
  ,
    code: '<blink foo={undefined} />', errors: [expectedError 'blink']
  ].map parserOptionsMapper
