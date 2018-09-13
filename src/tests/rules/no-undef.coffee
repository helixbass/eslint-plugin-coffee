###*
# @fileoverview Tests for no-undef rule.
# @author Mark Macdonald
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-undef'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-undef', rule,
  valid: [
    '''
      a = 1
      b = 2
      a
    '''
    '###global b### f = -> b'
  ,
    code: '-> b', globals: b: no
  ,
    '''
      ###global b a:false###
      a
      ->
        b
        a
    '''
    '''
      a = ->
      a()
    '''
    '(b) -> b'
    '''
      a = null
      a = 1
      a++
    '''
    '''
      a = null
      -> a = 1
    '''
    '###global b:true### b++'
  ,
    # '###eslint-env browser### window'
    code: 'window'
    env: browser: yes
  ,
    # '###eslint-env node### require("a")'
    code: 'require("a")'
    env: node: yes
  ,
    '''
      Object
      isNaN()
    '''
    'toString()'
    'hasOwnProperty()'
    '''
      (stuffToEval) ->
        ultimateAnswer = null
        ultimateAnswer = 42
        eval stuffToEval
    '''
    'typeof a'
    'typeof (a)'
    'b = typeof a'
    "typeof a is 'undefined'"
    "if typeof a is 'undefined' then ;"
  ,
    code: '''
      ->
        [a, b=4] = [1, 2]
        return {a, b}
    '''
  ,
    code: 'toString = 1'
  ,
    code: '(...foo) -> return foo'
  ,
    code: '''
      React = null
      App = null
      a = 1
      React.render(<App attr={a} />)
    '''
  ,
    code: '''
      console = null
      [1,2,3].forEach (obj) => console.log(obj)
    '''
  ,
    code: '''
      Foo = null
      class Bar extends Foo
        constructor: ->
          super()
    '''
  ,
    code: """
      import Warning from '../lib/warning'
      warn = new Warning 'text'
    """
  ,
    code: """
      import * as Warning from '../lib/warning'
      warn = new Warning('text')
    """
  ,
    code: '''
      a = null
      [a] = [0]
    '''
  ,
    code: '''
      a = null
      ({a} = {})
    '''
  ,
    code: '{b: a} = {}'
  ,
    code: '''
      obj = null
      [obj.a, obj.b] = [0, 1]
    '''
  ,
    code: 'URLSearchParams', env: browser: yes
  ,
    code: 'Intl', env: browser: yes
  ,
    code: 'IntersectionObserver', env: browser: yes
  ,
    code: 'Credential', env: browser: yes
  ,
    code: 'requestIdleCallback', env: browser: yes
  ,
    code: 'customElements', env: browser: yes
  ,
    code: 'PromiseRejectionEvent', env: browser: yes
  ,
    # Notifications of readonly are removed: https://github.com/eslint/eslint/issues/4504
    '###global b:false### -> b = 1'
  ,
    code: 'f = -> b = 1', globals: b: no
  ,
    '###global b:false### -> b++'
    '###global b### b = 1'
    '###global b:false### b = 1'
    'Array = 1'
  ,
    # # new.target: https://github.com/eslint/eslint/issues/5420
    # code: '''
    #   class A
    #     constructor: -> new.target
    # '''
    # Experimental,
    code: '''
      {bacon, ...others} = stuff
      foo(others)
    '''
    globals: stuff: no, foo: no
  ,
    code: '[a] = [0]'
  ,
    code: '{a} = {}'
  ,
    code: '{b: a} = {}'
  ,
    'a = 1'
  ]
  invalid: [
    code: "if (typeof anUndefinedVar is 'string') then ;"
    options: [typeof: yes]
    errors: [message: "'anUndefinedVar' is not defined.", type: 'Identifier']
  ,
    code: 'a = b'
    errors: [message: "'b' is not defined.", type: 'Identifier']
  ,
    code: '-> b'
    errors: [message: "'b' is not defined.", type: 'Identifier']
  ,
    code: 'window'
    errors: [message: "'window' is not defined.", type: 'Identifier']
  ,
    code: 'require "a"'
    errors: [message: "'require' is not defined.", type: 'Identifier']
  ,
    code: '''
      React = null
      React.render <img attr={a} />
    '''
    errors: [message: "'a' is not defined."]
  ,
    code: '''
      React = null
      App = null
      React.render(<App attr={a} />)
    '''
    errors: [message: "'a' is not defined."]
  ,
    code: '[obj.a, obj.b] = [0, 1]'
    errors: [
      message: "'obj' is not defined."
    ,
      message: "'obj' is not defined."
    ]
  ,
    # Experimental
    code: '''
      c = 0
      a = {...b, c}
    '''
    errors: [message: "'b' is not defined."]
  ]
