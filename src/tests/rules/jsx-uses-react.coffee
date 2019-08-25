###*
# @fileoverview Tests for jsx-uses-react
# @author Glen Mailer
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

eslint = require 'eslint'
rule = require '../../rules/no-unused-vars'
path = require 'path'
{RuleTester} = eslint

settings =
  react:
    pragma: 'Foo'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
linter = ruleTester.linter ? eslint.linter
linter.defineRule(
  'jsx-uses-react'
  require 'eslint-plugin-react/lib/rules/jsx-uses-react'
)
ruleTester.run 'no-unused-vars', rule,
  valid: [
    code: '''
      ###eslint jsx-uses-react:1###
      React = null
      <div />
    '''
  ,
    code: '''
      ###eslint jsx-uses-react:1###
      React = null
      (-> <div />)()
    '''
  ,
    code: '''
      ###eslint jsx-uses-react:1###
      React = null
      do -> <div />
    '''
  ,
    code: '''
      ###eslint jsx-uses-react:1###
      ###* @jsx Foo ###
      Foo = null
      <div />
    '''
  ,
    {
      code: '''
        ###eslint jsx-uses-react:1###
        Foo = null
        <div />
      '''
      settings
    }
    # ,
    #   code: '''
    #     ###eslint jsx-uses-react:1###
    #     React = null
    #     <></>
    #   '''
    #   # parser: 'babel-eslint'
  ]
  invalid: [
    code: '''
      ###eslint jsx-uses-react:1###
      React = null
    '''
    errors: [message: "'React' is assigned a value but never used."]
  ,
    code: '''
      ###eslint jsx-uses-react:1###
      ###* @jsx Foo ###
      React = null
      <div />
    '''
    errors: [message: "'React' is assigned a value but never used."]
  ,
    {
      code: '''
        ###eslint jsx-uses-react:1###
        React = null
        <div />
      '''
      errors: [message: "'React' is assigned a value but never used."]
      settings
    }
  ,
    {
      code: '''
        ###eslint jsx-uses-react:1###
        React = null
        <></>
      '''
      # parser: 'babel-eslint'
      errors: [message: "'React' is assigned a value but never used."]
      settings
    }
  ]
