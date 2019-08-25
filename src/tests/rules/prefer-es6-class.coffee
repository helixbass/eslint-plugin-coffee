###*
# @fileoverview Prefer es6 class instead of createClass for React Component
# @author Dan Hamilton
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/prefer-es6-class'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'prefer-es6-class', rule,
  valid: [
    code: """
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
      Hello.displayName = 'Hello'
    """
  ,
    code: """
      export default class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
      Hello.displayName = 'Hello'
    """
  ,
    code: """
      Hello = "foo"
      module.exports = {}
    """
  ,
    code: """
      Hello = createReactClass
        render: ->
          <div>Hello {@props.name}</div>
    """
    options: ['never']
  ,
    code: """
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
    """
    options: ['always']
  ]

  invalid: [
    code: """
      Hello = createReactClass
        displayName: 'Hello'
        render: ->
          <div>Hello {this.props.name}</div>
    """
    errors: [message: 'Component should use es6 class instead of createClass']
  ,
    code: """
      Hello = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
    options: ['always']
    errors: [message: 'Component should use es6 class instead of createClass']
  ,
    code: """
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
    """
    options: ['never']
    errors: [message: 'Component should use createClass instead of es6 class']
  ]
