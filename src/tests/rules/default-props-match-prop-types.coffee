###*
# @fileoverview Enforce all defaultProps are declared and non-required propTypes
# @author Vitor Balocco
# @author Roy Sutton
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/default-props-match-prop-types'
{RuleTester} = require 'eslint'

# require 'babel-eslint'

ruleTester = new RuleTester parser: '../../..'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester.run 'default-props-match-prop-types', rule,
  valid: [
    #
    # stateless components
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes =
        foo: React.PropTypes.string.isRequired
        bar: React.PropTypes.string.isRequired
    '''
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes =
        foo: React.PropTypes.string
        bar: React.PropTypes.string.isRequired
      MyStatelessComponent.defaultProps =
        foo: "foo"
    '''
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
    '''
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes =
        bar: React.PropTypes.string.isRequired
      MyStatelessComponent.propTypes.foo = React.PropTypes.string
      MyStatelessComponent.defaultProps =
        foo: "foo"
    '''
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = {
        bar: React.PropTypes.string.isRequired
      }
      MyStatelessComponent.defaultProps = {
        bar: "bar"
      }
    '''
    options: [allowRequiredDefaults: yes]
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        return <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes =
        bar: React.PropTypes.string.isRequired
      MyStatelessComponent.propTypes.foo = React.PropTypes.string
      MyStatelessComponent.defaultProps = {}
      MyStatelessComponent.defaultProps.foo = "foo"
    '''
  ,
    code: '''
      MyStatelessComponent = ({ foo }) ->
        <div>{foo}</div>
      MyStatelessComponent.propTypes = {}
      MyStatelessComponent.propTypes.foo = React.PropTypes.string
      MyStatelessComponent.defaultProps = {}
      MyStatelessComponent.defaultProps.foo = "foo"
    '''
  ,
    code: '''
      types =
        foo: React.PropTypes.string
        bar: React.PropTypes.string.isRequired

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = types
      MyStatelessComponent.defaultProps =
        foo: "foo"
    '''
  ,
    code: '''
      defaults =
        foo: "foo"

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes =
        foo: React.PropTypes.string
        bar: React.PropTypes.string.isRequired
      MyStatelessComponent.defaultProps = defaults
    '''
  ,
    code: '''
      defaults =
        foo: "foo"
      types =
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = types
      MyStatelessComponent.defaultProps = defaults
    '''
  ,
    #
    # createReactClass components
    code: '''
      Greeting = createReactClass
        render: ->
          <div>Hello {this.props.foo} {this.props.bar}</div>
        propTypes:
          foo: React.PropTypes.string.isRequired,
          bar: React.PropTypes.string.isRequired
    '''
  ,
    code: '''
      Greeting = createReactClass({
        render: ->
          return <div>Hello {this.props.foo} {this.props.bar}</div>
        propTypes: {
          foo: React.PropTypes.string,
          bar: React.PropTypes.string.isRequired
        },
        getDefaultProps: ->
          {
            foo: "foo"
          }
      })
    '''
  ,
    code: '''
      Greeting = createReactClass
        render: ->
          <div>Hello {this.props.foo} {this.props.bar}</div>
        propTypes:
          foo: React.PropTypes.string
          bar: React.PropTypes.string
        getDefaultProps: ->
          return {
            foo: "foo",
            bar: "bar"
          }
    '''
  ,
    code: '''
      Greeting = createReactClass
        render: ->
          <div>Hello {this.props.foo} {this.props.bar}</div>
    '''
  ,
    #
    # ES6 class component
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      Greeting.defaultProps =
        foo: "foo"
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      Greeting.defaultProps = {
        foo: "foo"
      }
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {@props.foo} {@props.bar}</h1>
          )
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        bar: React.PropTypes.string.isRequired
      }
      Greeting.propTypes.foo = React.PropTypes.string
      Greeting.defaultProps = {
        foo: "foo"
      }
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        bar: React.PropTypes.string.isRequired
      }
      Greeting.propTypes.foo = React.PropTypes.string
      Greeting.defaultProps = {}
      Greeting.defaultProps.foo = "foo"
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {}
      Greeting.propTypes.foo = React.PropTypes.string
      Greeting.defaultProps = {}
      Greeting.defaultProps.foo = "foo"
    '''
  ,
    #
    # edge cases

    # not a react component
    code: '''
      NotAComponent = ({ foo, bar }) ->
      NotAComponent.defaultProps = {
        bar: "bar"
      }
    '''
  ,
    code: '''
      class Greeting
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.defaulProps = {
        bar: "bar"
      }
    '''
  ,
    # external references
    code: '''
      defaults = require("./defaults")
      types = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string
      }

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = types
      MyStatelessComponent.defaultProps = defaults
    '''
  ,
    code: '''
      defaults = {
        foo: "foo"
      }
      types = require("./propTypes")

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = types
      MyStatelessComponent.defaultProps = defaults
    '''
  ,
    code: '''
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string
      }
      MyStatelessComponent.defaultProps = require("./defaults").foo

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
    '''
  ,
    code: '''
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string
      }
      MyStatelessComponent.defaultProps = require("./defaults").foo
      MyStatelessComponent.defaultProps.bar = "bar"

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
    '''
  ,
    code: '''
      import defaults from "./defaults"

      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string
      }
      MyStatelessComponent.defaultProps = defaults

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
    '''
  ,
    code: '''
      import { foo } from "./defaults"

      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string
      }
      MyStatelessComponent.defaultProps = foo

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
    '''
  ,
    # using spread operator
    code: '''
      component = rowsOfType(GuestlistEntry, (rowData, ownProps) => ({
          ...rowData,
          onPress: () => ownProps.onPress(rowData.id),
      }))
    '''
  ,
    code: '''
      MyStatelessComponent.propTypes = {
        ...stuff,
        foo: React.PropTypes.string
      }
      MyStatelessComponent.defaultProps = {
       foo: "foo"
      }
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
    '''
  ,
    code: '''
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string
      }
      MyStatelessComponent.defaultProps = {
        ...defaults,
      }
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        ...someProps,
        bar: React.PropTypes.string.isRequired
      }
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      Greeting.defaultProps = {
        ...defaults,
        bar: "bar"
      }
    '''
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      Greeting.defaultProps = {
        ...defaults,
        bar: "bar"
      }
    '''

    #
    # with Flow annotations
    # code: [
    #   'type Props = {
    #   '  foo: string
    #   '}

    #   'class Hello extends React.Component {
    #   '  props: Props

    #   '  render() {
    #   '    return <div>Hello {this.props.foo}</div>
    #   '  }
    #   '}
    # ].join '\n
    # parser: 'babel-eslint
    # ,
    # code: [
    #   'type Props = {
    #   '  foo: string,
    #   '  bar?: string
    #   '}

    #   'class Hello extends React.Component {
    #   '  props: Props

    #   '  render() {
    #   '    return <div>Hello {this.props.foo}</div>
    #   '  }
    #   '}

    #   'Hello.defaultProps = {
    #   '  bar: "bar"
    #   '}
    # ].join '\n
    # parser: 'babel-eslint
    # ,
    # code: [
    #   'class Hello extends React.Component {
    #   '  props: {
    #   '    foo: string,
    #   '    bar?: string
    #   '  }

    #   '  render() {
    #   '    return <div>Hello {this.props.foo}</div>
    #   '  }
    #   '}

    #   'Hello.defaultProps = {
    #   '  bar: "bar"
    #   '}
    # ].join '\n
    # parser: 'babel-eslint
    # ,
    # code: [
    #   'class Hello extends React.Component {
    #   '  props: {
    #   '    foo: string
    #   '  }

    #   '  render() {
    #   '    return <div>Hello {this.props.foo}</div>'
    #   '  }'
    #   '}'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'function Hello(props: { foo?: string }) {'
    #   '  return <div>Hello {props.foo}</div>'
    #   '}'

    #   'Hello.defaultProps = { foo: "foo" }'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'function Hello(props: { foo: string }) {'
    #   '  return <div>Hello {foo}</div>'
    #   '}'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'Hello = (props: { foo?: string }) => {'
    #   '  return <div>Hello {props.foo}</div>'
    #   '}'

    #   'Hello.defaultProps = { foo: "foo" }'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'Hello = (props: { foo: string }) => {'
    #   '  return <div>Hello {foo}</div>'
    #   '}'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'Hello = function(props: { foo?: string }) {'
    #   '  return <div>Hello {props.foo}</div>'
    #   '}'

    #   'Hello.defaultProps = { foo: "foo" }'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'Hello = function(props: { foo: string }) {'
    #   '  return <div>Hello {foo}</div>'
    #   '}'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'type Props = {'
    #   '  foo: string,'
    #   '  bar?: string'
    #   '}'

    #   'type Props2 = {'
    #   '  foo: string,'
    #   '  baz?: string'
    #   '}'

    #   'function Hello(props: Props | Props2) {'
    #   '  return <div>Hello {props.foo}</div>'
    #   '}'

    #   'Hello.defaultProps = {'
    #   '  bar: "bar",'
    #   '  baz: "baz"'
    #   '}'
    # ].join '\n'
    # parser: 'babel-eslint'
    # ,
    # code: """
    #     type PropsA = { foo?: string }
    #     type PropsB = { bar?: string, fooBar: string }
    #     type Props = PropsA & PropsB

    #     class Bar extends React.Component {
    #       props: Props
    #       static defaultProps = {
    #         foo: \"foo\",
    #       }

    #       render() {
    #         return <div>{this.props.foo} - {this.props.bar}</div>
    #       }
    #     }
    #   """
    # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'import type Props from "fake"'
    #     'class Hello extends React.Component {'
    #     '  props: Props'
    #     '  render () {'
    #     '    return <div>Hello {this.props.name.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = any'

    #     'Hello = function({ foo }: Props) {'
    #     '  return <div>Hello {foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'import type ImportedProps from "fake"'
    #     'type Props = ImportedProps'
    #     'function Hello(props: Props) {'
    #     '  return <div>Hello {props.name.firstname}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   # don't error when variable is not in scope
    #   code: [
    #     'import type { ImportedType } from "fake"'
    #     'type Props = ImportedType'
    #     'function Hello(props: Props) {'
    #     '  return <div>Hello {props.name.firstname}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   # make sure error is not thrown with multiple assignments
    #   code: [
    #     'import type ImportedProps from "fake"'
    #     'type NestedProps = ImportedProps'
    #     'type Props = NestedProps'
    #     'function Hello(props: Props) {'
    #     '  return <div>Hello {props.name.firstname}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   # don't error when variable is not in scope with intersection
    #   code: [
    #     'import type ImportedProps from "fake"'
    #     'type Props = ImportedProps & {'
    #     '  foo: string'
    #     '}'
    #     'function Hello(props: Props) {'
    #     '  return <div>Hello {props.name.firstname}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
  ]

  invalid: [
    #
    # stateless components
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      MyStatelessComponent.defaultProps = {
        baz: "baz"
      }
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 8
      column: 3
    ]
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = forbidExtraProps
        foo: React.PropTypes.string
        bar: React.PropTypes.string.isRequired
      MyStatelessComponent.defaultProps =
        baz: "baz"
    '''
    settings:
      propWrapperFunctions: ['forbidExtraProps']
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 7
      column: 3
    ]
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      MyStatelessComponent.propTypes = forbidExtraProps(propTypes)
      MyStatelessComponent.defaultProps = {
        baz: "baz"
      }
    '''
    settings:
      propWrapperFunctions: ['forbidExtraProps']
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 9
      column: 3
    ]
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      MyStatelessComponent.defaultProps = {
        baz: "baz"
      }
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 8
      column: 3
    ]
    options: [allowRequiredDefaults: yes]
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      MyStatelessComponent.defaultProps = {
        bar: "bar"
      }
      MyStatelessComponent.defaultProps.baz = "baz"
    '''
    errors: [
      message: 'defaultProp "bar" defined for isRequired propType.'
      line: 8
      column: 3
    ,
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 10
      column: 1
    ]
  ,
    code: '''
      types = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = types
      MyStatelessComponent.defaultProps = {
        bar: "bar"
      }
    '''
    errors: [
      message: 'defaultProp "bar" defined for isRequired propType.'
      line: 10
      column: 3
    ]
  ,
    code: '''
      defaults = {
        foo: "foo"
      }

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string.isRequired,
        bar: React.PropTypes.string
      }
      MyStatelessComponent.defaultProps = defaults
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 2
      column: 3
    ]
  ,
    code: '''
      defaults = {
        foo: "foo"
      }
      types = {
        foo: React.PropTypes.string.isRequired,
        bar: React.PropTypes.string
      }

      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = types
      MyStatelessComponent.defaultProps = defaults
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 2
      column: 3
    ]
  ,
    #
    # createReactClass components
    code: '''
      Greeting = createReactClass({
        render: ->
          return <div>Hello {this.props.foo} {this.props.bar}</div>
        propTypes: {
          foo: React.PropTypes.string,
          bar: React.PropTypes.string.isRequired
        },
        getDefaultProps: ->
          return {
            baz: "baz"
          }
      })
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 10
      column: 7
    ]
  ,
    code: '''
      Greeting = createReactClass
        render: -> <div>Hello {this.props.foo} {this.props.bar}</div>
        propTypes:
          foo: React.PropTypes.string.isRequired,
          bar: React.PropTypes.string
        getDefaultProps: -> {
          foo: "foo"
        }
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 7
      column: 5
    ]
  ,
    #
    # ES6 class component
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      Greeting.defaultProps = {
        baz: "baz"
      }
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 11
      column: 3
    ]
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        foo: React.PropTypes.string.isRequired,
        bar: React.PropTypes.string
      }
      Greeting.defaultProps = {
        foo: "foo"
      }
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 11
      column: 3
    ]
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        bar: React.PropTypes.string.isRequired
      }
      Greeting.propTypes.foo = React.PropTypes.string.isRequired
      Greeting.defaultProps = {}
      Greeting.defaultProps.foo = "foo"
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 11
      column: 1
    ]
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {
        bar: React.PropTypes.string
      }
      Greeting.propTypes.foo = React.PropTypes.string
      Greeting.defaultProps = {}
      Greeting.defaultProps.baz = "baz"
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 11
      column: 1
    ]
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      Greeting.propTypes = {}
      Greeting.propTypes.foo = React.PropTypes.string.isRequired
      Greeting.defaultProps = {}
      Greeting.defaultProps.foo = "foo"
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 9
      column: 1
    ]
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      props = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      Greeting.propTypes = props
      defaults = {
        bar: "bar"
      }
      Greeting.defaultProps = defaults
    '''
    errors: [
      message: 'defaultProp "bar" defined for isRequired propType.'
      line: 12
      column: 3
    ]
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
      props = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string
      }
      defaults = {
        baz: "baz"
      }
      Greeting.propTypes = props
      Greeting.defaultProps = defaults
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 11
      column: 3
    ]
  ,

  ,
    #
    # ES6 classes with static getter methods
    # code: '''
    #   class Hello extends React.Component {
    #     static get propTypes() {
    #       return {
    #         name: React.PropTypes.string.isRequired
    #       }
    #     }
    #     static get defaultProps() {
    #       return {
    #         name: "name"
    #       }
    #     }
    #     render() {
    #       return <div>Hello {this.props.name}</div>
    #     }
    #   }
    # '''
    # errors: [
    #   message: 'defaultProp "name" defined for isRequired propType.'
    #   line: 9
    #   column: 7
    # ]
    # ,
    #   code: '''
    #     'class Hello extends React.Component {
    #     '  static get propTypes() {
    #     '    return {
    #     '      foo: React.PropTypes.string,
    #     '      bar: React.PropTypes.string
    #     '    }
    #     '  }
    #     '  static get defaultProps() {
    #     '    return {
    #     '      baz: "world"
    #     '    }
    #     '  }
    #     '  render() {
    #     '    return <div>Hello {this.props.bar}</div>
    #     '  }
    #     '}
    #   '''
    #   errors: [
    #     message: 'defaultProp "baz" has no corresponding propTypes declaration.'
    #     line: 10
    #     column: 7
    #   ]
    # ,
    #   code: [
    #     'props = {'
    #     '  foo: React.PropTypes.string'
    #     '}'
    #     'defaults = {'
    #     '  baz: "baz"'
    #     '}'

    #     'class Hello extends React.Component {'
    #     '  static get propTypes() {'
    #     '    return props'
    #     '  }'
    #     '  static get defaultProps() {'
    #     '    return defaults'
    #     '  }'
    #     '  render() {'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: 'defaultProp "baz" has no corresponding propTypes declaration.'
    #     line: 5
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'defaults = {'
    #     '  bar: "world"'
    #     '}'

    #     'class Hello extends React.Component {'
    #     '  static get propTypes() {'
    #     '    return {'
    #     '      foo: React.PropTypes.string,'
    #     '      bar: React.PropTypes.string.isRequired'
    #     '    }'
    #     '  }'
    #     '  static get defaultProps() {'
    #     '    return defaults'
    #     '  }'
    #     '  render() {'
    #     '    return <div>Hello {this.props.bar}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: 'defaultProp "bar" defined for isRequired propType.'
    #     line: 2
    #     column: 3
    #   ]
    #
    # ES6 classes with property initializers
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
        @propTypes =
          foo: React.PropTypes.string,
          bar: React.PropTypes.string.isRequired
        @defaultProps =
          bar: "bar"
    '''
    errors: [
      message: 'defaultProp "bar" defined for isRequired propType.'
      line: 10
      column: 5
    ]
  ,
    code: '''
      MyStatelessComponent = ({ foo, bar }) ->
        <div>{foo}{bar}</div>
      MyStatelessComponent.propTypes = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      MyStatelessComponent.defaultProps = {
        baz: "baz"
      }
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 8
      column: 3
    ]
  ,
    code: '''
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
        @propTypes = {
          foo: React.PropTypes.string,
          bar: React.PropTypes.string
        }
        @defaultProps = {
          baz: "baz"
        }
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 11
      column: 5
    ]
  ,
    code: '''
      props = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string.isRequired
      }
      defaults = {
        bar: "bar"
      }
      class Greeting extends React.Component
        render: ->
          return (
            <h1>Hello, {this.props.foo} {this.props.bar}</h1>
          )
        @propTypes = props
        @defaultProps = defaults
    '''
    errors: [
      message: 'defaultProp "bar" defined for isRequired propType.'
      line: 6
      column: 3
    ]
  ,
    code: '''
      props = {
        foo: React.PropTypes.string,
        bar: React.PropTypes.string
      }
      defaults = {
        baz: "baz"
      }
      class Greeting extends React.Component
        render: ->
          <h1>Hello, {@props.foo} {@props.bar}</h1>
        @propTypes = props
        @defaultProps = defaults
    '''
    errors: [
      message: 'defaultProp "baz" has no corresponding propTypes declaration.'
      line: 6
      column: 3
    ]
  ,
    #
    # edge cases
    code: '''
      Greetings = {}
      Greetings.Hello = class extends React.Component
        render: ->
          return <div>Hello {this.props.foo}</div>
      Greetings.Hello.propTypes = {
        foo: React.PropTypes.string.isRequired
      }
      Greetings.Hello.defaultProps = {
        foo: "foo"
      }
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 9
      column: 3
    ]
  ,
    code: '''
      Greetings = ({ foo = "foo" }) =>
        return <div>Hello {this.props.foo}</div>
      Greetings.propTypes = {
        foo: React.PropTypes.string.isRequired
      }
      Greetings.defaultProps = {
        foo: "foo"
      }
    '''
    errors: [
      message: 'defaultProp "foo" defined for isRequired propType.'
      line: 7
      column: 3
    ]

    #
    # with Flow annotations
    # code: [
    #   'class Hello extends React.Component {'
    #   '  props: {'
    #   '    foo: string,'
    #   '    bar?: string'
    #   '  }'

    #   '  render() {'
    #   '    return <div>Hello {this.props.foo}</div>'
    #   '  }'
    #   '}'

    #   'Hello.defaultProps = {'
    #   '  foo: "foo"'
    #   '}'
    # ].join '\n'
    # parser: 'babel-eslint'
    # errors: [
    #   message: 'defaultProp "foo" defined for isRequired propType.'
    #   line: 11
    #   column: 3
    # ]
    # ,
    # # Investigate why this test fails. Flow type not finding foo?
    # code: [
    #   'function Hello(props: { foo: string }) {'
    #   '  return <div>Hello {props.foo}</div>'
    #   '}'
    #   'Hello.defaultProps = {'
    #   '  foo: "foo"'
    #   '}'
    # ].join '\n'
    # parser: 'babel-eslint'
    # errors: [
    #   message: 'defaultProp "foo" defined for isRequired propType.'
    #   line: 5
    #   column: 3
    # ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo: string'
    #     '}'

    #     'function Hello(props: Props) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #     'Hello.defaultProps = {'
    #     '  foo: "foo"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message: 'defaultProp "foo" defined for isRequired propType.'
    #     line: 8
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'Hello = (props: { foo: string, bar?: string }) => {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #     'Hello.defaultProps = { foo: "foo", bar: "bar" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message: 'defaultProp "foo" defined for isRequired propType.'
    #     line: 4
    #     column: 24
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'type Props2 = {'
    #     '  foo: string,'
    #     '  baz?: string'
    #     '}'

    #     'function Hello(props: Props | Props2) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #     'Hello.defaultProps = { foo: "foo", frob: "frob" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message: 'defaultProp "foo" defined for isRequired propType.'
    #     line: 12
    #     column: 24
    #   ,
    #     message: 'defaultProp "frob" has no corresponding propTypes declaration.'
    #     line: 12
    #     column: 36
    #   ]
    # ,
    #   code: """
    #       type PropsA = { foo: string }
    #       type PropsB = { bar: string }
    #       type Props = PropsA & PropsB

    #       class Bar extends React.Component {
    #         props: Props
    #         static defaultProps = {
    #           fooBar: \"fooBar\",
    #           foo: \"foo\",
    #         }

    #         render() {
    #           return <div>{this.props.foo} - {this.props.bar}</div>
    #         }
    #       }
    #     """
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'defaultProp "fooBar" has no corresponding propTypes declaration.'
    #   ,
    #     message: 'defaultProp "foo" defined for isRequired propType.'
    #   ]
  ]
