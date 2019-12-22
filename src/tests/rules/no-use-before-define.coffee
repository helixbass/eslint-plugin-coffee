###*
# @fileoverview Tests for no-use-before-define rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-use-before-define'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-use-before-define', rule,
  valid: [
    '''
      a = 10
      alert a
    '''
    'b = (a) -> alert(a)'
    'Object.hasOwnProperty.call(a)'
    'a = -> alert(arguments)'
    'foo = (a = 1) ->'
  ,
    code: '''
      b = -> a()
      a = -> alert(arguments)
    '''
    options: ['nofunc']
  ,
    '''
      do ->
        a = 42
        alert a
    '''
    '''
      a()
      try
        throw new Error()
      catch a
    '''
    '''
      class A
      new A()
    '''
    '''
      a = 0
      b = a
    '''
    '{a = 0, b = a} = {}'
    '[a = 0, b = a] = {}'
    'foo = -> foo()'
    '''
      a = null
      for a of a
        ;
    '''
    '''
      a = null
      for a from a
        ;
    '''
    '''
      a = null
      for a in a
        ;
    '''
    '''
      b for b in [0...1]
    '''
    '''
      b++ while b
    '''
    '''
      not b unless b
    '''
  ,
    # object style options
    code: '''
      b = -> a()
      a = -> alert(arguments)
    '''
    options: [functions: no]
  ,
    code: '''
      foo = -> new A
      class A
    '''
    options: [classes: no]
  ,
    # "variables" option
    code: '''
      foo = -> bar
      bar = null
    '''
    options: [variables: no]
  ,
    '''
      nums    = (y for n in [1, 2, 3] when n & 1)
    '''
    '''
      odds  = (prop + '!' for prop, value of obj when value & 1)
    '''
    '''
      ob =
        a: for v, i in test then i
        b: for v, i in test then i
    '''
  ]
  invalid: [
    code: '''
      a++
      a = 19
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      a()
      a = ->
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      alert a[1]
      a = [1, 3]
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      a()
      a = ->
        alert b
        b = 10
        a()
    '''
    errors: [
      message: "'a' was used before it was defined.", type: 'Identifier'
    ,
      message: "'b' was used before it was defined.", type: 'Identifier'
    ]
  ,
    code: '''
      a()
      a = ->
    '''
    options: ['nofunc']
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      a()
      a = -> alert(arguments)
    '''
    options: [functions: no]
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      do ->
        alert a
        a = 42
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      do => a()
      a = ->
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      (-> a())()
      a = ->
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      a()
      try
        throw new Error()
      catch foo
        a = null
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      f = -> a
      a = null
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      new A()
      class A
    '''
    errors: [message: "'A' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      foo = -> new A
      class A
    '''
    errors: [message: "'A' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      new A()
      A = class
    '''
    errors: [message: "'A' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      foo = -> new A()
      A = class
    '''
    errors: [message: "'A' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      switch foo
        when 1
          a()
        else
          a = null
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      if true
        foo = -> a
        a = null
    '''
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    # object style options
    code: '''
      a()
      a = ->
    '''
    options: [functions: no, classes: no]
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      new A()
      class A
    '''
    options: [functions: no, classes: no]
    errors: [message: "'A' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      new A()
      A = class
    '''
    options: [classes: no]
    parserOptions: ecmaVersion: 6
    errors: [message: "'A' was used before it was defined.", type: 'Identifier']
  ,
    code: '''
      foo = -> new A()
      A = class
    '''
    options: [classes: no]
    errors: [message: "'A' was used before it was defined.", type: 'Identifier']
  ,
    # invalid initializers
    code: 'a = a'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: 'a = a + b'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: 'a = foo a'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: 'foo = (a = a) ->'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '{a = a} = []'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '[a = a] = []'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '{b = a, a} = {}'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '[b = a, a] = {}'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '{a = 0} = a'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    code: '[a = 0] = a'
    errors: [message: "'a' was used before it was defined.", type: 'Identifier']
  ,
    # "variables" option
    code: '''
      foo = ->
        bar
        bar = 1
      bar
    '''
    options: [variables: no]
    errors: [
      message: "'bar' was used before it was defined.", type: 'Identifier'
    ]
  ,
    code: '''
      foo
      foo = null
    '''
    options: [variables: no]
    errors: [
      message: "'foo' was used before it was defined.", type: 'Identifier'
    ]
  ,
    code: '''
      for x of xs
        ;
      xs = []
    '''
    errors: ["'xs' was used before it was defined."]
  ,
    code: '''
      for x from xs
        ;
      xs = []
    '''
    errors: ["'xs' was used before it was defined."]
  ,
    code: '''
      try
      catch {message = x}
        ;
      x = ''
    '''
    errors: ["'x' was used before it was defined."]
  ]
