###*
# @fileoverview Forbid target='_blank' attribute
# @author Kevin Miller
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/jsx-no-target-blank'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
defaultErrors = [
  message:
    'Using target="_blank" without rel="noreferrer" is a security risk:' +
    ' see https://html.spec.whatwg.org/multipage/links.html#link-type-noopener'
]

ruleTester.run 'jsx-no-target-blank', rule,
  valid: [
    code: '<a href="foobar"></a>'
  ,
    code: '<a randomTag></a>'
  ,
    # ,
    #   code: '<a target />'
    code: '<a href="foobar" target="_blank" rel="noopener noreferrer"></a>'
  ,
    code: '<a target="_blank" {...spreadProps} rel="noopener noreferrer"></a>'
  ,
    code:
      '<a {...spreadProps} target="_blank" rel="noopener noreferrer" href="http://example.com">s</a>'
  ,
    code: '<a target="_blank" rel="noopener noreferrer" {...spreadProps}></a>'
  ,
    code: '<p target="_blank"></p>'
  ,
    code: '<a href="foobar" target="_BLANK" rel="NOOPENER noreferrer"></a>'
  ,
    code: '<a target="_blank" rel={relValue}></a>'
  ,
    code: '<a target={targetValue} rel="noopener noreferrer"></a>'
  ,
    code: '<a target={targetValue} href="relative/path"></a>'
  ,
    code: '<a target={targetValue} href="/absolute/path"></a>'
  ,
    code: '<a target="_blank" href={ dynamicLink }></a>'
    options: [enforceDynamicLinks: 'never']
  ]
  invalid: [
    code: '<a target="_blank" href="http://example.com"></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" rel="" href="http://example.com"></a>'
    errors: defaultErrors
  ,
    code:
      '<a target="_blank" rel="noopenernoreferrer" href="http://example.com"></a>'
    errors: defaultErrors
  ,
    code: '<a target="_BLANK" href="http://example.com"></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" href="//example.com"></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" href="//example.com" rel={true}></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" href="//example.com" rel={3}></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" href="//example.com" rel={null}></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" href="//example.com" rel></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" href={ dynamicLink }></a>'
    errors: defaultErrors
  ,
    code: '<a target="_blank" href={ dynamicLink }></a>'
    options: [enforceDynamicLinks: 'always']
    errors: defaultErrors
  ]
