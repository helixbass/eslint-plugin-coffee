###*
# @fileoverview Tests for no-redundant-should-component-update
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require '../../rules/no-redundant-should-component-update'
{RuleTester} = require 'eslint'
path = require 'path'

errorMessage = (node) ->
  "#{node} does not need shouldComponentUpdate when extending React.PureComponent."

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-redundant-should-component-update', rule,
  valid: [
    code: """
      class Foo extends React.Component
        shouldComponentUpdate: ->
          return true
    """
  ,
    code: """
      class Foo extends React.Component
        shouldComponentUpdate: () =>
          return true
    """
  ,
    # parser: 'babel-eslint'
    code: """
        class Foo extends React.Component
          shouldComponentUpdate: ->
            return true
      """
  ,
    code: """
      Foo = ->
        return class Bar extends React.Component
          shouldComponentUpdate: ->
            return true
    """
  ]

  invalid: [
    code: """
      class Foo extends React.PureComponent
        shouldComponentUpdate: ->
          return true
    """
    errors: [message: errorMessage 'Foo']
  ,
    code: """
      class Foo extends PureComponent
        shouldComponentUpdate: ->
          return true
    """
    errors: [message: errorMessage 'Foo']
  ,
    code: """
      class Foo extends React.PureComponent
        shouldComponentUpdate: () =>
          return true
    """
    errors: [message: errorMessage 'Foo']
  ,
    # parser: 'babel-eslint'
    code: """
      Foo = ->
        return class Bar extends React.PureComponent
          shouldComponentUpdate: ->
            return true
    """
    errors: [message: errorMessage 'Bar']
  ,
    code: """
      Foo = ->
        return class Bar extends PureComponent
          shouldComponentUpdate: ->
            return true
    """
    errors: [message: errorMessage 'Bar']
  ,
    code: """
      Foo = class extends PureComponent
        shouldComponentUpdate: ->
          return true
    """
    errors: [message: errorMessage 'Foo']
  ]
