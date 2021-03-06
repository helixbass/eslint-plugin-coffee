###*
# @fileoverview Prevent multiple component definition per file
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-multi-comp'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-multi-comp', rule,
  valid: [
    code: '''
      Hello = require('./components/Hello')
      HelloJohn = createReactClass({
        render: ->
          return <Hello name="John" />
      })
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
    '''
  ,
    code: '''
      Heading = createReactClass({
        render: ->
          return (
            <div>
              {this.props.buttons.map (button, index) ->
                <Button {...button} key={index}/>
              }
            </div>
          )
      })
    '''
  ,
    code: '''
      Hello = (props) ->
        <div>Hello {props.name}</div>
      HelloAgain = (props) ->
        <div>Hello again {props.name}</div>
    '''
    # parser: 'babel-eslint'
    options: [ignoreStateless: yes]
  ,
    code: '''
      Hello = (props) ->
        <div>Hello {props.name}</div>
      class HelloJohn extends React.Component
        render: ->
          return <Hello name="John" />
    '''
    options: [ignoreStateless: yes]
  ,
    # multiple non-components
    code: '''
      import React, { createElement } from "react"
      helperFoo = () =>
        return true
      helperBar = () ->
        false
      RealComponent = () ->
        createElement("img")
    '''
  ]

  invalid: [
    code: '''
      Hello = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
      HelloJohn = createReactClass({
        render: ->
          return <Hello name="John" />
      })
    '''
    errors: [
      message: 'Declare only one React component per file'
      line: 5
    ]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
      class HelloJohn extends React.Component
        render: ->
          return <Hello name="John" />
      class HelloJohnny extends React.Component
        render: ->
          return <Hello name="Johnny" />
    '''
    errors: [
      message: 'Declare only one React component per file'
      line: 4
    ,
      message: 'Declare only one React component per file'
      line: 7
    ]
  ,
    code: '''
      Hello = (props) ->
        <div>Hello {props.name}</div>
      HelloAgain = (props) ->
        <div>Hello again {props.name}</div>
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Declare only one React component per file'
      line: 3
    ]
  ,
    code: '''
      Hello = (props) ->
        <div>Hello {props.name}</div>
      class HelloJohn extends React.Component
        render: ->
          return <Hello name="John" />
    '''
    errors: [
      message: 'Declare only one React component per file'
      line: 3
    ]
  ,
    code: '''
      export default
        renderHello: (props) ->
          {name} = props
          <div>{name}</div>
        renderHello2: (props) ->
          {name} = props
          <div>{name}</div>
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Declare only one React component per file'
      line: 5
    ]
  ]
