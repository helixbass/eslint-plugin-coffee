###*
# @fileoverview Forbid "button" element without an explicit "type" attribute
# @author Filipp Riabchun
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/button-has-type'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'button-has-type', rule,
  valid: [
    code: '<span/>'
  ,
    code: '<span type="foo"/>'
  ,
    code: '<button type="button"/>'
  ,
    code: '<button type="submit"/>'
  ,
    code: '<button type="reset"/>'
  ,
    code: '<button type="button"/>'
    options: [reset: no]
  ,
    code: 'React.createElement("span")'
  ,
    code: 'React.createElement("span", {type: "foo"})'
  ,
    code: 'React.createElement "span", type: "foo"'
  ,
    code: 'React.createElement("button", {type: "button"})'
  ,
    code: 'React.createElement("button", {type: "submit"})'
  ,
    code: 'React.createElement("button", {type: "reset"})'
  ,
    code: 'React.createElement("button", {type: "button"})'
    options: [reset: no]
  ,
    code: 'document.createElement("button")'
  ,
    code: 'Foo.createElement("span")'
    settings:
      react:
        pragma: 'Foo'
  ]
  invalid: [
    code: '<button/>'
    errors: [message: 'Missing an explicit type attribute for button']
  ,
    code: '<button type="foo"/>'
    errors: [message: '"foo" is an invalid value for button type attribute']
  ,
    code: '<button type={foo}/>'
    errors: [
      message:
        'The button type attribute must be specified by a static string or a trivial ternary expression'
    ]
  ,
    code: '<button type="reset"/>'
    options: [reset: no]
    errors: [message: '"reset" is an invalid value for button type attribute']
  ,
    code: 'React.createElement("button")'
    errors: [message: 'Missing an explicit type attribute for button']
  ,
    code: 'React.createElement("button", {type: "foo"})'
    errors: [message: '"foo" is an invalid value for button type attribute']
  ,
    code: 'React.createElement "button", type: "foo"'
    errors: [message: '"foo" is an invalid value for button type attribute']
  ,
    code: 'React.createElement("button", {type: "reset"})'
    options: [reset: no]
    errors: [message: '"reset" is an invalid value for button type attribute']
  ,
    code: 'Foo.createElement("button")'
    errors: [message: 'Missing an explicit type attribute for button']
    settings:
      react:
        pragma: 'Foo'
  ]
