###*
# @fileoverview Tests for max-statements rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/max-statements'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'max-statements', rule,
  valid: [
    code: '''
      ->
        bar = 1
        ->
          noCount = 2
        return 3
    '''
    options: [3]
  ,
    code: '''
      ->
        bar = 1
        if yes
          loop
            qux = null
        else
          quxx()
        return 3
    '''
    options: [6]
  ,
    code: '''
      x = 5
      -> y = 6
      bar()
      z = 10
      baz()
    '''
    options: [5]
  ,
    '''
      ->
        a = null
        b = null
        c = null
        x = null
        y = null
        z = null
        bar()
        baz()
        qux()
        quxx()
    '''
  ,
    code: '''
      do ->
        bar = 1
        return -> return 42
    '''
    options: [1, {ignoreTopLevelFunctions: yes}]
  ,
    code: '''
      foo = ->
        bar = 1
        baz = 2
    '''
    options: [1, {ignoreTopLevelFunctions: yes}]
  ,
    code: """
      define ['foo', 'qux'], (foo, qux) ->
        bar = 1
        baz = 2
    """
    options: [1, {ignoreTopLevelFunctions: yes}]
  ,
    # object property options
    code: '''
      foo =
        thing: ->
          bar = 1
          baz = 2
    '''
    options: [2]
  ,
    code: '''
      foo =
        ['thing']: ->
          bar = 1
          baz = 2
    '''
    options: [2]
  ]
  invalid: [
    code: '''
      foo = ->
        bar = 1
        baz = 2
        qux = 3
    '''
    options: [2]
    errors: [
      message:
        'Function has too many statements (3). Maximum allowed is 2.'
    ]
  ,
    code: '''
        foo = ->
          bar = 1
          if yes
            while no
              qux = null
          return 3
      '''
    options: [4]
    errors: [
      message:
        'Function has too many statements (5). Maximum allowed is 4.'
    ]
  ,
    code: '''
      foo = ->
        bar = 1
        if yes
          loop
            qux = null
        return 3
    '''
    options: [4]
    errors: [
      message:
        'Function has too many statements (5). Maximum allowed is 4.'
    ]
  ,
    code: '''
        foo = ->
          bar = 1
          if yes
            loop
              qux = null
          else
            quxx()
          return 3
      '''
    options: [5]
    errors: [
      message:
        'Function has too many statements (6). Maximum allowed is 5.'
    ]
  ,
    code: '''
        foo = ->
          x = 5
          bar = ->
            y = 6
          bar()
          z = 10
          baz()
      '''
    options: [3]
    errors: [
      message:
        'Function has too many statements (5). Maximum allowed is 3.'
    ]
  ,
    code: '''
        foo = ->
          x = 5
          bar = -> y = 6
          bar()
          z = 10
          baz()
      '''
    options: [4]
    errors: [
      message:
        'Function has too many statements (5). Maximum allowed is 4.'
    ]
  ,
    code: '''
      do ->
        bar = 1
        ->
          z = null
          return 42
    '''
    options: [1, {ignoreTopLevelFunctions: yes}]
    errors: [
      message: 'Function has too many statements (2). Maximum allowed is 1.'
    ]
  ,
    code: '''
      do ->
        bar = 1
        baz = 2
      do ->
        bar = 1
        baz = 2
    '''
    options: [1, {ignoreTopLevelFunctions: yes}]
    errors: [
      message: 'Function has too many statements (2). Maximum allowed is 1.'
    ,
      message: 'Function has too many statements (2). Maximum allowed is 1.'
    ]
  ,
    code: """
      define ['foo', 'qux'], (foo, qux) ->
        bar = 1
        baz = 2
        ->
          z = null
          return 42
    """
    options: [1, {ignoreTopLevelFunctions: yes}]
    errors: [
      message: 'Function has too many statements (2). Maximum allowed is 1.'
    ]
  ,
    code: '''
      ->
        a = null
        b = null
        c = null
        x = null
        y = null
        z = null
        bar()
        baz()
        qux()
        quxx()
        foo()
    '''
    errors: [
      message:
        'Function has too many statements (11). Maximum allowed is 10.'
    ]
  ,
    # object property options
    code: '''
      foo = {
        thing: ->
          bar = 1
          baz = 2
          baz2
      }
    '''
    options: [2]
    errors: [
      message:
        "Method 'thing' has too many statements (3). Maximum allowed is 2."
    ]
    ###
    # TODO decide if we want this or not
    # {
    #     code: "var foo = { ['thing']() { var bar = 1; var baz = 2; var baz2; } }",
    #     options: [2],
    #     parserOptions: { ecmaVersion: 6 },
    #     errors: [{ message: "Method ''thing'' has too many statements (3). Maximum allowed is 2." }]
    # },
    ###
  ]
