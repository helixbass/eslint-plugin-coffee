###*
# @fileoverview Tests for react-in-jsx-scope
# @author Glen Mailer
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/react-in-jsx-scope'
{RuleTester} = require 'eslint'

settings =
  react:
    pragma: 'Foo'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'react-in-jsx-scope', rule,
  valid: [
    code: '''
      React = null
      App <App />
    '''
  ,
    code: '''
      React = null
      <img />
    '''
  ,
    code: '''
      React = null
      <>fragment</>
    '''
  ,
    code: '''
      React = null
      <x-gif />
    '''
  ,
    code: '''
      React = null
      App = null
      a = 1
      <App attr={a} />
    '''
  ,
    code: '''
      React = null
      App = null
      a = 1
      elem = -> return <App attr={a} />
    '''
  ,
    code: '''
      React = null
      App = null
      <App />
    '''
  ,
    code: '''
      ###* @jsx Foo ###
      Foo = null
      App = null
      <App />
    '''
  ,
    code: '''
      ###* @jsx Foo.Bar ###
      Foo = null
      App = null
      <App />
    '''
  ,
    code: """
      import React from 'react/addons'
      Button = createReactClass
        render: ->
          <button {@props...}>{@props.children}</button>
      export default Button
    """
  ,
    {
      code: '''
        Foo = null
        App = null
        <App />
      '''
      settings
    }
  ]
  invalid: [
    code: '''
      App = null
      a = <App />
    '''
    errors: [message: "'React' must be in scope when using JSX"]
  ,
    code: 'a = <App />'
    errors: [message: "'React' must be in scope when using JSX"]
  ,
    code: 'a = <img />'
    errors: [message: "'React' must be in scope when using JSX"]
  ,
    code: 'a = <>fragment</>'
    errors: [message: "'React' must be in scope when using JSX"]
  ,
    code: '''
      ###* @jsx React.DOM ###
      a = <img />
    '''
    errors: [message: "'React' must be in scope when using JSX"]
  ,
    code: '''
      ###* @jsx Foo.bar ###
      React = null
      a = <img />
    '''
    errors: [message: "'Foo' must be in scope when using JSX"]
  ,
    {
      code: '''
        React = null
        a = <img />
      '''
      errors: [message: "'Foo' must be in scope when using JSX"]
      settings
    }
  ]
