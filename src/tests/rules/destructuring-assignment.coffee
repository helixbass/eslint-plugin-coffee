###*
# @fileoverview Rule to forbid or enforce destructuring assignment consistency.
### #
'use strict'

rule = require '../../rules/destructuring-assignment'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'destructuring-assignment', rule,
  valid: [
    code: """
      Foo = class extends React.PureComponent
        render: ->
          { foo } = @props
          <div>{foo}</div>
    """
    options: ['always']
  ,
    # parser: 'babel-eslint'
    code: """
      MyComponent = ({ id, className }) => (
        <div id={id} className={className} />
      )
    """
  ,
    code: """
      MyComponent = (props) =>
        { id, className } = props
        return <div id={id} className={className} />
    """
  ,
    # parser: 'babel-eslint'
    code: """
      MyComponent = ({ id, className }) => (
        <div id={id} className={className} />
      )
    """
    options: ['always']
  ,
    code: """
      MyComponent = (props) =>
        { id, className } = props
        return <div id={id} className={className} />
    """
  ,
    code: """
      MyComponent = (props) =>
        { id, className } = props
        return <div id={id} className={className} />
    """
    options: ['always']
  ,
    code: """
      MyComponent = (props) => (
        <div id={id} props={props} />
      )
    """
  ,
    code: """
      MyComponent = (props) => (
        <div id={id} props={props} />
      )
    """
    options: ['always']
  ,
    code: """
      MyComponent = (props, { color }) => (
        <div id={id} props={props} color={color} />
      )
    """
  ,
    code: """
      MyComponent = (props, { color }) => (
        <div id={id} props={props} color={color} />
      )
    """
    options: ['always']
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          return <div>{this.props.foo}</div>
    """
    options: ['never']
  ,
    code: """
      class Foo extends React.Component
        doStuff: ->
        render: ->
          return <div>{this.props.foo}</div>
    """
    options: ['never']
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          { foo } = this.props
          return <div>{foo}</div>
    """
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          { foo } = this.props
          return <div>{foo}</div>
    """
    options: ['always']
  ,
    # parser: 'babel-eslint'
    code: """
      Foo = class extends React.PureComponent
        render: ->
          { foo } = this.props
          return <div>{foo}</div>
    """
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          { foo } = this.props
          return <div>{foo}</div>
    """
    options: ['always']
  ,
    # parser: 'babel-eslint'
    code: """
      MyComponent = (props) =>
        { h, i } = hi
        return <div id={props.id} className={props.className} />
    """
    options: ['never']
  ,
    # parser: 'babel-eslint'
    code: """
      Foo = class extends React.PureComponent
        constructor: ->
          @state = {}
          @state.foo = 'bar'
    """
    options: ['always']
  ,
    code: '''
      div = styled.div"""
        & .button {
          border-radius: #{(props) => props.borderRadius}px
        }
      """
    '''
  ,
    # ,
    #   code: """
    #     export default (context: $Context) => ({
    #       foo: context.bar
    #     })
    #   """
    #   # parser: 'babel-eslint'
    code: """
      class Foo
        bar: (context) ->
          context.baz
    """
  ,
    code: """
      class Foo
        bar: (props) ->
          return props.baz
    """
  ]

  invalid: [
    code: """
      MyComponent = (props) =>
        return (<div id={props.id} />)
    """
    errors: [message: 'Must use destructuring props assignment']
  ,
    code: """
      MyComponent = ({ id, className }) => (
        <div id={id} className={className} />
      )
    """
    options: ['never']
    errors: [
      message: 'Must never use destructuring props assignment in SFC argument'
    ]
  ,
    code: """
      MyComponent = (props, { color }) => (
        <div id={props.id} className={props.className} />
      )
    """
    options: ['never']
    errors: [
      message: 'Must never use destructuring context assignment in SFC argument'
    ]
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          <div>{@props.foo}</div>
    """
    errors: [message: 'Must use destructuring props assignment']
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          return <div>{this.state.foo}</div>
    """
    errors: [message: 'Must use destructuring state assignment']
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          return <div>{this.context.foo}</div>
    """
    errors: [message: 'Must use destructuring context assignment']
  ,
    code: """
      class Foo extends React.Component
        render: ->
        foo: ->
          return this.props.children
    """
    errors: [message: 'Must use destructuring props assignment']
  ,
    code: """
      Hello = React.createClass
        render: ->
          <Text>{this.props.foo}</Text>
    """
    errors: [message: 'Must use destructuring props assignment']
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          foo = this.props.foo
          return <div>{foo}</div>
    """
    errors: [message: 'Must use destructuring props assignment']
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          { foo } = this.props
          return <div>{foo}</div>
    """
    options: ['never']
    # parser: 'babel-eslint'
    errors: [message: 'Must never use destructuring props assignment']
  ,
    code: """
      MyComponent = (props) =>
        { id, className } = props
        return <div id={id} className={className} />
    """
    options: ['never']
    # parser: 'babel-eslint'
    errors: [message: 'Must never use destructuring props assignment']
  ,
    code: """
      Foo = class extends React.PureComponent
        render: ->
          { foo } = @state
          <div>{foo}</div>
    """
    options: ['never']
    # parser: 'babel-eslint'
    errors: [message: 'Must never use destructuring state assignment']
  ]
