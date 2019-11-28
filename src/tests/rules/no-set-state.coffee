###*
# @fileoverview Prevent usage of setState
# @author Mark Dalgleish
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-set-state'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-set-state', rule,
  valid: [
    code: '''
      Hello = ->
        this.setState({})
    '''
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          someNonMemberFunction(arg)
          this.someHandler = this.setState
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    '''
  ]

  invalid: [
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          this.setState({
            name: this.props.name.toUpperCase()
          })
        render: ->
          return <div>Hello {this.state.name}</div>
      })
    '''
    errors: [message: 'Do not use setState']
  ,
    code: '''
      Hello = createReactClass({
        someMethod: ->
          this.setState({
            name: this.props.name.toUpperCase()
          })
        render: ->
          return <div onClick={this.someMethod.bind(this)}>Hello {this.state.name}</div>
      })
    '''
    errors: [message: 'Do not use setState']
  ,
    code: '''
      class Hello extends React.Component
        someMethod: ->
          this.setState({
            name: this.props.name.toUpperCase()
          })
        render: ->
          return <div onClick={this.someMethod.bind(this)}>Hello {this.state.name}</div>
    '''
    errors: [message: 'Do not use setState']
  ,
    code: '''
      class Hello extends React.Component
        someMethod: () =>
          this.setState({
            name: this.props.name.toUpperCase()
          })
        render: ->
          return <div onClick={this.someMethod.bind(this)}>Hello {this.state.name}</div>
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState']
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div onMouseEnter={() => this.setState({dropdownIndex: index})} />
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState']
  ]
