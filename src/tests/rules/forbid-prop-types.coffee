###*
# @fileoverview Tests for forbid-prop-types
###
'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require '../../rules/forbid-prop-types'
{RuleTester} = require 'eslint'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ANY_ERROR_MESSAGE = 'Prop type `any` is forbidden'
ARRAY_ERROR_MESSAGE = 'Prop type `array` is forbidden'
NUMBER_ERROR_MESSAGE = 'Prop type `number` is forbidden'
OBJECT_ERROR_MESSAGE = 'Prop type `object` is forbidden'

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'forbid-prop-types', rule,
  valid: [
    code: '''
      First = createReactClass
        render: ->
          <div />
    '''
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <div />
      })
    '''
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          s: PropTypes.string,
          n: PropTypes.number,
          i: PropTypes.instanceOf,
          b: PropTypes.bool
        },
        render: ->
          return <div />
      })
    '''
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.array
        },
        render: ->
          return <div />
      })
    '''
    options: [forbid: ['any', 'object']]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          o: PropTypes.object
        },
        render: ->
          return <div />
      })
    '''
    options: [forbid: ['any', 'array']]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          o: PropTypes.object,
        },
        render: ->
          return <div />
      })
    '''
    options: [forbid: ['any', 'array']]
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.propTypes = {
        a: PropTypes.string,
        b: PropTypes.string
      }
      First.propTypes.justforcheck = PropTypes.string
    '''
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.propTypes = {
        elem: PropTypes.instanceOf(HTMLElement)
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello</div>
      Hello.propTypes = {
        "aria-controls": PropTypes.string
      }
    '''
  ,
    # parser: 'babel-eslint'
    # Invalid code, should not be validated
    code: '''
      class Component extends React.Component
        propTypes: {
          a: PropTypes.any,
          c: PropTypes.any,
          b: PropTypes.any
        }
        render: ->
          return <div />
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      Hello = createReactClass({
        render: ->
          { a, ...b } = obj
          c = { ...d }
          return <div />
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        },
        render: ->
          return <div />
      })
    '''
  ,
    # Proptypes declared with a spread property
    code: '''
      class Test extends react.component
        @propTypes = {
          intl: React.propTypes.number,
          ...propTypes
        }
    '''
  ,
    # parser: 'babel-eslint'
    # ,
    #   # Proptypes declared with a spread property
    #   code: '''
    #     class Test extends react.component {
    #       static get propTypes() {
    #         return {
    #           intl: React.propTypes.number,
    #           ...propTypes
    #         }
    #       }
    #     }
    #   '''
    code: '''
      First = createReactClass({
        childContextTypes: externalPropTypes,
        render: ->
          return <div />
      })
    '''
    options: [checkContextTypes: yes]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          s: PropTypes.string,
          n: PropTypes.number,
          i: PropTypes.instanceOf,
          b: PropTypes.bool
        },
        render: ->
          return <div />
      })
    '''
    options: [checkContextTypes: yes]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          a: PropTypes.array
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['any', 'object']
      checkContextTypes: yes
    ]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          o: PropTypes.object
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['any', 'array']
      checkContextTypes: yes
    ]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          o: PropTypes.object,
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['any', 'array']
      checkContextTypes: yes
    ]
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.childContextTypes = {
        a: PropTypes.string,
        b: PropTypes.string
      }
      First.childContextTypes.justforcheck = PropTypes.string
    '''
    options: [checkContextTypes: yes]
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.childContextTypes = {
        elem: PropTypes.instanceOf(HTMLElement)
      }
    '''
    options: [checkContextTypes: yes]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello</div>
      Hello.childContextTypes = {
        "aria-controls": PropTypes.string
      }
    '''
    # parser: 'babel-eslint'
    options: [checkContextTypes: yes]
  ,
    # Invalid code, should not be validated
    code: '''
      class Component extends React.Component
        childContextTypes: {
          a: PropTypes.any,
          c: PropTypes.any,
          b: PropTypes.any
        }
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    options: [checkContextTypes: yes]
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          { a, ...b } = obj
          c = { ...d }
          return <div />
      })
    '''
    options: [checkContextTypes: yes]
  ,
    code: '''
      Hello = createReactClass({
        childContextTypes: {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        },
        render: ->
          return <div />
      })
    '''
    options: [checkContextTypes: yes]
  ,
    # Proptypes declared with a spread property
    code: '''
      class Test extends react.component
        @childContextTypes = {
          intl: React.childContextTypes.number,
          ...childContextTypes
        }
    '''
    # parser: 'babel-eslint'
    options: [checkContextTypes: yes]
  ,
    # ,
    #   # Proptypes declared with a spread property
    #   code: '''
    #     class Test extends react.component {
    #       static get childContextTypes() {
    #         return {
    #           intl: React.childContextTypes.number,
    #           ...childContextTypes
    #         }
    #       }
    #   '''
    #   options: [checkContextTypes: yes]
    code: '''
      First = createReactClass({
        childContextTypes: externalPropTypes,
        render: ->
          return <div />
      })
    '''
    options: [checkChildContextTypes: yes]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          s: PropTypes.string,
          n: PropTypes.number,
          i: PropTypes.instanceOf,
          b: PropTypes.bool
        },
        render: ->
          return <div />
      })
    '''
    options: [checkChildContextTypes: yes]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          a: PropTypes.array
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['any', 'object']
      checkChildContextTypes: yes
    ]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          o: PropTypes.object
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['any', 'array']
      checkChildContextTypes: yes
    ]
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          o: PropTypes.object,
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['any', 'array']
      checkChildContextTypes: yes
    ]
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.childContextTypes = {
        a: PropTypes.string,
        b: PropTypes.string
      }
      First.childContextTypes.justforcheck = PropTypes.string
    '''
    options: [checkChildContextTypes: yes]
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.childContextTypes = {
        elem: PropTypes.instanceOf(HTMLElement)
      }
    '''
    options: [checkChildContextTypes: yes]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello</div>
      Hello.childContextTypes = {
        "aria-controls": PropTypes.string
      }
    '''
    # parser: 'babel-eslint'
    options: [checkChildContextTypes: yes]
  ,
    # Invalid code, should not be validated
    code: '''
      class Component extends React.Component
        childContextTypes: {
          a: PropTypes.any,
          c: PropTypes.any,
          b: PropTypes.any
        }
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    options: [checkChildContextTypes: yes]
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          { a, ...b } = obj
          c = { ...d }
          return <div />
      })
    '''
    options: [checkChildContextTypes: yes]
  ,
    code: '''
      Hello = createReactClass({
        childContextTypes: {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        },
        render: ->
          return <div />
      })
    '''
    options: [checkChildContextTypes: yes]
  ,
    # Proptypes declared with a spread property
    code: '''
      class Test extends react.component
        @childContextTypes = {
          intl: React.childContextTypes.number,
          ...childContextTypes
        }
    '''
    # parser: 'babel-eslint'
    options: [checkChildContextTypes: yes]
    # ,
    #   # Proptypes declared with a spread property
    #   code: '''
    #     class Test extends react.component {
    #       static get childContextTypes() {
    #         return {
    #           intl: React.childContextTypes.number,
    #           ...childContextTypes
    #         }
    #       }
    #   '''
    #   options: [checkChildContextTypes: yes]
  ]

  invalid: [
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.any
        },
        render: ->
          return <div />
      })
    '''
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          n: PropTypes.number
        },
        render: ->
          return <div />
      })
    '''
    errors: [
      message: NUMBER_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
    options: [forbid: ['number']]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.any.isRequired
        },
        render: ->
          return <div />
      })
    '''
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.array
        },
        render: ->
          return <div />
      })
    '''
    errors: [
      message: ARRAY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.array.isRequired
        },
        render: ->
          return <div />
      })
    '''
    errors: [
      message: ARRAY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.object
        },
        render: ->
          return <div />
      })
    '''
    errors: [
      message: OBJECT_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.object.isRequired
        },
        render: ->
          return <div />
      })
    '''
    errors: [
      message: OBJECT_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.array,
          o: PropTypes.object
        },
        render: ->
          return <div />
      })
    '''
    errors: 2
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          s: PropTypes.shape({,
            o: PropTypes.object
          })
        },
        render: ->
          return <div />
      })
    '''
    errors: 1
  ,
    code: '''
      First = createReactClass({
        propTypes: {
          a: PropTypes.array
        },
        render: ->
          return <div />
      })
      Second = createReactClass({
        propTypes: {
          o: PropTypes.object
        },
        render: ->
          return <div />
      })
    '''
    errors: 2
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.propTypes = {
          a: PropTypes.array,
          o: PropTypes.object
      }
      class Second extends React.Component
        render: ->
          return <div />
      Second.propTypes = {
          a: PropTypes.array,
          o: PropTypes.object
      }
    '''
    errors: 4
  ,
    code: '''
      class First extends React.Component
        render: ->
          return <div />
      First.propTypes = forbidExtraProps({
          a: PropTypes.array
      })
    '''
    errors: 1
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      import { forbidExtraProps } from "airbnb-prop-types"
      export propTypes = {dpm: PropTypes.any}
      export default Component = ->
      Component.propTypes = propTypes
    '''
    errors: [message: ANY_ERROR_MESSAGE]
  ,
    code: '''
      import { forbidExtraProps } from "airbnb-prop-types"
      export propTypes = {a: PropTypes.any}
      export default Component = ->
      Component.propTypes = forbidExtraProps(propTypes)
    '''
    errors: [message: ANY_ERROR_MESSAGE]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      class Component extends React.Component
        @propTypes = {
          a: PropTypes.array,
          o: PropTypes.object
        }
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    errors: 2
  ,
    # ,
    #   code: '''
    #     class Component extends React.Component
    #       static get propTypes() {
    #         return {
    #           a: PropTypes.array,
    #           o: PropTypes.object
    #         }
    #       }
    #       render: ->
    #         return <div />
    #   '''
    #   errors: 2
    code: '''
      class Component extends React.Component
        @propTypes = forbidExtraProps({
          a: PropTypes.array,
          o: PropTypes.object
        })
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    errors: 2
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    # ,
    #   code: '''
    #     class Component extends React.Component {
    #       static get propTypes() {
    #         return forbidExtraProps({
    #           a: PropTypes.array,
    #           o: PropTypes.object
    #     '    })
    #     '  }
    #     '  render() {
    #     '    return <div />
    #     '  }
    #     '}
    #   '''
    #   errors: 2
    #   settings:
    #     propWrapperFunctions: ['forbidExtraProps']
    code: '''
      Hello = createReactClass({
        propTypes: {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        },
        render: ->
          return <div />
      })
    '''
    options: [forbid: ['instanceOf']]
    errors: 1
  ,
    code: '''
      object = PropTypes.object
      Hello = createReactClass({
        propTypes: {
          retailer: object,
        },
        render: ->
          return <div />
      })
    '''
    options: [forbid: ['object']]
    errors: 1
  ,
    code: '''
      First = createReactClass({
        contextTypes: {
          a: PropTypes.any
        },
        render: ->
          return <div />
      })
    '''
    options: [checkContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      class Foo extends Component
        @contextTypes = {
          a: PropTypes.any
        }
        render: ->
          return <div />
    '''
    options: [checkContextTypes: yes]
    # parser: 'babel-eslint'
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    # ,
    #   code: '''
    #     class Foo extends Component
    #       static get contextTypes() {
    #         return {
    #           a: PropTypes.any
    #         }
    #       }
    #       render: ->
    #         return <div />
    #   '''
    #   options: [checkContextTypes: yes]
    #   errors: [
    #     message: ANY_ERROR_MESSAGE
    #     line: 4
    #     column: 7
    #     type: 'Property'
    #   ]
    code: '''
      class Foo extends Component
        render: ->
          return <div />
      Foo.contextTypes = {
        a: PropTypes.any
      }
    '''
    options: [checkContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 5
      column: 3
      type: 'Property'
    ]
  ,
    code: '''
      Foo = (props) ->
        <div />
      Foo.contextTypes = {
        a: PropTypes.any
      }
    '''
    options: [checkContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 4
      column: 3
      type: 'Property'
    ]
  ,
    code: '''
      Foo = (props) =>
        return <div />
      Foo.contextTypes = {
        a: PropTypes.any
      }
    '''
    options: [checkContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 4
      column: 3
      type: 'Property'
    ]
  ,
    code: '''
      class Component extends React.Component
        @contextTypes: forbidExtraProps({
          a: PropTypes.array,
          o: PropTypes.object
        })
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    errors: 2
    options: [checkContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    # ,
    #   code: '''
    #     class Component extends React.Component
    #       static get contextTypes() {
    #         return forbidExtraProps({
    #           a: PropTypes.array,
    #           o: PropTypes.object
    #         })
    #       }
    #       render: ->
    #         return <div />
    #   '''
    #   errors: 2
    #   options: [checkContextTypes: yes]
    #   settings:
    #     propWrapperFunctions: ['forbidExtraProps']
    code: '''
      class Component extends React.Component
        render: ->
          return <div />
      Component.contextTypes = forbidExtraProps({
        a: PropTypes.array,
        o: PropTypes.object
      })
    '''
    errors: 2
    options: [checkContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      Component = (props) ->
        return <div />
      Component.contextTypes = forbidExtraProps({
        a: PropTypes.array,
        o: PropTypes.object
      })
    '''
    errors: 2
    options: [checkContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      Component = (props) =>
        return <div />
      Component.contextTypes = forbidExtraProps({
        a: PropTypes.array,
        o: PropTypes.object
      })
    '''
    errors: 2
    options: [checkContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      Hello = createReactClass({
        contextTypes: {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['instanceOf']
      checkContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      class Component extends React.Component
        @contextTypes = {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        }
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    options: [
      forbid: ['instanceOf']
      checkContextTypes: yes
    ]
    errors: 1
  ,
    # ,
    #   code: '''
    #     class Component extends React.Component {
    #       static get contextTypes() {
    #         return {
    #           retailer: PropTypes.instanceOf(Map).isRequired,
    #           requestRetailer: PropTypes.func.isRequired
    #         }
    #       }
    #       render() {
    #         return <div />
    #       }
    #     }
    #   '''
    #   options: [
    #     forbid: ['instanceOf']
    #     checkContextTypes: yes
    #   ]
    #   errors: 1
    code: '''
      class Component extends React.Component
        render: ->
          return <div />
      Component.contextTypes = {
        retailer: PropTypes.instanceOf(Map).isRequired,
        requestRetailer: PropTypes.func.isRequired
      }
    '''
    options: [
      forbid: ['instanceOf']
      checkContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      Component = (props) ->
        return <div />
      Component.contextTypes = {
        retailer: PropTypes.instanceOf(Map).isRequired,
        requestRetailer: PropTypes.func.isRequired
      }
    '''
    options: [
      forbid: ['instanceOf']
      checkContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      Component = (props) =>
        return <div />
      Component.contextTypes = {
        retailer: PropTypes.instanceOf(Map).isRequired,
        requestRetailer: PropTypes.func.isRequired
      }
    '''
    options: [
      forbid: ['instanceOf']
      checkContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      First = createReactClass({
        childContextTypes: {
          a: PropTypes.any
        },
        render: ->
          return <div />
      })
    '''
    options: [checkChildContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    code: '''
      class Foo extends Component
        @childContextTypes = {
          a: PropTypes.any
        }
        render: ->
          return <div />
    '''
    options: [checkChildContextTypes: yes]
    # parser: 'babel-eslint'
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 3
      column: 5
      type: 'Property'
    ]
  ,
    # ,
    #   code: '''
    #     class Foo extends Component
    #       static get childContextTypes() {
    #         return {
    #           a: PropTypes.any
    #         }
    #       }
    #       render: ->
    #         return <div />
    #   '''
    #   options: [checkChildContextTypes: yes]
    #   errors: [
    #     message: ANY_ERROR_MESSAGE
    #     line: 4
    #     column: 7
    #     type: 'Property'
    #   ]
    code: '''
      class Foo extends Component
        render: ->
          return <div />
      Foo.childContextTypes = {
        a: PropTypes.any
      }
    '''
    options: [checkChildContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 5
      column: 3
      type: 'Property'
    ]
  ,
    code: '''
      Foo = (props) ->
        <div />
      Foo.childContextTypes = {
        a: PropTypes.any
      }
    '''
    options: [checkChildContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 4
      column: 3
      type: 'Property'
    ]
  ,
    code: '''
      Foo = (props) =>
        return <div />
      Foo.childContextTypes = {
        a: PropTypes.any
      }
    '''
    options: [checkChildContextTypes: yes]
    errors: [
      message: ANY_ERROR_MESSAGE
      line: 4
      column: 3
      type: 'Property'
    ]
  ,
    code: '''
      class Component extends React.Component
        @childContextTypes = forbidExtraProps({
          a: PropTypes.array,
          o: PropTypes.object
        })
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    errors: 2
    options: [checkChildContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    # ,
    #   code: '''
    #     class Component extends React.Component {
    #       static get childContextTypes() {
    #         return forbidExtraProps({
    #           a: PropTypes.array,
    #           o: PropTypes.object
    #         })
    #       }
    #       render() {
    #         return <div />
    #       }
    #     }
    #   '''
    #   errors: 2
    #   options: [checkChildContextTypes: yes]
    #   settings:
    #     propWrapperFunctions: ['forbidExtraProps']
    code: '''
      class Component extends React.Component
        render: ->
          return <div />
      Component.childContextTypes = forbidExtraProps({
        a: PropTypes.array,
        o: PropTypes.object
      })
    '''
    errors: 2
    options: [checkChildContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      Component = (props) ->
        <div />
      Component.childContextTypes = forbidExtraProps({
        a: PropTypes.array,
        o: PropTypes.object
      })
    '''
    errors: 2
    options: [checkChildContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      Component = (props) =>
        return <div />
      Component.childContextTypes = forbidExtraProps({
        a: PropTypes.array,
        o: PropTypes.object
      })
    '''
    errors: 2
    options: [checkChildContextTypes: yes]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    code: '''
      Hello = createReactClass({
        childContextTypes: {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        },
        render: ->
          return <div />
      })
    '''
    options: [
      forbid: ['instanceOf']
      checkChildContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      class Component extends React.Component
        @childContextTypes = {
          retailer: PropTypes.instanceOf(Map).isRequired,
          requestRetailer: PropTypes.func.isRequired
        }
        render: ->
          return <div />
    '''
    # parser: 'babel-eslint'
    options: [
      forbid: ['instanceOf']
      checkChildContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      class Component extends React.Component
        render: ->
          return <div />
      Component.childContextTypes = {
        retailer: PropTypes.instanceOf(Map).isRequired,
        requestRetailer: PropTypes.func.isRequired
      }
    '''
    options: [
      forbid: ['instanceOf']
      checkChildContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      Component = (props) ->
        <div />
      Component.childContextTypes = {
        retailer: PropTypes.instanceOf(Map).isRequired,
        requestRetailer: PropTypes.func.isRequired
      }
    '''
    options: [
      forbid: ['instanceOf']
      checkChildContextTypes: yes
    ]
    errors: 1
  ,
    code: '''
      Component = (props) =>
        return <div />
      Component.childContextTypes = {
        retailer: PropTypes.instanceOf(Map).isRequired,
        requestRetailer: PropTypes.func.isRequired
      }
    '''
    options: [
      forbid: ['instanceOf']
      checkChildContextTypes: yes
    ]
    errors: 1
  ]
