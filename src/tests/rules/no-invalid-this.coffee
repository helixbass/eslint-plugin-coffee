###*
# @fileoverview Tests for no-invalid-this rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-invalid-this'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

errors = [
  message: "Unexpected 'this'.", type: 'ThisExpression'
,
  message: "Unexpected 'this'.", type: 'ThisExpression'
]

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-invalid-this', rule,
  valid: [
    '''
      obj =
        foo: if hasNative then foo else ->
          console.log(this)
          z (x) => console.log(x, this)
    '''
    '''
      obj = {
        foo: (->
          return ->
            console.log(this)
            z (x) => console.log(x, this)
        )()
      }
    '''
    '''
      obj = {
        foo: do -> ->
          console.log(this)
          z (x) => console.log(x, this)
      }
    '''
    '''
      Object.defineProperty obj, "foo",
        value: ->
          console.log this
          z (x) => console.log(x, this)
    '''
    '''
      Object.defineProperties obj,
        foo:
          value: ->
            console.log this
            z (x) => console.log(x, this)
    '''
    # Assigns to a property.
    '''
      obj.foo = ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    '''
      obj.foo = foo or ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    '''
      obj.foo = if foo then bar else ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    '''
      obj.foo = do ->
        ->
          console.log(this)
          z (x) => console.log(x, this)
    '''
    '''
      obj.foo = do => ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    '''
      Reflect.apply ->
        console.log this
        z (x) => console.log(x, this)
      , obj, []
    '''
    '''
      Array.from [], ->
        console.log(this)
        z (x) => console.log(x, this)
      , obj
    '''
    '''
      foo.every ->
        console.log(this)
        z((x) => console.log(x, this))
      , obj
    '''
    '''
      foo.filter(->
        console.log(this)
        z((x) => console.log(x, this))
      , obj)
    '''
    '''
      foo.find(->
        console.log(this)
        z (x) => console.log(x, this)
      , obj)
    '''
    '''
      foo.findIndex(->
        console.log(this)
        z((x) => console.log(x, this))
      , obj)
    '''
    '''
      foo.forEach(->
        console.log(this)
        z (x) => console.log(x, this)
      , obj)
    '''
    '''
      foo.map(->
        console.log(this)
        z (x) => console.log(x, this)
      , obj)
    '''
    '''
      foo.some(->
        console.log(this)
        z (x) => console.log(x, this)
      , obj)
    '''
    # Class Instance Methods.
    '''
      class A
        foo: ->
          console.log(this)
          z (x) => console.log(x, this)
    '''
    # Bind/Call/Apply
    '''
      foo = (->
        console.log(this)
        z (x) =>
          console.log(x, this)
      ).bind obj
    '''
    '''
      foo = (->
        console.log(this)
        z (x) =>
          console.log(x, this)
      ).call obj
    '''
    '''
      foo = (->
        console.log(this)
        z (x) =>
          console.log(x, this)
      ).apply obj
    '''
    # Class Static methods.
    '''
      class A
        @foo: ->
          console.log this
          z (x) => console.log(x, this)
    '''
    # Constructors.
    '''
      Foo = ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    '''
      class A
        constructor: ->
          console.log(@)
          z (x) => console.log(x, @)
    '''
    # On a property.
    '''
      obj =
        foo: ->
          console.log(this)
          z (x) => console.log(x, this)
    '''
    '''
      obj =
        foo: foo or ->
          console.log this
          z (x) => console.log(x, this)
    '''
    '''
      foo = (Ctor = ->
        console.log(this)
        z (x) => console.log(x, this)
      ) ->
    '''
    '''
      [
        obj.method = ->
          console.log(this)
          z((x) => console.log(x, this))
      ] = a
    '''
    '''
      Ctor = ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    '''
      foo(### @this Obj ### ->
        console.log(this)
        z (x) => console.log(x, this)
      )
    '''
    # https://github.com/eslint/eslint/issues/3287
    '''
      foo = ->
        ###* @this Obj### return ->
          console.log(this)
          z (x) => console.log(x, this)
    '''
    # https://github.com/eslint/eslint/issues/6824
    '''
      Ctor = ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    # @this tag.
    '''
      ###* @this Obj ### foo = ->
        console.log(this)
        z (x) => console.log(x, this)
    '''
    '''
      ###*
      # @returns {void}
      # @this Obj
      ###
      foo = ->
        console.log this
        z (x) => console.log(x, this)
    '''
  ]
  invalid: [
    {
      code: '''
        [
          func = ->
            console.log @
            z (x) -> console.log x, @
        ] = a
      '''
      errors
    }
  ,
    # https://github.com/eslint/eslint/issues/3254
    {
      code: '''
        foo = ->
          console.log(this)
          z((x) => console.log(x, this))
      '''
      errors
    }
  ,
    # Global.
    {
      code: '''
        console.log(this)
        z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    # IIFE.
    {
      code: '''
        do ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    # Just functions.
    {
      code: '''
        foo = ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo = ->
          "use strict"
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        return ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo = (->
          console.log(this)
          z (x) => console.log(x, this)
        ).bar obj
      '''
      errors
    }
  ,
    # Functions in methods.
    {
      code: '''
        obj =
          foo: ->
            foo = ->
              console.log(this)
              z (x) => console.log(x, this)
            foo()
      '''
      errors
    }
  ,
    {
      code: '''
        obj =
          foo: ->
            ->
              console.log(this)
              z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        obj =
          foo: ->
            "use strict"
            ->
              console.log this
              z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        obj.foo = ->
          ->
            console.log(this)
            z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        obj.foo = ->
          "use strict"
          return ->
            console.log(this)
            z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        class A
          foo: -> ->
            console.log(this)
            z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        obj.foo = do ->
          =>
            console.log(this)
            z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        obj.foo = do => =>
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo = (->
          console.log(this)
          z (x) => console.log(x, this)
        ).bind(null)
      '''
      errors
    }
  ,
    {
      code: '''
        (->
          console.log(this)
          z (x) => console.log(x, this)
        ).call(undefined)
      '''
      errors
    }
  ,
    # Array methods.
    {
      code: '''
        Array.from [], ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo.every ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo.filter ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo.find ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo.findIndex ->
          console.log this
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''foo.forEach ->
        console.log this
        z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo.map ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo.some ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo.forEach ->
          console.log(this)
          z (x) => console.log(x, this)
        , null
      '''
      errors
    }
  ,
    {
      code: '''
        ###* @returns {void} ### ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        ###* @this Obj ### foo ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        func = ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        func = ->
          console.log(this)
          z (x) => console.log(x, this)
      '''
      errors
    }
  ,
    {
      code: '''
        foo = (func = ->
          console.log(this)
          z (x) => console.log(x, this)
        ) ->
      '''
      errors
    }
  ]
