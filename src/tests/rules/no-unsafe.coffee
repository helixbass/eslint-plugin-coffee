###*
# @fileoverview Prevent usage of UNSAFE_ methods
# @author Sergei Startsev
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-unsafe'
{RuleTester} = require 'eslint'
path = require 'path'

errorMessage = (method, useInstead = 'componentDidMount') ->
  "#{method} is unsafe for use in async rendering. Update the component to use #{useInstead} instead. See https://reactjs.org/blog/2018/03/27/update-on-async-rendering.html."

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-unsafe', rule,
  valid: [
    code: '''
        class Foo extends React.Component
          componentDidUpdate: ->
          render: ->
    '''
    settings: react: version: '16.4.0'
  ,
    code: '''
        Foo = createReactClass
          componentDidUpdate: ->
          render: ->
      '''
    settings: react: version: '16.4.0'
  ,
    code: '''
        class Foo extends Bar {
          UNSAFE_componentWillMount: ->
          UNSAFE_componentWillReceiveProps: ->
          UNSAFE_componentWillUpdate: ->
        }
      '''
    settings: react: version: '16.4.0'
  ,
    code: '''
        Foo = bar({
          UNSAFE_componentWillMount: ->
          UNSAFE_componentWillReceiveProps: ->
          UNSAFE_componentWillUpdate: ->
        })
      '''
    settings: react: version: '16.4.0'
  ,
    code: '''
        class Foo extends React.Component
          UNSAFE_componentWillMount: ->
          UNSAFE_componentWillReceiveProps: ->
          UNSAFE_componentWillUpdate: ->
      '''
    settings: react: version: '16.2.0'
  ,
    code: '''
          Foo = createReactClass({
            UNSAFE_componentWillMount: ->
            UNSAFE_componentWillReceiveProps: ->
            UNSAFE_componentWillUpdate: ->
          })
        '''
    settings: react: version: '16.2.0'
  ]

  invalid: [
    code: '''
      class Foo extends React.Component
        UNSAFE_componentWillMount: ->
        UNSAFE_componentWillReceiveProps: ->
        UNSAFE_componentWillUpdate: ->
    '''
    settings: react: version: '16.3.0'
    errors: [
      message: errorMessage 'UNSAFE_componentWillMount'
      line: 1
      column: 1
      type: 'ClassDeclaration'
    ,
      message: errorMessage(
        'UNSAFE_componentWillReceiveProps'
        'getDerivedStateFromProps'
      )
      line: 1
      column: 1
      type: 'ClassDeclaration'
    ,
      message: errorMessage 'UNSAFE_componentWillUpdate', 'componentDidUpdate'
      line: 1
      column: 1
      type: 'ClassDeclaration'
    ]
  ,
    code: '''
        Foo = createReactClass
          UNSAFE_componentWillMount: ->
          UNSAFE_componentWillReceiveProps: ->
          UNSAFE_componentWillUpdate: ->
      '''
    settings: react: version: '16.3.0'
    errors: [
      message: errorMessage 'UNSAFE_componentWillMount'
      line: 2
      column: 3
      type: 'ObjectExpression'
    ,
      message: errorMessage(
        'UNSAFE_componentWillReceiveProps'
        'getDerivedStateFromProps'
      )
      line: 2
      column: 3
      type: 'ObjectExpression'
    ,
      message: errorMessage 'UNSAFE_componentWillUpdate', 'componentDidUpdate'
      line: 2
      column: 3
      type: 'ObjectExpression'
    ]
  ]
