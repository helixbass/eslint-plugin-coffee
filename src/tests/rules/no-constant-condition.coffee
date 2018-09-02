###*
# @fileoverview Tests for no-constant-condition rule.
# @author Christian Schulz <http://rndm.de>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-constant-condition'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-constant-condition', rule,
  valid: [
    'if a then ;'
    'if (a == 0) then ;'
    'if (a = f()) then ;'
    'if (1; a) then ;'
    "if ('every' of []) then ;"
    'while (~!a) then ;'
    'while (a = b) then ;'
    'if q > 0 then 1 else 2'
    'while (x += 3) then ;'

    # #5228, typeof conditions
    "if typeof x is 'undefined' then ;"
    "if a is 'str' and typeof b then ;"
    'typeof a == typeof b'
    "typeof 'a' is 'string' or typeof b is 'string'"

    # #5693
    "if (xyz is 'str1' && abc is 'str2') then ;"
    "if (xyz is 'str1' || abc is 'str2') then ;"
    "if (xyz is 'str1' || abc is 'str2' && pqr is 5) then ;"
    "if (typeof abc is 'string' && abc is 'str2') then ;"
    "if (false || abc is 'str') then ;"
    "if (true && abc is 'str') then ;"
    "if (typeof 'str' && abc is 'str') then ;"
    "if (abc is 'str' || no || def is 'str') then ;"
    "if (true && abc is 'str' || def is 'str') then ;"
    "if (yes && typeof abc is 'string') then ;"
  ,
    # { checkLoops: false }
    code: 'while (true) then ;', options: [checkLoops: no]
  ,
    code: 'loop then ;', options: [checkLoops: no]
  ,
    """
      foo = ->
        while true
          yield 'foo'
    """
    '''
      foo = ->
        while yes
          while true
            yield
    '''
    '''
      foo = ->
        while true
          -> yield
          yield
    '''
  ]
  invalid: [
    code: 'if true then 1 else 2'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'if yes then 1 else 2'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'if q = 0 then 1 else 2'
    errors: [messageId: 'unexpected', type: 'AssignmentExpression']
  ,
    code: 'if (q = 0) then 1 else 2'
    errors: [messageId: 'unexpected', type: 'AssignmentExpression']
  ,
    code: 'if (-2) then ;'
    errors: [messageId: 'unexpected', type: 'UnaryExpression']
  ,
    code: 'if (true) then ;'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'if ({}) then ;'
    errors: [messageId: 'unexpected', type: 'ObjectExpression']
  ,
    code: 'if (0 < 1) then ;'
    errors: [messageId: 'unexpected', type: 'BinaryExpression']
  ,
    code: 'if (0 || 1) then ;'
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: 'if (0 ? 1) then ;'
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: 'if (a; 1) then ;'
    errors: [messageId: 'unexpected', type: 'SequenceExpression']
  ,
    code: 'while ([]) then ;'
    errors: [messageId: 'unexpected', type: 'ArrayExpression']
  ,
    code: 'while (~!0) then ;'
    errors: [messageId: 'unexpected', type: 'UnaryExpression']
  ,
    code: 'while (x = 1) then ;'
    errors: [messageId: 'unexpected', type: 'AssignmentExpression']
  ,
    code: 'while (->) then ;'
    errors: [messageId: 'unexpected', type: 'FunctionExpression']
  ,
    code: 'while (true) then ;'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'loop then ;', errors: [messageId: 'unexpected', type: 'Literal']
  ,
    # #5228 , typeof conditions
    code: 'if (typeof x) then ;'
    errors: [messageId: 'unexpected', type: 'UnaryExpression']
  ,
    code: "if (typeof 'abc' is 'string') then ;"
    errors: [messageId: 'unexpected', type: 'BinaryExpression']
  ,
    code: 'if (a = typeof b) then ;'
    errors: [messageId: 'unexpected', type: 'AssignmentExpression']
  ,
    code: 'if (a; typeof b) then ;'
    errors: [messageId: 'unexpected', type: 'SequenceExpression']
  ,
    code: "if (typeof 'a' == 'string' or typeof 'b' == 'string') then ;"
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: 'while (typeof x) then ;'
    errors: [messageId: 'unexpected', type: 'UnaryExpression']
  ,
    # #5693
    code: "if (no and abc is 'str') then ;"
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: "if (true || abc is 'str') then ;"
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: "if (abc is 'str' || true) then ;"
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: "if (abc is 'str' || true || def is 'str') then ;"
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: 'if (no ? yes) then ;'
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: "if (typeof abc is 'str' || true) then ;"
    errors: [messageId: 'unexpected', type: 'LogicalExpression']
  ,
    code: """
      ->
        while (true)
          ;
        yield 'foo'
    """
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: """
      ->
        loop
          yield 'foo' if true
    """
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: """
      ->
        while true
          yield 'foo'
        while true
          ;
    """
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: """
      a = ->
        while true
          ;
        yield 'foo'
    """
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: '''
      while true
        -> yield
    '''
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: """
      ->
        yield 'foo' if yes
    """
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: '''
      foo = ->
        while true
          bar = ->
            while true
              yield
    '''
    errors: [messageId: 'unexpected', type: 'Literal']
  ]
