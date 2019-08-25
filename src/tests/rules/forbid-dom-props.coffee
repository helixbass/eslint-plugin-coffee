###*
# @fileoverview Tests for forbid-dom-props
###
'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/forbid-dom-props'
{RuleTester} = require 'eslint'
path = require 'path'

parserOptions =
  ecmaVersion: 2018
  sourceType: 'module'
  ecmaFeatures:
    jsx: yes

require 'babel-eslint'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ID_ERROR_MESSAGE = 'Prop `id` is forbidden on DOM Nodes'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'forbid-element-props', rule,
  valid: [
    code: '''
      First = createReactClass
        render: ->
          <Foo id="foo" />
    '''
    options: [forbid: ['id']]
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <Foo id="bar" style={color: "red"} />
      })
    '''
    options: [forbid: ['style', 'id']]
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <this.Foo bar="baz" />
      })
    '''
    options: [forbid: ['id']]
  ,
    code: '''
      class First extends createReactClass
        render: ->
          return <this.foo id="bar" />
    '''
    options: [forbid: ['id']]
  ,
    code: '''
      First = (props) => (
        <this.Foo {...props} />
      )
    '''
    options: [forbid: ['id']]
  ,
    code: '''
      First = (props) => (
        <div name="foo" />
      )
    '''
    options: [forbid: ['id']]
  ]

  invalid: [
    code: '''
      First = createReactClass
        propTypes: externalPropTypes
        render: ->
          <div id="bar" />
    '''
    options: [forbid: ['id']]
    errors: [
      message: ID_ERROR_MESSAGE
      line: 4
      column: 10
      type: 'JSXAttribute'
    ]
  ,
    code: '''
      class First extends createReactClass
        render: ->
          return <div id="bar" />
    '''
    options: [forbid: ['id']]
    errors: [
      message: ID_ERROR_MESSAGE
      line: 3
      column: 17
      type: 'JSXAttribute'
    ]
  ,
    code: '''
      First = (props) => (
        <div id="foo" />
      )
    '''
    options: [forbid: ['id']]
    errors: [
      message: ID_ERROR_MESSAGE
      line: 2
      column: 8
      type: 'JSXAttribute'
    ]
  ]
