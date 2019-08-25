###*
# @fileoverview Disallows or enforces spaces inside of parentheses.
# @author Jonathan Rajavuori
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/space-in-parens'
{RuleTester} = require 'eslint'
path = require 'path'

MISSING_SPACE_ERROR = 'There must be a space inside this paren.'
REJECTED_SPACE_ERROR = 'There should be no spaces inside this paren.'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'space-in-parens', rule,
  valid: [
    code: 'foo()', options: ['always']
  ,
    code: 'foo( bar )', options: ['always']
  ,
    code: 'foo bar', options: ['always']
  ,
    code: 'foo bar', options: ['never']
  ,
    code: '''
      foo(
        bar
      )
    '''
    options: ['always']
  ,
    code: '''
      foo(
        bar
        )
    '''
    options: ['always']
  ,
    code: '''
      foo(\t
        bar
      )
    '''
    options: ['always']
  ,
    code: '''
      \tfoo(
      \t\tbar
      \t)
    '''
    options: ['always']
  ,
    code: 'x = ( 1 + 2 ) * 3', options: ['always']
  ,
    code: "x = 'foo(bar)'", options: ['always']
  ,
    code: "x = 'bar( baz )'", options: ['always']
  ,
    code: 'foo = "(bar)"'
    options: ['always']
  ,
    code: 'foo = "(bar #{baz})"'
    options: ['always']
  ,
    code: 'foo = "(bar #{( 1 + 2 )})"'
    options: ['always']
  ,
    code: 'bar()', options: ['never']
  ,
    code: 'bar(baz)', options: ['never']
  ,
    code: 'x = (4 + 5) * 6', options: ['never']
  ,
    code: '''
      foo(
        bar
      )
    '''
    options: ['never']
  ,
    code: '''
      foo(
        bar
        )
    '''
    options: ['never']
  ,
    code: 'foo = "( bar )"'
    options: ['never']
  ,
    code: 'foo = "( bar #{baz} )"'
    options: ['never']
  ,
    code: 'foo = "(bar #{(1 + 2)})"'
    options: ['never']
  ,
    # comments
    code: 'foo( ### bar ### )', options: ['always']
  ,
    code: 'foo( ### bar ###baz )', options: ['always']
  ,
    code: 'foo( ### bar ### baz )', options: ['always']
  ,
    code: 'foo( baz### bar ### )', options: ['always']
  ,
    code: 'foo( baz ### bar ### )', options: ['always']
  ,
    code: 'foo(### bar ###)', options: ['never']
  ,
    code: 'foo(### bar ### baz)', options: ['never']
  ,
    '''
      foo( #some comment
        bar
      )
    '''
  ,
    code: '''
      foo(#some comment
        bar
      )
    '''
    options: ['never']
  ,
    code: '''
      foo( #some comment
        bar
      )
    '''
    options: ['never']
  ,
    # exceptions
    code: "foo({ bar: 'baz' })", options: ['always', {exceptions: ['{}']}]
  ,
    code: "foo( bar: 'baz' )", options: ['always', {exceptions: ['{}']}]
  ,
    code: "foo( { bar: 'baz' } )"
    options: ['always', {exceptions: ['[]', '()']}]
  ,
    code: "foo( 1, { bar: 'baz' })", options: ['always', {exceptions: ['{}']}]
  ,
    code: "foo({ bar: 'baz' }, 1 )", options: ['always', {exceptions: ['{}']}]
  ,
    code: """
      foo({
        bar: 'baz',
        baz: 'bar'
      })
    """
    options: ['always', {exceptions: ['{}']}]
  ,
    code: "foo({ bar: 'baz' })"
    options: ['never', {exceptions: ['[]', '()']}]
  ,
    code: "foo( { bar: 'baz' } )", options: ['never', {exceptions: ['{}']}]
  ,
    code: "foo(1, { bar: 'baz' } )", options: ['never', {exceptions: ['{}']}]
  ,
    code: "foo( { bar: 'baz' }, 1)", options: ['never', {exceptions: ['{}']}]
  ,
    code: """
      foo( {
        bar: 'baz',
        baz: 'bar'
      } )
    """
    options: ['never', {exceptions: ['{}']}]
  ,
    code: 'foo([ 1, 2 ])', options: ['always', {exceptions: ['[]']}]
  ,
    code: 'foo( [ 1, 2 ] )', options: ['always', {exceptions: ['{}']}]
  ,
    code: 'foo( 1, [ 1, 2 ])', options: ['always', {exceptions: ['[]']}]
  ,
    code: 'foo([ 1, 2 ], 1 )', options: ['always', {exceptions: ['[]']}]
  ,
    code: '''
      foo([
        1
        2
      ])
    '''
    options: ['always', {exceptions: ['[]']}]
  ,
    code: 'foo([ 1, 2 ])', options: ['never', {exceptions: ['{}']}]
  ,
    code: 'foo( [ 1, 2 ] )', options: ['never', {exceptions: ['[]']}]
  ,
    code: 'foo(1, [ 1, 2 ] )', options: ['never', {exceptions: ['[]']}]
  ,
    code: 'foo( [ 1, 2 ], 1)', options: ['never', {exceptions: ['[]']}]
  ,
    code: '''
      foo( [
        1,
        2
      ] )
    '''
    options: ['never', {exceptions: ['[]']}]
  ,
    code: 'foo(( 1 + 2 ))', options: ['always', {exceptions: ['()']}]
  ,
    code: 'foo( ( 1 + 2 ) )', options: ['always', {exceptions: ['{}']}]
  ,
    code: 'foo( 1 / ( 1 + 2 ))', options: ['always', {exceptions: ['()']}]
  ,
    code: 'foo(( 1 + 2 ) / 1 )', options: ['always', {exceptions: ['()']}]
  ,
    code: '''
      foo((
        1 + 2
      ))
    '''
    options: ['always', {exceptions: ['()']}]
  ,
    code: 'foo((1 + 2))', options: ['never', {exceptions: ['{}']}]
  ,
    code: 'foo( (1 + 2) )', options: ['never', {exceptions: ['()']}]
  ,
    code: 'foo(1 / (1 + 2) )', options: ['never', {exceptions: ['()']}]
  ,
    code: 'foo( (1 + 2) / 1)', options: ['never', {exceptions: ['()']}]
  ,
    code: '''
      foo( (
        1 + 2
      ) )
    '''
    options: ['never', {exceptions: ['()']}]
  ,
    code: 'foo()', options: ['always', {exceptions: ['empty']}]
  ,
    code: 'foo( )', options: ['always', {exceptions: ['{}']}]
  ,
    code: '''
      foo(
        1 + 2
      )
    '''
    options: ['always', {exceptions: ['empty']}]
  ,
    code: 'foo()', options: ['never', {exceptions: ['{}']}]
  ,
    code: 'foo( )', options: ['never', {exceptions: ['empty']}]
  ,
    code: '''
      foo( 
        1 + 2
      )
    '''
    options: ['never', {exceptions: ['empty']}]
  ,
    code: "foo({ bar: 'baz' }, [ 1, 2 ])"
    options: ['always', {exceptions: ['{}', '[]']}]
  ,
    code: """
      foo({
        bar: 'baz'
      }, [
        1,
        2
      ])
    """
    options: ['always', {exceptions: ['{}', '[]']}]
  ,
    code: """
      foo()
      bar({bar:'baz'})
      baz([1,2])
    """
    options: ['always', {exceptions: ['{}', '[]', '()']}]
  ,
    code: "foo( { bar: 'baz' }, [ 1, 2 ] )"
    options: ['never', {exceptions: ['{}', '[]']}]
  ,
    code: """
      foo( {
        bar: 'baz'
      }, [
        1,
        2
      ] )
    """
    options: ['never', {exceptions: ['{}', '[]']}]
  ,
    code: """
      foo( )
      bar( {bar:'baz'} )
      baz( [1,2] )
    """
    options: ['never', {exceptions: ['{}', '[]', 'empty']}]
  ,
    # faulty exceptions option
    code: "foo( { bar: 'baz' } )", options: ['always', {exceptions: []}]
  ,
    code: "foo( { bar: 'baz' } )", options: ['always', {}]
  ]

  invalid: [
    code: 'foo( )'
    output: 'foo()'
    options: ['never']
    errors: [message: REJECTED_SPACE_ERROR, line: 1, column: 4]
  ,
    code: 'foo( bar)'
    output: 'foo( bar )'
    options: ['always']
    errors: [message: MISSING_SPACE_ERROR, line: 1, column: 9]
  ,
    code: 'foo(bar)'
    output: 'foo( bar )'
    options: ['always']
    errors: [
      message: MISSING_SPACE_ERROR, line: 1, column: 4
    ,
      message: MISSING_SPACE_ERROR, line: 1, column: 8
    ]
  ,
    code: 'x = ( 1 + 2) * 3'
    output: 'x = ( 1 + 2 ) * 3'
    options: ['always']
    errors: [message: MISSING_SPACE_ERROR, line: 1, column: 12]
  ,
    code: 'x = (1 + 2 ) * 3'
    output: 'x = ( 1 + 2 ) * 3'
    options: ['always']
    errors: [message: MISSING_SPACE_ERROR, line: 1, column: 5]
  ,
    code: 'bar(baz )'
    output: 'bar(baz)'
    options: ['never']
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: 'bar( baz )'
    output: 'bar(baz)'
    options: ['never']
    errors: [
      message: REJECTED_SPACE_ERROR, line: 1, column: 4
    ,
      message: REJECTED_SPACE_ERROR, line: 1, column: 10
    ]
  ,
    code: 'x = ( 4 + 5) * 6'
    output: 'x = (4 + 5) * 6'
    options: ['never']
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: 'x = (4 + 5 ) * 6'
    output: 'x = (4 + 5) * 6'
    options: ['never']
    errors: [REJECTED_SPACE_ERROR]
  ,
    # comments
    code: 'foo(### bar ###)'
    output: 'foo( ### bar ### )'
    options: ['always']
    errors: [MISSING_SPACE_ERROR, MISSING_SPACE_ERROR]
  ,
    code: 'foo(### bar ###baz )'
    output: 'foo( ### bar ###baz )'
    options: ['always']
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'foo(### bar ### baz )'
    output: 'foo( ### bar ### baz )'
    options: ['always']
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'foo( baz### bar ###)'
    output: 'foo( baz### bar ### )'
    options: ['always']
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'foo( baz ### bar ###)'
    output: 'foo( baz ### bar ### )'
    options: ['always']
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'foo( ### bar ### )'
    output: 'foo(### bar ###)'
    options: ['never']
    errors: [REJECTED_SPACE_ERROR, REJECTED_SPACE_ERROR]
  ,
    code: 'foo( ### bar ### baz)'
    output: 'foo(### bar ### baz)'
    options: ['never']
    errors: [message: REJECTED_SPACE_ERROR, line: 1, column: 4]
  ,
    # exceptions
    code: "foo({ bar: 'baz' })"
    output: "foo( { bar: 'baz' } )"
    options: ['always', {exceptions: ['[]']}]
    errors: [MISSING_SPACE_ERROR, MISSING_SPACE_ERROR]
  ,
    code: "foo( { bar: 'baz' } )"
    output: "foo({ bar: 'baz' })"
    options: ['always', {exceptions: ['{}']}]
    errors: [REJECTED_SPACE_ERROR, REJECTED_SPACE_ERROR]
  ,
    code: "foo({ bar: 'baz' })"
    output: "foo( { bar: 'baz' } )"
    options: ['never', {exceptions: ['{}']}]
    errors: [MISSING_SPACE_ERROR, MISSING_SPACE_ERROR]
  ,
    code: "foo( { bar: 'baz' } )"
    output: "foo({ bar: 'baz' })"
    options: ['never', {exceptions: ['[]']}]
    errors: [REJECTED_SPACE_ERROR, REJECTED_SPACE_ERROR]
  ,
    code: "foo( { bar: 'baz' })"
    output: "foo({ bar: 'baz' })"
    options: ['always', {exceptions: ['{}']}]
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: "foo( { bar: 'baz' })"
    output: "foo( { bar: 'baz' } )"
    options: ['never', {exceptions: ['{}']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: "foo({ bar: 'baz' } )"
    output: "foo({ bar: 'baz' })"
    options: ['always', {exceptions: ['{}']}]
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: "foo({ bar: 'baz' } )"
    output: "foo( { bar: 'baz' } )"
    options: ['never', {exceptions: ['{}']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'foo([ 1, 2 ])'
    output: 'foo( [ 1, 2 ] )'
    options: ['always', {exceptions: ['empty']}]
    errors: [MISSING_SPACE_ERROR, MISSING_SPACE_ERROR]
  ,
    code: 'foo( [ 1, 2 ] )'
    output: 'foo([ 1, 2 ])'
    options: ['always', {exceptions: ['[]']}]
    errors: [REJECTED_SPACE_ERROR, REJECTED_SPACE_ERROR]
  ,
    code: 'foo([ 1, 2 ])'
    output: 'foo( [ 1, 2 ] )'
    options: ['never', {exceptions: ['[]']}]
    errors: [MISSING_SPACE_ERROR, MISSING_SPACE_ERROR]
  ,
    code: 'foo( [ 1, 2 ] )'
    output: 'foo([ 1, 2 ])'
    options: ['never', {exceptions: ['()']}]
    errors: [REJECTED_SPACE_ERROR, REJECTED_SPACE_ERROR]
  ,
    code: 'foo([ 1, 2 ] )'
    output: 'foo([ 1, 2 ])'
    options: ['always', {exceptions: ['[]']}]
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: 'foo([ 1, 2 ] )'
    output: 'foo( [ 1, 2 ] )'
    options: ['never', {exceptions: ['[]']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'foo( [ 1, 2 ])'
    output: 'foo([ 1, 2 ])'
    options: ['always', {exceptions: ['[]']}]
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: 'foo( [ 1, 2 ])'
    output: 'foo( [ 1, 2 ] )'
    options: ['never', {exceptions: ['[]']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: '(( 1 + 2 ))'
    output: '( ( 1 + 2 ) )'
    options: ['always', {exceptions: ['[]']}]
    errors: [MISSING_SPACE_ERROR, MISSING_SPACE_ERROR]
  ,
    code: '( ( 1 + 2 ) )'
    output: '(( 1 + 2 ))'
    options: ['always', {exceptions: ['()']}]
    errors: [
      message: REJECTED_SPACE_ERROR, line: 1, column: 1
    ,
      message: REJECTED_SPACE_ERROR, line: 1, column: 13
    ]
  ,
    code: '( ( 1 + 2 ) )'
    output: '((1 + 2))'
    options: ['never']
    errors: [
      message: REJECTED_SPACE_ERROR, line: 1, column: 1
    ,
      message: REJECTED_SPACE_ERROR, line: 1, column: 3
    ,
      message: REJECTED_SPACE_ERROR, line: 1, column: 11
    ,
      message: REJECTED_SPACE_ERROR, line: 1, column: 13
    ]
  ,
    code: '( ( 1 + 2 ) )'
    output: '((1 + 2))'
    options: ['never', {exceptions: ['[]']}]
    errors: [
      REJECTED_SPACE_ERROR
      REJECTED_SPACE_ERROR
      REJECTED_SPACE_ERROR
      REJECTED_SPACE_ERROR
    ]
  ,
    code: '( ( 1 + 2 ))'
    output: '(( 1 + 2 ))'
    options: ['always', {exceptions: ['()']}]
    errors: [message: REJECTED_SPACE_ERROR, line: 1, column: 1]
  ,
    code: '( (1 + 2))'
    output: '( (1 + 2) )'
    options: ['never', {exceptions: ['()']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: '(( 1 + 2 ) )'
    output: '(( 1 + 2 ))'
    options: ['always', {exceptions: ['()']}]
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: '((1 + 2) )'
    output: '( (1 + 2) )'
    options: ['never', {exceptions: ['()']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'result = ( 1 / ( 1 + 2 ) ) + 3'
    output: 'result = ( 1 / ( 1 + 2 )) + 3'
    options: ['always', {exceptions: ['()']}]
    errors: [REJECTED_SPACE_ERROR]
  ,
    code: 'result = (1 / (1 + 2)) + 3'
    output: 'result = (1 / (1 + 2) ) + 3'
    options: ['never', {exceptions: ['()']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'result = ( 1 / ( 1 + 2)) + 3'
    output: 'result = ( 1 / ( 1 + 2 )) + 3'
    options: ['always', {exceptions: ['()']}]
    errors: [MISSING_SPACE_ERROR]
  ,
    code: 'foo( )'
    output: 'foo()'
    options: ['always', {exceptions: ['empty']}]
    errors: [message: REJECTED_SPACE_ERROR, line: 1, column: 4]
  ,
    code: 'foo()'
    output: 'foo( )'
    options: ['never', {exceptions: ['empty']}]
    errors: [message: MISSING_SPACE_ERROR, line: 1, column: 4]
  ,
    code: '''
      foo(
        bar )
    '''
    output: '''
      foo(
        bar)
    '''
    options: ['never']
    errors: [message: REJECTED_SPACE_ERROR, line: 2, column: 7]
  ,
    code: 'foo = "(bar #{(1 + 2 )})"'
    output: 'foo = "(bar #{(1 + 2)})"'
    options: ['never']
    errors: [message: REJECTED_SPACE_ERROR, line: 1, column: 22]
  ,
    code: 'foo = "(bar #{(1 + 2 )})"'
    output: 'foo = "(bar #{( 1 + 2 )})"'
    options: ['always']
    errors: [message: MISSING_SPACE_ERROR, line: 1, column: 15]
  ]
