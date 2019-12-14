###*
# @fileoverview Enforces that an assignment as the body of a postfix comprehension is wrapped in parens
# @author Julian Rosse
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/postfix-comprehension-assign-parens'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'postfix-comprehension-assign-parens', rule,
  valid: [
    'x = (y for y in z)'
    '''
      x =
        y for y in z
    '''
    '(x = y) for val in list'
    '(x = y) for key, val in list'
    '(x = y) for key of obj'
    '(x = y) for val from list'
    '''
      for x in xlist
        console.log x
    '''
    "yak(food) for food in foods when food isnt 'chocolate'"
    "eat food for food in foods when food isnt 'chocolate'"
    'myLines = -> row[start] + "!" for row in [start..end]'
    '''
      myLines = ->
        row[start] + "!" for row in [start..end]
    '''
    "b = a(food for food in foods when food isnt 'chocolate')"
    '((transform(col) for cols, col of rows) for rows in mtx)'
  ]
  invalid: [
    code: 'x[key] = val for key, val of z'
    output: '(x[key] = val) for key, val of z'
  ,
    code: 'x += y for y from z'
    output: '(x += y) for y from z'
  ,
    code: 'doubleIt = x * 2 for x in singles'
    output: '(doubleIt = x * 2) for x in singles'
  ,
    code: "x = y(food) for food in foods when food isnt 'chocolate'"
    output: "(x = y(food)) for food in foods when food isnt 'chocolate'"
  ,
    code: 'matrix3 = k for k,v in mtx'
    output: '(matrix3 = k) for k,v in mtx'
  ].map (test) ->
    {
      ...test
      errors: [
        messageId: 'missingParens'
        type: 'AssignmentExpression'
      ]
    }
