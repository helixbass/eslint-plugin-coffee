### eslint-env jest ###
###*
# @fileoverview Enforce all aria-* properties are valid.
# @author Ethan Cohen
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{aria} = require 'aria-query'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/aria-props'
{
  default: getSuggestion
} = require 'eslint-plugin-jsx-a11y/lib/util/getSuggestion'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ariaAttributes = [...aria.keys()]

errorMessage = (name) ->
  suggestions = getSuggestion name, ariaAttributes
  message = "#{name}: This attribute is an invalid ARIA attribute."

  return {
    type: 'JSXAttribute'
    message: "#{message} Did you mean to use #{suggestions}?"
  } if suggestions.length > 0

  {
    type: 'JSXAttribute'
    message
  }

# Create basic test cases using all valid role types.
basicValidityTests = ariaAttributes.map (prop) ->
  code: "<div #{prop.toLowerCase()}=\"foobar\" />"

ruleTester.run 'aria-props', rule,
  valid:
    [
      # Variables should pass, as we are only testing literals.
      code: '<div />'
    ,
      code: '<div></div>'
    ,
      code: '<div aria="wee"></div>' # Needs aria-*
    ,
      code: '<div abcARIAdef="true"></div>'
    ,
      code: '<div fooaria-foobar="true"></div>'
    ,
      code: '<div fooaria-hidden="true"></div>'
    ,
      code: '<Bar baz />'
    ,
      code: '<input type="text" aria-errormessage="foobar" />'
    ]
    .concat basicValidityTests
    .map parserOptionsMapper
  invalid: [
    code: '<div aria-="foobar" />', errors: [errorMessage 'aria-']
  ,
    code: '<div aria-labeledby="foobar" />'
    errors: [errorMessage 'aria-labeledby']
  ,
    code: '<div aria-skldjfaria-klajsd="foobar" />'
    errors: [errorMessage 'aria-skldjfaria-klajsd']
  ].map parserOptionsMapper
