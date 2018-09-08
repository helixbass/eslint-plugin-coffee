###*
# @fileoverview Test for no-underscore-dangle rule
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-underscore-dangle'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-underscore-dangle', rule,
  valid: [
    'foo_bar = 1'
    'foo_bar = ->'
    'foo.bar.__proto__'
    '''
      console.log(__filename)
      console.log(__dirname)
    '''
    "_ = require('underscore')"
    'a = b._'
    'export default ->'
  ,
    code: '_foo = 1', options: [allow: ['_foo']]
  ,
    code: '__proto__ = 1', options: [allow: ['__proto__']]
  ,
    code: 'foo._bar', options: [allow: ['_bar']]
  ,
    code: '_foo = ->', options: [allow: ['_foo']]
  ,
    code: 'this._bar', options: [allowAfterThis: yes]
  ,
    code: '@_bar', options: [allowAfterThis: yes]
  ,
    code: '''
      class foo
        constructor: ->
          super._bar
    '''
    options: [allowAfterSuper: yes]
  ,
    code: '''
      class foo
        _onClick: ->
    '''
  ,
    code: 'o = _onClick: ->'
  ,
    code: "o = { _foo: 'bar' }"
  ,
    code: "o = { foo_: 'bar' }"
  ]
  invalid: [
    code: '_foo = 1'
    errors: [message: "Unexpected dangling '_' in '_foo'.", type: 'Identifier']
  ,
    code: 'foo_ = 1'
    errors: [message: "Unexpected dangling '_' in 'foo_'.", type: 'Identifier']
  ,
    code: '_foo = ->'
    errors: [message: "Unexpected dangling '_' in '_foo'.", type: 'Identifier']
  ,
    code: 'foo_ = ->'
    errors: [message: "Unexpected dangling '_' in 'foo_'.", type: 'Identifier']
  ,
    code: '__proto__ = 1'
    errors: [
      message: "Unexpected dangling '_' in '__proto__'."
      type: 'Identifier'
    ]
  ,
    code: 'foo._bar'
    errors: [
      message: "Unexpected dangling '_' in '_bar'.", type: 'MemberExpression'
    ]
  ,
    code: 'this._prop'
    errors: [
      message: "Unexpected dangling '_' in '_prop'.", type: 'MemberExpression'
    ]
  ,
    code: '@_prop'
    errors: [
      message: "Unexpected dangling '_' in '_prop'.", type: 'MemberExpression'
    ]
  ,
    code: '''
      class foo
        constructor: ->
          super._prop
    '''
    errors: [
      message: "Unexpected dangling '_' in '_prop'.", type: 'MemberExpression'
    ]
  ,
    code: '''
      class foo
        constructor: ->
          this._prop
    '''
    options: [allowAfterSuper: yes]
    errors: [
      message: "Unexpected dangling '_' in '_prop'.", type: 'MemberExpression'
    ]
  ,
    code: '''
      class foo
        _onClick: ->
    '''
    options: [enforceInMethodNames: yes]
    errors: [
      message: "Unexpected dangling '_' in '_onClick'."
      type: 'MethodDefinition'
    ]
  ,
    code: '''
      class foo
        onClick_: ->
    '''
    options: [enforceInMethodNames: yes]
    errors: [
      message: "Unexpected dangling '_' in 'onClick_'."
      type: 'MethodDefinition'
    ]
  ,
    code: 'o = _onClick: ->'
    options: [enforceInMethodNames: yes]
    errors: [
      message: "Unexpected dangling '_' in '_onClick'.", type: 'Property'
    ]
  ,
    code: 'o = { onClick_: -> }'
    options: [enforceInMethodNames: yes]
    errors: [
      message: "Unexpected dangling '_' in 'onClick_'.", type: 'Property'
    ]
  ]
