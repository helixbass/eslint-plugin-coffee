###*
# @fileoverview Tests for sort-prop-types
###
'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require '../../rules/sort-prop-types'
{RuleTester} = require 'eslint'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ERROR_MESSAGE = 'Prop types declarations should be sorted alphabetically'
REQUIRED_ERROR_MESSAGE =
  'Required prop types must be listed before all other prop types'
CALLBACK_ERROR_MESSAGE =
  'Callback prop types must be listed after all other prop types'

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'sort-prop-types', rule,
  valid: [
    code: [
      'First = createReactClass({'
      '  render: ->'
      '    <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: externalPropTypes,'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    A: PropTypes.any,'
      '    Z: PropTypes.string,'
      '    a: PropTypes.any,'
      '    z: PropTypes.string'
      '  },'
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
      '  render: ->'
      '    return <div />'
      '})'
      'Second = createReactClass({'
      '  propTypes: {'
      '    AA: PropTypes.any,'
      '    ZZ: PropTypes.string'
      '  },'
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
    ].join '\n'
    options: [ignoreCase: yes]
  ,
    # ,
    #   # Invalid code, should not be validated
    #   code: [
    #     'class Component extends React.Component'
    #     '  propTypes: {'
    #     '    a: PropTypes.any,'
    #     '    c: PropTypes.any,'
    #     '    b: PropTypes.any'
    #     '  }'
    #     '  render: ->'
    #     '    return <div />'
    #   ].join '\n'
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
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [callbacksLast: yes]
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '  }'
      '  render: ->'
      '    return <div />'
    ].join '\n'
    options: [callbacksLast: yes]
  ,
    # parser: 'babel-eslint'
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '}'
    ].join '\n'
    options: [callbacksLast: yes]
  ,
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '    barRequired: PropTypes.string.isRequired,'
      '    a: PropTypes.any'
      '}'
    ].join '\n'
    options: [requiredFirst: yes]
  ,
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '    fooRequired: MyPropType,'
      '}'
    ].join '\n'
    options: [requiredFirst: yes]
  ,
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '    barRequired: PropTypes.string.isRequired,'
      '    fooRequired: PropTypes.any.isRequired,'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '}'
    ].join '\n'
    options: [
      requiredFirst: yes
      callbacksLast: yes
    ]
  ,
    code: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    b: PropTypes.string,'
      '    ...c.propTypes,'
      '    a: PropTypes.string'
      '  }'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      "propTypes = require('./externalPropTypes')"
      'TextFieldLabel = (props) =>'
      '  return <div />'
      'TextFieldLabel.propTypes = propTypes'
    ].join '\n'
  ,
    code: [
      'First = (props) => <div />'
      'export propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '}'
      'First.propTypes = propTypes'
    ].join '\n'
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          c: PropTypes.any,
          C: PropTypes.string,
          a: PropTypes.any,
          b: PropTypes.bool,
        }),
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        a: PropTypes.any,
        b: PropTypes.any,
        c: PropTypes.shape({
          c: PropTypes.any,
          ...otherPropTypes,
          a: PropTypes.any,
          b: PropTypes.bool,
        }),
      }
    """
    options: [sortShapeProp: yes]
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        a: PropTypes.any,
        b: PropTypes.any,
        c: PropTypes.shape(
          importedPropType,
        ),
      }
    """
    options: [sortShapeProp: yes]
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        a: PropTypes.any,
        z: PropTypes.any,
      }
    """
    options: [noSortAlphabetically: yes]
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        z: PropTypes.any,
        a: PropTypes.any,
      }
    """
    options: [noSortAlphabetically: yes]
  ]

  invalid: [
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    z: PropTypes.string,'
      '    a: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    z: PropTypes.any,'
      '    Z: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    Z: PropTypes.any,'
      '    z: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    Z: PropTypes.any,'
      '    a: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [ignoreCase: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    Z: PropTypes.any'
      '  },'
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
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    errors: 2
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    A: PropTypes.any,'
      '    Z: PropTypes.string,'
      '    a: PropTypes.any,'
      '    z: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    Zz: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
      'Second = createReactClass({'
      '  propTypes: {'
      '    aAA: PropTypes.any,'
      '    ZZ: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    errors: 2
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    Zz: PropTypes.string,'
      '    a: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
      'Second = createReactClass({'
      '  propTypes: {'
      '    ZZ: PropTypes.string,'
      '    aAA: PropTypes.any'
      '  },'
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
      '    yy: PropTypes.any,'
      '    bb: PropTypes.string'
      '}'
      'class Second extends React.Component'
      '  render: ->'
      '    return <div />'
      'Second.propTypes = {'
      '    aAA: PropTypes.any,'
      '    ZZ: PropTypes.string'
      '}'
    ].join '\n'
    errors: 2
    output: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '    bb: PropTypes.string,'
      '    yy: PropTypes.any'
      '}'
      'class Second extends React.Component'
      '  render: ->'
      '    return <div />'
      'Second.propTypes = {'
      '    ZZ: PropTypes.string,'
      '    aAA: PropTypes.any'
      '}'
    ].join '\n'
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes ='
      '    z: PropTypes.any'
      '    y: PropTypes.any'
      '    a: PropTypes.any'
      '  render: ->'
      '    return <div />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: 2
    output: [
      'class Component extends React.Component'
      '  @propTypes ='
      '    a: PropTypes.any'
      '    y: PropTypes.any'
      '    z: PropTypes.any'
      '  render: ->'
      '    return <div />'
    ].join '\n'
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes = forbidExtraProps({'
      '    z: PropTypes.any,'
      '    y: PropTypes.any,'
      '    a: PropTypes.any'
      '  })'
      '  render: ->'
      '    return <div />'
    ].join '\n'
    # parser: 'babel-eslint'
    settings:
      propWrapperFunctions: ['forbidExtraProps']
    errors: 2
    output: [
      'class Component extends React.Component'
      '  @propTypes = forbidExtraProps({'
      '    a: PropTypes.any,'
      '    y: PropTypes.any,'
      '    z: PropTypes.any'
      '  })'
      '  render: ->'
      '    return <div />'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onFoo: PropTypes.func,'
      '    onBar: PropTypes.func'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [callbacksLast: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 6
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'class Component extends React.Component'
      '  @propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onFoo: PropTypes.func,'
      '    onBar: PropTypes.func'
      '  }'
      '  render: ->'
      '    return <div />'
    ].join '\n'
    options: [callbacksLast: yes]
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 6
      column: 5
      type: 'Property'
    ]
    output: [
      'class Component extends React.Component'
      '  @propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '  }'
      '  render: ->'
      '    return <div />'
    ].join '\n'
  ,
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onFoo: PropTypes.func,'
      '    onBar: PropTypes.func'
      '}'
    ].join '\n'
    options: [callbacksLast: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 8
      column: 5
      type: 'Property'
    ]
    output: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '}'
    ].join '\n'
  ,
    code: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = forbidExtraProps({'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onFoo: PropTypes.func,'
      '    onBar: PropTypes.func'
      '})'
    ].join '\n'
    options: [callbacksLast: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
    errors: [
      message: ERROR_MESSAGE
      line: 8
      column: 5
      type: 'Property'
    ]
    output: [
      'class First extends React.Component'
      '  render: ->'
      '    return <div />'
      'First.propTypes = forbidExtraProps({'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '})'
    ].join '\n'
  ,
    code: [
      'First = (props) => <div />'
      'propTypes = {'
      '    z: PropTypes.string,'
      '    a: PropTypes.any,'
      '}'
      'First.propTypes = forbidExtraProps(propTypes)'
    ].join '\n'
    settings:
      propWrapperFunctions: ['forbidExtraProps']
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = (props) => <div />'
      'propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '}'
      'First.propTypes = forbidExtraProps(propTypes)'
    ].join '\n'
  ,
    code: [
      'First = (props) => <div />'
      'propTypes = {'
      '    z: PropTypes.string,'
      '    a: PropTypes.any,'
      '}'
      'First.propTypes = propTypes'
    ].join '\n'
    settings:
      propWrapperFunctions: ['forbidExtraProps']
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = (props) => <div />'
      'propTypes = {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '}'
      'First.propTypes = propTypes'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func,'
      '    z: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [callbacksLast: yes]
    errors: [
      message: CALLBACK_ERROR_MESSAGE
      line: 5
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string,'
      '    onBar: PropTypes.func,'
      '    onFoo: PropTypes.func'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    fooRequired: PropTypes.string.isRequired,'
      '    barRequired: PropTypes.string.isRequired,'
      '    a: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [requiredFirst: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    barRequired: PropTypes.string.isRequired,'
      '    fooRequired: PropTypes.string.isRequired,'
      '    a: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    barRequired: PropTypes.string.isRequired,'
      '    onFoo: PropTypes.func'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [requiredFirst: yes]
    errors: [
      message: REQUIRED_ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    barRequired: PropTypes.string.isRequired,'
      '    a: PropTypes.any,'
      '    onFoo: PropTypes.func'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    b: PropTypes.string,'
      '    ...a.propTypes,'
      '    d: PropTypes.string,'
      '    c: PropTypes.string'
      '  }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 6
      column: 5
      type: 'Property'
    ]
    output: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    b: PropTypes.string,'
      '    ...a.propTypes,'
      '    c: PropTypes.string,'
      '    d: PropTypes.string'
      '  }'
    ].join '\n'
  ,
    code: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    b: PropTypes.string,'
      '    ...a.propTypes,'
      '    f: PropTypes.string,'
      '    d: PropTypes.string,'
      '    ...e.propTypes,'
      '    c: PropTypes.string'
      '  }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 6
      column: 5
      type: 'Property'
    ]
    output: [
      'export default class ClassWithSpreadInPropTypes extends BaseClass'
      '  @propTypes = {'
      '    b: PropTypes.string,'
      '    ...a.propTypes,'
      '    d: PropTypes.string,'
      '    f: PropTypes.string,'
      '    ...e.propTypes,'
      '    c: PropTypes.string'
      '  }'
    ].join '\n'
  ,
    code: [
      'propTypes = {'
      '  b: PropTypes.string,'
      '  a: PropTypes.string,'
      '}'
      'TextFieldLabel = (props) =>'
      '  <div />'
      'TextFieldLabel.propTypes = propTypes'
    ].join '\n'
    errors: [
      message: ERROR_MESSAGE
      line: 3
      column: 3
      type: 'Property'
    ]
    output: [
      'propTypes = {'
      '  a: PropTypes.string,'
      '  b: PropTypes.string,'
      '}'
      'TextFieldLabel = (props) =>'
      '  <div />'
      'TextFieldLabel.propTypes = propTypes'
    ].join '\n'
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          c: PropTypes.any,
          a: PropTypes.any,
          b: PropTypes.bool,
        }),
      }
    """
    options: [sortShapeProp: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 9
      column: 5
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 10
      column: 5
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          a: PropTypes.any,
          b: PropTypes.bool,
          c: PropTypes.any,
        }),
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        z: PropTypes.shape(),
        y: PropTypes.any,
      }
    """
    options: [sortShapeProp: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 7
      column: 3
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape(),
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        z: PropTypes.shape(someType),
        y: PropTypes.any,
      }
    """
    options: [sortShapeProp: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 7
      column: 3
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape(someType),
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        z: PropTypes.any,
        y: PropTypes.any,
        a: PropTypes.shape({
          c: PropTypes.any,
          C: PropTypes.string,
          a: PropTypes.any,
          b: PropTypes.bool,
        }),
      }
    """
    options: [sortShapeProp: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 6
      column: 3
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 7
      column: 3
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 9
      column: 5
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 10
      column: 5
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 11
      column: 5
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        a: PropTypes.shape({
          C: PropTypes.string,
          a: PropTypes.any,
          b: PropTypes.bool,
          c: PropTypes.any,
        }),
        y: PropTypes.any,
        z: PropTypes.any,
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          c: PropTypes.any,
          C: PropTypes.string,
          a: PropTypes.any,
          b: PropTypes.bool,
        }),
      }
    """
    options: [
      sortShapeProp: yes
      ignoreCase: yes
    ]
    errors: [
      message: ERROR_MESSAGE
      line: 10
      column: 5
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 11
      column: 5
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          a: PropTypes.any,
          b: PropTypes.bool,
          c: PropTypes.any,
          C: PropTypes.string,
        }),
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          a: PropTypes.string,
          c: PropTypes.number.isRequired,
          b: PropTypes.any,
          d: PropTypes.bool,
        }),
      }
    """
    options: [
      sortShapeProp: yes
      requiredFirst: yes
    ]
    errors: [
      message: REQUIRED_ERROR_MESSAGE
      line: 9
      column: 5
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          c: PropTypes.number.isRequired,
          a: PropTypes.string,
          b: PropTypes.any,
          d: PropTypes.bool,
        }),
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          a: PropTypes.string,
          c: PropTypes.number.isRequired,
          b: PropTypes.any,
          onFoo: PropTypes.func,
          d: PropTypes.bool,
        }),
      }
    """
    options: [
      sortShapeProp: yes
      callbacksLast: yes
    ]
    errors: [
      message: ERROR_MESSAGE
      line: 10
      column: 5
      type: 'Property'
    ,
      message: CALLBACK_ERROR_MESSAGE
      line: 11
      column: 5
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          a: PropTypes.string,
          b: PropTypes.any,
          c: PropTypes.number.isRequired,
          d: PropTypes.bool,
          onFoo: PropTypes.func,
        }),
      }
    """
  ,
    code: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          a: PropTypes.string,
          c: PropTypes.number.isRequired,
          b: PropTypes.any,
          ...otherPropTypes,
          f: PropTypes.bool,
          d: PropTypes.string,
        }),
      }
    """
    options: [sortShapeProp: yes]
    errors: [
      message: ERROR_MESSAGE
      line: 10
      column: 5
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 13
      column: 5
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        render: ->
          return <div />
      Component.propTypes = {
        x: PropTypes.any,
        y: PropTypes.any,
        z: PropTypes.shape({
          a: PropTypes.string,
          b: PropTypes.any,
          c: PropTypes.number.isRequired,
          ...otherPropTypes,
          d: PropTypes.string,
          f: PropTypes.bool,
        }),
      }
    """
  ,
    code: """
      class Component extends React.Component
        @propTypes = {
          z: PropTypes.any,
          y: PropTypes.any,
          a: PropTypes.shape({
            c: PropTypes.any,
            a: PropTypes.any,
            b: PropTypes.bool,
          }),
        }
        render: ->
          return <div />
    """
    options: [sortShapeProp: yes]
    # parser: 'babel-eslint'
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 5
      column: 5
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 7
      column: 7
      type: 'Property'
    ,
      message: ERROR_MESSAGE
      line: 8
      column: 7
      type: 'Property'
    ]
    output: """
      class Component extends React.Component
        @propTypes = {
          a: PropTypes.shape({
            a: PropTypes.any,
            b: PropTypes.bool,
            c: PropTypes.any,
          }),
          y: PropTypes.any,
          z: PropTypes.any,
        }
        render: ->
          return <div />
    """
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      '    z: PropTypes.string,'
      '    a: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [noSortAlphabetically: no]
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      '    z: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ,
    code: [
      'First = createReactClass({'
      '  propTypes: {'
      "    'data-letter': PropTypes.string,"
      '    a: PropTypes.any,'
      '    e: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
    options: [noSortAlphabetically: no]
    errors: [
      message: ERROR_MESSAGE
      line: 4
      column: 5
      type: 'Property'
    ]
    output: [
      'First = createReactClass({'
      '  propTypes: {'
      '    a: PropTypes.any,'
      "    'data-letter': PropTypes.string,"
      '    e: PropTypes.any'
      '  },'
      '  render: ->'
      '    return <div />'
      '})'
    ].join '\n'
  ]
