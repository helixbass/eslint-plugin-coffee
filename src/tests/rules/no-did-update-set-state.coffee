###*
# @fileoverview Prevent usage of setState in componentDidUpdate
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-did-update-set-state'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-did-update-set-state', rule,
  valid: [
    code: '''
      Hello = createReactClass
        render: ->
          <div>Hello {this.props.name}</div>
    '''
  ,
    code: '''
      Hello = createReactClass
        componentDidUpdate: ->
    '''
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          someNonMemberFunction(arg)
          this.someHandler = this.setState
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          handleEvent = (data) ->
            this.setState({
              data: data
            })
          someClass.onSomeEvent(handleEvent)
      })
    '''
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          this.setState({
            data: data
          })
      })
    '''
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      class Hello extends React.Component
        componentDidUpdate: ->
          this.setState({
            data: data
          })
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          this.setState({
            data: data
          })
      })
    '''
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      class Hello extends React.Component
        componentDidUpdate: ->
          this.setState({
            data: data
          })
    '''
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
      })
    '''
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      class Hello extends React.Component
        componentDidUpdate: ->
          someClass.onSomeEvent (data) ->
            this.setState({
              data: data
            })
    '''
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          if (true)
            this.setState({
              data: data
            })
      })
    '''
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      class Hello extends React.Component
        componentDidUpdate: ->
          if (true)
            this.setState({
              data: data
            })
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      Hello = createReactClass({
        componentDidUpdate: ->
          someClass.onSomeEvent (data) => this.setState({data: data})
      })
    '''
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidUpdate']
  ,
    code: '''
      class Hello extends React.Component
        componentDidUpdate: ->
          someClass.onSomeEvent (data) => @setState data: data
    '''
    # parser: 'babel-eslint'
    options: ['disallow-in-func']
    errors: [message: 'Do not use setState in componentDidUpdate']
  ]
