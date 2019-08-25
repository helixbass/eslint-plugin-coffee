###*
# @fileoverview Tests for jsx-handler-names
# @author Jake Marsh
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/jsx-handler-names'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'jsx-handler-names', rule,
  valid: [
    code: '<TestComponent onChange={this.handleChange} />'
  ,
    code: '<TestComponent onChange={@handleChange} />'
  ,
    code: '<TestComponent onChange={this.props.onChange} />'
  ,
    code: '<TestComponent onChange={this.props.onFoo} />'
  ,
    code: '<TestComponent isSelected={this.props.isSelected} />'
  ,
    code: '<TestComponent shouldDisplay={this.state.shouldDisplay} />'
  ,
    code: '<TestComponent shouldDisplay={arr[0].prop} />'
  ,
    code: '<TestComponent onChange={props.onChange} />'
  ,
    code: '<TestComponent ref={this.handleRef} />'
  ,
    code: '<TestComponent ref={this.somethingRef} />'
  ,
    code: '<TestComponent test={this.props.content} />'
    options: [
      eventHandlerPrefix: 'on'
      eventHandlerPropPrefix: 'on'
    ]
  ,
    code: '<TestComponent only={this.only} />'
  ]

  invalid: [
    code: '<TestComponent onChange={this.doSomethingOnChange} />'
    errors: [
      message: "Handler function for onChange prop key must begin with 'handle'"
    ]
  ,
    code: '<TestComponent onChange={this.handlerChange} />'
    errors: [
      message: "Handler function for onChange prop key must begin with 'handle'"
    ]
  ,
    code: '<TestComponent only={this.handleChange} />'
    errors: [message: "Prop key for handleChange must begin with 'on'"]
  ,
    code: '<TestComponent handleChange={this.handleChange} />'
    errors: [message: "Prop key for handleChange must begin with 'on'"]
  ,
    code: '<TestComponent onChange={@onChange} />'
    errors: [
      message: "Handler function for onChange prop key must begin with 'handle'"
    ]
  ]
