###*
# @fileoverview Tests for array-element-newline rule.
# @author Jan Peer Stöcklmair <https:#github.com/JPeer264>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/array-element-newline'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'array-element-newline', rule,
  valid: [
    ###
    # ArrayExpression
    # "always"
    ###
    'foo = []'
    'foo = [1]'
    '''
      foo = [1,
        2]
    '''
    '''
      foo = [1
        2]
    '''
    '''
      foo = [1, # any comment
        2]
    '''
    '''
      foo = [# any comment 
        1
        2]
    '''
    '''
      foo = [1,
        2 # any comment
      ]
    '''
    '''
      foo = [1,
        2,
        3
      ]
    '''
    '''
      foo = [1
        , (2
        ; 3)]
    '''
    '''
      foo = [1,
      (  2   ),
      3]
    '''
    '''
      foo = [1,
        ((((2)))),
        3]
    '''
    '''
      foo = [1,
        (
          2
        ),
        3]
    '''
    '''
      foo = [1,
        (2),
        3]
    '''
    '''
      foo = [1,
      (2)
      , 3]
    '''
    '''
      foo = [1
      , 2
      , 3]
    '''
    '''
      foo = [1,
      2,
      ,
      3]
    '''
    '''
      foo = [
        ->
          dosomething()
        , ->
          osomething()
      ]
    '''
  ,
    code: 'foo = []', options: ['always']
  ,
    code: 'foo = [1]', options: ['always']
  ,
    code: '''
      foo = [1,
      2]
    '''
    options: ['always']
  ,
    code: '''
      foo = [1,
      (2)]
    '''
    options: ['always']
  ,
    code: '''
      foo = [1
      , (2)]
    '''
    options: ['always']
  ,
    code: '''
      foo = [1, # any comment
        2]
    '''
    options: ['always']
  ,
    code: '''
      foo = [# any comment 
        1
        2]
    '''
    options: ['always']
  ,
    code: '''
      foo = [1
      2 # any comment
      ]
    '''
    options: ['always']
  ,
    code: '''
      foo = [1,
        2,
        3]
    '''
    options: ['always']
  ,
    code: '''
      foo = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: ['always']
  ,
    # "never"
    code: 'foo = []', options: ['never']
  ,
    code: 'foo = [1]', options: ['never']
  ,
    code: 'foo = [1, 2]', options: ['never']
  ,
    code: 'foo = [1, ### any comment ### 2]', options: ['never']
  ,
    code: 'foo = [### any comment ### 1, 2]', options: ['never']
  ,
    code: 'foo = ### any comment ### [1, 2]', options: ['never']
  ,
    code: 'foo = [1, 2, 3]', options: ['never']
  ,
    code: '''
      foo = [1, (
        2
      ), 3]
    '''
    options: ['never']
  ,
    code: '''
      foo = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: ['never']
  ,
    code: '''
      foo = [
        ->
          dosomething()
      ,
        ->
          dosomething()
      ]
    '''
    options: ['never']
  ,
    # "consistent"
    code: 'foo = []', options: ['consistent']
  ,
    code: 'foo = [1]', options: ['consistent']
  ,
    code: 'foo = [1, 2]', options: ['consistent']
  ,
    code: '''
      foo = [1,
      2]
    '''
    options: ['consistent']
  ,
    code: 'foo = [1, 2, 3]', options: ['consistent']
  ,
    code: '''
      foo = [1,
      2,
      3]
    '''
    options: ['consistent']
  ,
    code: '''
      foo = [1,
      2,
      ,
      3]
    '''
    options: ['consistent']
  ,
    code: '''
      foo = [1, # any comment
      2]
    '''
    options: ['consistent']
  ,
    code: 'foo = [### any comment ### 1, 2]', options: ['consistent']
  ,
    code: '''
      foo = [1, (
        2
        ), 3]
    '''
    options: ['consistent']
  ,
    code: '''
      foo = [1,
      (2)
      , 3]
    '''
    options: ['consistent']
  ,
    code: '''
      foo = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: ['consistent']
  ,
    code: '''
      foo = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: ['consistent']
  ,
    code: '''
      foo = [
        ->
          dosomething()
        , ->
          dosomething()
        , ->
          dosomething()
      ]
    '''
    options: ['consistent']
  ,
    code: '''
      foo = [
        ->
          dosomething()
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: ['consistent']
  ,
    code: 'foo = []', options: [multiline: yes]
  ,
    code: 'foo = [1]', options: [multiline: yes]
  ,
    code: 'foo = [1, 2]', options: [multiline: yes]
  ,
    code: 'foo = [1, 2, 3]', options: [multiline: yes]
  ,
    code: '''
      f = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: [multiline: yes]
  ,
    # { minItems: null }
    code: 'foo = []', options: [minItems: null]
  ,
    code: 'foo = [1]', options: [minItems: null]
  ,
    code: 'foo = [1, 2]', options: [minItems: null]
  ,
    code: 'foo = [1, 2, 3]', options: [minItems: null]
  ,
    code: '''
      f = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: [minItems: null]
  ,
    # { minItems: 0 }
    code: 'foo = []', options: [minItems: 0]
  ,
    code: 'foo = [1]', options: [minItems: 0]
  ,
    code: '''
      foo = [1,
      2]
    '''
    options: [minItems: 0]
  ,
    code: '''
      foo = [1,
      2,
      3]
    '''
    options: [minItems: 0]
  ,
    code: '''
      f = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: [minItems: 0]
  ,
    # { minItems: 3 }
    code: 'foo = []', options: [minItems: 3]
  ,
    code: 'foo = [1]', options: [minItems: 3]
  ,
    code: 'foo = [1, 2]', options: [minItems: 3]
  ,
    code: '''
      foo = [1,
      2,
      3]
    '''
    options: [minItems: 3]
  ,
    code: '''
      f = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: [minItems: 3]
  ,
    # { multiline: true, minItems: 3 }
    code: 'foo = []', options: [multiline: yes, minItems: 3]
  ,
    code: 'foo = [1]', options: [multiline: yes, minItems: 3]
  ,
    code: 'foo = [1, 2]', options: [multiline: yes, minItems: 3]
  ,
    code: '''
      foo = [1, # any comment
      2,
      , 3]
    '''
    options: [multiline: yes, minItems: 3]
  ,
    code: '''
      foo = [1,
      2,
      # any comment
      , 3]
    '''
    options: [multiline: yes, minItems: 3]
  ,
    code: '''
      f = [
        ->
          dosomething()
        ->
          dosomething()
      ]
    '''
    options: [multiline: yes, minItems: 3]
  ,
    ###
    # ArrayPattern
    # "always"
    ###
    code: '[] = foo'
  ,
    code: '[a] = foo'
  ,
    code: '''
      [a,
      b] = foo
    '''
  ,
    code: '''
      [a, # any comment
      b] = foo
    '''
  ,
    code: '''
      [# any comment 
        a,
        b] = foo
    '''
  ,
    code: '''
      [a,
      b # any comment
      ] = foo
    '''
  ,
    code: '''
      [a,
      b,
      b] = foo
    '''
  ,
    # { minItems: 3 }
    code: '[] = foo'
    options: [minItems: 3]
  ,
    code: '[a] = foo'
    options: [minItems: 3]
  ,
    code: '[a, b] = foo'
    options: [minItems: 3]
  ,
    code: '''
      [a,
      b,
      c] = foo
    '''
    options: [minItems: 3]
  ]

  invalid: [
    ###
    # ArrayExpression
    # "always"
    ###
    code: 'foo = [1, 2]'
    # output: 'foo = [1,\n2]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 11
    ]
  ,
    code: 'foo = [1, 2, 3]'
    # output: 'foo = [1,\n2,\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 11
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 13
      endLine: 1
      endColumn: 14
    ]
  ,
    code: 'foo = [1,2, 3]'
    # output: 'foo = [1,\n2,\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 10
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 12
      endLine: 1
      endColumn: 13
    ]
  ,
    code: 'foo = [1, (2), 3]'
    # output: 'foo = [1,\n(2),\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 11
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 15
      endLine: 1
      endColumn: 16
    ]
  ,
    code: '''
      foo = [1,(
        2
        ), 3]
    '''
    # output: 'foo = [1,\n(\n2\n),\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
    ,
      messageId: 'missingLineBreak'
      line: 3
      column: 5
    ]
  ,
    code: '''
      foo = [1,        \t      (
        2
        ),
      3]
    '''
    # output: 'foo = [1,\n(\n2\n),\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
    ]
  ,
    code: 'foo = [1, ((((2)))), 3]'
    # output: 'foo = [1,\n((((2)))),\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 11
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 21
      endLine: 1
      endColumn: 22
    ]
  ,
    code: 'foo = [1,### any comment ###(2), 3]'
    # output: 'foo = [1,### any comment ###\n(2),\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 29
      endLine: 1
      endColumn: 29
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 33
      endLine: 1
      endColumn: 34
    ]
  ,
    code: 'foo = [1,(  2), 3]'
    # output: 'foo = [1,\n(  2),\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 10
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 16
      endLine: 1
      endColumn: 17
    ]
  ,
    code: 'foo = [1, [2], 3]'
    # output: 'foo = [1,\n[2],\n3]'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 11
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 15
      endLine: 1
      endColumn: 16
    ]
  ,
    # "never"
    code: '''
      foo = [
        1,
        2
      ]
    '''
    # output: 'foo = [\n1, 2\n]'
    options: ['never']
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 2
      column: 5
    ]
  ,
    code: '''
      foo = [
        1
        , 2
      ]
    '''
    # output: 'foo = [\n1, 2\n]'
    options: ['never']
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 3
      column: 4
    ]
  ,
    code: '''
      foo = [
        1 # any comment
        , 2
      ]
    '''
    # output: null
    options: ['never']
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 3
      column: 4
    ]
  ,
    code: '''
      foo = [
        1, # any comment
        2
      ]
    '''
    # output: null
    options: ['never']
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 2
      column: 19
    ]
  ,
    code: '''
      foo = [
        1,
        2 # any comment
      ]
    '''
    # output: 'foo = [\n1, 2 # any comment\n]'
    options: ['never']
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 2
      column: 5
    ]
  ,
    code: '''
      foo = [
        1,
        2,
        3
      ]
    '''
    # output: 'foo = [\n1, 2, 3\n]'
    options: ['never']
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 2
      column: 5
      endLine: 3
      endColumn: 3
    ,
      messageId: 'unexpectedLineBreak'
      line: 3
      column: 5
      endLine: 4
      endColumn: 3
    ]
  ,
    # "consistent"
    code: '''
      foo = [1,
      2, 3]
    '''
    # output: 'foo = [1,\n2,\n3]'
    options: ['consistent']
    errors: [
      messageId: 'missingLineBreak'
      line: 2
      column: 3
      endLine: 2
      endColumn: 4
    ]
  ,
    code: '''
      foo = [1, 2,
      3]
    '''
    # output: 'foo = [1,\n2,\n3]'
    options: ['consistent']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 11
    ]
  ,
    code: '''
      foo = [1,
      (
        2), 3]
    '''
    # output: 'foo = [1,\n(\n2),\n3]'
    options: ['consistent']
    errors: [
      messageId: 'missingLineBreak'
      line: 3
      column: 6
      endLine: 3
      endColumn: 7
    ]
  ,
    code: '''
      foo = [1,        \t      (
        2
      ),
      3]
    '''
    # output: 'foo = [1,\n(\n2\n),\n3]'
    options: ['consistent']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
      endLine: 1
      endColumn: 25
    ]
  ,
    code: '''
      foo = [1, ### any comment ###(2),
      3]
    '''
    # output: 'foo = [1, ### any comment ###\n(2),\n3]'
    options: ['consistent']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 30
    ]
  ,
    # { multiline: true }
    code: '''
      foo = [1,
      2, 3]
    '''
    # output: 'foo = [1, 2, 3]'
    options: [multiline: yes]
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 1
      column: 10
    ]
  ,
    # { minItems: null }
    code: '''
      foo = [1,
      2]
    '''
    # output: 'foo = [1, 2]'
    options: [minItems: null]
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 1
      column: 10
    ]
  ,
    code: '''
      foo = [1,
      2,
      3]
    '''
    # output: 'foo = [1, 2, 3]'
    options: [minItems: null]
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 1
      column: 10
    ,
      messageId: 'unexpectedLineBreak'
      line: 2
      column: 3
    ]
  ,
    # { minItems: 0 }
    code: 'foo = [1, 2]'
    # output: 'foo = [1,\n2]'
    options: [minItems: 0]
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
    ]
  ,
    code: 'foo = [1, 2, 3]'
    # output: 'foo = [1,\n2,\n3]'
    options: [minItems: 0]
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 13
    ]
  ,
    # { minItems: 3 }
    code: '''
      foo = [1,
      2]
    '''
    # output: 'foo = [1, 2]'
    options: [minItems: 3]
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 1
      column: 10
    ]
  ,
    code: 'foo = [1, 2, 3]'
    # output: 'foo = [1,\n2,\n3]'
    options: [minItems: 3]
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 13
    ]
  ,
    # { multiline: true, minItems: 3 }
    code: 'foo = [1, 2, 3]'
    # output: 'foo = [1,\n2,\n3]'
    options: [multiline: yes, minItems: 3]
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 10
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 13
    ]
  ,
    code: '''
      foo = [1,
      2]
    '''
    # output: 'foo = [1, 2]'
    options: [multiline: yes, minItems: 3]
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 1
      column: 10
    ]
  ,
    ###
    # ArrayPattern
    # "always"
    ###
    code: '[a, b] = foo'
    # output: '[a,\nb] = foo'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 4
    ]
  ,
    code: '[a, b, c] = foo'
    # output: '[a,\nb,\nc] = foo'
    options: ['always']
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 4
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 7
    ]
  ,
    # { minItems: 3 }
    code: '''
      [a,
        b] = foo
    '''
    # output: '[a, b] = foo'
    options: [minItems: 3]
    errors: [
      messageId: 'unexpectedLineBreak'
      line: 1
      column: 4
    ]
  ,
    code: '[a, b, c] = foo'
    # output: '[a,\nb,\nc] = foo'
    options: [minItems: 3]
    errors: [
      messageId: 'missingLineBreak'
      line: 1
      column: 4
    ,
      messageId: 'missingLineBreak'
      line: 1
      column: 7
    ]
  ]
