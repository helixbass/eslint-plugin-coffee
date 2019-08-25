###*
# @fileoverview Tests for jsx-no-undef
# @author Yannick Croissant
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

eslint = require 'eslint'
rule = require 'eslint-plugin-react/lib/rules/jsx-no-undef'
{RuleTester} = eslint
path = require 'path'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
linter = ruleTester.linter or eslint.linter
linter.defineRule 'no-undef', require 'eslint/lib/rules/no-undef'
ruleTester.run 'jsx-no-undef', rule,
  valid: [
    code: '''
      ###eslint no-undef:1###
      React = null
      App = null
      React.render(<App />)
    '''
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      App = null
      React.render(<App />)
    '''
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      React.render(<img />)
    '''
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      React.render(<x-gif />)
    '''
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      app = null
      React.render(<app.Foo />)
    '''
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      app = null
      React.render(<app.foo.Bar />)
    '''
  ,
    code: """
      ###eslint no-undef:1###
      React = null
      class Hello extends React.Component
        render: ->
          return <this.props.tag />
    """
  ,
    # ,
    #   code: '''
    #     React = null
    #     React.render(<Text />)
    #   '''
    #   globals:
    #     Text: yes
    code: '''
      React = null
      React.render(<Text />)
    '''
    globals:
      Text: yes
    options: [allowGlobals: yes]
  ,
    code: """
      import Text from "cool-module"
      TextWrapper = (props) ->
        (
          <Text />
        )
    """
    # parserOptions: Object.assign {sourceType: 'module'}, parserOptions
    options: [allowGlobals: no]
    # parser: 'babel-eslint'
  ]
  invalid: [
    code: '''
      ###eslint no-undef:1###
      React = null
      React.render(<App />)
    '''
    errors: [message: "'App' is not defined."]
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      React.render(<Appp.Foo />)
    '''
    errors: [message: "'Appp' is not defined."]
  ,
    # ,
    #   code: '''
    #     ###eslint no-undef:1###
    #     React = null
    #     React.render(<Apppp:Foo />)
    #   '''
    #   errors: [message: "'Apppp' is not defined."]
    code: '''
      ###eslint no-undef:1###
      React = null
      React.render(<appp.Foo />)
    '''
    errors: [message: "'appp' is not defined."]
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      React.render(<appp.foo.Bar />)
    '''
    errors: [message: "'appp' is not defined."]
  ,
    code: """
      TextWrapper = (props) ->
        return (
          <Text />
        )
      export default TextWrapper
    """
    # parserOptions: Object.assign {sourceType: 'module'}, parserOptions
    errors: [message: "'Text' is not defined."]
    options: [allowGlobals: no]
    # parser: 'babel-eslint'
    globals:
      Text: yes
  ,
    code: '''
      ###eslint no-undef:1###
      React = null
      React.render(<Foo />)
    '''
    errors: [message: "'Foo' is not defined."]
  ]
