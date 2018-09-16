###*
# @fileoverview Report "this" being used in stateless functional components.
###
'use strict'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

ERROR_MESSAGE = 'Stateless functional components should not use this'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-this-in-sfc'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-this-in-sfc', rule,
  valid: [
    code: """
    Foo = (props) ->
      { foo } = props
      <div bar={foo} />
    """
  ,
    code: """
    Foo = ({ foo }) ->
      return <div bar={foo} />
    """
  ,
    code: """
    class Foo extends React.Component
      render: ->
        { foo } = this.props
        return <div bar={foo} />
    """
  ,
    code: """
    Foo = createReactClass({
      render: ->
        return <div>{this.props.foo}</div>
    })"""
  ,
    code: """
    Foo = React.createClass({
      render: ->
        return <div>{this.props.foo}</div>
    })"""
    settings: react: createClass: 'createClass'
  ,
    code: """
    foo = (bar) ->
      this.bar = bar
      this.props = 'baz'
      this.getFoo = ->
        return this.bar + this.props
    """
  ,
    code: """
    Foo = (props) ->
      if props.foo then <span>{props.bar}</span> else null
    """
  ,
    code: """
    Foo = (props) ->
      if (props.foo)
        return <div>{props.bar}</div>
      return null
    """
  ,
    code: """
    Foo = (props) ->
      if (props.foo)
        something()
      null
    """
  ,
    code: 'Foo = (props) => <span>{props.foo}</span>'
  ,
    code: 'Foo = ({ foo }) => <span>{foo}</span>'
  ,
    code:
      'Foo = (props) => if props.foo then <span>{props.bar}</span> else null'
  ,
    code: 'Foo = ({ foo, bar }) => if foo then <span>{bar}</span> else null'
  ]
  invalid: [
    code: """
    Foo = (props) ->
      { foo } = @props
      <div>{foo}</div>
    """
    errors: [message: ERROR_MESSAGE]
  ,
    code: """
    Foo = (props) ->
      <div>{this.props.foo}</div>
    """
    errors: [message: ERROR_MESSAGE]
  ,
    code: """
    Foo = (props) ->
      <div>{this.state.foo}</div>
    """
    errors: [message: ERROR_MESSAGE]
  ,
    code: """
    Foo = (props) ->
      { foo } = this.state
      <div>{foo}</div>
    """
    errors: [message: ERROR_MESSAGE]
  ,
    code: """
    Foo = (props) ->
      if props.foo then <div>{this.props.bar}</div> else null
    """
    errors: [message: ERROR_MESSAGE]
  ,
    code: """
    Foo = (props) ->
      if (props.foo)
        <div>{this.props.bar}</div>
      return null
    """
    errors: [message: ERROR_MESSAGE]
  ,
    code: """
    Foo = (props) ->
      if (this.props.foo)
        something()
      null
    """
    errors: [message: ERROR_MESSAGE]
  ,
    code: 'Foo = (props) => <span>{this.props.foo}</span>'
    errors: [message: ERROR_MESSAGE]
  ,
    code:
      'Foo = (props) => if this.props.foo then <span>{props.bar}</span> else null'
    errors: [message: ERROR_MESSAGE]
  ,
    code: """
    Foo = (props) ->
      onClick = (bar) ->
        this.props.onClick()
      <div onClick={onClick}>{this.props.foo}</div>
    """
    errors: [{message: ERROR_MESSAGE}, {message: ERROR_MESSAGE}]
  ]
