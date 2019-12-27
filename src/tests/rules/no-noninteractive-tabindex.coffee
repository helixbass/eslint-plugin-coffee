### eslint-env jest ###
###*
# @fileoverview Disallow tabindex on static and noninteractive elements
# @author jessebeach
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
{configs} = require 'eslint-plugin-jsx-a11y'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/no-noninteractive-tabindex'
{
  default: ruleOptionsMapperFactory
} = require '../eslint-plugin-jsx-a11y-rule-options-mapper-factory'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleName = 'no-noninteractive-tabindex'

expectedError =
  message: '`tabIndex` should only be declared on interactive elements.'
  type: 'JSXAttribute'

alwaysValid = [
  code: '<MyButton tabIndex={0} />'
,
  code: '<button />'
,
  code: '<button tabIndex="0" />'
,
  code: '<button tabIndex={0} />'
,
  code: '<div />'
,
  code: '<div tabIndex="-1" />'
,
  code: '<div role="button" tabIndex="0" />'
,
  code: '<div role="article" tabIndex="-1" />'
,
  code: '<article tabIndex="-1" />'
]

neverValid = [
  code: '<div tabIndex="0" />', errors: [expectedError]
,
  code: '<div role="article" tabIndex="0" />', errors: [expectedError]
,
  code: '<article tabIndex="0" />', errors: [expectedError]
,
  code: '<article tabIndex={0} />', errors: [expectedError]
]

recommendedOptions = configs.recommended.rules["jsx-a11y/#{ruleName}"][1] or {}

ruleTester.run "#{ruleName}:recommended", rule,
  valid:
    [
      ...alwaysValid
    ,
      code: '<div role="tabpanel" tabIndex="0" />'
    ,
      # Expressions should fail in strict mode
      code: '<div role={ROLE_BUTTON} onClick={() => {}} tabIndex="0" />'
    ]
    .map ruleOptionsMapperFactory recommendedOptions
    .map parserOptionsMapper
  invalid:
    [...neverValid]
    .map(ruleOptionsMapperFactory recommendedOptions)
    .map parserOptionsMapper

ruleTester.run "#{ruleName}:strict", rule,
  valid: [...alwaysValid].map parserOptionsMapper
  invalid: [
    ...neverValid
  ,
    code: '<div role="tabpanel" tabIndex="0" />', errors: [expectedError]
  ,
    # Expressions should fail in strict mode
    code: '<div role={ROLE_BUTTON} onClick={() => {}} tabIndex="0" />'
    errors: [expectedError]
  ].map parserOptionsMapper
