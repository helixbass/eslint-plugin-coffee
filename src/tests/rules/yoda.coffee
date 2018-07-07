###*
# @fileoverview Tests for yoda rule.
# @author Raphael Pigulla
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------
rule = require '../../rules/yoda'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'yoda', rule,
  valid: [
    # "never" mode
    code: 'if (value is "red") then ;', options: ['never']
  ,
    code: 'if (value is value) then ;', options: ['never']
  ,
    code: 'if (value != 5) then ;', options: ['never']
  ,
    code: 'if (5 & foo) then ;', options: ['never']
  ,
    code: 'if (5 is 4) then ;', options: ['never']
  ,

    # "always" mode
    code: 'if ("blue" is value) then ;', options: ['always']
  ,
    code: 'if (value is value) then ;', options: ['always']
  ,
    code: 'if (4 != value) then ;', options: ['always']
  ,
    code: 'if (foo & 4) then ;', options: ['always']
  ,
    code: 'if (5 is 4) then ;', options: ['always']
  ,

    # Range exception
    code: 'if (0 < x && x <= 1) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (0 < x and x <= 1) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (x < 0 || 1 <= x) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (x < 0 or 1 <= x) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (0 <= x && x < 1) then ;'
    options: ['always', {exceptRange: yes}]
  ,
    code: "if (x <= 'bar' || 'foo' < x) then ;"
    options: ['always', {exceptRange: yes}]
  ,
    code: "if ('blue' < x.y && x.y < 'green') then ;"
    options: ['never', {exceptRange: yes}]
  ,
    code: "if (0 <= x['y'] && x['y'] <= 100) then ;"
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (a < 0 && (0 < b && b < 1)) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if ((0 < a && a < 1) && b < 0) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: "if (a < 4 || (b[c[0]].d['e'] < 0 || 1 <= b[c[0]].d['e'])) then ;"
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (-1 < x && x < 0) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (0 <= this.prop && this.prop <= 1) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (0 <= index && index < list.length) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (ZERO <= index && index < 100) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (value <= MIN || 10 < value) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (value <= 0 || MAX < value) then ;'
    options: ['never', {exceptRange: yes}]
  ,
    code: 'if (0 <= a.b && a["b"] <= 100) then ;'
    options: ['never', {exceptRange: yes}]
  ,

    # onlyEquality
    code: 'if (0 < x && x <= 1) then ;', options: ['never', {onlyEquality: yes}]
  ,
    code: "if (x isnt 'foo' && 'foo' isnt x) then ;"
    options: ['never', {onlyEquality: yes}]
  ,
    code: 'if (x < 2 && x isnt -3) then ;'
    options: ['always', {onlyEquality: yes}]
  ]
  invalid: [
    code: 'if ("red" == value) then ;'
    output: 'if (value == "red") then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of ==.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (true is value) then ;'
    output: 'if (value is true) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (5 != value) then ;'
    output: 'if (value != 5) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of !=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (null isnt value) then ;'
    output: 'if (value isnt null) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of isnt.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if ("red" <= value) then ;'
    output: 'if (value >= "red") then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (true >= value) then ;'
    output: 'if (value <= true) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of >=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'foo = (5 < value) ? true : false'
    output: 'foo = (value > 5) ? true : false'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of <.'
      type: 'BinaryExpression'
    ]
  ,
    code: '-> return (null > value)'
    output: '-> return (value < null)'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of >.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (-1 < str.indexOf(substr)) then ;'
    output: 'if (str.indexOf(substr) > -1) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of <.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (value == "red") then ;'
    output: 'if ("red" == value) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of ==.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (value is true) then ;'
    output: 'if (true is value) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (a < 0 && 0 <= b && b < 1) then ;'
    output: 'if (a < 0 && b >= 0 && b < 1) then ;'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (0 <= a && a < 1 && b < 1) then ;'
    output: 'if (a >= 0 && a < 1 && b < 1) then ;'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (1 < a && a < 0) then ;'
    output: 'if (a > 1 && a < 0) then ;'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <.'
      type: 'BinaryExpression'
    ]
  ,
    code: '0 < a && a < 1'
    output: 'a > 0 && a < 1'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'a = b < 0 || 1 <= b'
    output: 'a = b < 0 || b >= 1'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (0 <= x && x < -1) then ;'
    output: 'if (x >= 0 && x < -1) then ;'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'a = (b < 0 && 0 <= b)'
    output: 'a = (0 > b && 0 <= b)'
    options: ['always', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the left side of <.'
      type: 'BinaryExpression'
    ]
  ,
    code: "if (0 <= a[b] && a['b'] < 1) then ;"
    output: "if (a[b] >= 0 && a['b'] < 1) then ;"
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (0 <= a[b] && a.b < 1) then ;'
    output: 'if (a[b] >= 0 && a.b < 1) then ;'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (0 <= a[b()] && a[b()] < 1) then ;'
    output: 'if (a[b()] >= 0 && a[b()] < 1) then ;'
    options: ['never', {exceptRange: yes}]
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (3 == a) then ;'
    output: 'if (a == 3) then ;'
    options: ['never', {onlyEquality: yes}]
    errors: [
      message: 'Expected literal to be on the right side of ==.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'foo(3 is a)'
    output: 'foo(a is 3)'
    options: ['never', {onlyEquality: yes}]
    errors: [
      message: 'Expected literal to be on the right side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'foo(a is 3)'
    output: 'foo(3 is a)'
    options: ['always', {onlyEquality: yes}]
    errors: [
      message: 'Expected literal to be on the left side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (0 <= x && x < 1) then ;'
    output: 'if (x >= 0 && x < 1) then ;'
    errors: [
      message: 'Expected literal to be on the right side of <=.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if ( ### a ### 0 ### b ### < ### c ### foo ### d ### ) then ;'
    output: 'if ( ### a ### foo ### b ### > ### c ### 0 ### d ### ) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of <.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if ( ### a ### foo ### b ### > ### c ### 0 ### d ### ) then ;'
    output: 'if ( ### a ### 0 ### b ### < ### c ### foo ### d ### ) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of >.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (foo() is 1) then ;'
    output: 'if (1 is foo()) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (foo()     is 1) then ;'
    output: 'if (1     is foo()) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of is.'
      type: 'BinaryExpression'
    ]
  ,

    # https://github.com/eslint/eslint/issues/7326
    code: 'while (0 is (a)) then ;'
    output: 'while ((a) is 0) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'while (0 is (a = b)) then ;'
    output: 'while ((a = b) is 0) then ;'
    options: ['never']
    errors: [
      message: 'Expected literal to be on the right side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'while ((a) is 0) then ;'
    output: 'while (0 is (a)) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'while ((a = b) is 0) then ;'
    output: 'while (0 is (a = b)) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of is.'
      type: 'BinaryExpression'
    ]
  ,
    code: 'if (((((((((((foo)))))))))) is ((((((5))))))) then ;'
    output: 'if (((((((5)))))) is ((((((((((foo))))))))))) then ;'
    options: ['always']
    errors: [
      message: 'Expected literal to be on the left side of is.'
      type: 'BinaryExpression'
    ]
  ]
