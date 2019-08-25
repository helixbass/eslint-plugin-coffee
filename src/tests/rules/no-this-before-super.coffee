###*
# @fileoverview Tests for no-this-before-super rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-this-before-super'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-this-before-super', rule,
  valid: [
    ###
    # if the class has no extends or `extends null`, just ignore.
    # those classes cannot call `super()`.
    ###
    'class A'
    '''
      class A
        constructor: ->
    '''
    '''
      class A
        constructor: -> @b = 0
    '''
    '''
      class A
        constructor: -> @b()
    '''
    'class A extends null'
    '''
      class A extends null
        constructor: ->
    '''

    # allows `this`/`super` after `super()`.
    '''
      class A extends B
    '''
    '''
      class A extends B
        constructor: -> super()
    '''
    '''
      class A extends B
        constructor: ->
          super()
          @c = @d
    '''
    '''
      class A extends B
        constructor: ->
          super()
          this.c()
    '''
    '''
      class A extends B
        constructor: ->
          super()
          super.c()
    '''
    '''
      class A extends B
        constructor: (@a) ->
          super()
    '''
    '''
      class A extends B
        constructor: ->
          if yes
            super()
          else
            super()
          this.c()
    '''

    # allows `this`/`super` in nested executable scopes, even if before `super()`.
    '''
      class A extends B
        constructor: ->
          class B extends C
            constructor: ->
              super()
              @d = 0
          super()
    '''
    '''
      class A extends B
        constructor: ->
          B = class extends C
            constructor: ->
              super()
              this.d = 0
          super()
    '''
    '''
      class A extends B
        constructor: ->
          c = -> @d()
          super()
    '''
    '''
      class A extends B
        constructor: ->
          c = => @d()
          super()
    '''

    # ignores out of constructors.
    '''
      class A
        b: ->
          @c = 0
    '''
    '''
      class A extends B
        c: -> @d = 0
    '''
    '''
      a = -> @b = 0
    '''

    # multi code path.
    '''
      class A extends B
        constructor: ->
          if a
            super()
            this.a()
          else
            super()
            this.b()
    '''
    '''
      class A extends B
        constructor: ->
          if a
            super()
          else
            super()
          this.a()
    '''
    '''
      class A extends B
        constructor: ->
          try
            super()
          finally
          this.a()
    '''

    # https://github.com/eslint/eslint/issues/5261
    '''
      class A extends B
        constructor: (a) ->
          super()
          @a() for b from a
    '''
    '''
      class A extends B
        constructor: (a) ->
          foo b for b from a
          super()
    '''

    # https://github.com/eslint/eslint/issues/5319
    '''
      class A extends B
        constructor: (a) ->
          super()
          @a = a and (->) and @foo
    '''

    # https://github.com/eslint/eslint/issues/5894
    '''
      class A
        constructor: ->
          return
          this
    '''
    '''
      class A extends B
        constructor: ->
          return
          this
    '''

    # https://github.com/eslint/eslint/issues/8848
    """
      class A extends B
        constructor: (props) ->
          super props

          try
            arr = []
            for a from arr
              ;
          catch err
    """
  ]
  invalid: [
    # disallows all `this`/`super` if `super()` is missing.
    code: '''
      class A extends B
        constructor: -> @c = 0
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: (@c) ->
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: -> this.c()
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: -> super.c()
    '''
    errors: [
      message: "'super' is not allowed before 'super()'.", type: 'Super'
    ]
  ,
    # disallows `this`/`super` before `super()`.
    code: '''
      class A extends B
        constructor: ->
          @c = 0
          super()
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: ->
          @c()
          super()
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: ->
          super.c()
          super()
    '''
    errors: [
      message: "'super' is not allowed before 'super()'.", type: 'Super'
    ]
  ,
    # disallows `this`/`super` in arguments of `super()`.
    code: '''
      class A extends B
        constructor: -> super @c
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: -> super this.c()
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: -> super super.c()
    '''
    errors: [
      message: "'super' is not allowed before 'super()'.", type: 'Super'
    ]
  ,
    # even if is nested, reports correctly.
    code: '''
      class A extends B
        constructor: ->
          class C extends D
            constructor: ->
              super()
              @e()
          @f()
          super()
    '''
    errors: [
      message: "'this' is not allowed before 'super()'."
      type: 'ThisExpression'
      line: 7
    ]
  ,
    code: '''
      class A extends B
        constructor: ->
          class C extends D
            constructor: ->
              this.e()
              super()
          super()
          this.f()
    '''
    errors: [
      message: "'this' is not allowed before 'super()'."
      type: 'ThisExpression'
      line: 5
    ]
  ,
    # multi code path.
    code: '''
      class A extends B
        constructor: ->
          if a then super() else @a()
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: ->
          try
            super()
          finally
            this.a
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ,
    code: '''
      class A extends B
        constructor: ->
          try
            super()
          catch err
          this.a
    '''
    errors: [
      message: "'this' is not allowed before 'super()'.", type: 'ThisExpression'
    ]
  ]
