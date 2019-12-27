###*
# @fileoverview Tests for concise-object rule
# @author Jamund Ferguson <http://www.jamund.com>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/object-shorthand'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

PROPERTY_ERROR = message: 'Expected property shorthand.', type: 'Property'
LONGFORM_PROPERTY_ERROR =
  message: 'Expected longform property syntax.', type: 'Property'
ALL_SHORTHAND_ERROR =
  message: 'Expected shorthand for all properties.', type: 'ObjectExpression'
MIXED_SHORTHAND_ERROR =
  message: 'Unexpected mix of shorthand and non-shorthand properties.'
  type: 'ObjectExpression'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'object-shorthand', rule,
  valid: [
    'x = y: ->'
    'x = {y}'
    'x = {a: b}'
    "x = {a: 'a'}"
    "x = {'a': 'a'}"
    "x = {'a': b}"
    'x = {y: (x) ->}'
    '{x,y,z} = x'
    '{x: {y}} = z'
    'x = {x: y}'
    'x = {x: y, y: z}'
    "x = {x: y, y: z, z: 'z'}"
    'x = {x: ->, y: z, l: ->}'
    'x = {x: y, y: z, a: b}'
    "x = {x: y, y: z, 'a': b}"
    'x = {x: y, y: ->, z: a}'
    'x = {[y]: y}'
    'doSomething({x: y})'
    "doSomething({'x': y})"
    "doSomething({x: 'x'})"
    "doSomething({'x': 'x'})"
    'doSomething({y: ->})'
    'doSomething({x: y, y: ->})'
    'doSomething({y: ->, z: a})'
    '!{ a: -> }'

    # # getters and setters are ok
    # 'var x = {get y() {}}'
    # 'var x = {set y(z) {}}'
    # 'var x = {get y() {}, set y(z) {}}'
    # 'doSomething({get y() {}})'
    # 'doSomething({set y(z) {}})'
    # 'doSomething({get y() {}, set y(z) {}})'

    # object literal computed properties
    'x = {[y]: y}'
    "x = {['y']: 'y'}"
    "x = {['y']: y}"

    'x = {y}'
    'x = {y: {b}}'
  ,
    code: 'x = {a: n, c: d, f: g}'
    options: ['never']
  ,
    code: 'x = {a: ->, b: {c: d}}'
    options: ['never']
  ,
    # avoidQuotes
    code: "x = 'a': ->"
    options: ['always', {avoidQuotes: yes}]
  ,
    code: "x = ['a']: ->"
    options: ['always', {avoidQuotes: yes}]
  ,
    code: "'y': y"
    options: ['always', {avoidQuotes: yes}]
  ,
    # ignore object shorthand
    code: '{a, b} = o'
    options: ['never']
  ,
    code: 'x = {foo: foo, bar: bar, ...baz}'
    options: ['never']
  ,
    # consistent
    code: 'x = {a: a, b: b}'
    options: ['consistent']
  ,
    code: 'x = {a: b, c: d, f: g}'
    options: ['consistent']
  ,
    code: 'x = {a, b}'
    options: ['consistent']
  ,
    # ,
    #   code: 'x = {a, b, get test() { return 1; }}'
    #   options: ['consistent']
    code: 'x = {...bar}'
    options: ['consistent-as-needed']
  ,
    code: 'x = {foo, bar, ...baz}'
    options: ['consistent']
  ,
    code: 'x = {bar: baz, ...qux}'
    options: ['consistent']
  ,
    code: 'x = {...foo, bar: bar, baz: baz}'
    options: ['consistent']
  ,
    # consistent-as-needed
    code: 'x = {a, b}'
    options: ['consistent-as-needed']
  ,
    # ,
    #   code: 'x = {a, b, get test(){return 1;}}'
    #   options: ['consistent-as-needed']
    code: "x = {0: 'foo'}"
    options: ['consistent-as-needed']
  ,
    code: "x = {'key': 'baz'}"
    options: ['consistent-as-needed']
  ,
    code: "x = {foo: 'foo'}"
    options: ['consistent-as-needed']
  ,
    code: 'x = {[foo]: foo}'
    options: ['consistent-as-needed']
  ,
    code: 'x = {foo: ->}'
    options: ['consistent-as-needed']
  ,
    code: "x = {[foo]: 'foo'}"
    options: ['consistent-as-needed']
  ,
    code: 'x = {bar, ...baz}'
    options: ['consistent-as-needed']
  ,
    code: 'x = {bar: baz, ...qux}'
    options: ['consistent-as-needed']
  ,
    code: 'x = {...foo, bar, baz}'
    options: ['consistent-as-needed']
  ]
  invalid: [
    code: 'x = {x: x}'
    errors: [PROPERTY_ERROR]
  ,
    code: "x = {'x': x}"
    errors: [PROPERTY_ERROR]
  ,
    code: 'x = {y: y, x: x}'
    errors: [PROPERTY_ERROR, PROPERTY_ERROR]
  ,
    code: 'x = {y: z, x: x, a: b}'
    errors: [PROPERTY_ERROR]
  ,
    code: '''
      x = {
        y: z
        x: x
        a: b
        # comment
      }
    '''
    errors: [PROPERTY_ERROR]
  ,
    code: '''
      x = {
        a: b
        ### comment ###
        y: y
      }
    '''
    errors: [PROPERTY_ERROR]
  ,
    code: 'x = {x: y, y: z, a: a}'
    errors: [PROPERTY_ERROR]
  ,
    code: 'doSomething({x: x})'
    errors: [PROPERTY_ERROR]
  ,
    code: "doSomething({'x': x})"
    errors: [PROPERTY_ERROR]
  ,
    code: "doSomething({a: 'a', 'x': x})"
    errors: [PROPERTY_ERROR]
  ,
    code: 'x = {y}'
    options: ['never']
    errors: [LONGFORM_PROPERTY_ERROR]
  ,
    code: 'x = {y: {x}}'
    options: ['never']
    errors: [LONGFORM_PROPERTY_ERROR]
  ,
    code: 'x = {foo: foo, bar: baz, ...qux}'
    options: ['always']
    errors: [PROPERTY_ERROR]
  ,
    code: 'x = {foo, bar: baz, ...qux}'
    options: ['never']
    errors: [LONGFORM_PROPERTY_ERROR]
  ,
    # avoidQuotes
    code: 'x = {a: a}'
    options: ['always', {avoidQuotes: yes}]
    errors: [PROPERTY_ERROR]
  ,
    # consistent
    code: 'x = {a: a, b}'
    options: ['consistent']
    errors: [MIXED_SHORTHAND_ERROR]
  ,
    code: 'x = {b, c: d, f: g}'
    options: ['consistent']
    errors: [MIXED_SHORTHAND_ERROR]
  ,
    code: 'x = {foo, bar: baz, ...qux}'
    options: ['consistent']
    errors: [MIXED_SHORTHAND_ERROR]
  ,
    # consistent-as-needed
    code: 'x = {a: a, b: b}'
    options: ['consistent-as-needed']
    errors: [ALL_SHORTHAND_ERROR]
  ,
    code: 'x = {a: a, b: b, ...baz}'
    options: ['consistent-as-needed']
    errors: [ALL_SHORTHAND_ERROR]
  ,
    code: 'x = {foo, bar: bar, ...qux}'
    options: ['consistent-as-needed']
    errors: [MIXED_SHORTHAND_ERROR]
  ,
    code: 'x = {a, z: ->}'
    options: ['consistent-as-needed']
    errors: [MIXED_SHORTHAND_ERROR]
  ]
