###*
# @fileoverview Enforce a defaultProps definition for every prop that is not a required prop.
# @author Vitor Balocco
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/require-default-props'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester.run 'require-default-props', rule,
  valid: [
    #
    # stateless components
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string.isRequired,'
      '  bar: PropTypes.string.isRequired'
      '}'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'MyStatelessComponent.defaultProps = {'
      '  foo: "foo"'
      '}'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  <div>{foo}{bar}</div>'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  bar: PropTypes.string.isRequired'
      '}'
      'MyStatelessComponent.propTypes.foo = PropTypes.string'
      'MyStatelessComponent.defaultProps = {'
      '  foo: "foo"'
      '}'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  bar: PropTypes.string.isRequired'
      '}'
      'MyStatelessComponent.propTypes.foo = PropTypes.string'
      'MyStatelessComponent.defaultProps = {}'
      'MyStatelessComponent.defaultProps.foo = "foo"'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent = ({ foo }) ->'
      '  return <div>{foo}</div>'
      'MyStatelessComponent.propTypes = {}'
      'MyStatelessComponent.propTypes.foo = PropTypes.string'
      'MyStatelessComponent.defaultProps = {}'
      'MyStatelessComponent.defaultProps.foo = "foo"'
    ].join '\n'
  ,
    code: [
      'types = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = types'
      'MyStatelessComponent.defaultProps = {'
      '  foo: "foo"'
      '}'
    ].join '\n'
  ,
    code: [
      'defaults = {'
      '  foo: "foo"'
      '}'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'MyStatelessComponent.defaultProps = defaults'
    ].join '\n'
  ,
    code: [
      'defaults = {'
      '  foo: "foo"'
      '}'
      'types = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = types'
      'MyStatelessComponent.defaultProps = defaults'
    ].join '\n'
  ,
    #
    # createReactClass components
    code: [
      'Greeting = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.foo} {this.props.bar}</div>'
      '  propTypes: {'
      '    foo: PropTypes.string.isRequired,'
      '    bar: PropTypes.string.isRequired'
      '  }'
      '})'
    ].join '\n'
  ,
    code: [
      'Greeting = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.foo} {this.props.bar}</div>'
      '  propTypes: {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string.isRequired'
      '  },'
      '  getDefaultProps: ->'
      '    return {'
      '      foo: "foo"'
      '    }'
      '})'
    ].join '\n'
  ,
    code: [
      'Greeting = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.foo} {this.props.bar}</div>'
      '  propTypes: {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string'
      '  },'
      '  getDefaultProps: ->'
      '    return {'
      '      foo: "foo",'
      '      bar: "bar"'
      '    }'
      '})'
    ].join '\n'
  ,
    code: [
      'Greeting = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.foo} {this.props.bar}</div>'
      '})'
    ].join '\n'
  ,
    #
    # ES6 class component
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  foo: PropTypes.string.isRequired,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.defaultProps = {'
      '  foo: "foo"'
      '}'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.defaultProps = {'
      '  foo: "foo"'
      '}'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.propTypes.foo = PropTypes.string'
      'Greeting.defaultProps = {'
      '  foo: "foo"'
      '}'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.propTypes.foo = PropTypes.string'
      'Greeting.defaultProps = {}'
      'Greeting.defaultProps.foo = "foo"'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {}'
      'Greeting.propTypes.foo = PropTypes.string'
      'Greeting.defaultProps = {}'
      'Greeting.defaultProps.foo = "foo"'
    ].join '\n'
  ,
    #
    # edge cases

    # not a react component
    code: [
      'NotAComponent = ({ foo, bar }) ->'
      'NotAComponent.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
    ].join '\n'
  ,
    code: [
      'class Greeting'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  bar: PropTypes.string.isRequired'
      '}'
    ].join '\n'
  ,
    # external references
    code: [
      'defaults = require("./defaults")'
      'types = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string'
      '}'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = types'
      'MyStatelessComponent.defaultProps = defaults'
    ].join '\n'
  ,
    code: [
      'defaults = {'
      '  foo: "foo"'
      '}'
      'types = require("./propTypes")'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = types'
      'MyStatelessComponent.defaultProps = defaults'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string'
      '}'
      'MyStatelessComponent.defaultProps = require("./defaults").foo'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string'
      '}'
      'MyStatelessComponent.defaultProps = require("./defaults").foo'
      'MyStatelessComponent.defaultProps.bar = "bar"'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
    ].join '\n'
  ,
    code: [
      'import defaults from "./defaults"'

      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string'
      '}'
      'MyStatelessComponent.defaultProps = defaults'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
    ].join '\n'
  ,
    code: [
      'import { foo } from "./defaults"'

      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string'
      '}'
      'MyStatelessComponent.defaultProps = foo'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
    ].join '\n'
  ,
    # using spread operator
    code: [
      'component = rowsOfType(GuestlistEntry, (rowData, ownProps) => ({'
      '    ...rowData,'
      '    onPress: () => ownProps.onPress(rowData.id),'
      '}))'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent.propTypes = {'
      '  ...stuff,'
      '  foo: PropTypes.string'
      '}'
      'MyStatelessComponent.defaultProps = {'
      ' foo: "foo"'
      '}'
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
    ].join '\n'
  ,
    code: [
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string'
      '}'
      'MyStatelessComponent.defaultProps = {'
      ' ...defaults,'
      '}'
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  ...someProps,'
      '  bar: PropTypes.string.isRequired'
      '}'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.defaultProps = {'
      '  ...defaults,'
      '  bar: "bar"'
      '}'
    ].join '\n'
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.defaultProps = {'
      '  ...defaults,'
      '  bar: "bar"'
      '}'
    ].join '\n'
  ,
    # ,
    #   #
    #   # with Flow annotations
    #   code: [
    #     'type Props = {'
    #     '  foo: string'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  props: Props'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  props: Props'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  bar: "bar"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    foo: string,'
    #     '    bar?: string'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  bar: "bar"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    foo: string'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'Hello(props: { foo?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'

    #     'Hello.defaultProps = { foo: "foo" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'Hello(props: { foo: string }) ->'
    #     '  return <div>Hello {foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'Hello = (props: { foo?: string }) => {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'

    #     'Hello.defaultProps = { foo: "foo" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'Hello = (props: { foo: string }) => {'
    #     '  return <div>Hello {foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'Hello = function(props: { foo?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'

    #     'Hello.defaultProps = { foo: "foo" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'Hello = function(props: { foo: string }) ->'
    #     '  return <div>Hello {foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
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

    #     'Hello(props: Props | Props2) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  bar: "bar",'
    #     '  baz: "baz"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'import type Props from "fake"'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
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
    #     'Hello(props: Props) {'
    #     '  return <div>Hello {props.name.firstname}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   # don't error when variable is not in scope
    #   code: [
    #     'import type { ImportedType } from "fake"'
    #     'type Props = ImportedType'
    #     'Hello(props: Props) {'
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
    #     'Hello(props: Props) {'
    #     '  return <div>Hello {props.name.firstname}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # make sure defaultProps are correctly detected with quoted properties
    code: [
      'Hello = (props) ->'
      '  return <div>Hello {props.bar}</div>'
      'Hello.propTypes = {'
      '  bar: PropTypes.string'
      '}'
      'Hello.defaultProps = {'
      '  "bar": "bar"'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {'
      '    foo: PropTypes.string.isRequired'
      '  }'
      '  render: ->'
      '    return <div>Hello {this.props.foo}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [forbidDefaultForRequired: yes]
    # ,
    #   # test support for React PropTypes as Component's class generic
    #   code: [
    #     'type HelloProps = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends React.Component<HelloProps> {'
    #     '  @defaultProps = {'
    #     '    bar: "bar"'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   options: [forbidDefaultForRequired: yes]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends Component<HelloProps> {'
    #     '  @defaultProps = {'
    #     '    bar: "bar"'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   options: [forbidDefaultForRequired: yes]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'type HelloState = {'
    #     '  dummyState: string'
    #     '}'

    #     'class Hello extends Component<HelloProps, HelloState> {'
    #     '  @defaultProps = {'
    #     '    bar: "bar"'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   options: [forbidDefaultForRequired: yes]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  foo?: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends Component<HelloProps> {'
    #     '  @defaultProps = {'
    #     '    foo: "foo",'
    #     '    bar: "bar"'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   options: [forbidDefaultForRequired: yes]
  ]

  invalid: [
    #
    # stateless components
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 4
      column: 3
    ]
  ,
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = forbidExtraProps({'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '})'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 4
      column: 3
    ]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'MyStatelessComponent.propTypes = forbidExtraProps(propTypes)'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 4
      column: 3
    ]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: [
      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'MyStatelessComponent.propTypes.baz = React.propTypes.string'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 4
      column: 3
    ,
      message:
        'propType "baz" is not required, but has no corresponding defaultProp declaration.'
      line: 7
      column: 1
    ]
  ,
    code: [
      'types = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = types'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 2
      column: 3
    ]
  ,
    code: [
      'defaults = {'
      '  foo: "foo"'
      '}'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string'
      '}'
      'MyStatelessComponent.defaultProps = defaults'
    ].join '\n'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 8
      column: 3
    ]
  ,
    code: [
      'defaults = {'
      '  foo: "foo"'
      '}'
      'types = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string'
      '}'

      'MyStatelessComponent = ({ foo, bar }) ->'
      '  return <div>{foo}{bar}</div>'
      'MyStatelessComponent.propTypes = types'
      'MyStatelessComponent.defaultProps = defaults'
    ].join '\n'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 6
      column: 3
    ]
  ,
    #
    # createReactClass components
    code: [
      'Greeting = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.foo} {this.props.bar}</div>'
      '  propTypes: {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string.isRequired'
      '  }'
      '})'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 5
      column: 5
    ]
  ,
    code: [
      'Greeting = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.foo} {this.props.bar}</div>'
      '  propTypes: {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string'
      '  },'
      '  getDefaultProps: ->'
      '    return {'
      '      foo: "foo"'
      '    }'
      '})'
    ].join '\n'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 6
      column: 5
    ]
  ,
    #
    # ES6 class component
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 7
      column: 3
    ]
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string'
      '}'
      'Greeting.defaultProps = {'
      '  foo: "foo"'
      '}'
    ].join '\n'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 8
      column: 3
    ]
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.propTypes.foo = PropTypes.string'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 9
      column: 1
    ]
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {'
      '  bar: PropTypes.string'
      '}'
      'Greeting.propTypes.foo = PropTypes.string'
      'Greeting.defaultProps = {}'
      'Greeting.defaultProps.foo = "foo"'
    ].join '\n'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 7
      column: 3
    ]
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'Greeting.propTypes = {}'
      'Greeting.propTypes.foo = PropTypes.string'
      'Greeting.defaultProps = {}'
      'Greeting.defaultProps.bar = "bar"'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 7
      column: 1
    ]
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'props = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'Greeting.propTypes = props'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 7
      column: 3
    ]
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      'props = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string'
      '}'
      'defaults = {'
      '  foo: "foo"'
      '}'
      'Greeting.propTypes = props'
      'Greeting.defaultProps = defaults'
    ].join '\n'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 8
      column: 3
    ]
  ,
    # ,
    #   #
    #   # ES6 classes with @getter methods
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes: ->'
    #     '    return {'
    #     '      name: PropTypes.string'
    #     '    }'
    #     '  }'
    #     '  render: ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message:
    #       'propType "name" is not required, but has no corresponding defaultProp declaration.'
    #     line: 4
    #     column: 7
    #   ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes: ->'
    #     '    return {'
    #     '      foo: PropTypes.string,'
    #     '      bar: PropTypes.string'
    #     '    }'
    #     '  }'
    #     '  @get defaultProps: ->'
    #     '    return {'
    #     '      bar: "world"'
    #     '    }'
    #     '  }'
    #     '  render: ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 4
    #     column: 7
    #   ]
    # ,
    #   code: [
    #     'props = {'
    #     '  foo: PropTypes.string'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  @get propTypes: ->'
    #     '    return props'
    #     '  }'
    #     '  render: ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 2
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'defaults = {'
    #     '  bar: "world"'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  @get propTypes: ->'
    #     '    return {'
    #     '      foo: PropTypes.string,'
    #     '      bar: PropTypes.string'
    #     '    }'
    #     '  }'
    #     '  @get defaultProps: ->'
    #     '    return defaults'
    #     '  }'
    #     '  render: ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 7
    #     column: 7
    #   ]
    #
    # ES6 classes with property initializers
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string.isRequired'
      '  }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 7
      column: 5
    ]
  ,
    code: [
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string'
      '  }'
      '  @defaultProps = {'
      '    foo: "foo"'
      '  }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 8
      column: 5
    ]
  ,
    code: [
      'props = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string.isRequired'
      '}'
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      '  @propTypes = props'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 2
      column: 3
    ]
  ,
    code: [
      'props = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string'
      '}'
      'defaults = {'
      '  foo: "foo"'
      '}'
      'class Greeting extends React.Component'
      '  render: ->'
      '    return ('
      '      <h1>Hello, {this.props.foo} {this.props.bar}</h1>'
      '    )'
      '  @propTypes = props'
      '  @defaultProps = defaults'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message:
        'propType "bar" is not required, but has no corresponding defaultProp declaration.'
      line: 3
      column: 3
    ]
  ,
    #
    # edge cases
    code: [
      'Greetings = {}'
      'Greetings.Hello = class extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.foo}</div>'
      'Greetings.Hello.propTypes = {'
      '  foo: PropTypes.string'
      '}'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 6
      column: 3
    ]
  ,
    code: [
      'Greetings = ({ foo = "foo" }) =>'
      '  return <div>Hello {this.props.foo}</div>'
      'Greetings.propTypes = {'
      '  foo: PropTypes.string'
      '}'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 4
      column: 3
    ]
  ,
    # component with no declared props followed by a failing component
    code: [
      'ComponentWithNoProps = ({ bar = "bar" }) =>'
      '  return <div>Hello {this.props.foo}</div>'
      'Greetings = ({ foo = "foo" }) =>'
      '  return <div>Hello {this.props.foo}</div>'
      'Greetings.propTypes = {'
      '  foo: PropTypes.string'
      '}'
    ].join '\n'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 6
      column: 3
    ]
  ,
    # ,
    #   #
    #   # with Flow annotations
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    foo?: string,'
    #     '    bar?: string'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  foo: "foo"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 4
    #     column: 5
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  props: Props'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 3
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo?: string'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  props: Props'

    #     '  @defaultProps: { foo: string }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 2
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    foo: string,'
    #     '    bar?: string'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 4
    #     column: 5
    #   ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    foo?: string,'
    #     '    bar?: string'
    #     '  }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 3
    #     column: 5
    #   ,
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 4
    #     column: 5
    #   ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    foo?: string'
    #     '  }'

    #     '  @defaultProps: { foo: string }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 3
    #     column: 5
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo?: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  props: Props'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  foo: "foo"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 3
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo?: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends React.Component'
    #     '  props: Props'

    #     '  @defaultProps: { foo: string, bar: string }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  foo: "foo"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 3
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    foo?: string,'
    #     '    bar?: string'
    #     '  }'

    #     '  @defaultProps: { foo: string, bar: string }'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  foo: "foo"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 4
    #     column: 5
    #   ]
    # ,
    #   code: [
    #     'Hello(props: { foo?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 25
    #   ]
    # ,
    #   code: [
    #     'Hello({ foo = "foo" }: { foo?: string }) ->'
    #     '  return <div>Hello {foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 35
    #   ]
    # ,
    #   code: [
    #     'Hello(props: { foo?: string, bar?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #     'Hello.defaultProps = { foo: "foo" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 39
    #   ]
    # ,
    #   code: [
    #     'Hello(props: { foo?: string, bar?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 25
    #   ,
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 39
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo?: string'
    #     '}'

    #     'Hello(props: Props) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 2
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'Hello = (props: { foo?: string }) => {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 25
    #   ]
    # ,
    #   code: [
    #     'Hello = (props: { foo?: string, bar?: string }) => {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #     'Hello.defaultProps = { foo: "foo" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 39
    #   ]
    # ,
    #   code: [
    #     'Hello = function(props: { foo?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 33
    #   ]
    # ,
    #   code: [
    #     'Hello = function(props: { foo?: string, bar?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #     'Hello.defaultProps = { foo: "foo" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 47
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo?: string'
    #     '}'

    #     'Hello(props: Props) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #     line: 2
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'type Props = {'
    #     '  foo?: string,'
    #     '  bar?: string'
    #     '}'

    #     'Hello(props: Props) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #     'Hello.defaultProps = { foo: "foo" }'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 3
    #     column: 3
    #   ]
    # ,
    #   # UnionType
    #   code: [
    #     'Hello(props: { one?: string } | { two?: string }) ->'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "one" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 25
    #   ,
    #     message:
    #       'propType "two" is not required, but has no corresponding defaultProp declaration.'
    #     line: 1
    #     column: 44
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

    #     'Hello(props: Props | Props2) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #     line: 3
    #     column: 3
    #   ,
    #     message:
    #       'propType "baz" is not required, but has no corresponding defaultProp declaration.'
    #     line: 7
    #     column: 3
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

    #     'Hello(props: Props | Props2) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'

    #     'Hello.defaultProps = {'
    #     '  bar: "bar"'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "baz" is not required, but has no corresponding defaultProp declaration.'
    #     line: 7
    #     column: 3
    #   ]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  two?: string,'
    #     '  three: string'
    #     '}'
    #     'Hello(props: { one?: string } | HelloProps) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "two" is not required, but has no corresponding defaultProp declaration.'
    #     line: 2
    #     column: 3
    #   ,
    #     message:
    #       'propType "one" is not required, but has no corresponding defaultProp declaration.'
    #     line: 5
    #     column: 25
    #   ]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  two?: string,'
    #     '  three: string'
    #     '}'
    #     'Hello(props: ExternalProps | HelloProps) {'
    #     '  return <div>Hello {props.foo}</div>'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "two" is not required, but has no corresponding defaultProp declaration.'
    #     line: 2
    #     column: 3
    #   ]
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {'
      '    foo: PropTypes.string'
      '  }'
      '  render: ->'
      '    return <div>Hello {this.props.foo}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message:
        'propType "foo" is not required, but has no corresponding defaultProp declaration.'
      line: 3
      column: 5
    ]
  ,
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes: ->'
    #     '    return {'
    #     '      name: PropTypes.string'
    #     '    }'
    #     '  }'
    #     '  @defaultProps: ->'
    #     '    return {'
    #     "      name: 'John'"
    #     '    }'
    #     '  }'
    #     '  render: ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "name" is not required, but has no corresponding defaultProp declaration.'
    #   ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes: ->'
    #     '    return {'
    #     "      'first-name': PropTypes.string"
    #     '    }'
    #     '  }'
    #     '  render: ->'
    #     "    return <div>Hello {this.props['first-name']}</div>"
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "first-name" is not required, but has no corresponding defaultProp declaration.'
    #   ]
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.foo}</div>'
      'Hello.propTypes = {'
      '  foo: PropTypes.string.isRequired'
      '}'
      'Hello.defaultProps = {'
      "  foo: 'bar'"
      '}'
    ].join '\n'
    options: [forbidDefaultForRequired: yes]
    errors: [
      message:
        'propType "foo" is required and should not have a defaultProp declaration.'
    ]
  ,
    code: [
      'Hello = (props) ->'
      '  return <div>Hello {props.foo}</div>'
      'Hello.propTypes = {'
      '  foo: PropTypes.string.isRequired'
      '}'
      'Hello.defaultProps = {'
      "  foo: 'bar'"
      '}'
    ].join '\n'
    options: [forbidDefaultForRequired: yes]
    errors: [
      message:
        'propType "foo" is required and should not have a defaultProp declaration.'
    ]
  ,
    code: [
      'Hello = (props) =>'
      '  return <div>Hello {props.foo}</div>'
      'Hello.propTypes = {'
      '  foo: PropTypes.string.isRequired'
      '}'
      'Hello.defaultProps = {'
      "  foo: 'bar'"
      '}'
    ].join '\n'
    options: [forbidDefaultForRequired: yes]
    errors: [
      message:
        'propType "foo" is required and should not have a defaultProp declaration.'
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {'
      '    foo: PropTypes.string.isRequired'
      '  }'
      '  @defaultProps = {'
      "    foo: 'bar'"
      '  }'
      '  render: ->'
      '    return <div>Hello {this.props.foo}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [forbidDefaultForRequired: yes]
    errors: [
      message:
        'propType "foo" is required and should not have a defaultProp declaration.'
    ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes : ->'
    #     '    return {'
    #     '      foo: PropTypes.string.isRequired'
    #     '    }'
    #     '  }'
    #     '  @get defaultProps: ->'
    #     '    return {'
    #     "      foo: 'bar'"
    #     '    }'
    #     '  }'
    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   options: [forbidDefaultForRequired: yes]
    #   errors: [
    #     message:
    #       'propType "foo" is required and should not have a defaultProp declaration.'
    #   ]
    # ,
    #   # test support for React PropTypes as Component's class generic
    #   code: [
    #     'type HelloProps = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends React.Component<HelloProps> {'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #   ]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends Component<HelloProps> {'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #   ]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  foo: string,'
    #     '  bar?: string'
    #     '}'

    #     'type HelloState = {'
    #     '  dummyState: string'
    #     '}'

    #     'class Hello extends Component<HelloProps, HelloState> {'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #   ]
    # ,
    #   code: [
    #     'type HelloProps = {'
    #     '  foo?: string,'
    #     '  bar?: string'
    #     '}'

    #     'class Hello extends Component<HelloProps> {'

    #     '  render: ->'
    #     '    return <div>Hello {this.props.foo}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    #   errors: [
    #     message:
    #       'propType "foo" is not required, but has no corresponding defaultProp declaration.'
    #   ,
    #     message:
    #       'propType "bar" is not required, but has no corresponding defaultProp declaration.'
    #   ]
  ]
