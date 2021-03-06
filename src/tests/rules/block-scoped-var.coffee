###*
# @fileoverview Tests for block-scoped-var rule
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/block-scoped-var'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'block-scoped-var', rule,
  valid: [
    # See issue https://github.com/eslint/eslint/issues/2242
    code: '''
      f = ->
      f()
      exports = { f: f }
    '''
  ,
    '!(f = -> f)'
    '''
      f = ->
        a = true
        b = a
    '''
    '''
      a = null
      f = ->
        b = a
    '''
    'f = (a) ->'
    '!((a) ->)'
    '!(f = (a) ->)'
    'f = (a) -> b = a'
    '!(f = (a) -> b = a)'
    'f = -> g = f'
    '''
      f = ->
      g = ->
        f = g
    '''
    '''
      f = ->
        g()
        g = ->
    '''
    '''
      if yes
        a = 1
        a
    '''
    '''
      a = null
      if yes
        a
    '''
    '''
      for i in [0...10]
        i
    '''
    '''
      i for i in [0...10]
    '''
    '''
      i = null 
      for [0...10]
        i
    '''
  ,
    code: '''
      myFunc = (foo) ->
        "use strict"
        { bar } = foo
        bar.hello()
    '''
  ,
    code: '''
      myFunc = (foo) ->
        "use strict"
        [ bar ] = foo
        bar.hello()
    '''
  ,
    code: 'myFunc = (...foo) -> return foo'
  ,
    code: '''
      class Foo
      export default Foo
    '''
  ,
    code: 'new Date', globals: Date: no
  ,
    code: 'new Date', globals: {}
  ,
    code: "eslint = require('eslint')", globals: require: no
  ,
    code: 'fun = ({x}) -> return x'
  ,
    code: 'fun = ([,x]) -> x'
  ,
    'f = (a) -> return a.b'
    'a = { "foo": 3 }'
    'a = { foo: 3 }'
    'a = { foo: 3, bar: 5 }'
    # 'a = { set foo(a){}, get bar(){} };'
    'f = (a) -> arguments[0]'
    '''
      f = ->
      a = f
    '''
    '''
      f = ->
        for a in {}
          a
    '''
    '''
      f = ->
        a for a in {}
    '''
    '''
      f = ->
        switch 2
          when 1
            b = 2
            b
          else
            b
    '''
  ,
    code: '''
      React = require("react/addons")
      cx = React.addons.classSet
    '''
    globals: require: no
  ,
    '''
      v = 1
      x = -> return v
    '''
    '''
      import * as y from "./other.js"
      y()
    '''
    '''
      import y from "./other.js"
      y()
    '''
    '''
      import {x as y} from "./other.js"
      y()
    '''
    '''
      x = null
      export {x}
    '''
    '''
      x = null
      export {x as v}
    '''
    'export {x} from "./other.js"'
    'export {x as v} from "./other.js"'
    '''
      class Test
        myFunction: ->
          return true
    '''
    # 'class Test { get flag() { return true; }}'
    '''
      Test = class
        myFunction: ->
          return true
    '''
  ,
    code: '''
      doStuff = null
      {x: y} = {x: 1}
      doStuff(y)
    '''
  ,
    'foo = ({x: y}) -> y'
    # those are the same as `no-undef`.
    '''
      !(f = ->)
      f
    '''
    '''
      f = foo = ->
      foo()
      exports = { f: foo }
    '''
    'f = => x'
    "eslint = require('eslint')"
    'f = (a) -> a[b]'
    'f = -> b.a'
    'a = { foo: bar }'
    'a = foo: foo'
    'a = { bar: 7, foo: bar }'
    'a = arguments'
    '''
      x = ->
      a = arguments
    '''
    '''
      z = (b) ->
      a = b
    '''
    '''
      z = ->
        b = null
      a = b
    '''
    '''
      f = ->
        try
        catch e
        e
    '''
  ,
    # https://github.com/eslint/eslint/issues/2253
    code: '''
      ###global React###
      {PropTypes, addons: {PureRenderMixin}} = React
      Test = React.createClass({mixins: [PureRenderMixin]})
    '''
  ,
    code: '''
      ###global prevState###
      { virtualSize: prevVirtualSize = 0 } = prevState
    '''
  ,
    code: '''
      { dummy: { data, isLoading }, auth: { isLoggedIn } } = @props
    '''
  ,
    # https://github.com/eslint/eslint/issues/2747
    '''
      a = (n) ->
        if n > 0 then b(n - 1) else "a"
      b = (n) ->
        if n > 0 then a(n - 1) else "b"
    '''

    # https://github.com/eslint/eslint/issues/2967
    '''
      (-> foo())()
      foo = ->
    '''
    '''
      do -> foo()
      foo = ->
    '''
    '''
      for i in []
        ;
    '''
    '''
      for i, j in []
        i + j
    '''
    '''
      i for i in []
    '''
  ]
  invalid: [
    code: '''
      f = ->
        try
          a = 0
        catch e
          b = a
    '''
    errors: [messageId: 'outOfScope', data: {name: 'a'}, type: 'Identifier']
  ,
    code: '''
      a = ->
        for b of {}
          c = b
        c
    '''
    errors: [messageId: 'outOfScope', data: {name: 'c'}, type: 'Identifier']
  ,
    code: '''
      a = ->
        for b from {}
          c = b
        c
    '''
    errors: [messageId: 'outOfScope', data: {name: 'c'}, type: 'Identifier']
  ,
    code: '''
      a = ->
        c = b for b in []
        c
    '''
    errors: [messageId: 'outOfScope', data: {name: 'c'}, type: 'Identifier']
  ,
    code: '''
      f = ->
        switch 2
          when 1
            b = 2
            b
          else
            b
        b
    '''
    errors: [messageId: 'outOfScope', data: {name: 'b'}, type: 'Identifier']
  ,
    code: '''
      for a in []
        ;
      a
    '''
    errors: [messageId: 'outOfScope', data: {name: 'a'}, type: 'Identifier']
  ,
    code: '''
      for a of {}
        ;
      a
    '''
    errors: [messageId: 'outOfScope', data: {name: 'a'}, type: 'Identifier']
  ,
    code: '''
      for a from []
        ;
      a
    '''
    errors: [messageId: 'outOfScope', data: {name: 'a'}, type: 'Identifier']
  ,
    code: '''
      if yes
        a = null
      a
    '''
    errors: [messageId: 'outOfScope', data: {name: 'a'}, type: 'Identifier']
  ,
    code: '''
      if yes
        a = 1
      else
        a = 2
    '''
    errors: [
      messageId: 'outOfScope', data: {name: 'a'}, type: 'Identifier'
      # ,
      #   messageId: 'outOfScope', data: {name: 'a'}, type: 'Identifier'
    ]
  ,
    code: '''
      for i in []
        ;
      for i in []
        ;
    '''
    errors: [
      messageId: 'outOfScope', data: {name: 'i'}, type: 'Identifier'
    ,
      messageId: 'outOfScope', data: {name: 'i'}, type: 'Identifier'
    ]
  ]
