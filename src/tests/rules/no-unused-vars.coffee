###*
# @fileoverview Tests for no-unused-vars rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-unused-vars'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.defineRule 'use-every-a', (context) ->
  ###*
  # Mark a variable as used
  # @returns {void}
  # @private
  ###
  useA = -> context.markVariableAsUsed 'a'
  AssignmentExpression: useA
  FunctionExpression: useA
  ReturnStatement: useA

###*
# Returns an expected error for defined-but-not-used variables.
# @param {string} varName The name of the variable
# @param {string} [type] The node type (defaults to "Identifier")
# @returns {Object} An expected error object
###
definedError = (varName, type) ->
  message: "'#{varName}' is defined but never used.", type: type or 'Identifier'

###*
# Returns an expected error for assigned-but-not-used variables.
# @param {string} varName The name of the variable
# @param {string} [type] The node type (defaults to "Identifier")
# @returns {Object} An expected error object
###
assignedError = (varName, type) ->
  message: "'#{varName}' is assigned a value but never used."
  type: type or 'Identifier'

ruleTester.run 'no-unused-vars', rule,
  valid: [
    '''
      foo = 5
      loop
        console.log foo
        break
    '''
    '''
      for prop of box
        box[prop] = parseInt box[prop]
    '''
    '''
      box = {a: 2}
      for prop of box
        box[prop] = parseInt(box[prop])
    '''
  ,
    code: '''
      a = 10
      alert a
    '''
    options: ['all']
  ,
    code: '''
      a = 10
      (-> alert(a))()
    '''
    options: ['all']
  ,
    code: '''
      a = 10
      do -> alert a
    '''
    options: ['all']
  ,
    code: '''
      a = 10
      do ->
        setTimeout(
          -> alert a
          0
        )
    '''
    options: ['all']
  ,
    code: '''
      a = 10
      d[a] = 0
    '''
    options: ['all']
  ,
    code: '''
      do ->
        a = 10
        return a
    '''
    options: ['all']
  ,
    code: '''
      do ->
        a = 10
        a
    '''
    options: ['all']
  ,
    code: '''
      f = (a) -> alert(a)
      f()
    '''
    options: ['all']
  ,
    code: '''
      c = 0
      f = (a) ->
        b = a
        b
      f c
    '''
    options: ['all']
  ,
    code: '''
      a = (x, y) -> y
      a()
    '''
    options: ['all']
  ,
    code: '''
      arr1 = [1, 2]
      arr2 = [3, 4]
      for i in arr1
        arr1[i] = 5
      for i in arr2
        arr2[i] = 10
    '''
    options: ['all']
  ,
    # ,
    #   code: 'a = 10', options: ['local']
    code: '''
      min = "min"
      Math[min]
    '''
    options: ['all']
  ,
    code: '''
      Foo.bar = (baz) -> baz
    '''
    options: ['all']
  ,
    'myFunc (->).bind @'
    'myFunc (->).toString()'
    '''
      foo = (first, second) ->
        doStuff ->
          console.log second
      foo()
    '''
    '''
      do ->
        doSomething = ->
        doSomething()
    '''
    '''
      try
      catch e
    '''
    '###global a ### a'
  ,
    code: '''
      a = 10
      do -> alert a
    '''
    options: [vars: 'all']
  ,
    code: '''
      g = (bar, baz) -> baz
      g()
    '''
    options: [vars: 'all']
  ,
    code: '''
      g = (bar, baz) -> baz
      g()
    '''
    options: [vars: 'all', args: 'after-used']
  ,
    code: '''
      g = (bar, baz) -> bar
      g()
    '''
    options: [vars: 'all', args: 'none']
  ,
    code: '''
      g = (bar, baz) -> 2
      g()
    '''
    options: [vars: 'all', args: 'none']
  ,
    code: '''
      g = (bar, baz) -> bar + baz
      g()
    '''
    options: [vars: 'local', args: 'all']
  ,
    code: '''
      g = (bar, baz) -> 2
      g()
    '''
    options: [vars: 'all', args: 'none']
  ,
    'do (z = -> z())'
  ,
    code: ' ', globals: a: yes
  ,
    '''
      who = "Paul"
      module.exports = "Hello #{who}!"
    '''
    'export foo = 123'
    'export foo = ->'
    '''
      toUpper = (partial) => partial.toUpperCase
      export {toUpper}
    '''
    '''
      export class foo
    '''
    '''
      class Foo
      x = new Foo()
      x.foo()
    '''
    '''
      foo = "hello!"
      bar = (foobar = foo) ->
        foobar.replace /!$/, " world!"
      bar();
    '''
    '''
      Foo = ->
      x = new Foo
      x.foo()
    '''
    '''
      foo = ->
        foo = 1
        foo
      do foo
    '''
    '''
      foo = (foo) -> foo
      foo 1
    '''
    '''
      foo = ->
        foo = -> 1
        foo()
      foo()
    '''
    '''
      foo = ->
        foo = 1
        foo
      foo()
    '''
    '''
      foo = (foo) -> foo
      foo(1)
    '''
    '''
      x = 1
      [y = x] = []
      foo y
    '''
    '''
      x = 1
      {y = x} = {}
      foo(y)
    '''
    '''
      x = 1
      {z: [y = x]} = {}
      foo(y)
    '''
    '''
      x = []
      {z: [y] = x} = {}
      foo(y)
    '''
    '''
      x = 1
      y = null
      [y = x] = []
      foo y
    '''
    '''
      x = 1
      y = null
      {z: [y = x]} = {}
      foo y
    '''
    '''
      x = []
      y = null
      {z: [y] = x} = {}
      foo y
    '''
    '''
      x = 1
      foo = (y = x) -> bar y
      foo()
    '''
    '''
      x = 1
      foo = ({y = x} = {}) -> bar(y)
      foo()
    '''
    '''
      x = 1
      foo = (y = (z = x) -> bar(z)) -> y()
      foo()
    '''
    '''
      x = 1
      foo = (y = -> bar x) -> y()
      foo()
    '''
    '''
      x = 1
      [y = x] = []
      foo y
    '''
    '''
      x = 1
      {y = x} = {}
      foo(y)
    '''
    '''
      x = 1
      {z: [y = x]} = {}
      foo(y)
    '''
    '''
      x = []
      {z: [y] = x} = {}
      foo(y)
    '''
    '''
      x = 1
      y = null
      [y = x] = []
      foo(y)
    '''
    '''
      x = 1
      y = null
      {z: [y = x]} = {}
      foo(y)
    '''
    '''
      x = []
      y = null
      {z: [y] = x} = {}
      foo(y)
    '''
    '''
      x = 1
      foo = (y = x) -> bar(y)
      foo()
    '''
    '''
      x = 1
      foo = ({y = x} = {}) -> bar(y)
      foo()
    '''
    '''
      x = 1
      foo = (y = (z = x) -> bar(z)) -> y()
      foo()
    '''
    '''
      x = 1
      foo = (y = -> bar(x)) -> y()
      foo()
    '''
    # exported variables should work
    # TODO: guessing these don't work because of "environment" (sourceType: 'module'?)
    # "###exported toaster### toaster = 'great'"
    # '''
    #   ###exported toaster, poster###
    #   toaster = 1
    #   poster = 0
    # '''
    # '###exported x### { x } = y'
    # '###exported x, y###  { x, y } = z'
    # Can mark variables as used via context.markVariableAsUsed()
    '###eslint use-every-a:1### a'
    '###eslint use-every-a:1### !(a) -> 1'
    '''
      ###eslint use-every-a:1###
      !->
        a = null
        1
    '''
  ,
    # ignore pattern
    code: '_a = null', options: [vars: 'all', varsIgnorePattern: '^_']
  ,
    # ,
    #   code: '''
    #     a = null
    #     foo = -> _b = null
    #     foo()
    #   '''
    #   options: [vars: 'local', varsIgnorePattern: '^_']
    code: '''
      foo = (_a) ->
      foo()
    '''
    options: [args: 'all', argsIgnorePattern: '^_']
  ,
    code: '''
      foo = (a, _b) -> a
      foo()
    '''
    options: [args: 'after-used', argsIgnorePattern: '^_']
  ,
    code: '''
      [ firstItemIgnored, secondItem ] = items
      console.log secondItem
    '''
    options: [vars: 'all', varsIgnorePattern: '[iI]gnored']
  ,
    # for-in loops (see #2342)
    '''
      do (obj = {}) ->
        name = null
        for name of obj
          return
    '''
    '''
      do (obj = {}) ->
        name = null
        return yes for name of obj
    '''
  ,
    # caughtErrors
    code: '''
      try
      catch err
        console.error err
    '''
    options: [caughtErrors: 'all']
  ,
    code: '''
      try
      catch err
    '''
    options: [caughtErrors: 'none']
  ,
    code: '''
      try
      catch ignoreErr
    '''
    options: [caughtErrors: 'all', caughtErrorsIgnorePattern: '^ignore']
  ,
    # caughtErrors with other combinations
    code: '''
      try
      catch err
    '''
    options: [vars: 'all', args: 'all']
  ,
    # Using object rest for variable omission
    code: """
      data = type: 'coords', x: 1, y: 2
      { type, ...coords } = data
      console.log coords
    """
    options: [ignoreRestSiblings: yes]
  ,
    # https://github.com/eslint/eslint/issues/6348
    '''
      a = 0
      b = a = a + 1
      foo(b)
    '''
    '''
      a = 0
      b = null
      b = a += a + 1
      foo b
    '''
    '''
      a = 0
      b = a++
      foo(b)
    '''
    '''
      foo = (a) ->
        b = a = a + 1
        bar(b)
      foo()
    '''
    '''
      foo = (a) ->
        b = a += a + 1
        bar(b)
      foo()
    '''
    '''
      foo = (a) ->
        b = a++
        bar(b)
      foo()
    '''

    # https://github.com/eslint/eslint/issues/6576
    '''
      unregisterFooWatcher
      # ...
      unregisterFooWatcher = $scope.$watch "foo", ->
        # ...some code..
        unregisterFooWatcher()
    '''
    '''
      ref = setInterval(
        -> clearInterval ref
        10
      )
    '''
    '''
      _timer = null
      f = ->
        _timer = setTimeout(
          ->
          if _timer then 100 else 0
        )
      f()
    '''
    '''
      foo = (cb) ->
        cb = do ->
          something = (a) -> cb(1 + a)
          register(something)
      foo
    '''
    '''
      foo = (cb) ->
        cb = yield (a) -> cb(1 + a)
      foo
    '''
    '''
      foo = (cb) ->
        cb = tag"hello#{(a) -> cb(1 + a)}"
      foo()
    '''
    '''
      foo = (cb) ->
        cb = b = (a) -> cb(1 + a)
        b()
      foo()
    '''

    # https://github.com/eslint/eslint/issues/6646
    '''
      someFunction = ->
        a = 0
        for [0...2]
          a = myFunction(a)
      someFunction()
    '''

    '''
      a = null
      foo = ->
        a ?= 10
      foo()
    '''
  ,
    # https://github.com/eslint/eslint/issues/7124
    code: '(a, b, {c, d}) -> d'
    options: [argsIgnorePattern: 'c']
  ,
    code: '(a, b, {c, d}) -> c'
    options: [argsIgnorePattern: 'd']
  ,
    # https://github.com/eslint/eslint/issues/7250
    code: '(a, b, c) -> c'
    options: [argsIgnorePattern: 'c']
  ,
    code: '(a, b, {c, d}) -> c'
    options: [argsIgnorePattern: '[cd]']
  ,
    # https://github.com/eslint/eslint/issues/8119
    code: '({a, ...rest}) => rest'
    options: [args: 'all', ignoreRestSiblings: yes]
  ,
    '''
      foo = ->
      x = 1
      do (x) ->
        foo x
    '''
    '''
      foo = ->
      x = 1
      do (y = x) ->
        foo y
    '''
    '''
      foo = ->
      x = 1
      do ([x]) ->
        foo x
    '''
  ]
  invalid: [
    code: 'foox = -> foox()', errors: [assignedError 'foox']
  ,
    code: '''
      do ->
        foox = ->
          return foox() if yes
    '''
    errors: [assignedError 'foox']
  ,
    code: 'a = 10', errors: [assignedError 'a']
  ,
    code: '''
      f = ->
        a = 1
        -> f(a *= 2)
    '''
    errors: [assignedError 'f']
  ,
    code: '''
      f = ->
        a = 1
        return -> f ++a
    '''
    errors: [assignedError 'f']
  ,
    code: '###global a ###', errors: [definedError 'a', 'Program']
  ,
    code: '''
      foo = (first, second) ->
        doStuff ->
          console.log second
    '''
    errors: [assignedError 'foo']
  ,
    code: 'a = 10', options: ['all'], errors: [assignedError 'a']
  ,
    code: '''
      a = 10
      a = 20
    '''
    options: ['all']
    errors: [assignedError 'a']
  ,
    code: '''
      a = 10
      b = 0
      c = null
      alert a + b
    '''
    options: ['all']
    errors: [assignedError 'c']
  ,
    code: '''
      f = ->
        a = []
        a.map ->
    '''
    options: ['all']
    errors: [assignedError 'f']
  ,
    code: '''
      f = ->
        x = null
        a = -> x = 42
        b = -> alert x
    '''
    options: ['all']
    errors: 3
  ,
    code: '''
      f = (a) ->
      f()
    '''
    options: ['all']
    errors: [definedError 'a']
  ,
    code: '''
      a = (x, y, z) ->
        y
      a()
    '''
    options: ['all']
    errors: [definedError 'z']
  ,
    code: 'min = Math.min'
    options: ['all']
    errors: [assignedError 'min']
  ,
    code: 'min = {min: 1}'
    options: ['all']
    errors: [assignedError 'min']
  ,
    code: 'Foo.bar = (baz) -> 1'
    options: ['all']
    errors: [definedError 'baz']
  ,
    code: '''
      gg = (baz, bar) -> baz
      gg()
    '''
    options: [vars: 'all']
    errors: [definedError 'bar']
  ,
    code: '''
      do (foo, baz, bar) -> baz
    '''
    options: [vars: 'all', args: 'after-used']
    errors: [definedError 'bar']
  ,
    code: '''
      do (foo, baz, bar) -> baz
    '''
    options: [vars: 'all', args: 'all']
    errors: [definedError('foo'), definedError('bar')]
  ,
    code: 'do (foo) -> bar = 33'
    options: [vars: 'all', args: 'all']
    errors: [definedError('foo'), assignedError('bar')]
  ,
    code: 'do z = (foo) -> z()'
    options: [{}]
    errors: [definedError 'foo']
  ,
    code: '(z = (foo) -> z())()'
    options: [{}]
    errors: [definedError 'foo']
  ,
    code: '''
      f = ->
        a = 1
        -> f(a = 2)
    '''
    options: [{}]
    errors: [
      assignedError 'f'
    ,
      message: "'a' is assigned a value but never used."
    ]
  ,
    code: 'import x from "y"'
    parserOptions: sourceType: 'module'
    errors: [definedError 'x']
  ,
    code: 'export fn2 = ({ x, y }) -> console.log x'
    errors: [definedError 'y']
  ,
    code: 'export fn2 = (x, y) -> console.log(x)'
    errors: [definedError 'y']
  ,
    # ,
    #   # exported
    #   code: '''
    #     ###exported max###
    #     max = 1
    #     min = {min: 1}
    #   '''
    #   errors: [assignedError 'min']
    # ,
    #   code: '###exported x### { x, y } = z'
    #   errors: [assignedError 'y']
    # ignore pattern
    code: '''
      _a = b = null
    '''
    options: [vars: 'all', varsIgnorePattern: '^_']
    errors: [
      message:
        "'b' is assigned a value but never used. Allowed unused vars must match /^_/."
      line: 1
      column: 6
    ]
  ,
    code: '''
      a = null
      foo = ->
        _b = null
        c_ = null
      foo()
    '''
    options: [vars: 'local', varsIgnorePattern: '^_']
    errors: [
      message:
        "'a' is assigned a value but never used. Allowed unused vars must match /^_/."
    ,
      message:
        "'c_' is assigned a value but never used. Allowed unused vars must match /^_/."
      line: 4
      column: 3
    ]
  ,
    code: '''
      foo = (a, _b) ->
      foo()
    '''
    options: [args: 'all', argsIgnorePattern: '^_']
    errors: [
      message:
        "'a' is defined but never used. Allowed unused args must match /^_/."
      line: 1
      column: 8
    ]
  ,
    code: '''
      foo = (a, _b, c) -> a
      foo()
    '''
    options: [args: 'after-used', argsIgnorePattern: '^_']
    errors: [
      message:
        "'c' is defined but never used. Allowed unused args must match /^_/."
      line: 1
      column: 15
    ]
  ,
    code: '''
      foo = (_a) ->
      foo()
    '''
    options: [args: 'all', argsIgnorePattern: '[iI]gnored']
    errors: [
      message:
        "'_a' is defined but never used. Allowed unused args must match /[iI]gnored/."
      line: 1
      column: 8
    ]
  ,
    code: '[ firstItemIgnored, secondItem ] = items'
    options: [vars: 'all', varsIgnorePattern: '[iI]gnored']
    errors: [
      message:
        "'secondItem' is assigned a value but never used. Allowed unused vars must match /[iI]gnored/."
      line: 1
      column: 21
    ]
  ,
    # for-in loops (see #2342)
    code: '''
      do (obj = {}) ->
        for name in obj
          i()
          return
    '''
    errors: [
      message: "'name' is assigned a value but never used.", line: 2, column: 7
    ]
  ,
    code: '''
      do (obj = {}) ->
        for name in obj
          ;
    '''
    errors: [
      message: "'name' is assigned a value but never used.", line: 2, column: 7
    ]
  ,
    # https://github.com/eslint/eslint/issues/3617
    code: '''
      ### global foobar, foo, bar ###
      foobar
    '''
    errors: [
      line: 1, column: 19, message: "'foo' is defined but never used."
    ,
      line: 1, column: 24, message: "'bar' is defined but never used."
    ]
  ,
    code: '''
      ### global foobar,
        foo,
        bar
       ###
      foobar
    '''
    errors: [
      line: 2, column: 2, message: "'foo' is defined but never used."
    ,
      line: 3, column: 2, message: "'bar' is defined but never used."
    ]
  ,
    # Rest property sibling without ignoreRestSiblings
    code: """
      data = { type: 'coords', x: 1, y: 2 }
      { type, ...coords } = data
      console.log(coords)
    """
    errors: [
      line: 2, column: 3, message: "'type' is assigned a value but never used."
    ]
  ,
    # Unused rest property with ignoreRestSiblings
    code: """
      data = { type: 'coords', x: 1, y: 2 }
      { type, ...coords } = data
      console.log(type)
    """
    options: [ignoreRestSiblings: yes]
    errors: [
      line: 2
      column: 12
      message: "'coords' is assigned a value but never used."
    ]
  ,
    # Nested array destructuring with rest property
    code: """
      data = { vars: ['x','y'], x: 1, y: 2 }
      { vars: [x], ...coords } = data
      console.log(coords)
    """
    errors: [
      line: 2, column: 10, message: "'x' is assigned a value but never used."
    ]
  ,
    # Nested object destructuring with rest property
    code: '''
      data = defaults: { x: 0 }, x: 1, y: 2
      { defaults: { x }, ...coords } = data
      console.log(coords)
    '''
    errors: [
      line: 2, column: 15, message: "'x' is assigned a value but never used."
    ]
  ,
    # https://github.com/eslint/eslint/issues/8119
    code: '({a, ...rest}) => {}'
    options: [args: 'all', ignoreRestSiblings: yes]
    errors: ["'rest' is defined but never used."]
  ,
    # https://github.com/eslint/eslint/issues/3714
    code: '''
      ### global a$fooz,$foo ###
      a$fooz
    '''
    errors: [line: 1, column: 18, message: "'$foo' is defined but never used."]
  ,
    code: '''
      ### globals a$fooz, $ ###
      a$fooz
    '''
    errors: [line: 1, column: 20, message: "'$' is defined but never used."]
  ,
    code: '###globals $foo###'
    errors: [line: 1, column: 11, message: "'$foo' is defined but never used."]
  ,
    code: '### global global###'
    errors: [
      line: 1, column: 11, message: "'global' is defined but never used."
    ]
  ,
    code: '###global foo:true###'
    errors: [line: 1, column: 10, message: "'foo' is defined but never used."]
  ,
    # non ascii.
    code: '###global 変数, 数###\n変数;'
    errors: [line: 1, column: 14, message: "'数' is defined but never used."]
  ,
    # https://github.com/eslint/eslint/issues/4047
    code: 'export default (a) ->'
    errors: [message: "'a' is defined but never used."]
  ,
    code: 'export default (a, b) -> console.log(a)'
    errors: [message: "'b' is defined but never used."]
  ,
    code: 'export default ((a) ->)'
    errors: [message: "'a' is defined but never used."]
  ,
    # caughtErrors
    code: '''
      try
      catch err
    '''
    options: [caughtErrors: 'all']
    errors: [message: "'err' is defined but never used."]
  ,
    code: '''
      try
      catch err
    '''
    options: [caughtErrors: 'all', caughtErrorsIgnorePattern: '^ignore']
    errors: [
      message:
        "'err' is defined but never used. Allowed unused args must match /^ignore/."
    ]
  ,
    # multiple try catch with one success
    code: '''
      try
      catch ignoreErr
      try
      catch err
    '''
    options: [caughtErrors: 'all', caughtErrorsIgnorePattern: '^ignore']
    errors: [
      message:
        "'err' is defined but never used. Allowed unused args must match /^ignore/."
    ]
  ,
    # multiple try catch both fail
    code: '''
      try
      catch error
      try
      catch err
    '''
    options: [caughtErrors: 'all', caughtErrorsIgnorePattern: '^ignore']
    errors: [
      message:
        "'error' is defined but never used. Allowed unused args must match /^ignore/."
    ,
      message:
        "'err' is defined but never used. Allowed unused args must match /^ignore/."
    ]
  ,
    # caughtErrors with other configs
    code: '''
      try
      catch err
    '''
    options: [vars: 'all', args: 'all', caughtErrors: 'all']
    errors: [message: "'err' is defined but never used."]
  ,
    # no conclict in ignore patterns
    code: '''
      try
      catch err
    '''
    options: [
      vars: 'all'
      args: 'all'
      caughtErrors: 'all'
      argsIgnorePattern: '^er'
    ]
    errors: [message: "'err' is defined but never used."]
  ,
    # Ignore reads for modifications to itself: https://github.com/eslint/eslint/issues/6348
    code: '''
      a = 0
      a = a + 1
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      a = 0
      a = a + a
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      a = 0
      a += a + 1
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      a = 0
      a++
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      foo = (a) -> a = a + 1
      foo()
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      foo = (a) ->
        a += a + 1
        null
      foo()
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      foo = (a) -> a++
      foo()
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      a = 3
      a = a * 5 + 6
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    code: '''
      a = 2
      b = 4
      a = a * 2 + b
    '''
    errors: [message: "'a' is assigned a value but never used."]
  ,
    # https://github.com/eslint/eslint/issues/6576 (For coverage)
    code: '''
      foo = (cb) ->
        cb = (a) -> cb(1 + a)
        bar(not_cb)
      foo()
    '''
    errors: [message: "'cb' is assigned a value but never used."]
  ,
    code: '''
      foo = (cb) ->
        cb = do (a) -> cb(1 + a)
      foo()
    '''
    errors: [message: "'cb' is assigned a value but never used."]
  ,
    code: '''
      foo = (cb) ->
        cb = (((a) -> cb(1 + a)); cb)
      foo()
    '''
    errors: [message: "'cb' is assigned a value but never used."]
  ,
    code: '''
      foo = (cb) ->
        cb = (0; (a) -> cb(1 + a))
      foo()
    '''
    errors: [message: "'cb' is assigned a value but never used."]
  ,
    # https://github.com/eslint/eslint/issues/6646
    code: '''
      while a
        foo = (b) -> b = b + 1
        foo()
    '''
    errors: [message: "'b' is assigned a value but never used."]
  ,
    # https://github.com/eslint/eslint/issues/7124
    code: '(a, b, c) ->'
    options: [argsIgnorePattern: 'c']
    errors: [
      message:
        "'a' is defined but never used. Allowed unused args must match /c/."
    ,
      message:
        "'b' is defined but never used. Allowed unused args must match /c/."
    ]
  ,
    code: '(a, b, {c, d}) ->'
    options: [argsIgnorePattern: '[cd]']
    errors: [
      message:
        "'a' is defined but never used. Allowed unused args must match /[cd]/."
    ,
      message:
        "'b' is defined but never used. Allowed unused args must match /[cd]/."
    ]
  ,
    code: '(a, b, {c, d}) ->'
    options: [argsIgnorePattern: 'c']
    errors: [
      message:
        "'a' is defined but never used. Allowed unused args must match /c/."
    ,
      message:
        "'b' is defined but never used. Allowed unused args must match /c/."
    ,
      message:
        "'d' is defined but never used. Allowed unused args must match /c/."
    ]
  ,
    code: '(a, b, {c, d}) ->'
    options: [argsIgnorePattern: 'd']
    errors: [
      message:
        "'a' is defined but never used. Allowed unused args must match /d/."
    ,
      message:
        "'b' is defined but never used. Allowed unused args must match /d/."
    ,
      message:
        "'c' is defined but never used. Allowed unused args must match /d/."
    ]
  ,
    # https://github.com/eslint/eslint/issues/8442
    code: 'do ({ a }, b ) -> b'
    errors: ["'a' is defined but never used."]
  ,
    code: 'do ({ a }, { b, c } ) -> b'
    errors: [
      "'a' is defined but never used."
      "'c' is defined but never used."
    ]
  ,
    code: 'do ({ a, b }, { c } ) -> return b'
    errors: [
      "'a' is defined but never used."
      "'c' is defined but never used."
    ]
  ,
    code: 'do ([ a ], b ) -> b'
    errors: ["'a' is defined but never used."]
  ,
    code: 'do ([ a ], [ b, c ] ) -> b'
    errors: [
      "'a' is defined but never used."
      "'c' is defined but never used."
    ]
  ,
    code: '([ a, b ], [ c ] ) -> b'
    errors: [
      "'a' is defined but never used."
      "'c' is defined but never used."
    ]
  ,
    # https://github.com/eslint/eslint/issues/9774
    code: 'do (_a) ->'
    options: [args: 'all', varsIgnorePattern: '^_']
    errors: [message: "'_a' is defined but never used."]
  ,
    code: 'do (_a) ->'
    options: [args: 'all', caughtErrorsIgnorePattern: '^_']
    errors: [message: "'_a' is defined but never used."]
  ]
