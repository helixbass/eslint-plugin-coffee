###*
# @fileoverview Tests for jsx-uses-vars
# @author Yannick Croissant
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

eslint = require 'eslint'
ruleNoUnusedVars = require '../../rules/no-unused-vars'
path = require 'path'
{RuleTester} = eslint

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
linter = ruleTester.linter ? eslint.linter
linter.defineRule(
  'jsx-uses-vars'
  require 'eslint-plugin-react/lib/rules/jsx-uses-vars'
)
ruleTester.run 'no-unused-vars', ruleNoUnusedVars,
  valid: [
    code: """
        ### eslint jsx-uses-vars: 1 ###
        foo = ->
          App = null
          bar = React.render(<App/>)
          return bar
        foo()
      """
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        App = null
        React.render(<App/>)
      """
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        App = null
        React.render(<App/>)
      """
  ,
    # parser: 'babel-eslint'
    code: """
        ### eslint jsx-uses-vars: 1 ###
        a = 1
        React.render(<img src={a} />)
      """
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        App = null
        f = ->
          <App />
        f()
      """
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        App = null
        <App.Hello />
      """
  ,
    # ,
    #   code: """
    #       ### eslint jsx-uses-vars: 1 ###
    #       App = null
    #       <App:Hello />
    #     """
    code: """
        ### eslint jsx-uses-vars: 1 ###
        class HelloMessage
        <HelloMessage />
      """
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        class HelloMessage
          render: ->
            HelloMessage = <div>Hello</div>
            return HelloMessage
        <HelloMessage />
      """
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        foo = ->
          App = { Foo: { Bar: {} } }
          bar = React.render(<App.Foo.Bar/>)
          return bar
        foo()
      """
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        foo = ->
          App = { Foo: { Bar: { Baz: {} } } }
          bar = React.render(<App.Foo.Bar.Baz/>)
          return bar
        foo()
      """
  ]
  invalid: [
    code: '''
      ### eslint jsx-uses-vars: 1 ###
      App = null
    '''
    errors: [message: "'App' is assigned a value but never used."]
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        App = null
        unused = null
        React.render(<App unused=""/>)
      """
    errors: [message: "'unused' is assigned a value but never used."]
  ,

  ,
    # code: """
    #     ### eslint jsx-uses-vars: 1 ###
    #     App = null
    #     Hello = null
    #     React.render(<App:Hello/>)
    #   """
    # errors: [message: "'Hello' is defined but never used."]
    code: """
        ### eslint jsx-uses-vars: 1 ###
        Button = null
        Input = null
        React.render(<Button.Input unused=""/>)
      """
    errors: [message: "'Input' is assigned a value but never used."]
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        class unused
      """
    errors: [message: "'unused' is defined but never used."]
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        class HelloMessage
          render: ->
            HelloMessage = <div>Hello</div>
            return HelloMessage
      """
    errors: [
      message: "'HelloMessage' is defined but never used."
      line: 2
    ]
  ,
    code: """
        ### eslint jsx-uses-vars: 1 ###
        class HelloMessage
          render: (HelloMessage) ->
            HelloMessage = <div>Hello</div>
            return HelloMessage
      """
    errors: [
      message: "'HelloMessage' is defined but never used."
      line: 2
    ]
  ,
    # parser: 'babel-eslint'
    code: """
        ### eslint jsx-uses-vars: 1 ###
        import {Hello} from 'Hello'
        Greetings = (Hello) ->
          Hello = require('Hello').default
          return <Hello />
        Greetings()
      """
    errors: [
      message: "'Hello' is defined but never used."
      line: 2
    ]
    # parser: 'babel-eslint'
  ]
