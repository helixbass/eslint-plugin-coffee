###*
# @fileoverview Tests for forbid-component-props
###
'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/forbid-component-props'
{RuleTester} = require 'eslint'
path = require 'path'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

CLASSNAME_ERROR_MESSAGE = 'Prop "className" is forbidden on Components'
STYLE_ERROR_MESSAGE = 'Prop "style" is forbidden on Components'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'forbid-component-props', rule,
  valid: [
    code: '''
      First = createReactClass({
        render: ->
          return <div className="foo" />
      })
    '''
  ,
    code: '''
      First = createReactClass({
        render: ->
          return <div style={{color: "red"}} />
      })
    '''
    options: [forbid: ['style']]
  ,
    code: '''
      First = createReactClass
        propTypes: externalPropTypes
        render: ->
          <Foo bar="baz" />
    '''
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes
        render: ->
          return <Foo className="bar" />
      })
    '''
    options: [forbid: ['style']]
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <Foo className="bar" />
      })
    '''
    options: [forbid: ['style', 'foo']]
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <this.Foo bar="baz" />
      })
    '''
  ,
    code: '''
      class First extends createReactClass
        render: ->
          return <this.foo className="bar" />
    '''
    options: [forbid: ['style']]
  ,
    code: '''
      First = (props) => (
        <this.Foo {...props} />
      )
    '''
  ,
    code: 'item = (<ReactModal className="foo" />)'
    options: [forbid: [propName: 'className', allowedFor: ['ReactModal']]]
  ]

  invalid: [
    code: '''
      First = createReactClass
        propTypes: externalPropTypes
        render: ->
          <Foo className="bar" />
    '''
    errors: [
      message: CLASSNAME_ERROR_MESSAGE
      line: 4
      column: 10
      type: 'JSXAttribute'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <Foo style={{color: "red"}} />
      })
    '''
    errors: [
      message: STYLE_ERROR_MESSAGE
      line: 4
      column: 17
      type: 'JSXAttribute'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <Foo className="bar" />
      })
    '''
    options: [forbid: ['className', 'style']]
    errors: [
      message: CLASSNAME_ERROR_MESSAGE
      line: 4
      column: 17
      type: 'JSXAttribute'
    ]
  ,
    code: '''
      First = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <Foo style={{color: "red"}} />
      })
    '''
    options: [forbid: ['className', 'style']]
    errors: [
      message: STYLE_ERROR_MESSAGE
      line: 4
      column: 17
      type: 'JSXAttribute'
    ]
  ,
    code: 'item = (<Foo className="foo" />)'
    options: [forbid: [propName: 'className', allowedFor: ['ReactModal']]]
    errors: [
      message: CLASSNAME_ERROR_MESSAGE
      line: 1
      column: 14
      type: 'JSXAttribute'
    ]
  ,
    code: 'item = (<this.ReactModal className="foo" />)'
    options: [forbid: [propName: 'className', allowedFor: ['ReactModal']]]
    errors: [
      message: CLASSNAME_ERROR_MESSAGE
      line: 1
      column: 26
      type: 'JSXAttribute'
    ]
  ]
