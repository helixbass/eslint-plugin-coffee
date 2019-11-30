###*
# @fileoverview Tests for no-typos
###
'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require '../../rules/no-typos'
{RuleTester} = require 'eslint'
path = require 'path'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ERROR_MESSAGE = 'Typo in static class property declaration'
ERROR_MESSAGE_LIFECYCLE_METHOD =
  'Typo in component lifecycle method declaration'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-typos', rule,
  valid: [
    code: '''
      class First
        @PropTypes = {key: "myValue"}
        @ContextTypes = {key: "myValue"}
        @ChildContextTypes = {key: "myValue"}
        @DefaultProps = {key: "myValue"}
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class First
      First.PropTypes = {key: "myValue"}
      First.ContextTypes = {key: "myValue"}
      First.ChildContextTypes = {key: "myValue"}
      First.DefaultProps = {key: "myValue"}
    '''
  ,
    code: '''
      class First extends React.Component
        @propTypes = {key: "myValue"}
        @contextTypes = {key: "myValue"}
        @childContextTypes = {key: "myValue"}
        @defaultProps = {key: "myValue"}
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class First extends React.Component
      First.propTypes = {key: "myValue"}
      First.contextTypes = {key: "myValue"}
      First.childContextTypes = {key: "myValue"}
      First.defaultProps = {key: "myValue"}
    '''
  ,
    code: '''
      class MyClass
        propTypes = {key: "myValue"}
        contextTypes = {key: "myValue"}
        childContextTypes = {key: "myValue"}
        defaultProps = {key: "myValue"}
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class MyClass
        PropTypes = {key: "myValue"}
        ContextTypes = {key: "myValue"}
        ChildContextTypes = {key: "myValue"}
        DefaultProps = {key: "myValue"}
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class MyClass
        proptypes = {key: "myValue"}
        contexttypes = {key: "myValue"}
        childcontextypes = {key: "myValue"}
        defaultprops = {key: "myValue"}
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class MyClass
        @PropTypes: ->
        @ContextTypes: ->
        @ChildContextTypes: ->
        @DefaultProps: ->
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class MyClass
        @proptypes: ->
        @contexttypes: ->
        @childcontexttypes: ->
        @defaultprops: ->
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class MyClass
      MyClass::PropTypes = ->
      MyClass::ContextTypes = ->
      MyClass::ChildContextTypes = ->
      MyClass::DefaultProps = ->
    '''
  ,
    code: '''
      class MyClass
      MyClass.PropTypes = ->
      MyClass.ContextTypes = ->
      MyClass.ChildContextTypes = ->
      MyClass.DefaultProps = ->
    '''
  ,
    code: '''
      MyRandomFunction = ->
      MyRandomFunction.PropTypes = {}
      MyRandomFunction.ContextTypes = {}
      MyRandomFunction.ChildContextTypes = {}
      MyRandomFunction.DefaultProps = {}
    '''
  ,
    # This case is currently not supported
    code: '''
      class First extends React.Component
      First["prop" + "Types"] = {}
      First["context" + "Types"] = {}
      First["childContext" + "Types"] = {}
      First["default" + "Props"] = {}
    '''
  ,
    # This case is currently not supported
    code: '''
      class First extends React.Component
      First["PROP" + "TYPES"] = {}
      First["CONTEXT" + "TYPES"] = {}
      First["CHILDCONTEXT" + "TYPES"] = {}
      First["DEFAULT" + "PROPS"] = {}
    '''
  ,
    code: '''
      propTypes = "PROPTYPES"
      contextTypes = "CONTEXTTYPES"
      childContextTypes = "CHILDCONTEXTTYPES"
      defautProps = "DEFAULTPROPS"

      class First extends React.Component
      First[propTypes] = {}
      First[contextTypes] = {}
      First[childContextTypes] = {}
      First[defautProps] = {}
    '''
  ,
    code: '''
      class Hello extends React.Component
        componentWillMount: ->
        componentDidMount: ->
        componentWillReceiveProps: ->
        shouldComponentUpdate: ->
        componentWillUpdate: ->
        componentDidUpdate: ->
        componentWillUnmount: ->
        render: ->
          return <div>Hello {this.props.name}</div>
    '''
  ,
    code: '''
      class MyClass
        componentWillMount: ->
        componentDidMount: ->
        componentWillReceiveProps: ->
        shouldComponentUpdate: ->
        componentWillUpdate: ->
        componentDidUpdate: ->
        componentWillUnmount: ->
        render: ->
    '''
  ,
    code: '''
      class MyClass
        componentwillmount: ->
        componentdidmount: ->
        componentwillreceiveprops: ->
        shouldcomponentupdate: ->
        componentwillupdate: ->
        componentdidupdate: ->
        componentwillUnmount: ->
        render: ->
    '''
  ,
    code: '''
      class MyClass
        Componentwillmount: ->
        Componentdidmount: ->
        Componentwillreceiveprops: ->
        Shouldcomponentupdate: ->
        Componentwillupdate: ->
        Componentdidupdate: ->
        ComponentwillUnmount: ->
        Render: ->
    '''
  ,
    # https://github.com/yannickcr/eslint-plugin-react/issues/1353
    code: '''
      test = (b) ->
        return a.bind(b)
      a = ->
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.number.isRequired
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        e: PropTypes.shape({
          ea: PropTypes.string,
        })
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.string,
        b: PropTypes.string.isRequired,
        c: PropTypes.shape({
          d: PropTypes.string,
          e: PropTypes.number.isRequired,
        }).isRequired
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.oneOfType([
          PropTypes.string,
          PropTypes.number
        ])
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.oneOf([
          'hello',
          'hi'
        ])
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.string,
        b: PropTypes.string.isRequired,
        c: PropTypes.shape({
          d: PropTypes.string,
          e: PropTypes.number.isRequired,
        }).isRequired
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.oneOf([
          'hello',
          'hi'
        ])
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.string,
        b: PropTypes.string.isRequired,
        c: PropTypes.shape({
          d: PropTypes.string,
          e: PropTypes.number.isRequired,
        }).isRequired
      }
   '''
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.contextTypes = {
        a: PropTypes.string,
        b: PropTypes.string.isRequired,
        c: PropTypes.shape({
          d: PropTypes.string,
          e: PropTypes.number.isRequired,
        }).isRequired
      }
   '''
  ,
    code: '''
      import PropTypes from 'prop-types'
      import * as MyPropTypes from 'lib/my-prop-types'
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.string,
        b: MyPropTypes.MYSTRING,
        c: MyPropTypes.MYSTRING.isRequired,
      }
   '''
  ,
    code: '''
      import PropTypes from "prop-types"
      import * as MyPropTypes from 'lib/my-prop-types'
      class Component extends React.Component
      Component.propTypes = {
        b: PropTypes.string,
        a: MyPropTypes.MYSTRING,
      }
   '''
  ,
    code: '''
      import CustomReact from "react"
      class Component extends React.Component
      Component.propTypes = {
        b: CustomReact.PropTypes.string,
      }
   '''
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.string,
        b: PropTypes.string.isRequired,
        c: PropTypes.shape({
          d: PropTypes.string,
          e: PropTypes.number.isRequired,
        }).isRequired
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.contextTypes = {
        a: PropTypes.string,
        b: PropTypes.string.isRequired,
        c: PropTypes.shape({
          d: PropTypes.string,
          e: PropTypes.number.isRequired,
        }).isRequired
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from 'prop-types'
      import * as MyPropTypes from 'lib/my-prop-types'
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.string,
        b: MyPropTypes.MYSTRING,
        c: MyPropTypes.MYSTRING.isRequired,
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import PropTypes from "prop-types"
      import * as MyPropTypes from 'lib/my-prop-types'
      class Component extends React.Component
      Component.propTypes = {
        b: PropTypes.string,
        a: MyPropTypes.MYSTRING,
      }
   '''
  ,
    # parser: 'babel-eslint'
    code: '''
      import CustomReact from "react"
      class Component extends React.Component
      Component.propTypes = {
        b: CustomReact.PropTypes.string,
      }
   '''
  ,
    # parser: 'babel-eslint'
    # ensure that an absent arg to PropTypes.shape does not crash
    code: '''
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.shape(),
      }
      Component.contextTypes = {
        a: PropTypes.shape(),
      }
    '''
  ,
    # ensure that an absent arg to PropTypes.shape does not crash
    code: '''
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.shape(),
      }
      Component.contextTypes = {
        a: PropTypes.shape(),
      }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      fn = (err, res) =>
        { body: data = {} } = { ...res }
        data.time = data.time || {}
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
     class Component extends React.Component
     Component.propTypes = {
       b: string.isRequired,
       c: PropTypes.shape({
         d: number.isRequired,
       }).isRequired
     }
   '''
  ,
    code: '''
     class Component extends React.Component
     Component.propTypes = {
       b: string.isRequired,
       c: PropTypes.shape({
         d: number.isRequired,
       }).isRequired
     }
   '''
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: '''
      class Component extends React.Component
        @PropTypes = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.PropTypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> return (<div>{this.props.myProp}</div>)
      MyComponent.PropTypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
        @proptypes = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.proptypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> return (<div>{this.props.myProp}</div>)
      MyComponent.proptypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
        @ContextTypes = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.ContextTypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> return (<div>{this.props.myProp}</div>)
      MyComponent.ContextTypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
        @contexttypes = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.contexttypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> return (<div>{this.props.myProp}</div>)
      MyComponent.contexttypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
        @ChildContextTypes = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.ChildContextTypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> (<div>{this.props.myProp}</div>)
      MyComponent.ChildContextTypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
        @childcontexttypes = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.childcontexttypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> return (<div>{this.props.myProp}</div>)
      MyComponent.childcontexttypes = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
        @DefaultProps = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.DefaultProps = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> return (<div>{this.props.myProp}</div>)
      MyComponent.DefaultProps = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
        @defaultprops = {}
    '''
    # parser: 'babel-eslint'
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Component extends React.Component
      Component.defaultprops = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      MyComponent = -> return (<div>{this.props.myProp}</div>)
      MyComponent.defaultprops = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      Component.defaultprops = {}
      class Component extends React.Component
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      ###* @extends React.Component ###
      class MyComponent extends BaseComponent
      MyComponent.PROPTYPES = {}
    '''
    errors: [message: ERROR_MESSAGE]
  ,
    code: '''
      class Hello extends React.Component
        @GetDerivedStateFromProps: ->
        ComponentWillMount: ->
        UNSAFE_ComponentWillMount: ->
        ComponentDidMount: ->
        ComponentWillReceiveProps: ->
        UNSAFE_ComponentWillReceiveProps: ->
        ShouldComponentUpdate: ->
        ComponentWillUpdate: ->
        UNSAFE_ComponentWillUpdate: ->
        GetSnapshotBeforeUpdate: ->
        ComponentDidUpdate: ->
        ComponentDidCatch: ->
        ComponentWillUnmount: ->
        render: ->
          return <div>Hello {this.props.name}</div>
    '''
    errors: [
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ]
  ,
    code: '''
      class Hello extends React.Component
        @Getderivedstatefromprops: ->
        Componentwillmount: ->
        UNSAFE_Componentwillmount: ->
        Componentdidmount: ->
        Componentwillreceiveprops: ->
        UNSAFE_Componentwillreceiveprops: ->
        Shouldcomponentupdate: ->
        Componentwillupdate: ->
        UNSAFE_Componentwillupdate: ->
        Getsnapshotbeforeupdate: ->
        Componentdidupdate: ->
        Componentdidcatch: ->
        Componentwillunmount: ->
        Render: ->
          return <div>Hello {this.props.name}</div>
    '''
    errors: [
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ]
  ,
    code: '''
      class Hello extends React.Component
        @getderivedstatefromprops: ->
        componentwillmount: ->
        unsafe_componentwillmount: ->
        componentdidmount: ->
        componentwillreceiveprops: ->
        unsafe_componentwillreceiveprops: ->
        shouldcomponentupdate: ->
        componentwillupdate: ->
        unsafe_componentwillupdate: ->
        getsnapshotbeforeupdate: ->
        componentdidupdate: ->
        componentdidcatch: ->
        componentwillunmount: ->
        render: ->
          return <div>Hello {this.props.name}</div>
    '''
    errors: [
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ,
      message: ERROR_MESSAGE_LIFECYCLE_METHOD
      type: 'MethodDefinition'
    ]
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
          a: PropTypes.Number.isRequired
      }
    '''
    errors: [message: 'Typo in declared prop type: Number']
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
          a: PropTypes.number.isrequired
      }
    '''
    errors: [message: 'Typo in prop type chain qualifier: isrequired']
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
        @propTypes = {
          a: PropTypes.number.isrequired
        }
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Typo in prop type chain qualifier: isrequired']
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
        @propTypes = {
          a: PropTypes.Number
        }
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Typo in declared prop type: Number']
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
          a: PropTypes.Number
      }
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Typo in declared prop type: Number']
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.shape({
          b: PropTypes.String,
          c: PropTypes.number.isRequired,
        })
      }
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Typo in declared prop type: String']
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.oneOfType([
          PropTypes.bools,
          PropTypes.number,
        ])
      }
    '''
    # parser: 'babel-eslint'
    errors: [message: 'Typo in declared prop type: bools']
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.propTypes = {
        a: PropTypes.bools,
        b: PropTypes.Array,
        c: PropTypes.function,
        d: PropTypes.objectof,
      }
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
      import PropTypes from "prop-types"
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.bools,
        b: PropTypes.Array,
        c: PropTypes.function,
        d: PropTypes.objectof,
      }
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
      import PropTypes from 'prop-types'
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.bools,
        b: PropTypes.Array,
        c: PropTypes.function,
        d: PropTypes.objectof,
      }
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
     import PropTypes from 'prop-types'
     class Component extends React.Component
     Component.propTypes = {
       a: PropTypes.string.isrequired,
       b: PropTypes.shape({
         c: PropTypes.number
       }).isrequired
     }
    '''
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
     import PropTypes from 'prop-types'
     class Component extends React.Component
     Component.propTypes = {
       a: PropTypes.string.isrequired,
       b: PropTypes.shape({
         c: PropTypes.number
       }).isrequired
     }
   '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
      import RealPropTypes from 'prop-types'
      class Component extends React.Component
      Component.childContextTypes = {
        a: RealPropTypes.bools,
        b: RealPropTypes.Array,
        c: RealPropTypes.function,
        d: RealPropTypes.objectof,
      }
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
     import React from 'react'
     class Component extends React.Component
     Component.propTypes = {
       a: React.PropTypes.string.isrequired,
       b: React.PropTypes.shape({
         c: React.PropTypes.number
       }).isrequired
     }
   '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
      import React from 'react'
      class Component extends React.Component
      Component.childContextTypes = {
        a: React.PropTypes.bools,
        b: React.PropTypes.Array,
        c: React.PropTypes.function,
        d: React.PropTypes.objectof,
      }
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
     import { PropTypes } from 'react'
     class Component extends React.Component
     Component.propTypes = {
       a: PropTypes.string.isrequired,
       b: PropTypes.shape({
         c: PropTypes.number
       }).isrequired
     }
   '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
     import 'react'
     class Component extends React.Component
   '''
    # parser: 'babel-eslint'
    errors: []
  ,
    code: '''
      import { PropTypes } from 'react'
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.bools,
        b: PropTypes.Array,
        c: PropTypes.function,
        d: PropTypes.objectof,
      }
    '''
    # parser: 'babel-eslint'
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
      import PropTypes from 'prop-types'
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.bools,
        b: PropTypes.Array,
        c: PropTypes.function,
        d: PropTypes.objectof,
      }
    '''
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
     import PropTypes from 'prop-types'
     class Component extends React.Component
     Component.propTypes = {
       a: PropTypes.string.isrequired,
       b: PropTypes.shape({
         c: PropTypes.number
       }).isrequired
     }
    '''
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
     import PropTypes from 'prop-types'
     class Component extends React.Component
     Component.propTypes = {
       a: PropTypes.string.isrequired,
       b: PropTypes.shape({
         c: PropTypes.number
       }).isrequired
     }
   '''
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
      import RealPropTypes from 'prop-types'
      class Component extends React.Component
      Component.childContextTypes = {
        a: RealPropTypes.bools,
        b: RealPropTypes.Array,
        c: RealPropTypes.function,
        d: RealPropTypes.objectof,
      }
    '''
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
     import React from 'react'
     class Component extends React.Component
     Component.propTypes = {
       a: React.PropTypes.string.isrequired,
       b: React.PropTypes.shape({
         c: React.PropTypes.number
       }).isrequired
     }
   '''
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
      import React from 'react'
      class Component extends React.Component
      Component.childContextTypes = {
        a: React.PropTypes.bools,
        b: React.PropTypes.Array,
        c: React.PropTypes.function,
        d: React.PropTypes.objectof,
      }
    '''
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ,
    code: '''
     import { PropTypes } from 'react'
     class Component extends React.Component
     Component.propTypes = {
       a: PropTypes.string.isrequired,
       b: PropTypes.shape({
         c: PropTypes.number
       }).isrequired
     }
   '''
    errors: [
      message: 'Typo in prop type chain qualifier: isrequired'
    ,
      message: 'Typo in prop type chain qualifier: isrequired'
    ]
  ,
    code: '''
      import { PropTypes } from 'react'
      class Component extends React.Component
      Component.childContextTypes = {
        a: PropTypes.bools,
        b: PropTypes.Array,
        c: PropTypes.function,
        d: PropTypes.objectof,
      }
    '''
    errors: [
      message: 'Typo in declared prop type: bools'
    ,
      message: 'Typo in declared prop type: Array'
    ,
      message: 'Typo in declared prop type: function'
    ,
      message: 'Typo in declared prop type: objectof'
    ]
  ]
  ###
    // PropTypes declared on a component that is detected through JSDoc comments and is
    // declared AFTER the PropTypes assignment
    // Commented out since it only works with ESLint 5.
      ,{
        code: `
          MyComponent.PROPTYPES = {}
          \* @extends React.Component *\/
          class MyComponent extends BaseComponent
        `,
        parserOptions: parserOptions
      },
  ###
  ###
    // createClass tests below fail, so they're commented out
    // ---------
      }, {
        code: `
          import React from 'react'
          import PropTypes from 'prop-types'
          Component = React.createClass({
            propTypes: {
              a: PropTypes.string.isrequired,
              b: PropTypes.shape({
                c: PropTypes.number
              }).isrequired
            }
          })
        `,
        # parser: 'babel-eslint',
        parserOptions: parserOptions,
        errors: [{
          message: 'Typo in prop type chain qualifier: isrequired'
        }, {
          message: 'Typo in prop type chain qualifier: isrequired'
        }]
      }, {
        code: `
          import React from 'react'
          import PropTypes from 'prop-types'
          Component = React.createClass({
            childContextTypes: {
              a: PropTypes.bools,
              b: PropTypes.Array,
              c: PropTypes.function,
              d: PropTypes.objectof,
            }
          })
        `,
        # parser: 'babel-eslint',
        parserOptions: parserOptions,
        errors: [{
          message: 'Typo in declared prop type: bools'
        }, {
          message: 'Typo in declared prop type: Array'
        }, {
          message: 'Typo in declared prop type: function'
        }, {
          message: 'Typo in declared prop type: objectof'
        }]
      }, {
        code: `
          import React from 'react'
          import PropTypes from 'prop-types'
          Component = React.createClass({
            propTypes: {
              a: PropTypes.string.isrequired,
              b: PropTypes.shape({
                c: PropTypes.number
              }).isrequired
            }
          })
        `,
        parserOptions: parserOptions,
        errors: [{
          message: 'Typo in prop type chain qualifier: isrequired'
        }, {
          message: 'Typo in prop type chain qualifier: isrequired'
        }]
      }, {
        code: `
          import React from 'react'
          import PropTypes from 'prop-types'
          Component = React.createClass({
            childContextTypes: {
              a: PropTypes.bools,
              b: PropTypes.Array,
              c: PropTypes.function,
              d: PropTypes.objectof,
            }
          })
        `,
        parserOptions: parserOptions,
        errors: [{
          message: 'Typo in declared prop type: bools'
        }, {
          message: 'Typo in declared prop type: Array'
        }, {
          message: 'Typo in declared prop type: function'
        }, {
          message: 'Typo in declared prop type: objectof'
        }]
      }]
    // ---------
    // createClass tests above fail, so they're commented out
  ###
