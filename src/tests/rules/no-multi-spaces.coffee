###*
# @fileoverview tests for checking multiple spaces.
# @author Vignesh Anand aka vegetableman
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-multi-spaces'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-multi-spaces', rule,
  valid: [
    'a = 1'
    'a=1'
    'a = 1; b = 2'
    'arr = [1, 2]'
    'arr = [ (1), (2) ]'
    "obj = {'a': 1, 'b': (2)}"
    'a; b'
    'a >>> b'
    'a ^ b'
    '(a) | (b)'
    'a & b'
    'a << b'
    'a isnt b'
    'a >>>= b'
    'if a & b then ;'
    'foo = (a,b) ->'
    'foo = (a, b) ->'
    'if ( a is 3 && b is 4) then ;'
    'if ( a is 3||b is 4 ) then ;'
    'if ( a <= 4) then ;'
    'foo = if bar is 1 then 2else 3'
    '[1, , 3]'
    '[1, ]'
    '[ ( 1 ) , ( 2 ) ]'
    'a = 1; b = 2'
    '((a, b)->)'
    'x.in = 0'
    '((a,### b, ###c)->)'
    '((a,###b,###c)->)'
    '((a, ###b,###c)->)'
    '((a,###b,### c)->)'
    '((a, ###b,### c)->)'
    '((###a, b, ###c)->)'
    '((###a, ###b, c)->)'
    '((a, b###, c###)->)'
    '((a, b###,c###)->)'
    '((a, b ###,c###)->)'
    '((a###, b ,c###)->)'
    '((a ###, b ,c###)->)'
    '((a ###, b        ,c###)->)'
    '###*\n * hello\n * @param {foo} int hi\n *      set.\n * @private\n###'
    '###*\n * hello\n * @param {foo} int hi\n *      set.\n *      set.\n * @private\n###'
    'a;### b;###c'
    'foo = [1,### 2,###3]'
    'bar = {a: 1,### b: 2###c: 3}'
    'foo = "hello     world"'
    '''
      foo = ->
          return
    '''
    '''
      foo = ->
          if foo
              return
    '''
  ,
    code: 'foo = "hello     world"'
  ,
    '{ a:  b }'
    'a:  b'
  ,
    code: 'answer  = 6 *  7'
    options: [exceptions: AssignmentExpression: yes, BinaryExpression: yes]
  ,
    # https:#github.com/eslint/eslint/issues/7693
    'x = 5 # comment'
    'x = 5 ### multiline\n * comment\n ###'
    'x = 5\n  # comment'
    'x = 5  \n# comment'
    'x = 5\n  ### multiline\n * comment\n ###'
    'x = 5  \n### multiline\n * comment\n ###'
  ,
    code: 'x = 5 # comment', options: [ignoreEOLComments: no]
  ,
    code: 'x = 5 ### multiline\n * comment\n ###'
    options: [ignoreEOLComments: no]
  ,
    code: 'x = 5\n  # comment', options: [ignoreEOLComments: no]
  ,
    code: 'x = 5  \n# comment', options: [ignoreEOLComments: no]
  ,
    code: 'x = 5\n  ### multiline\n * comment\n ###'
    options: [ignoreEOLComments: no]
  ,
    code: 'x = 5  \n### multiline\n * comment\n ###'
    options: [ignoreEOLComments: no]
  ,
    code: 'x = 5  # comment', options: [ignoreEOLComments: yes]
  ,
    code: 'x = 5  ### multiline\n * comment\n ###'
    options: [ignoreEOLComments: yes]
  ,
    code: 'x = 5\n  # comment', options: [ignoreEOLComments: yes]
  ,
    code: 'x = 5  \n# comment', options: [ignoreEOLComments: yes]
  ,
    code: 'x = 5\n  ### multiline\n * comment\n ###'
    options: [ignoreEOLComments: yes]
  ,
    code: 'x = 5  \n### multiline\n * comment\n ###'
    options: [ignoreEOLComments: yes]
  ,
    # https:#github.com/eslint/eslint/issues/9001
    'a'.repeat 2e5

    'foo\t\t+bar'
  ]

  invalid: [
    code: '(a,  b) ->'
    output: '(a, b) ->'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'foo = (a,  b) => {}'
    output: 'foo = (a, b) => {}'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'a =  1'
    output: 'a = 1'
    errors: [
      message: "Multiple spaces found before '1'."
      type: 'Numeric'
    ]
  ,
    code: 'a = 1;  b = 2'
    output: 'a = 1; b = 2'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'a <<  b'
    output: 'a << b'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: "arr = {'a': 1,  'b': 2}"
    output: "arr = {'a': 1, 'b': 2}"
    errors: [
      message: 'Multiple spaces found before \'"b"\'.'
      type: 'String'
    ]
  ,
    code: 'if (a &  b) then ;'
    output: 'if (a & b) then ;'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'if ( a is 3  and  b is 4) then ;'
    output: 'if ( a is 3 and b is 4) then ;'
    errors: [
      message: "Multiple spaces found before 'and'."
      type: 'Punctuator'
    ,
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'foo = if bar is 1 then  2else  3'
    output: 'foo = if bar is 1 then 2else 3'
    errors: [
      message: "Multiple spaces found before '2'."
      type: 'Numeric'
    ,
      message: "Multiple spaces found before '3'."
      type: 'Numeric'
    ]
  ,
    code: 'a = [1,  2,  3,  4]'
    output: 'a = [1, 2, 3, 4]'
    errors: [
      message: "Multiple spaces found before '2'."
      type: 'Numeric'
    ,
      message: "Multiple spaces found before '3'."
      type: 'Numeric'
    ,
      message: "Multiple spaces found before '4'."
      type: 'Numeric'
    ]
  ,
    code: 'arr = [1,  2]'
    output: 'arr = [1, 2]'
    errors: [
      message: "Multiple spaces found before '2'."
      type: 'Numeric'
    ]
  ,
    code: '[  , 1,  , 3,  ,  ]'
    output: '[ , 1, , 3, , ]'
    errors: [
      message: "Multiple spaces found before ','."
      type: 'Punctuator'
    ,
      message: "Multiple spaces found before ','."
      type: 'Punctuator'
    ,
      message: "Multiple spaces found before ','."
      type: 'Punctuator'
    ,
      message: "Multiple spaces found before ']'."
      type: 'Punctuator'
    ]
  ,
    code: 'a >>>  b'
    output: 'a >>> b'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'a = 1;  b =  2'
    output: 'a = 1; b = 2'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ,
      message: "Multiple spaces found before '2'."
      type: 'Numeric'
    ]
  ,
    code: '((a,  b)->)'
    output: '((a, b)->)'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: '(a,  b)->'
    output: '(a, b)->'
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'o = { fetch: ()  -> }'
    output: 'o = { fetch: () -> }'
    errors: [
      message: "Multiple spaces found before '->'."
      type: 'Punctuator'
    ]
  ,
    code: 'if foo  then ;'
    output: 'if foo then ;'
    errors: [
      message: "Multiple spaces found before 'then'."
      type: 'Keyword'
    ]
  ,
    code: 'if    foo then ;'
    output: 'if foo then ;'
    errors: [
      message: "Multiple spaces found before 'foo'."
      type: 'Identifier'
    ]
  ,
    code: '''
      try
      catch    ex
    '''
    output: '''
      try
      catch ex
    '''
    errors: [
      message: "Multiple spaces found before 'ex'."
      type: 'Identifier'
    ]
  ,
    code: 'throw  error'
    output: 'throw error'
    errors: [
      message: "Multiple spaces found before 'error'."
      type: 'Identifier'
    ]
  ,
    code: '-> return      bar'
    output: '-> return bar'
    errors: [
      message: "Multiple spaces found before 'bar'."
      type: 'Identifier'
    ]
  ,
    code: '''
      switch   a
        when 1 then 2
    '''
    output: '''
      switch a
        when 1 then 2
    '''
    errors: [
      message: "Multiple spaces found before 'a'."
      type: 'Identifier'
    ]
  ,
    code: 'answer = 6 *  7'
    output: 'answer = 6 * 7'
    errors: [
      message: "Multiple spaces found before '7'."
      type: 'Numeric'
    ]
  ,
    code: '({ a:  6  * 7 })'
    output: '({ a:  6 * 7 })'
    errors: [
      message: "Multiple spaces found before '*'."
      type: 'Punctuator'
    ]
  ,
    code: '({ a:   b })'
    output: '({ a: b })'
    options: [exceptions: Property: no]
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'a:   b'
    output: 'a: b'
    options: [exceptions: Property: no]
    errors: [
      message: "Multiple spaces found before 'b'."
      type: 'Identifier'
    ]
  ,
    code: 'foo = bar: -> 1    + 2'
    output: 'foo = bar: -> 1 + 2'
    errors: [
      message: "Multiple spaces found before '+'."
      type: 'Punctuator'
    ]
  ,
    code: '\t\tx = 5;\n\t\ty =  2'
    output: '\t\tx = 5;\n\t\ty = 2'
    errors: [
      message: "Multiple spaces found before '2'."
      type: 'Numeric'
    ]
  ,
    code: 'x =\t  5'
    output: 'x = 5'
    errors: [
      message: "Multiple spaces found before '5'."
      type: 'Numeric'
    ]
  ,
    # https:#github.com/eslint/eslint/issues/7693
    code: 'x =  ### comment ### 5'
    output: 'x = ### comment ### 5'
    errors: [
      message: "Multiple spaces found before '### comment ###'."
      type: 'Block'
    ]
  ,
    code: 'x = ### comment ###  5'
    output: 'x = ### comment ### 5'
    errors: [
      message: "Multiple spaces found before '5'."
      type: 'Numeric'
    ]
  ,
    code: 'x = 5  # comment'
    output: 'x = 5 # comment'
    errors: [
      message: "Multiple spaces found before '# comment'."
      type: 'Line'
    ]
  ,
    code: 'x = 5  # comment\ny = 6'
    output: 'x = 5 # comment\ny = 6'
    errors: [
      message: "Multiple spaces found before '# comment'."
      type: 'Line'
    ]
  ,
    code: 'x = 5  ### multiline\n * comment\n ###'
    output: 'x = 5 ### multiline\n * comment\n ###'
    errors: [
      message: "Multiple spaces found before '### multiline...###'."
      type: 'Block'
    ]
  ,
    code: 'x = 5  ### multiline\n * comment\n ###\ny = 6'
    output: 'x = 5 ### multiline\n * comment\n ###\ny = 6'
    errors: [
      message: "Multiple spaces found before '### multiline...###'."
      type: 'Block'
    ]
  ,
    code: 'x = 5  # this is a long comment'
    output: 'x = 5 # this is a long comment'
    errors: [
      message: "Multiple spaces found before '# this is a l...'."
      type: 'Line'
    ]
  ,
    code: 'x =  ### comment ### 5'
    output: 'x = ### comment ### 5'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '### comment ###'."
      type: 'Block'
    ]
  ,
    code: 'x = ### comment ###  5'
    output: 'x = ### comment ### 5'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '5'."
      type: 'Numeric'
    ]
  ,
    code: 'x = 5  # comment'
    output: 'x = 5 # comment'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '# comment'."
      type: 'Line'
    ]
  ,
    code: 'x = 5  # comment\ny = 6'
    output: 'x = 5 # comment\ny = 6'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '# comment'."
      type: 'Line'
    ]
  ,
    code: 'x = 5  ### multiline\n * comment\n ###'
    output: 'x = 5 ### multiline\n * comment\n ###'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '### multiline...###'."
      type: 'Block'
    ]
  ,
    code: 'x = 5  ### multiline\n * comment\n ###\ny = 6'
    output: 'x = 5 ### multiline\n * comment\n ###\ny = 6'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '### multiline...###'."
      type: 'Block'
    ]
  ,
    code: 'x = 5  # this is a long comment'
    output: 'x = 5 # this is a long comment'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '# this is a l...'."
      type: 'Line'
    ]
  ,
    code: 'x =  ### comment ### 5  # EOL comment'
    output: 'x = ### comment ### 5  # EOL comment'
    options: [ignoreEOLComments: yes]
    errors: [
      message: "Multiple spaces found before '### comment ###'."
      type: 'Block'
    ]
  ,
    code: 'x =  ### comment ### 5  # EOL comment\ny = 6'
    output: 'x = ### comment ### 5  # EOL comment\ny = 6'
    options: [ignoreEOLComments: yes]
    errors: [
      message: "Multiple spaces found before '### comment ###'."
      type: 'Block'
    ]
  ,
    code: 'x = ### comment ###  5  ### EOL comment ###'
    output: 'x = ### comment ### 5  ### EOL comment ###'
    options: [ignoreEOLComments: yes]
    errors: [
      message: "Multiple spaces found before '5'."
      type: 'Numeric'
    ]
  ,
    code: 'x = ### comment ###  5  ### EOL comment ###\ny = 6'
    output: 'x = ### comment ### 5  ### EOL comment ###\ny = 6'
    options: [ignoreEOLComments: yes]
    errors: [
      message: "Multiple spaces found before '5'."
      type: 'Numeric'
    ]
  ,
    code: 'x =  ###comment without spaces### 5'
    output: 'x = ###comment without spaces### 5'
    options: [ignoreEOLComments: yes]
    errors: [
      message: "Multiple spaces found before '###comment with...###'."
      type: 'Block'
    ]
  ,
    code: 'x = 5  #comment without spaces'
    output: 'x = 5 #comment without spaces'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '#comment with...'."
      type: 'Line'
    ]
  ,
    code: 'x = 5  ###comment without spaces###'
    output: 'x = 5 ###comment without spaces###'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '###comment with...###'."
      type: 'Block'
    ]
  ,
    code: 'x = 5  ###comment\n without spaces###'
    output: 'x = 5 ###comment\n without spaces###'
    options: [ignoreEOLComments: no]
    errors: [
      message: "Multiple spaces found before '###comment...###'."
      type: 'Block'
    ]
  ,
    code: '\ffoo\n\fbar  + baz'
    output: '\ffoo\n\fbar + baz'
    errors: [
      message: "Multiple spaces found before '+'."
      type: 'Punctuator'
    ]
  ]
