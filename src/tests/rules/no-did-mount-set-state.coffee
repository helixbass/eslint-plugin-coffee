###*
# @fileoverview Prevent usage of setState in componentDidMount
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-did-mount-set-state'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-did-mount-set-state', rule,
  valid: [
    code: """
      Hello = createReactClass
        render: ->
          <div>Hello {@props.name}</div>
    """
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          someNonMemberFunction(arg)
          this.someHandler = this.setState
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          handleEvent = (data) ->
            this.setState({
              data: data
            })
          someClass.onSomeEvent(handleEvent)
      })
    """
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: """
      Hello = createReactClass
        componentDidMount: ->
          @setState
            data: data
    """
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      class Hello extends React.Component
        componentDidMount: ->
          this.setState({
            data: data
          })
    """
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          this.setState({
            data: data
          })
      })
    """
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      class Hello extends React.Component
        componentDidMount: ->
          this.setState({
            data: data
          })
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
      })
    """
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      class Hello extends React.Component
        componentDidMount: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          if (true)
            this.setState({
              data: data
            })
      })
    """
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      class Hello extends React.Component
        componentDidMount: ->
          if (true)
            this.setState({
              data: data
            })
    """
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      Hello = createReactClass({
        componentDidMount: ->
          someClass.onSomeEvent((data) => this.setState({data: data}))
      })
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidMount']
  ,
    code: """
      class Hello extends React.Component
        componentDidMount: ->
          someClass.onSomeEvent (data) => this.setState({data: data})
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidMount']
  ]
