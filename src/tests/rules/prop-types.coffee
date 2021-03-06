###*
# @fileoverview Prevent missing props validation in a React component definition
# @author Yannick Croissant
###
'use strict'

### eslint-disable coffee/object-shorthand, coffee/prefer-object-spread ###

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/prop-types'
{RuleTester} = require 'eslint'
path = require 'path'

settings =
  react:
    pragma: 'Foo'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'prop-types', rule,
  valid: [
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.string.isRequired'
      '  },'
      '  render: ->'
      '    <div>Hello {@props.name}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.object.isRequired'
      '  },'
      '  render: ->'
      '    return <div>Hello {this.props.name.firstname}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    return <div>Hello World</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    return <div>Hello World {this.props.children}</div>'
      '})'
    ].join '\n'
    options: [ignore: ['children']]
  ,
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    props = this.props'
      '    return <div>Hello World</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    propName = "foo"'
      '    return <div>Hello World {this.props[propName]}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: externalPropTypes,'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: externalPropTypes.mySharedPropTypes,'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello World</div>'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.firstname} {this.props.lastname}</div>'
      'Hello.propTypes = {'
      '  firstname: PropTypes.string'
      '}'
      'Hello.propTypes.lastname = PropTypes.string'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.object.isRequired'
      '  },'
      '  render: ->'
      '    user = {'
      '      name: this.props.name'
      '    }'
      '    return <div>Hello {user.name}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'class Hello'
      '  render: ->'
      "    return 'Hello' + this.props.name"
    ].join '\n'
  ,
    # ,
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
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    { firstname, ...other } = this.props'
      '    return <div>Hello {firstname}</div>'
      'Hello.propTypes = {'
      '  firstname: PropTypes.string'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    {firstname, lastname} = this.state'
      '    something = this.props'
      '    return <div>Hello {firstname}</div>'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {'
      '    name: PropTypes.string'
      '  }'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.firstname}</div>'
      'Hello.propTypes = {'
      "  'firstname': PropTypes.string"
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      "    if (Object.prototype.hasOwnProperty.call(this.props, 'firstname'))"
      '      return <div>Hello {this.props.firstname}</div>'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      "  'firstname': PropTypes.string"
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b'
      '    return <div>Hello</div>'
      'Hello.propTypes = {}'
      'Hello.propTypes.a = PropTypes.shape({'
      '  b: PropTypes.string'
      '})'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b.c'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.shape({'
      '    b: PropTypes.shape({'
      '    })'
      '  })'
      '}'
      'Hello.propTypes.a.b.c = PropTypes.number'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b.c'
      '    this.props.a.__.d.length'
      '    this.props.a.anything.e[2]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.objectOf('
      '    PropTypes.shape({'
      '      c: PropTypes.number,'
      '      d: PropTypes.string,'
      '      e: PropTypes.array'
      '    })'
      '  )'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    i = 3'
      '    this.props.a[2].c'
      '    this.props.a[i].d.length'
      '    this.props.a[i + 2].e[2]'
      '    this.props.a.length'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.arrayOf('
      '    PropTypes.shape({'
      '      c: PropTypes.number,'
      '      d: PropTypes.string,'
      '      e: PropTypes.array'
      '    })'
      '  )'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.length'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.oneOfType(['
      '    PropTypes.array,'
      '    PropTypes.string'
      '  ])'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.c'
      '    this.props.a[2] is true'
      '    this.props.a.e[2]'
      '    this.props.a.length'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.oneOfType(['
      '    PropTypes.shape({'
      '      c: PropTypes.number,'
      '      e: PropTypes.array'
      '    }).isRequired,'
      '    PropTypes.arrayOf('
      '      PropTypes.bool'
      '    )'
      '  ])'
      '}'
    ].join '\n'
  ,
    code: '''
        class Component extends React.Component
          render: ->
            return <div>{this.props.foo.baz}</div>
        Component.propTypes = {
          foo: PropTypes.oneOfType([
            PropTypes.shape({
              bar: PropTypes.string
            }),
            PropTypes.shape({
              baz: PropTypes.string
            })
          ])
        }
      '''
  ,
    code: '''
        class Component extends React.Component
          render: ->
            return <div>{this.props.foo.baz}</div>
        Component.propTypes = {
          foo: PropTypes.oneOfType([
            PropTypes.shape({
              bar: PropTypes.string
            }),
            PropTypes.instanceOf(Baz)
          ])
        }
      '''
  ,
    code: '''
        class Component extends React.Component
          render: ->
            return <div>{this.props.foo.baz}</div>
        Component.propTypes = {
          foo: PropTypes.oneOf(['bar', 'baz'])
        }
      '''
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.render'
      '    this.props.a.c'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.instanceOf(Hello)'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    @props.arr'
      '    @props.arr[3]'
      '    @props.arr.length'
      '    @props.arr.push(3)'
      '    @props.bo'
      '    @props.bo.toString()'
      '    @props.fu'
      '    @props.fu.bind(this)'
      '    @props.numb'
      '    @props.numb.toFixed()'
      '    @props.stri'
      '    @props.stri.length()'
      '    <div>Hello</div>'
      'Hello.propTypes = {'
      '  arr: PropTypes.array,'
      '  bo: PropTypes.bool.isRequired,'
      '  fu: PropTypes.func,'
      '  numb: PropTypes.number,'
      '  stri: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    { '
      '      propX,'
      '      "aria-controls": ariaControls, '
      '      ...props } = this.props'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "propX": PropTypes.string,'
      '  "aria-controls": PropTypes.string'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["some.value"]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "some.value": PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["arr"][1]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "arr": PropTypes.array'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["arr"][1]["some.value"]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "arr": PropTypes.arrayOf('
      '    PropTypes.shape({"some.value": PropTypes.string})'
      '  )'
      '}'
    ].join '\n'
  ,
    code: [
      'TestComp1 = createReactClass({'
      '  propTypes: {'
      '    size: PropTypes.string'
      '  },'
      '  render: ->'
      '    foo = {'
      "      baz: 'bar'"
      '    }'
      '    icons = foo[this.props.size].salut'
      '    return <div>{icons}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>{this.props.name.firstname}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [ignore: ['name']]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    {firstname, lastname} = this.props.name'
      '    return <div>{firstname} {lastname}</div>'
      'Hello.propTypes = {'
      '  name: PropTypes.shape({'
      '    firstname: PropTypes.string,'
      '    lastname: PropTypes.string'
      '  })'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'foo = {}'
      'class Hello extends React.Component'
      '  render: ->'
      '    {firstname, lastname} = this.props.name'
      '    return <div>{firstname} {lastname}</div>'
      'Hello.propTypes = {'
      '  name: PropTypes.shape(foo)'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    {firstname} = this'
      '    return <div>{firstname}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    router: PropTypes.func'
      '  },'
      '  render: ->'
      '    nextPath = this.props.router.getCurrentQuery().nextPath'
      '    return <div>{nextPath}</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    firstname: CustomValidator.string'
      '  },'
      '  render: ->'
      '    return <div>{this.props.firstname}</div>'
      '})'
    ].join '\n'
    options: [customValidators: ['CustomValidator']]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    outer: CustomValidator.shape({'
      '      inner: CustomValidator.map'
      '    })'
      '  },'
      '  render: ->'
      '    return <div>{this.props.outer.inner}</div>'
      '})'
    ].join '\n'
    options: [customValidators: ['CustomValidator']]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    outer: PropTypes.shape({'
      '      inner: CustomValidator.string'
      '    })'
      '  },'
      '  render: ->'
      '    return <div>{this.props.outer.inner}</div>'
      '})'
    ].join '\n'
    options: [customValidators: ['CustomValidator']]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    outer: CustomValidator.shape({'
      '      inner: PropTypes.string'
      '    })'
      '  },'
      '  render: ->'
      '    return <div>{this.props.outer.inner}</div>'
      '})'
    ].join '\n'
    options: [customValidators: ['CustomValidator']]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div>{this.props.name.get("test")}</div>'
      '})'
    ].join '\n'
    options: [customValidators: ['CustomValidator']]
  ,
    code: [
      'class Comp1 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp1.propTypes = {'
      '  prop1: PropTypes.number'
      '}'
      'class Comp2 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp2.propTypes = {'
      '  prop2: PropTypes.arrayOf(Comp1.propTypes.prop1)'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Comp1 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp1.propTypes = {'
      '  prop1: PropTypes.number'
      '}'
      'class Comp2 extends Component'
      '  @propTypes = {'
      '    prop2: PropTypes.arrayOf(Comp1.propTypes.prop1)'
      '  }'
      '  render: ->'
      '    return <span />'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Comp1 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp1.propTypes = {'
      '  prop1: PropTypes.number'
      '}'
      'Comp2 = createReactClass({'
      '  propTypes: {'
      '    prop2: PropTypes.arrayOf(Comp1.propTypes.prop1)'
      '  },'
      '  render: ->'
      '    return <span />'
      '})'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'SomeComponent = createReactClass({'
      '  propTypes: SomeOtherComponent.propTypes'
      '})'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    { a, ...b } = obj'
      '    c = { ...d }'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes() {}'
    #     '  render: ->'
    #     '    return <div>Hello World</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes() {}'
    #     '  render: ->'
    #     "    users = this.props.users.find(user => user.name === 'John')"
    #     '    return <div>Hello you {users.length}</div>'
    #     '  }'
    #     '}'
    #     'Hello.propTypes = {'
    #     '  users: PropTypes.arrayOf(PropTypes.object)'
    #     '}'
    #   ].join '\n'
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    {} = this.props'
      '    return <div>Hello</div>'
    ].join '\n'
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      "    foo = 'fullname'"
      '    { [foo]: firstname } = this.props'
      '    return <div>Hello {firstname}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: props.source.uri }'
      '  @propTypes = {'
      '    source: PropTypes.object'
      '  }'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: this.props.source.uri }'
      '  @propTypes = {'
      '    source: PropTypes.object'
      '  }'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Should not be detected as a component
    code: [
      'HelloJohn.prototype.render = ->'
      '  return React.createElement(Hello, {'
      '    name: this.props.firstname'
      '  })'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'HelloComponent = ->'
      '  class Hello extends React.Component'
      '    render: ->'
      '      return <div>Hello {this.props.name}</div>'
      '  Hello.propTypes = { name: PropTypes.string }'
      '  Hello'
      'module.exports = HelloComponent()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'HelloComponent = ->'
      '  Hello = createReactClass({'
      '    propTypes: { name: PropTypes.string },'
      '    render: ->'
      '      return <div>Hello {this.props.name}</div>'
      '  })'
      '  return Hello'
      'module.exports = HelloComponent()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class DynamicHello extends Component'
      '  render: ->'
      '    {firstname} = this.props'
      '    class Hello extends Component'
      '      render: ->'
      '        {name} = this.props'
      '        return <div>Hello {name}</div>'
      '    Hello.propTypes = {'
      '      name: PropTypes.string'
      '    }'
      '    Hello = connectReduxForm({name: firstname})(Hello)'
      '    return <Hello />'
      'DynamicHello.propTypes = {'
      '  firstname: PropTypes.string,'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'Hello = (props) =>'
      '  team = props.names.map((name) =>'
      '      return <li>{name}, {props.company}</li>'
      '    )'
      '  return <ul>{team}</ul>'
      'Hello.propTypes = {'
      '  names: PropTypes.array,'
      '  company: PropTypes.string'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'export default {'
      '  renderHello: ->'
      '    {name} = this.props'
      '    return <div>{name}</div>'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Reassigned props are ignored
    code: [
      'export class Hello extends Component'
      '  render: ->'
      '    props = this.props'
      "    return <div>Hello {props.name.firstname} {props['name'].lastname}</div>"
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'export default FooBar = (props) ->'
      '  bar = props.bar'
      '  return (<div bar={bar}><div {...props}/></div>)'
      "if (process.env.NODE_ENV isnt 'production')"
      '  FooBar.propTypes = {'
      '    bar: PropTypes.string'
      '  }'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    {...other} = this.props'
      '    return ('
      '      <div {...other} />'
      '    )'
      '})'
    ].join '\n'
  ,
    code: [
      'statelessComponent = (props) =>'
      '  subRender = () =>'
      '    return <span>{props.someProp}</span>'
      '  return <div>{subRender()}</div>'
      'statelessComponent.propTypes = {'
      '  someProp: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'statelessComponent = ({ someProp }) =>'
      '  subRender = () =>'
      '    return <span>{someProp}</span>'
      '  return <div>{subRender()}</div>'
      'statelessComponent.propTypes = {'
      '  someProp: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'statelessComponent = ({ someProp }) ->'
      '  subRender = () =>'
      '    return <span>{someProp}</span>'
      '  return <div>{subRender()}</div>'
      'statelessComponent.propTypes = {'
      '  someProp: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'statelessComponent = ({ someProp }) ->'
      '  subRender = () =>'
      '    return <span>{someProp}</span>'
      '  return <div>{subRender()}</div>'
      'statelessComponent.propTypes = {'
      '  someProp: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: ['notAComponent = ({ something }) ->', '  return something + 1'].join(
      '\n'
    )
  ,
    code: ['notAComponent = ({ something }) ->', '  return something + 1'].join(
      '\n'
    )
  ,
    code: ['notAComponent = ({ something }) =>', '  return something + 1'].join(
      '\n'
    )
  ,
    # Validation is ignored on reassigned props object
    code: [
      'statelessComponent = (props) =>'
      '  newProps = props'
      '  return <span>{newProps.someProp}</span>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    name: string'
    #     '  }'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    name: Object'
    #     '  }'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {name: Object}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     "type Props = {'data-action': string}"
    #     "function Button({ 'data-action': dataAction }: Props) {"
    #     '  return <div data-action={dataAction} />'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
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
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    name: {'
    #     '      firstname: string'
    #     '    }'
    #     '  }'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {name: {firstname: string}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {name: {firstname: string lastname: string}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {name: {firstname: string}}'
    #     'class Hello extends React.Component'
    #     '  props: {people: Person[]}'
    #     '  render : ->'
    #     '    names = []'
    #     '    for (i = 0 i < this.props.people.length i++) {'
    #     '      names.push(this.props.people[i].name.firstname)'
    #     '    }'
    #     '    return <div>Hello {names.join('
    #     ')}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {name: {firstname: string}}'
    #     'type Props = {people: Person[]}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    names = []'
    #     '    for (i = 0 i < this.props.people.length i++) {'
    #     '      names.push(this.props.people[i].name.firstname)'
    #     '    }'
    #     '    return <div>Hello {names.join('
    #     ')}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {name: {firstname: string}}'
    #     'type Props = {people: Person[]|Person}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    names = []'
    #     '    if (Array.isArray(this.props.people)) {'
    #     '      for (i = 0 i < this.props.people.length i++) {'
    #     '        names.push(this.props.people[i].name.firstname)'
    #     '      }'
    #     '    } else {'
    #     '      names.push(this.props.people.name.firstname)'
    #     '    }'
    #     '    return <div>Hello {names.join('
    #     ')}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {ok: string | boolean}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.ok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {result: {ok: string | boolean}|{ok: number | Array}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.ok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {result?: {ok?: ?string | boolean}|{ok?: ?number | Array}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.ok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props = {a: 123}'
    #     '  render : ->'
    #     '    return <div>Hello</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # Ignore component validation if propTypes are composed using spread
    code: [
      'class Hello extends React.Component'
      '    render: ->'
      '        return  <div>Hello {this.props.firstName} {this.props.lastName}</div>'
      'otherPropTypes = {'
      '    lastName: PropTypes.string'
      '}'
      'Hello.propTypes = {'
      '    ...otherPropTypes,'
      '    firstName: PropTypes.string'
      '}'
    ].join '\n'
  ,
    # Ignore destructured function arguments
    code: [
      'class Hello extends React.Component'
      '  render : ->'
      '    return ["string"].map(({length}) => <div>{length}</div>)'
    ].join '\n'
  ,
    # ,
    #   # Flow annotations on stateless components
    #   code: [
    #     'type Props = {'
    #     '  firstname: string'
    #     '  lastname: string'
    #     '}'
    #     'function Hello(props: Props): React.Element'
    #     '  {firstname, lastname} = props'
    #     '  return <div>Hello {firstname} {lastname}</div>'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {'
    #     '  firstname: string'
    #     '  lastname: string'
    #     '}'
    #     'Hello = function(props: Props): React.Element'
    #     '  {firstname, lastname} = props'
    #     '  return <div>Hello {firstname} {lastname}</div>'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {'
    #     '  firstname: string'
    #     '  lastname: string'
    #     '}'
    #     'Hello = (props: Props): React.Element => {'
    #     '  {firstname, lastname} = props'
    #     '  return <div>Hello {firstname} {lastname}</div>'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {'
    #     "  'completed?': boolean,"
    #     '}'
    #     'Hello = (props: Props): React.Element => {'
    #     "  return <div>{props['completed?']}</div>"
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {'
    #     '  name: string,'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render: ->'
    #     '    {name} = this.props'
    #     '    return name'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type PropsUnionA = {'
    #     '  a: string,'
    #     '  b?: void,'
    #     '}'
    #     'type PropsUnionB = {'
    #     '  a?: void,'
    #     '  b: string,'
    #     '}'
    #     'type Props = {'
    #     '  name: string,'
    #     '} & (PropsUnionA | PropsUnionB)'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render: ->'
    #     '    {name} = this.props'
    #     '    return name'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'import type { FieldProps } from "redux-form"'
    #     ''
    #     'type Props = {'
    #     'label: string,'
    #     '  type: string,'
    #     '  options: Array<SelectOption>'
    #     '} & FieldProps'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   # Impossible intersection type
    #   code: """
    #       import React from 'react'
    #       type Props = string & {
    #         fullname: string
    #       }
    #       class Test extends React.PureComponent<Props> {
    #         render: ->
    #           return <div>Hello {this.props.fullname}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    code: [
      'Card = ({ title, children, footer }) ->'
      '  return ('
      '    <div/>'
      '  )'
      'Card.propTypes = {'
      '  title: PropTypes.string.isRequired,'
      '  children: PropTypes.element.isRequired,'
      '  footer: PropTypes.node'
      '}'
    ].join '\n'
  ,
    code: [
      'JobList = (props) ->'
      '  props'
      '  .jobs'
      '  .forEach(() => {})'
      '  <div></div>'
      'JobList.propTypes = {'
      '  jobs: PropTypes.array'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {'
    #     '  firstname: ?string,'
    #     '}'
    #     'function Hello({firstname}: Props): React$Element'
    #     '  return <div>Hello {firstname}</div>'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    code: [
      'Greetings = ->'
      '  return <div>{({name}) => <Hello name={name} />}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'Greetings = ->'
      '  return <div>{({name}) -> return <Hello name={name} />}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Should stop at the class when searching for a parent component
    code: [
      'export default (ComposedComponent) => class Something extends SomeOtherComponent'
      '  someMethod: ({width}) => {}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Should stop at the decorator when searching for a parent component
    code: [
      '@asyncConnect([{'
      '  promise: ({dispatch}) => {}'
      '}])'
      'class Something extends Component'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Should not find any used props
    code: [
      'Hello = (props) ->'
      '  {...rest} = props'
      '  return <div>Hello</div>'
    ].join '\n'
  ,
    code: [
      'Greetings = class extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.name}</div>'
      'Greetings.propTypes = {'
      '  name: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'Greetings = {'
      '  Hello: class extends React.Component'
      '    render : ->'
      '      return <div>Hello {this.props.name}</div>'
      '}'
      'Greetings.Hello.propTypes = {'
      '  name: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'Greetings = {}'
      'Greetings.Hello = class extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.name}</div>'
      'Greetings.Hello.propTypes = {'
      '  name: PropTypes.string'
      '}'
    ].join '\n'
  ,
    code: [
      'Hello = ({names}) ->'
      '  return names.map((name) =>'
      '    return <div>{name}</div>'
      '  )'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Target = { target: EventTarget }'
    #     'class MyComponent extends Component'
    #     '  @propTypes = {'
    #     '    children: PropTypes.any,'
    #     '  }'
    #     '  handler({ target }: Target) {}'
    #     '  render: ->'
    #     '    return <div>{this.props.children}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    code: [
      'class Hello extends Component'
      'Hello.Foo = ({foo}) => ('
      '  <div>Hello {foo}</div>'
      ')'
      'Hello.Foo.propTypes = {'
      '  foo: PropTypes.node'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    return <div>{this.props.name}</div>'
      '})'
    ].join '\n'
    options: [skipUndeclared: yes]
  ,
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    return <div>{this.props.name}</div>'
      '})'
    ].join '\n'
    options: [skipUndeclared: yes]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>{this.props.name}</div>'
    ].join '\n'
    options: [skipUndeclared: yes]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.object.isRequired'
      '  },'
      '  render: ->'
      '    return <div>{this.props.name}</div>'
      '})'
    ].join '\n'
    options: [skipUndeclared: yes]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.object.isRequired'
      '  },'
      '  render: ->'
      '    return <div>{this.props.name}</div>'
      '})'
    ].join '\n'
    options: [skipUndeclared: no]
  ,
    # Async functions can't be components.
    code: [
      'Hello = (props) ->'
      '  await 1'
      '  return <div>Hello {props.name}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Async functions can't be components.
    code: [
      'Hello = (props) ->'
      '  await 1'
      '  return <div>Hello {props.name}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Async functions can't be components.
    code: [
      'Hello = (props) =>'
      '  await 1'
      '  return <div>Hello {props.name}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # ,
    #   # Flow annotations with variance
    #   code: [
    #     'type Props = {'
    #     '  +firstname: string'
    #     '  -lastname: string'
    #     '}'
    #     'function Hello(props: Props): React.Element'
    #     '  {firstname, lastname} = props'
    #     '  return <div>Hello {firstname} {lastname}</div>'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  onSelect: ({ name }) ->'
      '    await 1'
      '    return null'
      '  render: ->'
      '    return <Greeting onSelect={this.onSelect} />'
    ].join '\n'
  ,
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    onDelete: PropTypes.func.isRequired'
      '  }'
      '  handleDeleteConfirm: =>'
      '    this.props.onDelete()'
      '  handleSubmit: ({certificate, key}) => await 1'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  ...data,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {|'
    #     '  ...data,'
    #     '  lastname: string'
    #     '|}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  ...$Exact<data>,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     "import type {Data} from './Data'"
    #     'type Person = {'
    #     '  ...Data,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.bar}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     "import type {Data} from 'some-libdef-like-flow-typed-provides'"
    #     'type Person = {'
    #     '  ...Data,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.bar}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     "import type {BasePerson} from './types'"
    #     'type Props = {'
    #     '  person: {'
    #     '   ...$Exact<BasePerson>,'
    #     '   lastname: string'
    #     '  }'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    { firstname } = this.props'
    #     '    return <div>Hello {firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    { firstname } = this.props'
    #     '    return <div>Hello {firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {name: {firstname: string}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {name: {firstname: string}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Note = {text: string, children?: Note[]}'
    #     'type Props = {'
    #     '  notes: Note[]'
    #     '}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.notes[0].text}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'import type Props from "fake"'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'import type Props from "fake"'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, { person: Person }, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, { person: Person }, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {result?: {ok?: ?string | boolean}|{ok?: ?number | Array}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.ok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    # ,
    #   code: [
    #     'type Props = {result?: {ok?: ?string | boolean}|{ok?: ?number | Array}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.ok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #       type Props = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<Props> {
    #         render: ->
    #           return <div>{this.props.foo}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #       type Props = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<Props> {
    #         render: ->
    #           return <div>{this.props.foo}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #       type FancyProps = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<FancyProps> {
    #         render: ->
    #           return <div>{this.props.foo}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #       type FancyProps = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<FancyProps> {
    #         render: ->
    #           return <div>{this.props.foo}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #       type PropsA = { foo: string }
    #       type PropsB = { bar: string }
    #       type Props = PropsA & PropsB

    #       class Bar extends React.Component
    #         props: Props

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #       type PropsA = { foo: string }
    #       type PropsB = { bar: string }
    #       type PropsC = { zap: string }
    #       type Props = PropsA & PropsB

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar} - {this.props.zap}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #       import type { PropsA } from \"./myPropsA\"
    #       type PropsB = { bar: string }
    #       type PropsC = { zap: string }
    #       type Props = PropsA & PropsB

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar} - {this.props.zap}</div>
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type PropsA = { bar: string }
    #       type PropsB = { zap: string }
    #       type Props = PropsA & {
    #         baz: string
    #       }

    #       class Bar extends React.Component
    #         props: Props & PropsB

    #         render: ->
    #           return <div>{this.props.bar} - {this.props.zap} - {this.props.baz}</div>
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type PropsA = { bar: string }
    #       type PropsB = { zap: string }
    #       type Props =  {
    #         baz: string
    #       } & PropsA

    #       class Bar extends React.Component
    #         props: Props & PropsB

    #         render: ->
    #           return <div>{this.props.bar} - {this.props.zap} - {this.props.baz}</div>
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Props = { foo: string }
    #       function higherOrderComponent<Props>: ->
    #         return class extends React.Component<Props> {
    #           render: ->
    #             return <div>{this.props.foo}</div>
    #           }
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       function higherOrderComponent<P: { foo: string }>: ->
    #         return class extends React.Component<P> {
    #           render: ->
    #             return <div>{this.props.foo}</div>
    #           }
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       withOverlayState = <P: {foo: string}>(WrappedComponent: ComponentType<P>): CpmponentType<P> => (
    #         class extends React.Component<P> {
    #           constructor(props) {
    #             super(props)
    #             this.state = {foo: props.foo}
    #           }
    #           render: ->
    #             return <div>Hello World</div>
    #           }
    #         }
    #       )
    #     """
    # parser: 'babel-eslint'
    # issue #1288
    '''
      Foo = ->
        props = {}
        props.bar = 'bar'
        <div {...props} />
    '''
    # issue #1288
    '''
      Foo = (props) ->
        props.bar = 'bar'
        <div {...props} />
    '''
  ,
    # issue #106
    code: '''
      import React from 'react'
      import SharedPropTypes from './SharedPropTypes'

      export default class A extends React.Component
        render: ->
          return (
            <span
              a={this.props.a}
              b={this.props.b}
              c={this.props.c}>
              {this.props.children}
            </span>
          )

      A.propTypes = {
        a: React.PropTypes.string,
        ...SharedPropTypes # eslint-disable-line object-shorthand
      }
    '''
  ,
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #     # @flow
    #     import * as React from 'react'

    #     type Props = {}

    #     func = <OP: *>(arg) => arg

    #     hoc = <OP>() => () => {
    #       class Inner extends React.Component<Props & OP> {
    #         render: ->
    #           return <div />
    #         }
    #       }
    #     }
    #   """
    # parser: 'babel-eslint'
    code: '''
        Slider = (props) => (
          <RcSlider {...props} />
        )

        Slider.propTypes = RcSlider.propTypes
      '''
  ,
    code: '''
        Slider = props => (
          <RcSlider foo={props.bar} />
        )

        Slider.propTypes = RcSlider.propTypes
      '''
  ]

  invalid: [
    # code: [
    #   'type Props = {'
    #   '  name: string,'
    #   '}'
    #   'class Hello extends React.Component'
    #   '  foo(props: Props) {}'
    #   '  render: ->'
    #   '    return this.props.name'
    #   '  }'
    #   '}'
    # ].join '\n'
    # errors: [
    #   message: "'name' is missing in props validation"
    #   line: 7
    #   column: 23
    #   type: 'Identifier'
    # ]
    # ,
    # parser: 'babel-eslint'
    code: [
      'Hello = createReactClass'
      '  render: ->'
      '    React.createElement("div", {}, this.props.name)'
    ].join '\n'
    errors: [
      message: "'name' is missing in props validation"
      line: 3
      column: 47
      type: 'Identifier'
    ]
  ,
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    <div>Hello {this.props.name}</div>'
      '})'
    ].join '\n'
    errors: [
      message: "'name' is missing in props validation"
      line: 3
      column: 28
      type: 'Identifier'
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    errors: [
      message: "'name' is missing in props validation"
      line: 3
      column: 35
      type: 'Identifier'
    ]
  ,
    code: [
      '###* @extends React.Component ###'
      'class Hello extends ChildComponent'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    errors: [
      message: "'name' is missing in props validation"
      line: 4
      column: 35
      type: 'Identifier'
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.firstname} {this.props.lastname}</div>'
      'Hello.propTypes = {'
      '  firstname: PropTypes.string'
      '}'
    ].join '\n'
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
      'Hello.propTypes = {'
      '  name: PropTypes.string'
      '}'
      'class HelloBis extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.string.isRequired'
      '  },'
      '  render: ->'
      '    return <div>Hello {this.props.name} and {this.props.propWithoutTypeDefinition}</div>'
      '})'
      'Hello2 = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
      '})'
    ].join '\n'
    errors: [
      message: "'propWithoutTypeDefinition' is missing in props validation"
    ,
      message: "'name' is missing in props validation"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    { firstname, lastname } = this.props'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  firstname: PropTypes.string'
      '}'
    ].join '\n'
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.shape({'
      '  })'
      '}'
    ].join '\n'
    errors: [message: "'a.b' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b.c'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.shape({'
      '    b: PropTypes.shape({'
      '    })'
      '  })'
      '}'
    ].join '\n'
    errors: [message: "'a.b.c' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b.c'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.shape({})'
      '}'
      'Hello.propTypes.a.b = PropTypes.shape({})'
    ].join '\n'
    errors: [message: "'a.b.c' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b.c'
      '    this.props.a.__.d.length'
      '    this.props.a.anything.e[2]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.objectOf('
      '    PropTypes.shape({'
      '    })'
      '  )'
      '}'
    ].join '\n'
    errors: [
      message: "'a.b.c' is missing in props validation"
    ,
      message: "'a.__.d' is missing in props validation"
    ,
      message: "'a.__.d.length' is missing in props validation"
    ,
      message: "'a.anything.e' is missing in props validation"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    i = 3'
      '    this.props.a[2].c'
      '    this.props.a[i].d.length'
      '    this.props.a[i + 2].e[2]'
      '    this.props.a.length'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.arrayOf('
      '    PropTypes.shape({'
      '    })'
      '  )'
      '}'
    ].join '\n'
    errors: [
      message: "'a[].c' is missing in props validation"
    ,
      message: "'a[].d' is missing in props validation"
    ,
      message: "'a[].d.length' is missing in props validation"
    ,
      message: "'a[].e' is missing in props validation"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.length'
      '    this.props.a.b'
      '    this.props.a.e.length'
      '    this.props.a.e.anyProp'
      '    this.props.a.c.toString()'
      '    this.props.a.c.someThingElse()'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.oneOfType(['
      '    PropTypes.shape({'
      '      c: PropTypes.number,'
      '      e: PropTypes.array'
      '    })'
      '  ])'
      '}'
    ].join '\n'
    errors: [
      message: "'a.length' is missing in props validation"
    ,
      message: "'a.b' is missing in props validation"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    { '
      '      "aria-controls": ariaControls, '
      '      propX,'
      '      ...props } = this.props'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "aria-controls": PropTypes.string'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'propX' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["some.value"]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '}'
    ].join '\n'
    errors: [message: "'some.value' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["arr"][1]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '}'
    ].join '\n'
    errors: [message: "'arr' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["arr"][1]["some.value"]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "arr": PropTypes.arrayOf('
      '    PropTypes.shape({})'
      '  )'
      '}'
    ].join '\n'
    errors: [message: "'arr[].some.value' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    text'
      "    text = 'Hello '"
      '    {props: {firstname}} = this'
      '    return <div>{text} {firstname}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'firstname' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      "    {'props': {firstname}} = this"
      '    return <div>Hello {firstname}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'firstname' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    if (true)'
      '      return <span>{this.props.firstname}</span>'
      '    else'
      '      return <span>{this.props.lastname}</span>'
      'Hello.propTypes = {'
      '  lastname: PropTypes.string'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'firstname' is missing in props validation"]
  ,
    code: ['Hello = (props) ->', '  <div>Hello {props.name}</div>'].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: ['Hello = (props) ->', '  return <div>Hello {props.name}</div>'].join(
      '\n'
    )
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: ['Hello = (props) =>', '  return <div>Hello {props.name}</div>'].join(
      '\n'
    )
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'Hello = (props) =>'
      '  {name} = props'
      '  return <div>Hello {name}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: ['Hello = ({ name }) ->', '  <div>Hello {name}</div>'].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: ['Hello = ({ name }) ->', '  return <div>Hello {name}</div>'].join(
      '\n'
    )
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: ['Hello = ({ name }) =>', '  return <div>Hello {name}</div>'].join(
      '\n'
    )
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      "    props = {firstname: 'John'}"
      '    return <div>Hello {props.firstname} {this.props.lastname}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: props.source }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'source' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: props.source.uri }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'source' is missing in props validation"
    ,
      message: "'source.uri' is missing in props validation"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: this.props.source }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'source' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: this.props.source.uri }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'source' is missing in props validation"
    ,
      message: "'source.uri' is missing in props validation"
    ]
  ,
    code: [
      'HelloComponent = ->'
      '  class Hello extends React.Component'
      '    render: ->'
      '      return <div>Hello {this.props.name}</div>'
      '  Hello'
      'module.exports = HelloComponent()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'HelloComponent = ->'
      '  Hello = createReactClass({'
      '    render: ->'
      '      return <div>Hello {this.props.name}</div>'
      '  })'
      '  return Hello'
      'module.exports = HelloComponent()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'class DynamicHello extends Component'
      '  render: ->'
      '    {firstname} = this.props'
      '    class Hello extends Component'
      '      render: ->'
      '        {name} = this.props'
      '        return <div>Hello {name}</div>'
      '    Hello = connectReduxForm({name: firstname})(Hello)'
      '    return <Hello />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'firstname' is missing in props validation"
    ,
      message: "'name' is missing in props validation"
    ]
  ,
    code: [
      'Hello = (props) =>'
      '  team = props.names.map((name) =>'
      '      return <li>{name}, {props.company}</li>'
      '    )'
      '  return <ul>{team}</ul>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'names' is missing in props validation"
    ,
      message: "'names.map' is missing in props validation"
    ,
      message: "'company' is missing in props validation"
    ]
  ,
    code: [
      'Annotation = (props) => ('
      '  <div>'
      '    {props.text}'
      '  </div>'
      ')'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'text' is missing in props validation"]
  ,
    code: [
      'for key of foo'
      '  Hello = createReactClass({'
      '    render: ->'
      '      return <div>Hello {this.props.name}</div>'
      '  })'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'propTypes = {'
      '  firstname: PropTypes.string'
      '}'
      'class Test extends React.Component'
      '  render: ->'
      '    return ('
      '      <div>{this.props.firstname} {this.props.lastname}</div>'
      '    )'
      'Test.propTypes = propTypes'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      'class Test extends Foo.Component'
      '  render: ->'
      '    return ('
      '      <div>{this.props.firstname} {this.props.lastname}</div>'
      '    )'
      'Test.propTypes = {'
      '  firstname: PropTypes.string'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    settings: settings
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      'class Test extends Foo.Component'
      '  render: ->'
      '    return ('
      '      <div>{this.props.firstname} {this.props.lastname}</div>'
      '    )'
      'Test.propTypes = forbidExtraProps({'
      '  firstname: PropTypes.string'
      '})'
    ].join '\n'
    # parser: 'babel-eslint'
    settings: Object.assign {}, settings,
      propWrapperFunctions: ['forbidExtraProps']
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      'class Test extends Foo.Component'
      '  render: ->'
      '    return ('
      '      <div>{this.props.firstname} {this.props.lastname}</div>'
      '    )'
      'Test.propTypes = Object.freeze({'
      '  firstname: PropTypes.string'
      '})'
    ].join '\n'
    # parser: 'babel-eslint'
    settings: Object.assign {}, settings,
      propWrapperFunctions: ['Object.freeze']
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      '###* @jsx Foo ###'
      'class Test extends Foo.Component'
      '  render: ->'
      '    return ('
      '      <div>{this.props.firstname} {this.props.lastname}</div>'
      '    )'
      'Test.propTypes = {'
      '  firstname: PropTypes.string'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'lastname' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  props: {}'
      '  render : ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  props: {'
      '    name: Object'
      '  }'
      '  render : ->'
      '    return <div>Hello {this.props.firstname}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'firstname' is missing in props validation"]
  ,
    # ,
    #   code: [
    #     'type Props = {name: Object}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'firstname' is missing in props validation"]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    name: {'
    #     '      firstname: string'
    #     '    }'
    #     '  }'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'name.lastname' is missing in props validation"]
    # ,
    #   code: [
    #     'type Props = {name: {firstname: string}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'name.lastname' is missing in props validation"]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {person: {name: {firstname: string}}}'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'person.name.lastname' is missing in props validation"]
    # ,
    #   code: [
    #     'type Props = {person: {name: {firstname: string}}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'person.name.lastname' is missing in props validation"]
    # ,
    #   code: [
    #     'type Person = {name: {firstname: string}}'
    #     'class Hello extends React.Component'
    #     '  props: {people: Person[]}'
    #     '  render : ->'
    #     '    names = []'
    #     '    for (i = 0 i < this.props.people.length i++) {'
    #     '      names.push(this.props.people[i].name.lastname)'
    #     '    }'
    #     '    return <div>Hello {names.join('
    #     ')}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [
    #     message: "'people[].name.lastname' is missing in props validation"
    #   ]
    # ,
    #   code: [
    #     'type Person = {name: {firstname: string}}'
    #     'type Props = {people: Person[]}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    names = []'
    #     '    for (i = 0 i < this.props.people.length i++) {'
    #     '      names.push(this.props.people[i].name.lastname)'
    #     '    }'
    #     '    return <div>Hello {names.join('
    #     ')}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [
    #     message: "'people[].name.lastname' is missing in props validation"
    #   ]
    # ,
    #   code: [
    #     'type Props = {result?: {ok: string | boolean}|{ok: number | Array}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.notok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'result.notok' is missing in props validation"]
    code: [
      'Greetings = class extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.name}</div>'
      'Greetings.propTypes = {}'
    ].join '\n'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'Greetings = {'
      '  Hello: class extends React.Component'
      '    render : ->'
      '      return <div>Hello {this.props.name}</div>'
      '}'
      'Greetings.Hello.propTypes = {}'
    ].join '\n'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'Greetings = {}'
      'Greetings.Hello = class extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.name}</div>'
      'Greetings.Hello.propTypes = {}'
    ].join '\n'
    errors: [message: "'name' is missing in props validation"]
  ,
    code: [
      'Greetings = ({names}) ->'
      '  names = names.map(({firstname, lastname}) => <div>{firstname} {lastname}</div>)'
      '  return <Hello>{names}</Hello>'
    ].join '\n'
    errors: [message: "'names' is missing in props validation"]
  ,
    code: [
      'MyComponent = (props) => ('
      '  <div onClick={() => props.toggle()}></div>'
      ')'
    ].join '\n'
    errors: [message: "'toggle' is missing in props validation"]
  ,
    code: [
      'MyComponent = (props) => if props.test then <div /> else <span />'
    ].join '\n'
    errors: [message: "'test' is missing in props validation"]
  ,
    code: [
      'TestComponent = (props) =>'
      '  <div onClick={() => props.test()} />'
      'mapStateToProps = (_, props) => ({'
      '  otherProp: props.otherProp,'
      '})'
    ].join '\n'
    errors: [message: "'test' is missing in props validation"]
  ,
    # ,
    #   code: [
    #     'type Props = {'
    #     '  firstname: ?string,'
    #     '}'
    #     'function Hello({firstname, lastname}: Props): React$Element'
    #     '  return <div>Hello {firstname} {lastname}</div>'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' is missing in props validation"]
    code: [
      'class Hello extends React.Component'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    firstname = props.firstname'
      '    {lastname} = props'
      '    this.state = {'
      '      firstname,'
      '      lastname'
      '    }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'firstname' is missing in props validation"
    ,
      message: "'lastname' is missing in props validation"
    ]
  ,
    code: [
      'Hello = (props) ->'
      '  return <div>{props.name.constructor.firstname}</div>'
      'Hello.propTypes = {'
      '  name: PropTypes.shape({'
      '    firstname: PropTypes.object'
      '  })'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'name.constructor.firstname' is missing in props validation"
    ]
  ,
    code: [
      'SomeComponent = ({bar}) ->'
      '  f = ({foo}) ->'
      '  return <div className={f()}>{bar}</div>'
    ].join '\n'
    errors: [message: "'bar' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.PureComponent'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    errors: [
      message: "'name' is missing in props validation"
      line: 3
      column: 35
      type: 'Identifier'
    ]
  ,
    code: [
      'class Hello extends PureComponent'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    errors: [
      message: "'name' is missing in props validation"
      line: 3
      column: 35
      type: 'Identifier'
    ]
  ,
    # ,
    #   code: [
    #     'type MyComponentProps = {'
    #     '  a: number,'
    #     '}'
    #     'function MyComponent({ a, b }: MyComponentProps) {'
    #     '  return <div />'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [
    #     message: "'b' is missing in props validation"
    #     line: 4
    #     column: 27
    #     type: 'Property'
    #   ]
    code: [
      'Hello = createReactClass({'
      '  propTypes: {},'
      '  render: ->'
      '    return <div>{this.props.firstname}</div>'
      '})'
    ].join '\n'
    options: [skipUndeclared: yes]
    errors: [
      message: "'firstname' is missing in props validation"
      line: 4
      column: 29
    ]
  ,
    code: [
      'Hello = (props) ->'
      '  return <div>{props.firstname}</div>'
      'Hello.propTypes = {}'
    ].join '\n'
    options: [skipUndeclared: yes]
    errors: [
      message: "'firstname' is missing in props validation"
      line: 2
      column: 22
    ]
  ,
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  @get propTypes: ->'
    #     '    return {}'
    #     '  }'
    #     '  render: ->'
    #     '    return <div>{this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   options: [skipUndeclared: yes]
    #   errors: [
    #     message: "'firstname' is missing in props validation"
    #     line: 6
    #     column: 29
    #   ]
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>{this.props.firstname}</div>'
      'Hello.propTypes = {}'
    ].join '\n'
    options: [skipUndeclared: yes]
    errors: [
      message: "'firstname' is missing in props validation"
      line: 3
      column: 29
    ]
  ,
    code: [
      'Hello = createReactClass({'
      '  render: ->'
      '    return <div>{this.props.firstname}</div>'
      '})'
    ].join '\n'
    options: [skipUndeclared: no]
    errors: [
      message: "'firstname' is missing in props validation"
      line: 3
      column: 29
    ]
  ,
    # ,
    #   code: [
    #     'type MyComponentProps = {'
    #     '  +a: number,'
    #     '}'
    #     'function MyComponent({ a, b }: MyComponentProps) {'
    #     '  return <div />'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [
    #     message: "'b' is missing in props validation"
    #     line: 4
    #     column: 27
    #     type: 'Property'
    #   ]
    # ,
    #   code: [
    #     'type MyComponentProps = {'
    #     '  -a: number,'
    #     '}'
    #     'function MyComponent({ a, b }: MyComponentProps) {'
    #     '  return <div />'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [
    #     message: "'b' is missing in props validation"
    #     line: 4
    #     column: 27
    #     type: 'Property'
    #   ]
    # ,
    #   code: [
    #     'type Props = {+name: Object}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'firstname' is missing in props validation"]
    code: [
      'class Hello extends React.Component'
      '  onSelect: ({ name }) =>'
      '    await 1'
      '    return this.props.foo'
      '  render: ->'
      '    return <Greeting onSelect={this.onSelect} />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = forbidExtraProps({'
      '    bar: PropTypes.func'
      '  })'
      '  componentWillReceiveProps: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return'
      '  render: ->'
      '    return <div bar={this.props.bar} />'
    ].join '\n'
    # parser: 'babel-eslint'
    settings: Object.assign {}, settings,
      propWrapperFunctions: ['forbidExtraProps']
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    bar: PropTypes.func'
      '  }'
      '  componentWillReceiveProps: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return'
      '  render: ->'
      '    return <div bar={this.props.bar} />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    bar: PropTypes.func'
      '  }'
      '  componentWillReceiveProps: (nextProps) ->'
      '    {foo} = nextProps'
      '    if (foo)'
      '      return'
      '  render: ->'
      '    return <div bar={this.props.bar} />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    bar: PropTypes.func'
      '  }'
      '  componentWillReceiveProps: ({foo}) ->'
      '    if (foo)'
      '      return'
      '  render: ->'
      '    return <div bar={this.props.bar} />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends Component'
      '  componentWillReceiveProps: ({foo}) ->'
      '    if (foo)'
      '      return'
      '  render: ->'
      '    return <div bar={this.props.bar} />'
      'Hello.propTypes = {'
      '    bar: PropTypes.func'
      '  }'
    ].join '\n'
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = forbidExtraProps({'
      '    bar: PropTypes.func'
      '  })'
      '  shouldComponentUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return'
      '  render: ->'
      '    return <div bar={this.props.bar} />'
    ].join '\n'
    # parser: 'babel-eslint'
    settings: Object.assign {}, settings,
      propWrapperFunctions: ['forbidExtraProps']
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends Component'
      '  shouldComponentUpdate: ({foo}) ->'
      '    if (foo)'
      '      return'
      '  render: ->'
      '    return <div bar={this.props.bar} />'
      'Hello.propTypes = {'
      '    bar: PropTypes.func'
      '  }'
    ].join '\n'
    errors: [message: "'foo' is missing in props validation"]
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes: ->'
      '    return {'
      '      name: PropTypes.string'
      '    }'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    errors: [message: "'name' is missing in props validation"]
  ,
    # ,
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: "'lastname' is missing in props validation"
    #     line: 6
    #     column: 35
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   errors: [
    #     message: "'lastname' is missing in props validation"
    #     line: 6
    #     column: 35
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    {'
    #     '      lastname,'
    #     '    } = this.props'
    #     '    return <div>Hello {lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: "'lastname' is missing in props validation"
    #     line: 7
    #     column: 7
    #     type: 'Property'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, Person, void> {'
    #     '  render : ->'
    #     '    {'
    #     '      lastname,'
    #     '    } = this.props'
    #     '    return <div>Hello {lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   errors: [
    #     message: "'lastname' is missing in props validation"
    #     line: 7
    #     column: 7
    #     type: 'Property'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Props = {name: {firstname: string}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: "'name.lastname' is missing in props validation"
    #     line: 4
    #     column: 40
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Props = {name: {firstname: string}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   errors: [
    #     message: "'name.lastname' is missing in props validation"
    #     line: 4
    #     column: 40
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Props = {result?: {ok: string | boolean}|{ok: number | Array}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.notok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: "'result.notok' is missing in props validation"
    #     line: 4
    #     column: 42
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Props = {result?: {ok: string | boolean}|{ok: number | Array}}'
    #     'class Hello extends React.Component<void, Props, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.notok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   errors: [
    #     message: "'result.notok' is missing in props validation"
    #     line: 4
    #     column: 42
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, { person: Person }, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: "'person.lastname' is missing in props validation"
    #     line: 6
    #     column: 42
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     'type Person = {'
    #     '  firstname: string'
    #     '}'
    #     'class Hello extends React.Component<void, { person: Person }, void> {'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   settings: react: flowVersion: '0.52'
    #   errors: [
    #     message: "'person.lastname' is missing in props validation"
    #     line: 6
    #     column: 42
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Props = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<Props> {
    #         render: ->
    #           return <div>{this.props.bar}</div>
    #         }
    #       }
    #     """
    #   errors: [
    #     message: "'bar' is missing in props validation"
    #     line: 8
    #     column: 37
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Props = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<Props> {
    #         render: ->
    #           return <div>{this.props.bar}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    #   errors: [
    #     message: "'bar' is missing in props validation"
    #     line: 8
    #     column: 37
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type FancyProps = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<FancyProps> {
    #         render: ->
    #           return <div>{this.props.bar}</div>
    #         }
    #       }
    #     """
    #   errors: [
    #     message: "'bar' is missing in props validation"
    #     line: 8
    #     column: 37
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type FancyProps = {
    #         foo: string,
    #       }

    #       class Bar extends React.Component<FancyProps> {
    #         render: ->
    #           return <div>{this.props.bar}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    #   errors: [
    #     message: "'bar' is missing in props validation"
    #     line: 8
    #     column: 37
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Person = {
    #         firstname: string
    #       }
    #       class Hello extends React.Component<{ person: Person }> {
    #         render : ->
    #           return <div>Hello {this.props.person.lastname}</div>
    #         }
    #       }
    #     """
    #   errors: [
    #     message: "'person.lastname' is missing in props validation"
    #     line: 7
    #     column: 50
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Person = {
    #         firstname: string
    #       }
    #       class Hello extends React.Component<{ person: Person }> {
    #         render : ->
    #           return <div>Hello {this.props.person.lastname}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    #   errors: [
    #     message: "'person.lastname' is missing in props validation"
    #     line: 7
    #     column: 50
    #     type: 'Identifier'
    #   ]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Props = { foo: string }
    #       function higherOrderComponent<Props>: ->
    #         return class extends React.Component<Props> {
    #           render: ->
    #             return <div>{this.props.foo} - {this.props.bar}</div>
    #           }
    #         }
    #       }
    #     """
    #   errors: [message: "'bar' is missing in props validation"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       function higherOrderComponent<P: { foo: string }>: ->
    #         return class extends React.Component<P> {
    #           render: ->
    #             return <div>{this.props.foo} - {this.props.bar}</div>
    #           }
    #         }
    #       }
    #     """
    #   errors: [message: "'bar' is missing in props validation"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       withOverlayState = <P: {foo: string}>(WrappedComponent: ComponentType<P>): CpmponentType<P> => (
    #         class extends React.Component<P> {
    #           constructor(props) {
    #             super(props)
    #             this.state = {foo: props.foo, bar: props.bar}
    #           }
    #           render: ->
    #             return <div>Hello World</div>
    #           }
    #         }
    #       )
    #     """
    #   errors: [message: "'bar' is missing in props validation"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type PropsA = {foo: string }
    #       type PropsB = { bar: string }
    #       type Props = PropsA & PropsB

    #       class MyComponent extends React.Component
    #         props: Props

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar} - {this.props.fooBar}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'fooBar' is missing in props validation"]
    # ,
    #   code: """
    #       type PropsA = { foo: string }
    #       type PropsB = { bar: string }
    #       type PropsC = { zap: string }
    #       type Props = PropsA & PropsB

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar} - {this.props.zap} - {this.props.fooBar}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'fooBar' is missing in props validation"]
    # ,
    #   code: """
    #       type PropsB = { bar: string }
    #       type PropsC = { zap: string }
    #       type Props = PropsB & {
    #         baz: string
    #       }

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.bar} - {this.props.baz} - {this.props.fooBar}</div>
    #         }
    #       }
    #     """
    #   errors: [message: "'fooBar' is missing in props validation"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type PropsB = { bar: string }
    #       type PropsC = { zap: string }
    #       type Props = {
    #         baz: string
    #       } & PropsB

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.bar} - {this.props.baz} - {this.props.fooBar}</div>
    #         }
    #       }
    #     """
    #   errors: [message: "'fooBar' is missing in props validation"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #     type ReduxState = {bar: number}

    #     mapStateToProps = (state: ReduxState) => ({
    #         foo: state.bar,
    #     })
    #     # utility to extract the return type from a function
    #     type ExtractReturn_<R, Fn: (...args: any[]) => R> = R
    #     type ExtractReturn<T> = ExtractReturn_<*, T>

    #     type PropsFromRedux = ExtractReturn<typeof mapStateToProps>

    #     type OwnProps = {
    #         baz: string,
    #     }

    #     # I want my Props to be {baz: string, foo: number}
    #     type Props = PropsFromRedux & OwnProps

    #     Component = (props: Props) => (
    #       <div>
    #           {props.baz}
    #           {props.bad}
    #       </div>
    #     )
    #   """
    #   errors: [message: "'bad' is missing in props validation"]
    # parser: 'babel-eslint'
    code: '''
        class Component extends React.Component
          render: ->
            return <div>{this.props.foo.baz}</div>
        Component.propTypes = {
          foo: PropTypes.oneOfType([
            PropTypes.shape({
              bar: PropTypes.string
            })
          ])
        }
      '''
    errors: [message: "'foo.baz' is missing in props validation"]
    # ,
    #   code: """
    #       ForAttendees = ({ page }) => (
    #         <>
    #           <section>{page}</section>
    #         </>
    #       )

    #       export default ForAttendees
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'page' is missing in props validation"]
  ]
