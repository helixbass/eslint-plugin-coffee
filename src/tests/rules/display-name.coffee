###*
# @fileoverview Prevent missing displayName in a React component definition
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/display-name'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'display-name', rule,
  valid: [
    code: """
      Hello = createReactClass({
        displayName: 'Hello',
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
    options: [ignoreTranspilerName: yes]
  ,
    code: """
      Hello = React.createClass({
        displayName: 'Hello',
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
    options: [ignoreTranspilerName: yes]
    settings:
      react:
        createClass: 'createClass'
  ,
    code: """
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
      Hello.displayName = 'Hello'
    """
    options: [ignoreTranspilerName: yes]
  ,
    code: """
      class Hello
        render: ->
          return 'Hello World'
    """
  ,
    code: """
      class Hello extends Greetings
        @text = 'Hello World'
        render: ->
          return Hello.text
    """
  ,
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #     class Hello extends React.Component {
    #       static get displayName() {
    #         return 'Hello'
    #       }
    #       render() {
    #         return <div>Hello {this.props.name}</div>
    #       }
    #     }
    #   """
    #   options: [ignoreTranspilerName: yes]
    code: """
      class Hello extends React.Component
        @displayName: 'Widget'
        render: ->
          return <div>Hello {this.props.name}</div>
    """
    options: [ignoreTranspilerName: yes]
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
  ,
    code: """
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      export default class Hello
        render: ->
          return <div>Hello {this.props.name}</div>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = null
      Hello = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
  ,
    code: """
      module.exports = createReactClass({
        "displayName": "Hello",
        "render": ->
          return <div>Hello {this.props.name}</div>
      })
    """
  ,
    code: """
      Hello = createReactClass({
        displayName: 'Hello',
        render: ->
          { a, ...b } = obj
          c = { ...d }
          return <div />
      })
    """
    options: [ignoreTranspilerName: yes]
  ,
    code: """
      export default class
        render: ->
          return <div>Hello {this.props.name}</div>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = ->
        return <div>Hello {this.props.name}</div>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = ->
        <div>Hello {@props.name}</div>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = () =>
        return <div>Hello {this.props.name}</div>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      module.exports = Hello = ->
        return <div>Hello {this.props.name}</div>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = ->
        return <div>Hello {this.props.name}</div>
      Hello.displayName = 'Hello'
    """
    options: [ignoreTranspilerName: yes]
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = () =>
        return <div>Hello {this.props.name}</div>
      Hello.displayName = 'Hello'
    """
    options: [ignoreTranspilerName: yes]
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = ->
        return <div>Hello {this.props.name}</div>
      Hello.displayName = 'Hello'
    """
    options: [ignoreTranspilerName: yes]
  ,
    # parser: 'babel-eslint'
    code: """
      Mixins = {
        Greetings: {
          Hello: ->
            return <div>Hello {this.props.name}</div>
        }
      }
      Mixins.Greetings.Hello.displayName = 'Hello'
    """
    options: [ignoreTranspilerName: yes]
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = createReactClass({
        render: ->
          return <div>{this._renderHello()}</div>
        _renderHello: ->
          return <span>Hello {this.props.name}</span>
      })
    """
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = createReactClass({
        displayName: 'Hello',
        render: ->
          return <div>{this._renderHello()}</div>
        _renderHello: ->
          return <span>Hello {this.props.name}</span>
      })
    """
    options: [ignoreTranspilerName: yes]
  ,
    # parser: 'babel-eslint'
    code: """
      Mixin = {
        Button: ->
          return (
            <button />
          )
      }
    """
  ,
    # parser: 'babel-eslint'
    code: """
      obj = {
        pouf: ->
          return any
      }
    """
    options: [ignoreTranspilerName: yes]
  ,
    # parser: 'babel-eslint'
    code: """
      obj = {
        pouf: ->
          return any
      }
    """
  ,
    # parser: 'babel-eslint'
    code: """
      export default {
        renderHello: ->
          {name} = this.props
          return <div>{name}</div>
      }
    """
  ,
    # parser: 'babel-eslint'
    code: """
      import React, { createClass } from 'react'
      export default createClass({
        displayName: 'Foo',
        render: ->
          return <h1>foo</h1>
      })
    """
    options: [ignoreTranspilerName: yes]
    settings:
      react:
        createClass: 'createClass'
  ,
    # parser: 'babel-eslint'
    code: """
      import React, {Component} from "react"
      someDecorator = (ComposedComponent) ->
        return class MyDecorator extends Component
          render: -> <ComposedComponent {...@props} />
      module.exports = someDecorator
    """
  ,
    # parser: 'babel-eslint'
    code: """
      element = (
        <Media query={query} render={() =>
          renderWasCalled = true
          return <div/>
        }/>
      )
    """
  ,
    # parser: 'babel-eslint'
    code: """
      element = (
        <Media query={query} render={->
          renderWasCalled = true
          return <div/>
        }/>
      )
    """
  ,
    # parser: 'babel-eslint'
    code: """
      module.exports = {
        createElement: (tagName) => document.createElement(tagName)
      }
    """
  ,
    # parser: 'babel-eslint'
    code: """
      { createElement } = document
      createElement("a")
    """
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: """
      Hello = createReactClass({
        render: ->
          return React.createElement("div", {}, "text content")
      })
    """
    options: [ignoreTranspilerName: yes]
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      Hello = React.createClass({
        render: ->
          return React.createElement("div", {}, "text content")
      })
    """
    options: [ignoreTranspilerName: yes]
    settings:
      react:
        createClass: 'createClass'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      Hello = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
    options: [ignoreTranspilerName: yes]
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.name}</div>
    """
    options: [ignoreTranspilerName: yes]
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      HelloComponent = ->
        return createReactClass({
          render: ->
            return <div>Hello {this.props.name}</div>
        })
      module.exports = HelloComponent()
    """
    options: [ignoreTranspilerName: yes]
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      module.exports = () =>
        return <div>Hello {props.name}</div>
    """
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      module.exports = ->
        <div>Hello {props.name}</div>
    """
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      module.exports = createReactClass({
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    """
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      Hello = createReactClass({
        _renderHello: ->
          return <span>Hello {this.props.name}</span>
        render: ->
          return <div>{this._renderHello()}</div>
      })
    """
    options: [ignoreTranspilerName: yes]
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      Hello = Foo.createClass({
        _renderHello: ->
          return <span>Hello {this.props.name}</span>
        render: ->
          return <div>{this._renderHello()}</div>
      })
    """
    options: [ignoreTranspilerName: yes]
    # parser: 'babel-eslint'
    settings:
      react:
        pragma: 'Foo'
        createClass: 'createClass'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      ###* @jsx Foo ###
      Hello = Foo.createClass({
        _renderHello: ->
          return <span>Hello {this.props.name}</span>
        render: ->
          return <div>{this._renderHello()}</div>
      })
    """
    options: [ignoreTranspilerName: yes]
    settings:
      react:
        createClass: 'createClass'
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      Mixin = {
        Button: ->
          return (
            <button />
          )
      }
    """
    options: [ignoreTranspilerName: yes]
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      import React, { createElement } from "react"
      export default (props) =>
        return createElement("div", {}, "hello")
    """
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      import React from "react"
      { createElement } = React
      export default (props) =>
        return createElement("div", {}, "hello")
    """
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ,
    code: """
      import React from "react"
      createElement = React.createElement
      export default (props) =>
        return createElement("div", {}, "hello")
    """
    # parser: 'babel-eslint'
    errors: [message: 'Component definition is missing display name']
  ]
