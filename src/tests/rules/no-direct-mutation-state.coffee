###*
# @fileoverview Prevent direct mutation of this.state
# @author David Petersen
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-direct-mutation-state'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-direct-mutation-state', rule,
  valid: [
    code: '''
      Hello = createReactClass
        render: ->
          <div>Hello {@props.name}</div>
    '''
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          obj = {state: {}}
          obj.state.name = "foo"
          return <div>Hello {obj.state.name}</div>
      })
    '''
  ,
    code: '''
      Hello = "foo"
      module.exports = {}
    '''
  ,
    code: '''
      class Hello
        getFoo: ->
          this.state.foo = 'bar'
          return this.state.foo
    '''
  ,
    code: '''
      class Hello extends React.Component
        constructor: ->
          this.state.foo = "bar"
    '''
  ,
    code: '''
      class Hello extends React.Component
        constructor: ->
          this.state.foo = 1
    '''
  ,
    code: """
      class OneComponent extends Component
        constructor: ->
          super()
          class AnotherComponent extends Component
            constructor: ->
              super()
          this.state = {}
    """
  ]

  invalid: [
    code: '''
      Hello = createReactClass
        render: ->
          @state.foo = "bar"
          <div>Hello {@props.name}</div>
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          this.state.foo++
          return <div>Hello {this.props.name}</div>
      })
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          this.state.person.name= "bar"
          return <div>Hello {this.props.name}</div>
      })
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          this.state.person.name.first = "bar"
          return <div>Hello</div>
      })
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          this.state.person.name.first = "bar"
          this.state.person.name.last = "baz"
          return <div>Hello</div>
      })
    '''
    errors: [
      message: 'Do not mutate state directly. Use setState().'
      line: 3
      column: 5
    ,
      message: 'Do not mutate state directly. Use setState().'
      line: 4
      column: 5
    ]
  ,
    code: '''
      class Hello extends React.Component
        constructor: ->
          someFn()
        someFn: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        constructor: (props) ->
          super(props)
          doSomethingAsync(() =>
            this.state = "bad"
          )
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        componentWillMount: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        componentDidMount: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        componentWillReceiveProps: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        shouldComponentUpdate: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        componentWillUpdate: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        componentDidUpdate: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
  ,
    code: '''
      class Hello extends React.Component
        componentWillUnmount: ->
          this.state.foo = "bar"
    '''
    errors: [message: 'Do not mutate state directly. Use setState().']
    ###*
    # Would be nice to prevent this too
    , {
      code: [
        'Hello = createReactClass({',
        '  render: ->',
        '    that = this',
        '    that.state.person.name.first = "bar"',
        '    return <div>Hello</div>',
        '  }',
        '})'
      ].join('\n'),
      errors: [{
        message: 'Do not mutate state directly. Use setState().'
      }]
    }###
  ]
