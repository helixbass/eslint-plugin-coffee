###*
# @fileoverview Tests for jsx-sort-default-props
# @author Vladimir Kattsov
###
'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require '../../rules/jsx-sort-default-props'
{RuleTester} = require 'eslint'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ERROR_MESSAGE =
  'Default prop types declarations should be sorted alphabetically'

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-sort-default-props', rule,
  valid: [
    code: [
      'First = createReactClass({'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes:'
      '    A: PropTypes.any'
      '    Z: PropTypes.string'
      '    a: PropTypes.any'
      '    z: PropTypes.string'
      '  getDefaultProps: ->'
      '    A: "A"'
      '    Z: "Z"'
      '    a: "a"'
      '    z: "z"'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    A: PropTypes.any,'
      '    z: PropTypes.string,'
      '    Z: PropTypes.string'
      '  },'
      '  getDefaultProps: ->'
      '    return {'
      '      a: "a",'
      '      A: "A",'
      '      z: "z",'
      '      Z: "Z"'
      '    }'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [ignoreCase: yes]
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string'
      '  },'
      '  getDefaultProps: ->'
      '    return {'
      '      a: "a",'
      '      z: "z"'
      '    }'
      '  render: ->'
      '    return <div />'
      '})'
      'Second = createReactClass({'
      '  propTypes: {'
      '    AA: PropTypes.any,'
      '    ZZ: PropTypes.string'
      '  },'
      '  getDefaultProps: ->'
      '    return {'
      '      AA: "AA",'
      '      ZZ: "ZZ"'
      '    }'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '  a: PropTypes.string,'
      '  z: PropTypes.string'
      '}'
      'First.propTypes.justforcheck = PropTypes.string'
      'First.defaultProps = {'
      '  a: a,'
      '  z: z'
      '}'
      'First.defaultProps.justforcheck = "justforcheck"'
    ].join '\n'
  ,
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '  a: PropTypes.any,'
      '  A: PropTypes.any,'
      '  z: PropTypes.string,'
      '  Z: PropTypes.string'
      '}'
      'First.defaultProps = {'
      '  a: "a",'
      '  A: "A",'
      '  z: "z",'
      '  Z: "Z"'
      '}'
    ].join '\n'
    options: [ignoreCase: yes]
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes = {'
      '    a: PropTypes.any,'
      '    b: PropTypes.any,'
      '    c: PropTypes.any'
      '  }'
      '  @defaultProps = {'
      '    a: "a",'
      '    b: "b",'
      '    c: "c"'
      '  }'
      '  render: ->'
      '    return <div />'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "aria-controls": PropTypes.string'
      '}'
      'Hello.defaultProps = {'
      '  "aria-controls": "aria-controls"'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [ignoreCase: yes]
  ,
    # Invalid code, should not be validated
    code: [
      'class Component extends React.Component'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    c: PropTypes.any,'
      '    b: PropTypes.any'
      '  }'
      '  defaultProps: {'
      '    a: "a",'
      '    c: "c",'
      '    b: "b"'
      '  }'
      '  render: ->'
      '    return <div />'
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
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    barRequired: PropTypes.func.isRequired,'
      '    onBar: PropTypes.func,'
      '    z: PropTypes.any'
      '  },'
      '  getDefaultProps: ->'
      '    return {'
      '      barRequired: "barRequired",'
      '      onBar: "onBar",'
      '      z: "z"'
      '    }'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    b: PropTypes.string,'
      '    ...c.propTypes,'
      '    a: PropTypes.string'
      '  }'
      '  @defaultProps = {'
      '    b: "b",'
      '    ...c.defaultProps,'
      '    a: "a"'
      '  }'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    a: PropTypes.string,'
      '    b: PropTypes.string,'
      '    c: PropTypes.string,'
      '    d: PropTypes.string,'
      '    e: PropTypes.string,'
      '    f: PropTypes.string'
      '  }'
      '  @defaultProps = {'
      '    a: "a",'
      '    b: "b",'
      '    ...c.defaultProps,'
      '    e: "e",'
      '    f: "f",'
      '    ...d.defaultProps'
      '  }'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'defaults = {'
      '  b: "b"'
      '}'
      'types = {'
      '  a: PropTypes.string,'
      '  b: PropTypes.string,'
      '  c: PropTypes.string'
      '}'
      'StatelessComponentWithSpreadInPropTypes = ({ a, b, c }) ->'
      '  return <div>{a}{b}{c}</div>'
      'StatelessComponentWithSpreadInPropTypes.propTypes = types'
      'StatelessComponentWithSpreadInPropTypes.defaultProps = {'
      '  c: "c",'
      '  ...defaults,'
      '  a: "a"'
      '}'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      "propTypes = require('./externalPropTypes')"
      "defaultProps = require('./externalDefaultProps')"
      'TextFieldLabel = (props) =>'
      '  return <div />'
      'TextFieldLabel.propTypes = propTypes'
      'TextFieldLabel.defaultProps = defaultProps'
    ].join '\n'
  ,
    code: [
      'First = (props) => <div />'
      'export propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '}'
      'export defaultProps = {'
      '    a: "a",'
      '    z: "z",'
      '}'
      'First.propTypes = propTypes'
      'First.defaultProps = defaultProps'
    ].join '\n'
  ]

  invalid: [
    code: [
      'class Component extends React.Component'
      '  @propTypes = {'
      '    a: PropTypes.any,'
      '    b: PropTypes.any,'
      '    c: PropTypes.any'
      '  }'
      '  @defaultProps = {'
      '    a: "a",'
      '    c: "c",'
      '    b: "b"'
      '  }'
      '  render: ->'
      '    return <div />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 10
      column: 5
      type: 'Property'
    ]
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes = {'
      '    a: PropTypes.any,'
      '    b: PropTypes.any,'
      '    c: PropTypes.any'
      '  }'
      '  @defaultProps = {'
      '    c: "c",'
      '    b: "b",'
      '    a: "a"'
      '  }'
      '  render: ->'
      '    return <div />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: 2
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes:'
      '    a: PropTypes.any'
      '    b: PropTypes.any'
      '  @defaultProps:'
      '    Z: "Z"'
      '    a: "a"'
      '  render: ->'
      '    <div />'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [ignoreCase: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 7
      column: 5
      type: 'Property'
    ]
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.any'
      '  }'
      '  @defaultProps = {'
      '    a: "a",'
      '    Z: "Z",'
      '  }'
      '  render: ->'
      '    return <div />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 8
      column: 5
      type: 'Property'
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "a": PropTypes.string,'
      '  "b": PropTypes.string'
      '}'
      'Hello.defaultProps = {'
      '  "b": "b",'
      '  "a": "a"'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 10
      column: 3
      type: 'Property'
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "a": PropTypes.string,'
      '  "b": PropTypes.string,'
      '  "c": PropTypes.string'
      '}'
      'Hello.defaultProps = {'
      '  "c": "c",'
      '  "b": "b",'
      '  "a": "a"'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: 2
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "a": PropTypes.string,'
      '  "B": PropTypes.string,'
      '}'
      'Hello.defaultProps = {'
      '  "a": "a",'
      '  "B": "B",'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 10
      column: 3
      type: 'Property'
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "a": PropTypes.string,'
      '  "B": PropTypes.string,'
      '}'
      'Hello.defaultProps = {'
      '  "B": "B",'
      '  "a": "a",'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [ignoreCase: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 10
      column: 3
      type: 'Property'
    ]
  ,
    code: [
      'First = (props) => <div />'
      'propTypes = {'
      '  z: PropTypes.string,'
      '  a: PropTypes.any,'
      '}'
      'defaultProps = {'
      '  z: "z",'
      '  a: "a",'
      '}'
      'First.propTypes = propTypes'
      'First.defaultProps = defaultProps'
    ].join '\n'
    errors: [
      message: ERROR_MESSAGE
      line: 8
      column: 3
      type: 'Property'
    ]
  ,
    code: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    b: PropTypes.string,'
      '    ...c.propTypes,'
      '    a: PropTypes.string'
      '  }'
      '  @defaultProps = {'
      '    b: "b",'
      '    a: "a",'
      '    ...c.defaultProps'
      '  }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 9
      column: 5
      type: 'Property'
    ]
  ,
    code: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    a: PropTypes.string,'
      '    b: PropTypes.string,'
      '    c: PropTypes.string,'
      '    d: PropTypes.string,'
      '    e: PropTypes.string,'
      '    f: PropTypes.string'
      '  }'
      '  @defaultProps = {'
      '    b: "b",'
      '    a: "a",'
      '    ...c.defaultProps,'
      '    f: "f",'
      '    e: "e",'
      '    ...d.defaultProps'
      '  }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: 2
  ,
    code: [
      'defaults = {'
      '  b: "b"'
      '}'
      'types = {'
      '  a: PropTypes.string,'
      '  b: PropTypes.string,'
      '  c: PropTypes.string'
      '}'
      'StatelessComponentWithSpreadInPropTypes = ({ a, b, c }) ->'
      '  return <div>{a}{b}{c}</div>'
      'StatelessComponentWithSpreadInPropTypes.propTypes = types'
      'StatelessComponentWithSpreadInPropTypes.defaultProps = {'
      '  c: "c",'
      '  a: "a",'
      '  ...defaults,'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 14
      column: 3
      type: 'Property'
    ]
  ]
