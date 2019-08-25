###*
# @fileoverview Tests for regex-spaces rule.
# @author Matt DuVall <http://www.mattduvall.com/>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-regex-spaces'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-regex-spaces', rule,
  valid: [
    'foo = /bar {3}baz/'
    "foo = RegExp('bar {3}baz')"
    "foo = new RegExp('bar {3}baz')"
    'foo = /bar\t\t\tbaz/'
    "foo = RegExp('bar\t\t\tbaz')"
    "foo = new RegExp('bar\t\t\tbaz')"
    """
      RegExp = ->
      foo = new RegExp('bar   baz')
    """
    """
      RegExp = ->
      foo = RegExp('bar   baz')
    """
    'foo = /  +/'
    '''
      foo = ///
            a
       b     ///
    '''
    '''
      foo = ///
            a
       b  #{c}   ///
     '''
  ]

  invalid: [
    code: 'foo = /bar    baz/'
    output: 'foo = /bar {4}baz/'
    errors: [
      message: 'Spaces are hard to count. Use {4}.'
      type: 'Literal'
    ]
  ,
    code: "foo = RegExp('bar    baz')"
    output: "foo = RegExp('bar {4}baz')"
    errors: [
      message: 'Spaces are hard to count. Use {4}.'
      type: 'CallExpression'
    ]
  ,
    code: "foo = new RegExp('bar    baz')"
    output: "foo = new RegExp('bar {4}baz')"
    errors: [
      message: 'Spaces are hard to count. Use {4}.'
      type: 'NewExpression'
    ]
  ,
    # `RegExp` is not shadowed in the scope where it's called
    code: """
      ->
        RegExp = ->
      foo = RegExp('bar    baz')
    """
    output: """
      ->
        RegExp = ->
      foo = RegExp('bar {4}baz')
    """
    errors: [
      message: 'Spaces are hard to count. Use {4}.'
      type: 'CallExpression'
    ]
  ,
    code: 'foo = /bar    ?baz/'
    output: 'foo = /bar {3} ?baz/'
    errors: [
      message: 'Spaces are hard to count. Use {3}.'
      type: 'Literal'
    ]
  ,
    code: "foo = new RegExp('bar    ')"
    output: "foo = new RegExp('bar {4}')"
    errors: [
      message: 'Spaces are hard to count. Use {4}.'
      type: 'NewExpression'
    ]
  ]
