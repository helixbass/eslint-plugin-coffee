###*
# @fileoverview Tests for no-mixed-operators rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-mixed-operators'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-mixed-operators', rule,
  valid: [
    'a && b && c && d'
    'a and b and c and d'
    'a and b && c and d'
    'a || b || c || d'
    'a or b or c or d'
    'a or b or c || d'
    'a ? b ? c ? d'
    '(a || b) && c && d'
    '(a or b) and c and d'
    'a || (b && c && d)'
    'a or (b and c and d)'
    '(a || b || c) && d'
    '(a or b or c) and d'
    '(a ? b ? c) and d'
    '(a or b or c) ? d'
    'a || b || (c && d)'
    'a or b or (c and d)'
    'a or b or (c ? d)'
    'a ? b ? (c and d)'
    'a + b + c + d'
    'a * b * c * d'
    'a == 0 && b == 1'
    'a is 0 and b is 1'
    'a == 0 || b == 1'
    'a is 0 or b is 1'
  ,
    code: '(a == 0) && (b == 1)'
    options: [groups: [['&&', '==']]]
  ,
    code: '(a is 0) and (b is 1)'
    options: [groups: [['and', 'is']]]
  ,
    code: 'a + b - c * d / e'
    options: [groups: [['&&', '||']]]
  ,
    'a + b - c'
    'a * b / c'
  ,
    code: 'a + b - c'
    options: [allowSamePrecedence: yes]
  ,
    code: 'a * b / c'
    options: [allowSamePrecedence: yes]
  ]
  invalid: [
    code: 'a && b || c'
    errors: [
      column: 3, message: "Unexpected mix of '&&' and '||'."
    ,
      column: 8, message: "Unexpected mix of '&&' and '||'."
    ]
  ,
    code: 'a and b or c'
    errors: [
      column: 3, message: "Unexpected mix of 'and' and 'or'."
    ,
      column: 9, message: "Unexpected mix of 'and' and 'or'."
    ]
  ,
    code: 'a and b ? c'
    errors: [
      column: 3, message: "Unexpected mix of 'and' and '?'."
    ,
      column: 9, message: "Unexpected mix of 'and' and '?'."
    ]
  ,
    code: 'a ? b || c'
    errors: [
      column: 3, message: "Unexpected mix of '?' and '||'."
    ,
      column: 7, message: "Unexpected mix of '?' and '||'."
    ]
  ,
    code: 'a && b > 0 || c'
    options: [groups: [['&&', '||', '>']]]
    errors: [
      column: 3, message: "Unexpected mix of '&&' and '||'."
    ,
      column: 3, message: "Unexpected mix of '&&' and '>'."
    ,
      column: 8, message: "Unexpected mix of '&&' and '>'."
    ,
      column: 12, message: "Unexpected mix of '&&' and '||'."
    ]
  ,

  ,
    code: 'a and b > 0 or c'
    options: [groups: [['and', 'or', '>']]]
    errors: [
      column: 3, message: "Unexpected mix of 'and' and 'or'."
    ,
      column: 3, message: "Unexpected mix of 'and' and '>'."
    ,
      column: 9, message: "Unexpected mix of 'and' and '>'."
    ,
      column: 13, message: "Unexpected mix of 'and' and 'or'."
    ]
  ,
    code: 'a && b > 0 || c'
    options: [groups: [['&&', '||']]]
    errors: [
      column: 3, message: "Unexpected mix of '&&' and '||'."
    ,
      column: 12, message: "Unexpected mix of '&&' and '||'."
    ]
  ,
    code: 'a && b + c - d / e || f'
    options: [groups: [['&&', '||'], ['+', '-', '*', '/']]]
    errors: [
      column: 3, message: "Unexpected mix of '&&' and '||'."
    ,
      column: 12, message: "Unexpected mix of '-' and '/'."
    ,
      column: 16, message: "Unexpected mix of '-' and '/'."
    ,
      column: 20, message: "Unexpected mix of '&&' and '||'."
    ]
  ,
    code: 'a && b + c - d / e || f'
    options: [
      groups: [['&&', '||'], ['+', '-', '*', '/']], allowSamePrecedence: yes
    ]
    errors: [
      column: 3, message: "Unexpected mix of '&&' and '||'."
    ,
      column: 12, message: "Unexpected mix of '-' and '/'."
    ,
      column: 16, message: "Unexpected mix of '-' and '/'."
    ,
      column: 20, message: "Unexpected mix of '&&' and '||'."
    ]
  ,
    code: 'a + b - c'
    options: [allowSamePrecedence: no]
    errors: [
      column: 3, message: "Unexpected mix of '+' and '-'."
    ,
      column: 7, message: "Unexpected mix of '+' and '-'."
    ]
  ,
    code: 'a * b / c'
    options: [allowSamePrecedence: no]
    errors: [
      column: 3, message: "Unexpected mix of '*' and '/'."
    ,
      column: 7, message: "Unexpected mix of '*' and '/'."
    ]
  ]
