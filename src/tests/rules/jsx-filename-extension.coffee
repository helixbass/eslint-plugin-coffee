###*
# @fileoverview Restrict file extensions that may contain JSX
# @author Joe Lencioni
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/jsx-filename-extension'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Code Snippets
# ------------------------------------------------------------------------------

withJSXElement = '''
  module.exports = MyComponent = ->
    <div>
      <div />
    </div>
'''
withJSXFragment = '''
  module.exports = MyComponent = ->
    <></>
'''
withoutJSX = 'module.exports = {}'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-filename-extension', rule,
  valid: [
    filename: '<text>'
    code: withJSXElement
  ,
    filename: 'MyComponent.jsx'
    code: withJSXElement
  ,
    filename: 'MyComponent.js'
    options: [extensions: ['.js', '.jsx']]
    code: withJSXElement
  ,
    filename: 'notAComponent.js'
    code: withoutJSX
  ,
    filename: '<text>'
    code: withJSXFragment
  ,
    # parser: 'babel-eslint'
    filename: 'MyComponent.jsx'
    code: withJSXFragment
  ,
    # parser: 'babel-eslint'
    filename: 'MyComponent.js'
    options: [extensions: ['.js', '.jsx']]
    code: withJSXFragment
    # parser: 'babel-eslint'
  ]

  invalid: [
    filename: 'MyComponent.js'
    code: withJSXElement
    errors: [message: "JSX not allowed in files with extension '.js'"]
  ,
    filename: 'MyComponent.jsx'
    code: withJSXElement
    options: [extensions: ['.js']]
    errors: [message: "JSX not allowed in files with extension '.jsx'"]
    # ,
    #   filename: 'MyComponent.js'
    #   code: withJSXFragment
    #   # parser: 'babel-eslint'
    #   errors: [message: "JSX not allowed in files with extension '.js'"]
    # ,
    #   filename: 'MyComponent.jsx'
    #   code: withJSXFragment
    #   # parser: 'babel-eslint'
    #   options: [extensions: ['.js']]
    #   errors: [message: "JSX not allowed in files with extension '.jsx'"]
  ]
