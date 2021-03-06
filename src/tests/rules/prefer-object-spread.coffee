###*
# @fileoverview Prefers object spread property over Object.assign
# @author Sharmila Jesupaul
# See LICENSE file in root directory for full license.
###

'use strict'

rule = require '../../rules/prefer-object-spread'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'prefer-object-spread', rule,
  valid: [
    'Object.assign()'
    'a = Object.assign(a, b)'
    'Object.assign(a, b)'
    'a = Object.assign(b, { c: 1 })'
    'bar = { ...foo }'
    'Object.assign(...foo)'
    'Object.assign(foo, { bar: baz })'
    'Object.assign({}, ...objects)'
    "foo({ foo: 'bar' })"
    '''
      Object = {}
      Object.assign({}, foo)
    '''
    '''
      Object = {}
      Object.assign({}, foo)
    '''
    '''
      Object = {}
      Object.assign foo: 'bar'
    '''
    '''
      Object = {}
      Object.assign { foo: 'bar' }
    '''
    '''
      Object = require 'foo'
      Object.assign({ foo: 'bar' })
    '''
    '''
      import Object from 'foo'
      Object.assign({ foo: 'bar' })
    '''
    '''
      import { Something as Object } from 'foo'
      Object.assign({ foo: 'bar' })
    '''
    '''
      import { Object, Array } from 'globals'
      Object.assign({ foo: 'bar' })
    '''
  ]

  invalid: [
    code: 'Object.assign({}, foo)'
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: 'Object.assign {}, foo'
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: "Object.assign {}, foo: 'bar'"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: "Object.assign({}, baz, { foo: 'bar' })"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: "Object.assign({}, { foo: 'bar', baz: 'foo' })"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: "Object.assign({ foo: 'bar' }, baz)"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    # Many args
    code: "Object.assign({ foo: 'bar' }, cats, dogs, trees, birds)"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code:
      "Object.assign({ foo: 'bar' }, Object.assign { bar: 'foo' }, baz)"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ,
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 31
    ]
  ,
    code:
      "Object.assign({ foo: 'bar' }, Object.assign({ bar: 'foo' }, Object.assign({}, { superNested: 'butwhy' })))"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ,
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 31
    ,
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 61
    ]
  ,
    # Mix spread in argument
    code: "Object.assign({foo: 'bar', ...bar}, baz)"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    # Object shorthand
    code: 'Object.assign({}, { foo, bar, baz })'
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    # Objects with computed properties
    code: "Object.assign({}, { [bar]: 'foo' })"
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    # Objects with spread properties
    code: 'Object.assign({ ...bar }, { ...baz })'
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    # Multiline objects
    code: '''
      Object.assign({ ...bar }, {
        # this is a bar
        foo: 'bar'
        baz: "cats"
      })
    '''
    errors: [
      messageId: 'useSpreadMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    ###
    # This is a special case where Object.assign is called with a single argument
    # and that argument is an object expression. In this case we warn and display
    # a message to use an object literal instead.
    ###
    code: 'Object.assign({})'
    errors: [
      messageId: 'useLiteralMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: 'Object.assign({ foo: bar })'
    errors: [
      messageId: 'useLiteralMessage'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: '''
      foo = 'bar'
      Object.assign({ foo: bar })
    '''
    errors: [
      messageId: 'useLiteralMessage'
      type: 'CallExpression'
      line: 2
      column: 1
    ]
  ,
    code: '''
      foo = 'bar'
      Object.assign({ foo: bar })
    '''
    errors: [
      messageId: 'useLiteralMessage'
      type: 'CallExpression'
      line: 2
      column: 1
    ]
  ]
