###*
# @fileoverview Prevent usage of isMounted
# @author Joe Lencioni
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-is-mounted'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-is-mounted', rule,
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
        componentDidUpdate: ->
          someNonMemberFunction(arg)
          this.someFunc = this.isMounted
        render: ->
          return <div>Hello</div>
      })
    """
  ]

  invalid: [
    code: """
      Hello = createReactClass({
        componentDidUpdate: ->
          if (!this.isMounted())
            return
        render: ->
          return <div>Hello</div>
      })
    """
    errors: [message: 'Do not use isMounted']
  ,
    code: """
      Hello = createReactClass({
        someMethod: ->
          if (!this.isMounted())
            return
        render: ->
          return <div onClick={this.someMethod.bind(this)}>Hello</div>
      })
    """
    errors: [message: 'Do not use isMounted']
  ,
    code: """
      class Hello extends React.Component
        someMethod: ->
          return unless @isMounted()
        render: ->
          return <div onClick={this.someMethod.bind(this)}>Hello</div>
    """
    errors: [message: 'Do not use isMounted']
  ]
