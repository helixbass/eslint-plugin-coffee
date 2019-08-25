###*
# @fileoverview enforce consistent line breaks inside function parentheses
# @author Teddy Katz
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/function-paren-newline'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

LEFT_MISSING_ERROR = messageId: 'expectedAfter', type: 'Punctuator'
LEFT_UNEXPECTED_ERROR = messageId: 'unexpectedAfter', type: 'Punctuator'
RIGHT_MISSING_ERROR = messageId: 'expectedBefore', type: 'Punctuator'
RIGHT_UNEXPECTED_ERROR = messageId: 'unexpectedBefore', type: 'Punctuator'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'function-paren-newline', rule,
  valid: [
    # multiline option (default)
    'baz = (foo, bar) ->'
    '((foo, bar) ->)'
    '(foo, bar) => {}'
    '(foo) => {}'
    '() ->'
    '->'
    'baz(foo, bar)'
    'baz foo, bar'
    '''
      baz
        a: 1
    '''
    """
      baz = (
        foo,
        bar
      ) ->
    """
    """
      baz = (
        foo
        bar
      ) ->
    """
    """
      baz(
        foo,
        bar
      )
    """
    """
      baz("foo
          bar")
    """
    'new Foo(bar, baz)'
    'new Foo'
    'new (Foo)'

    """
      (foo)
      (bar)
    """
    """
      foo.map (value) ->
        return value
    """
  ,
    # always option
    code: 'baz = (foo, bar) ->'
    options: ['multiline']
  ,
    code: """
      baz = (
        foo,
        bar
      ) ->
    """
    options: ['always']
  ,
    code: """
      baz(
        foo,
        bar
      )
    """
    options: ['always']
  ,
    code: """
      baz(
        foo
        bar
      )
    """
    options: ['always']
  ,
    code: """
      (
      ) ->
    """
    options: ['always']
  ,
    # never option
    code: 'baz = (foo, bar) ->'
    options: ['never']
  ,
    code: '((foo, bar) ->)'
    options: ['never']
  ,
    code: 'baz(foo, bar)'
    options: ['never']
  ,
    code: 'baz foo, bar'
    options: ['never']
  ,
    code: '->'
    options: ['never']
  ,
    code: '() ->'
    options: ['never']
  ,
    # minItems option
    code: '(foo, bar) ->'
    options: [minItems: 3]
  ,
    code: """
      (
        foo, bar, qux
      ) ->
    """
    options: [minItems: 3]
  ,
    code: """
      baz(
        foo, bar, qux
      )
    """
    options: [minItems: 3]
  ,
    code: 'baz(foo, bar)'
    options: [minItems: 3]
  ,
    code: 'foo(bar, baz)'
    options: ['consistent']
  ,
    code: """
      foo(bar,
      baz)
    """
    options: ['consistent']
  ,
    code: """
      foo(
        bar, baz
      )
    """
    options: ['consistent']
  ,
    code: """
      foo(
        bar,
        baz
      )
    """
    options: ['consistent']
  ,
    code: '->'
    options: ['always']
  ]

  invalid: [
    # multiline option (default)
    code: """
      (foo,
        bar
      ) ->
    """
    # output: """
    #             function baz(\nfoo,
    #                 bar
    #             ) {}
    #         """
    errors: [LEFT_MISSING_ERROR]
  ,
    code: """
      ((
        foo,
        bar) ->)
    """
    # output: """
    #             (function(
    #                 foo,
    #                 bar\n) {})
    #         """
    errors: [RIGHT_MISSING_ERROR]
  ,
    code: """
      ((foo,
        bar) ->)
    """
    # output: """
    #             (function baz(\nfoo,
    #                 bar\n) {})
    #         """
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: """
      baz(
        foo, bar)
    """
    # output: """
    #             baz(foo, bar)
    #         """
    errors: [LEFT_UNEXPECTED_ERROR]
  ,
    code: """
      (foo, bar
      ) => {}
    """
    # output: """
    #             (foo, bar) => {}
    #         """
    errors: [RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      (
        foo, bar
      ) ->
    """
    # output: """
    #             function baz(foo, bar) {}
    #         """
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      (
        foo =
        1
      ) ->
    """
    # output: """
    #             function baz(foo =
    #                 1) {}
    #         """
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      (
      ) ->
    """
    # output: """
    #             function baz() {}
    #         """
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      new Foo(bar,
        baz)
    """
    # output: """
    #             new Foo(\nbar,
    #                 baz\n)
    #         """
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: """
      (### not fixed due to comment ###
      foo) ->
    """
    # output: null
    errors: [LEFT_UNEXPECTED_ERROR]
  ,
    code: """
      baz = (foo
      ### not fixed due to comment ###) ->
    """
    # output: null
    errors: [RIGHT_UNEXPECTED_ERROR]
  ,
    # always option
    code: """
      (foo,
        bar
      ) ->
    """
    # output: """
    #             function baz(\nfoo,
    #                 bar
    #             ) {}
    #         """
    options: ['always']
    errors: [LEFT_MISSING_ERROR]
  ,
    code: """
      ((
        foo,
        bar) ->)
    """
    # output: """
    #             (function(
    #                 foo,
    #                 bar\n) {})
    #         """
    options: ['always']
    errors: [RIGHT_MISSING_ERROR]
  ,
    code: """
      ((foo,
          bar) ->)
    """
    # output: """
    #             (function baz(\nfoo,
    #                 bar\n) {})
    #         """
    options: ['always']
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: '(foo, bar) ->'
    # output: 'function baz(\nfoo, bar\n) {}'
    options: ['always']
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: '((foo, bar) ->)'
    # output: '(function(\nfoo, bar\n) {})'
    options: ['always']
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: 'baz(foo, bar)'
    # output: 'baz(\nfoo, bar\n)'
    options: ['always']
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: '() ->'
    # output: 'function baz(\n) {}'
    options: ['always']
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    # never option
    code: """
      (foo,
        bar
      ) ->
    """
    # output: """
    #             function baz(foo,
    #                 bar) {}
    #         """
    options: ['never']
    errors: [RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      ((
        foo,
        bar) ->)
    """
    # output: """
    #             (function(foo,
    #                 bar) {})
    #         """
    options: ['never']
    errors: [LEFT_UNEXPECTED_ERROR]
  ,
    code: """
      (
        foo,
        bar
      ) ->
    """
    # output: """
    #             function baz(foo,
    #                 bar) {}
    #         """
    options: ['never']
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      ((
        foo,
        bar
      ) ->)
    """
    # output: """
    #             (function(foo,
    #                 bar) {})
    #         """
    options: ['never']
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      ((
          foo,
          bar
      ) ->)
    """
    # output: """
    #             (function baz(foo,
    #                 bar) {})
    #         """
    options: ['never']
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      (
        foo,
        bar
      ) => {}
    """
    # output: """
    #             (foo,
    #                 bar) => {}
    #         """
    options: ['never']
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      baz(
        foo
        bar
      )
    """
    # output: """
    #             baz(foo,
    #                 bar)
    #         """
    options: ['never']
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      baz = (
      ) ->
    """
    # output: """
    #             function baz() {}
    #         """
    options: ['never']
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    # minItems option
    code: '(foo, bar, qux) ->'
    # output: 'function baz(\nfoo, bar, qux\n) {}'
    options: [minItems: 3]
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: """
      (
        foo, bar
      ) ->
    """
    # output: """
    #             function baz(foo, bar) {}
    #         """
    options: [minItems: 3]
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: 'baz(foo, bar, qux)'
    # output: 'baz(\nfoo, bar, qux\n)'
    options: [minItems: 3]
    errors: [LEFT_MISSING_ERROR, RIGHT_MISSING_ERROR]
  ,
    code: """
      baz(
        foo,
        bar
      )
    """
    # output: """
    #             baz(foo,
    #                 bar)
    #         """
    options: [minItems: 3]
    errors: [LEFT_UNEXPECTED_ERROR, RIGHT_UNEXPECTED_ERROR]
  ,
    code: """
      foo(
        bar,
        baz)
    """
    # output: """
    #             foo(
    #                 bar,
    #                 baz\n)
    #         """
    options: ['consistent']
    errors: [RIGHT_MISSING_ERROR]
  ,
    code: """
      foo(bar,
        baz
      )
    """
    # output: """
    #             foo(bar,
    #                 baz)
    #         """
    options: ['consistent']
    errors: [RIGHT_UNEXPECTED_ERROR]
  ]
