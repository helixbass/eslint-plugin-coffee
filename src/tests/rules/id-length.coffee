###*
# @fileoverview Tests for id-length rule.
# @author Burak Yigit Kaya
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/id-length'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'id-length', rule,
  valid: [
    'xyz'
    'xy = 1'
    'xyz = ->'
    'xyz = (abc, de) ->'
    'obj = { abc: 1, de: 2 }'
    "obj = { 'a': 1, bc: 2 }"
    '''
      obj = {}
      obj['a'] = 2
    '''
    'abc = d'
    '''
      try
        blah()
      catch err
        ### pass ###
    '''
    'handler = ($e) ->'
    '_a = 2'
    '_ad$$ = new $'
    'xyz = new ΣΣ()'
    'unrelatedExpressionThatNeedsToBeIgnored()'
    '''
      obj = { 'a': 1, bc: 2 }
      obj.tk = obj.a
    '''
    "query = location.query.q or ''"
    "query = if location.query.q then location.query.q else ''"
  ,
    code: 'x = Foo(42)', options: [min: 1]
  ,
    code: 'x = Foo(42)', options: [min: 0]
  ,
    code: 'foo.$x = Foo(42)', options: [min: 1]
  ,
    code: 'lalala = Foo(42)', options: [max: 6]
  ,
    code: '''
      for q, h in list
        console.log(h)
    '''
    options: [exceptions: ['h', 'q']]
  ,
    code: '(num) => num * num'
  ,
    code: 'foo = (num = 0) ->'
  ,
    code: 'class MyClass'
  ,
    code: '''
      class Foo
        method: ->
    '''
  ,
    code: 'foo = (...args) ->'
  ,
    code: '{ prop } = {}'
  ,
    code: '{ a: prop } = {}'
  ,
    code: '{ x: [prop] } = {}'
  ,
    code: "import something from 'y'"
  ,
    code: 'export num = 0'
  ,
    code: '{ prop: obj.x.y.something } = {}'
  ,
    code: '{ prop: obj.longName } = {}'
  ,
    code: 'obj = { a: 1, bc: 2 }', options: [properties: 'never']
  ,
    code: '''
      obj = {}
      obj.a = 1
      obj.bc = 2
    '''
    options: [properties: 'never']
  ,
    code: '{ a: obj.x.y.z } = {}'
    options: [properties: 'never']
  ,
    code: '{ prop: obj.x } = {}'
    options: [properties: 'never']
  ,
    code: 'obj = { aaaaa: 1 }', options: [max: 4, properties: 'never']
  ,
    code: '''
      obj = {}
      obj.aaaaa = 1
    '''
    options: [max: 4, properties: 'never']
  ,
    code: '{ a: obj.x.y.z } = {}'
    options: [max: 4, properties: 'never']
  ,
    code: '{ prop: obj.xxxxx } = {}'
    options: [max: 4, properties: 'never']
  ]
  invalid: [
    code: 'x = 1'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'x = null'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'obj.e = document.body'
    errors: [
      message: "Identifier name 'e' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'x = ->'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'xyz = (a) ->'
    errors: [
      message: "Identifier name 'a' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'obj = { a: 1, bc: 2 }'
    errors: [
      message: "Identifier name 'a' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '{ prop: a } = {}'
    errors: [
      message: "Identifier name 'a' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '{ prop: [x] } = {}'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '''
      try
        blah()
      catch e
        ### pass ###
    '''
    errors: [
      message: "Identifier name 'e' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'handler = (e) ->'
    errors: [
      message: "Identifier name 'e' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'console.log i for i in [0...10]'
    errors: [
      message: "Identifier name 'i' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '''
      j = 0
      while j > -10
        console.log --j
    '''
    errors: [
      message: "Identifier name 'j' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '_$xt_$ = Foo(42)'
    options: [min: 2, max: 4]
    errors: [
      message: "Identifier name '_$xt_$' is too long (> 4).", type: 'Identifier'
    ]
  ,
    code: '_$x$_t$ = Foo(42)'
    options: [min: 2, max: 4]
    errors: [
      message: "Identifier name '_$x$_t$' is too long (> 4)."
      type: 'Identifier'
    ]
  ,
    code: '(a) => a * a'
    errors: [
      message: "Identifier name 'a' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'foo = (x = 0) ->'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'class x'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '''
      class Foo
        x: ->
    '''
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'foo = (...x) ->'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '{ x} = {}'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '{ x: a} = {}'
    errors: [
      message: "Identifier name 'a' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '{ a: [x]} = {}'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: "import x from 'y'"
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'export x = 0'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '{ a: obj.x.y.z } = {}'
    errors: [
      message: "Identifier name 'z' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: '{ prop: obj.x } = {}'
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ,
    code: 'x = 1'
    options: [properties: 'never']
    errors: [
      message: "Identifier name 'x' is too short (< 2).", type: 'Identifier'
    ]
  ]
