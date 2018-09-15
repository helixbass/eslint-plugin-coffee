###*
# @fileoverview Prevent usage of findDOMNode
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-find-dom-node'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-find-dom-node', rule,
  valid: [
    code: """
      Hello = ->
    """
  ,
    code: """
      Hello = createReactClass({
        render: ->
          return <div>Hello</div>
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          someNonMemberFunction(arg)
          this.someFunc = React.findDOMNode
        render: ->
          return <div>Hello</div>
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          React.someFunc(this)
        render: ->
          return <div>Hello</div>
      })
    """
  ]

  invalid: [
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          React.findDOMNode(this).scrollIntoView()
        render: ->
          return <div>Hello</div>
      })
    """
    errors: [message: 'Do not use findDOMNode']
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          ReactDOM.findDOMNode(this).scrollIntoView()
        render: ->
          return <div>Hello</div>
      })
    """
    errors: [message: 'Do not use findDOMNode']
  ,
    code: """
      class Hello extends Component
        componentDidMount: ->
          findDOMNode(this).scrollIntoView()
        render: ->
          return <div>Hello</div>
    """
    errors: [message: 'Do not use findDOMNode']
  ,
    code: """
      class Hello extends Component
        componentDidMount: ->
          this.node = findDOMNode(this)
        render: ->
          return <div>Hello</div>
    """
    errors: [message: 'Do not use findDOMNode']
  ]
