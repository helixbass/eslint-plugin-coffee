###*
# @fileoverview Prevent string definitions for references and prevent referencing this.refs
# @author Tom Hastjarjanto
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-string-refs'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-refs', rule,
  valid: [
    code: '''
      Hello = createReactClass
        componentDidMount: ->
           component = @hello
        render: ->
          <div ref={(c) => @hello = c}>Hello {@props.name}</div>
    '''
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: '''
      Hello = createReactClass({
        componentDidMount: ->
           component = this.refs.hello
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Using this.refs is deprecated.']
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          return <div ref="hello">Hello {this.props.name}</div>
      })
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Using string literals in ref attributes is deprecated.']
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          return <div ref={'hello'}>Hello {this.props.name}</div>
      })
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Using string literals in ref attributes is deprecated.']
  ,
    code: '''
      Hello = createReactClass
        componentDidMount: ->
           component = @refs.hello
        render: ->
          <div ref="hello">Hello {@props.name}</div>
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Using this.refs is deprecated.'
    ,
      message: 'Using string literals in ref attributes is deprecated.'
    ]
  ]
