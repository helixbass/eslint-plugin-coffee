###*
# @fileoverview Disallows or enforces spaces inside of object literals.
# @author Jamund Ferguson
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/object-curly-spacing'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'object-curly-spacing', rule,
  valid: [
    # always - object literals
    code: 'obj = { foo: bar, baz: qux }', options: ['always']
  ,
    code: 'obj = { foo: { bar: quxx }, baz: qux }', options: ['always']
  ,
    code: '''
      obj = {
        foo: bar
        baz: qux
      }
    '''
    options: ['always']
  ,
    code: 'x: y', options: ['always']
  ,
    code: 'x: y', options: ['never']
  ,
    # always - destructuring
    code: '{ x } = y', options: ['always']
  ,
    code: '{ x, y } = y'
    options: ['always']
  ,
    code: '{ x,y } = y'
    options: ['always']
  ,
    code: '''
      {
        x,y } = y
    '''
    options: ['always']
  ,
    code: '''
      {
        x,y
      } = z
    '''
    options: ['always']
  ,
    code: '{ x = 10, y } = y'
    options: ['always']
  ,
    code: '{ x: { z }, y } = y'
    options: ['always']
  ,
    code: '''
      {
        y,
      } = x
    '''
    options: ['always']
  ,
    code: '{ y, } = x', options: ['always']
  ,
    code: '{ y: x } = x'
    options: ['always']
  ,
    # always - import / export
    code: "import door from 'room'"
    options: ['always']
  ,
    code: "import * as door from 'room'"
    options: ['always']
  ,
    code: "import { door } from 'room'"
    options: ['always']
  ,
    code: """
      import {
        door
      } from 'room'
    """
    options: ['always']
  ,
    code: "export { door } from 'room'"
    options: ['always']
  ,
    code: "import { house, mouse } from 'caravan'"
    options: ['always']
  ,
    code: "import house, { mouse } from 'caravan'"
    options: ['always']
  ,
    code: "import door, { house, mouse } from 'caravan'"
    options: ['always']
  ,
    code: 'export { door }'
    options: ['always']
  ,
    code: "import 'room'"
    options: ['always']
  ,
    code: "import { bar as x } from 'foo'"
    options: ['always']
  ,
    code: "import { x, } from 'foo'"
    options: ['always']
  ,
    code: """
      import {
        x,
      } from 'foo'
    """
    options: ['always']
  ,
    code: "export { x, } from 'foo'"
    options: ['always']
  ,
    code: """
      export {
        x,
      } from 'foo'
    """
    options: ['always']
  ,
    # always - empty object
    code: 'foo = {}', options: ['always']
  ,
    # always - objectsInObjects
    code: "obj = { 'foo': { 'bar': 1, 'baz': 2 }}"
    options: ['always', {objectsInObjects: no}]
  ,
    code: 'a = { noop: -> }'
    options: ['always', {objectsInObjects: no}]
  ,
    code: '{ y: { z }} = x'
    options: ['always', {objectsInObjects: no}]
  ,
    # always - arraysInObjects
    code: "obj = { 'foo': [ 1, 2 ]}"
    options: ['always', {arraysInObjects: no}]
  ,
    code: 'a = { thingInList: list[0] }'
    options: ['always', {arraysInObjects: no}]
  ,
    # always - arraysInObjects, objectsInObjects
    code: "obj = { 'qux': [ 1, 2 ], 'foo': { 'bar': 1, 'baz': 2 }}"
    options: ['always', {arraysInObjects: no, objectsInObjects: no}]
  ,
    # always - arraysInObjects, objectsInObjects (reverse)
    code: "obj = { 'foo': { 'bar': 1, 'baz': 2 }, 'qux': [ 1, 2 ]}"
    options: ['always', {arraysInObjects: no, objectsInObjects: no}]
  ,
    code: '''
      obj = {
      foo: bar
      baz: qux
      }
    '''
    options: ['never']
  ,
    # never - object literals
    code: 'obj = {foo: bar, baz: qux}', options: ['never']
  ,
    code: 'obj = {foo: {bar: quxx}, baz: qux}', options: ['never']
  ,
    code: '''
      obj = {foo: {
        bar: quxx}, baz: qux
      }
    '''
    options: ['never']
  ,
    code: '''
      obj = {foo: {
        bar: quxx
      }, baz: qux}
    '''
    options: ['never']
  ,
    code: '''
      obj = {
        foo: bar,
        baz: qux
      }
    '''
    options: ['never']
  ,
    # never - destructuring
    code: '{x} = y', options: ['never']
  ,
    code: '{x, y} = y', options: ['never']
  ,
    code: '{x,y} = y', options: ['never']
  ,
    code: '''
      {
        x,y
      } = y
    '''
    options: ['never']
  ,
    code: '{x = 10} = y'
    options: ['never']
  ,
    code: '{x = 10, y} = y'
    options: ['never']
  ,
    code: '{x: {z}, y} = y'
    options: ['never']
  ,
    code: '''
      {
        x: {z
        }, y} = y
    '''
    options: ['never']
  ,
    code: '''
      {
        y,
      } = x
    '''
    options: ['never']
  ,
    code: '{y,} = x', options: ['never']
  ,
    code: '{y:x} = x', options: ['never']
  ,
    # never - import / export
    code: "import door from 'room'"
    options: ['never']
  ,
    code: "import * as door from 'room'"
    options: ['never']
  ,
    code: "import {door} from 'room'"
    options: ['never']
  ,
    code: "export {door} from 'room'"
    options: ['never']
  ,
    code: """
      import {
        door
      } from 'room'
    """
    options: ['never']
  ,
    code: """
      export {
        door
      } from 'room'
    """
    options: ['never']
  ,
    code: "import {house,mouse} from 'caravan'"
    options: ['never']
  ,
    code: "import {house, mouse} from 'caravan'"
    options: ['never']
  ,
    code: 'export {door}'
    options: ['never']
  ,
    code: "import 'room'"
    options: ['never']
  ,
    code: "import x, {bar} from 'foo'"
    options: ['never']
  ,
    code: "import x, {bar, baz} from 'foo'"
    options: ['never']
  ,
    code: "import {bar as y} from 'foo'"
    options: ['never']
  ,
    code: "import {x,} from 'foo'"
    options: ['never']
  ,
    code: """
      import {
        x,
      } from 'foo'
    """
    options: ['never']
  ,
    code: "export {x,} from 'foo'"
    options: ['never']
  ,
    code: """
      export {
        x,
      } from 'foo'
    """
    options: ['never']
  ,
    # never - empty object
    code: 'foo = {}', options: ['never']
  ,
    # never - objectsInObjects
    code: "obj = {'foo': {'bar': 1, 'baz': 2} }"
    options: ['never', {objectsInObjects: yes}]
  ,
    ###
    # https://github.com/eslint/eslint/issues/3658
    # Empty cases.
    ###
    code: '{} = foo'
  ,
    code: '[] = foo'
  ,
    code: '{a: {}} = foo'
  ,
    code: '{a: []} = foo'
  ,
    code: "import {} from 'foo'"
  ,
    code: "export {} from 'foo'"
  ,
    code: 'export {}'
  ,
    code: '{} = foo', options: ['never']
  ,
    code: '[] = foo', options: ['never']
  ,
    code: '{a: {}} = foo'
    options: ['never']
  ,
    code: '{a: []} = foo'
    options: ['never']
  ,
    code: "import {} from 'foo'"
    options: ['never']
  ,
    code: "export {} from 'foo'"
    options: ['never']
  ,
    code: 'export {}'
    options: ['never']
  ]

  invalid: [
    code: "import {bar} from 'foo.js'"
    output: "import { bar } from 'foo.js'"
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ImportDeclaration'
      line: 1
      column: 8
    ,
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 12
    ]
  ,
    code: "import { bar as y} from 'foo.js'"
    output: "import { bar as y } from 'foo.js'"
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 18
    ]
  ,
    code: "import {bar as y} from 'foo.js'"
    output: "import { bar as y } from 'foo.js'"
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ImportDeclaration'
      line: 1
      column: 8
    ,
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 17
    ]
  ,
    code: "import { bar} from 'foo.js'"
    output: "import { bar } from 'foo.js'"
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 13
    ]
  ,
    code: "import x, { bar} from 'foo'"
    output: "import x, { bar } from 'foo'"
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 16
    ]
  ,
    code: "import x, { bar, baz} from 'foo'"
    output: "import x, { bar, baz } from 'foo'"
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 21
    ]
  ,
    code: "import x, {bar} from 'foo'"
    output: "import x, { bar } from 'foo'"
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ImportDeclaration'
      line: 1
      column: 11
    ,
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 15
    ]
  ,
    code: "import x, {bar, baz} from 'foo'"
    output: "import x, { bar, baz } from 'foo'"
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ImportDeclaration'
      line: 1
      column: 11
    ,
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 20
    ]
  ,
    code: "import {bar,} from 'foo'"
    output: "import { bar, } from 'foo'"
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ImportDeclaration'
      line: 1
      column: 8
    ,
      message: "A space is required before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 13
    ]
  ,
    code: "import { bar, } from 'foo'"
    output: "import {bar,} from 'foo'"
    options: ['never']
    errors: [
      message: "There should be no space after '{'."
      type: 'ImportDeclaration'
      line: 1
      column: 8
    ,
      message: "There should be no space before '}'."
      type: 'ImportDeclaration'
      line: 1
      column: 15
    ]
  ,
    code: 'export {bar}'
    output: 'export { bar }'
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ExportNamedDeclaration'
      line: 1
      column: 8
    ,
      message: "A space is required before '}'."
      type: 'ExportNamedDeclaration'
      line: 1
      column: 12
    ]
  ,
    # always - arraysInObjects
    code: "obj = { 'foo': [ 1, 2 ] }"
    output: "obj = { 'foo': [ 1, 2 ]}"
    options: ['always', {arraysInObjects: no}]
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
    ]
  ,
    code: "obj = { 'foo': [ 1, 2 ] , 'bar': [ 'baz', 'qux' ] }"
    output: "obj = { 'foo': [ 1, 2 ] , 'bar': [ 'baz', 'qux' ]}"
    options: ['always', {arraysInObjects: no}]
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
    ]
  ,
    # always-objectsInObjects
    code: "obj = { 'foo': { 'bar': 1, 'baz': 2 } }"
    output: "obj = { 'foo': { 'bar': 1, 'baz': 2 }}"
    options: ['always', {objectsInObjects: no}]
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 39
    ]
  ,
    code: "obj = { 'foo': [ 1, 2 ] , 'bar': { 'baz': 1, 'qux': 2 } }"
    output: "obj = { 'foo': [ 1, 2 ] , 'bar': { 'baz': 1, 'qux': 2 }}"
    options: ['always', {objectsInObjects: no}]
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 57
    ]
  ,
    # always-destructuring trailing comma
    code: '{ a,} = x'
    output: '{ a, } = x'
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 5
    ]
  ,
    code: '{a, } = x'
    output: '{a,} = x'
    options: ['never']
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 5
    ]
  ,
    code: '{a:b } = x'
    output: '{a:b} = x'
    options: ['never']
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 6
    ]
  ,
    code: '{ a:b } = x'
    output: '{a:b} = x'
    options: ['never']
    errors: [
      message: "There should be no space after '{'."
      type: 'ObjectPattern'
      line: 1
      column: 1
    ,
      message: "There should be no space before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 7
    ]
  ,
    # never-objectsInObjects
    code: "obj = {'foo': {'bar': 1, 'baz': 2}}"
    output: "obj = {'foo': {'bar': 1, 'baz': 2} }"
    options: ['never', {objectsInObjects: yes}]
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 35
    ]
  ,
    code: "obj = {'foo': [1, 2] , 'bar': {'baz': 1, 'qux': 2}}"
    output: "obj = {'foo': [1, 2] , 'bar': {'baz': 1, 'qux': 2} }"
    options: ['never', {objectsInObjects: yes}]
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 51
    ]
  ,
    # always & never
    code: 'obj = {foo: bar, baz: qux}'
    output: 'obj = { foo: bar, baz: qux }'
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ObjectExpression'
      line: 1
      column: 7
    ,
      message: "A space is required before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 26
    ]
  ,
    code: 'obj = {foo: bar, baz: qux }'
    output: 'obj = { foo: bar, baz: qux }'
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ObjectExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'obj = { foo: bar, baz: qux}'
    output: 'obj = { foo: bar, baz: qux }'
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 27
    ]
  ,
    code: 'obj = { foo: bar, baz: qux }'
    output: 'obj = {foo: bar, baz: qux}'
    options: ['never']
    errors: [
      message: "There should be no space after '{'."
      type: 'ObjectExpression'
      line: 1
      column: 7
    ,
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 28
    ]
  ,
    code: 'obj = {foo: bar, baz: qux }'
    output: 'obj = {foo: bar, baz: qux}'
    options: ['never']
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 27
    ]
  ,
    code: 'obj = { foo: bar, baz: qux}'
    output: 'obj = {foo: bar, baz: qux}'
    options: ['never']
    errors: [
      message: "There should be no space after '{'."
      type: 'ObjectExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'obj = { foo: { bar: quxx}, baz: qux}'
    output: 'obj = {foo: {bar: quxx}, baz: qux}'
    options: ['never']
    errors: [
      message: "There should be no space after '{'."
      type: 'ObjectExpression'
      line: 1
      column: 7
    ,
      message: "There should be no space after '{'."
      type: 'ObjectExpression'
      line: 1
      column: 14
    ]
  ,
    code: 'obj = {foo: {bar: quxx }, baz: qux }'
    output: 'obj = {foo: {bar: quxx}, baz: qux}'
    options: ['never']
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 24
    ,
      message: "There should be no space before '}'."
      type: 'ObjectExpression'
      line: 1
      column: 36
    ]
  ,
    code: 'export thing = {value: 1 }'
    output: 'export thing = { value: 1 }'
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ObjectExpression'
      line: 1
      column: 16
    ]
  ,
    # destructuring
    code: '{x, y} = y'
    output: '{ x, y } = y'
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ObjectPattern'
      line: 1
      column: 1
    ,
      message: "A space is required before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 6
    ]
  ,
    code: '{ x, y} = y'
    output: '{ x, y } = y'
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 7
    ]
  ,
    code: '{ x, y } = y'
    output: '{x, y} = y'
    options: ['never']
    errors: [
      message: "There should be no space after '{'."
      type: 'ObjectPattern'
      line: 1
      column: 1
    ,
      message: "There should be no space before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 8
    ]
  ,
    code: '{x, y } = y'
    output: '{x, y} = y'
    options: ['never']
    errors: [
      message: "There should be no space before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 7
    ]
  ,
    code: '{ x=10} = y'
    output: '{ x=10 } = y'
    options: ['always']
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectPattern'
      line: 1
      column: 7
    ]
  ,
    code: '{x=10 } = y'
    output: '{ x=10 } = y'
    options: ['always']
    errors: [
      message: "A space is required after '{'."
      type: 'ObjectPattern'
      line: 1
      column: 1
    ]
  ,
    # never - arraysInObjects
    code: "obj = {'foo': [1, 2]}"
    output: "obj = {'foo': [1, 2] }"
    options: ['never', {arraysInObjects: yes}]
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectExpression'
    ]
  ,
    code: "obj = {'foo': [1, 2] , 'bar': ['baz', 'qux']}"
    output: "obj = {'foo': [1, 2] , 'bar': ['baz', 'qux'] }"
    options: ['never', {arraysInObjects: yes}]
    errors: [
      message: "A space is required before '}'."
      type: 'ObjectExpression'
    ]
  ]
