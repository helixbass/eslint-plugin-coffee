###*
# @fileoverview enforce the location of arrow function bodies
# @author Sharmila Jesupaul
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/implicit-arrow-linebreak'
{RuleTester} = require 'eslint'
path = require 'path'

EXPECTED_LINEBREAK = message: 'Expected a linebreak before this expression.'
UNEXPECTED_LINEBREAK = message: 'Expected no linebreak before this expression.'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'implicit-arrow-linebreak', rule,
  valid: [
    # always valid
    '''
      (foo) =>
        a
        bar
    '''

    # 'beside' option
    '() => bar'
    '-> bar'
    '() => (bar)'
    '() => (bar) => baz'
    '() => ((((bar))))'
    '''
      (foo) => (
        bar
      )
    '''
  ,
    code: '(foo) => bar()'
    options: ['beside']
  ,
    # 'below' option
    code: '''
      (foo) =>
        (
          bar
        )
    '''
    options: ['below']
  ,
    code: '''
      () ->
        ((((bar))))
    '''
    options: ['below']
  ,
    code: '''
      () =>
        bar()
    '''
    options: ['below']
  ,
    code: '''
      () =>
        (bar)
    '''
    options: ['below']
  ,
    code: '''
      () =>
        (bar) =>
          baz
    '''
    options: ['below']
  ]

  invalid: [
    # 'beside' option
    code: '''
      (foo) =>
        bar()
    '''
    output: '''
      (foo) => bar()
    '''
    errors: [UNEXPECTED_LINEBREAK]
  ,
    code: '''
      () =>
        (bar)
    '''
    output: '''
      () => (bar)
    '''
    errors: [UNEXPECTED_LINEBREAK]
  ,
    code: '''
      () =>
        (bar) =>
          baz
    '''
    output: '''
      () => (bar) => baz
    '''
    errors: [UNEXPECTED_LINEBREAK, UNEXPECTED_LINEBREAK]
  ,
    code: '''
      ->
        ((((bar))))
    '''
    output: '''
      -> ((((bar))))
    '''
    errors: [UNEXPECTED_LINEBREAK]
  ,
    code: '''
      (foo) =>
        (
          bar
        )
    '''
    output: '''
      (foo) => (
          bar
        )
    '''
    errors: [UNEXPECTED_LINEBREAK]
  ,
    # 'below' option
    code: '(foo) => bar()'
    # output: '(foo) => \nbar()'
    options: ['below']
    errors: [EXPECTED_LINEBREAK]
  ,
    code: '(foo) -> (bar) -> baz'
    # output: '(foo) => \nbar => \nbaz'
    options: ['below']
    errors: [EXPECTED_LINEBREAK, EXPECTED_LINEBREAK]
  ,
    code: '(foo) => (bar)'
    # output: '(foo) => \n(bar)'
    options: ['below']
    errors: [EXPECTED_LINEBREAK]
  ,
    code: '(foo) => (((bar)))'
    # output: '(foo) => \n(((bar)))'
    options: ['below']
    errors: [EXPECTED_LINEBREAK]
  ,
    code: '''
      (foo) => (
        bar
      )
    '''
    # output: """
    #             (foo) => \n(
    #                 bar
    #             )
    #         """
    options: ['below']
    errors: [EXPECTED_LINEBREAK]
  ]
