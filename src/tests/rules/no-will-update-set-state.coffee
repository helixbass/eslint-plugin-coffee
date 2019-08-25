###*
# @fileoverview Prevent usage of setState in componentWillUpdate
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-will-update-set-state'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-will-update-set-state', rule,
  valid: [
    code: """
      Hello = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          someNonMemberFunction(arg)
          this.someHandler = this.setState
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
      })
    """
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          handleEvent = (data) ->
            this.setState({
              data: data
            })
          someClass.onSomeEvent(handleEvent)
      })
    """
  ,
    # parser: 'babel-eslint'
    code: """
      class Hello extends React.Component
        UNSAFE_componentWillUpdate: ->
          this.setState({
            data: data
          })
    """
    settings: react: version: '16.2.0'
  ]

  invalid: [
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          this.setState({
            data: data
          })
      })
    """
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      class Hello extends React.Component
        componentWillUpdate: ->
          this.setState({
            data: data
          })
    """
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          this.setState({
            data: data
          })
      })
    """
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      class Hello extends React.Component
        componentWillUpdate: ->
          this.setState({
            data: data
          })
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
      })
    """
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      class Hello extends React.Component
        componentWillUpdate: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          if (true)
            this.setState({
              data: data
            })
      })
    """
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      class Hello extends React.Component
        componentWillUpdate: ->
          if (true)
            this.setState({
              data: data
            })
    """
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      Hello = createReactClass({
        componentWillUpdate: ->
          someClass.onSomeEvent (data) => this.setState({data: data})
      })
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      class Hello extends React.Component
        componentWillUpdate: ->
          someClass.onSomeEvent((data) => this.setState({data: data}))
    """
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentWillUpdate']
  ,
    code: """
      class Hello extends React.Component
        UNSAFE_componentWillUpdate: ->
          this.setState({
            data: data
          })
    """
    settings: react: version: '16.3.0'
    errors: [message: 'Do not use setState in UNSAFE_componentWillUpdate']
  ,
    code: """
      Hello = createReactClass({
        UNSAFE_componentWillUpdate: ->
          this.setState({
            data: data
          })
      })
    """
    settings: react: version: '16.3.0'
    errors: [message: 'Do not use setState in UNSAFE_componentWillUpdate']
  ]
