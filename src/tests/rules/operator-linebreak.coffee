###*
# @fileoverview Operator linebreak rule tests
# @author Benoît Zugmeyer
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

util = require 'util'
rule = require '../../rules/operator-linebreak'
path = require 'path'
{RuleTester} = require 'eslint'

# BAD_LN_BRK_MSG = "Bad line breaking before and after '%s'."
# BEFORE_MSG = "'%s' should be placed at the beginning of the line."
# AFTER_MSG = "'%s' should be placed at the end of the line."
NONE_MSG = "There should be no line break before or after '%s'."

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'operator-linebreak', rule,
  valid: [
    '1 + 1'
    '1 + 1 + 1'
    '1 +\n1'
    '1 + (1 +\n1)'
    'f(1 +\n1)'
    '1 || 1'
    '1 || \n1'
    '1 ? 1'
    '1 ? \n1'
    'a += 1'
    'a'
    'o = \nsomething'
    'o = \nsomething'
    "'a\\\n' +\n 'c'"
    "'a' +\n 'b\\\n'"
    '(a\n) + b'
    '''
      answer =
        if everything
          42
        else
          foo
    '''
  ,
    code: '''
      answer = if everything
          42
        else
          foo
    '''
    options: ['none']
  ,
    code: 'a += 1', options: ['before']
  ,
    code: '1 + 1', options: ['none']
  ,
    code: '1 + 1 + 1', options: ['none']
  ,
    code: '1 || 1', options: ['none']
  ,
    code: 'a += 1', options: ['none']
  ,
    code: 'a', options: ['none']
  ,
    code: '\n1 + 1', options: ['none']
  ,
    code: '1 + 1\n', options: ['none']
  ]

  invalid: [
    # code: '1 \n || 1'
    # output: '1 || \n 1'
    # errors: [
    #   message: util.format AFTER_MSG, '||'
    #   type: 'LogicalExpression'
    #   line: 2
    #   column: 4
    # ]
    # ,
    # code: '1 || \n 1'
    # output: '1 \n || 1'
    # options: ['before']
    # errors: [
    #   message: util.format BEFORE_MSG, '||'
    #   type: 'LogicalExpression'
    #   line: 1
    #   column: 5
    # ]
    # ,
    code: '1 +\n1'
    # output: '1 +1'
    options: ['none']
    errors: [
      message: util.format NONE_MSG, '+'
      type: 'BinaryExpression'
      line: 1
      column: 4
    ]
  ,
    code: 'f(1 +\n1)'
    # output: 'f(1 +1)'
    options: ['none']
    errors: [
      message: util.format NONE_MSG, '+'
      type: 'BinaryExpression'
      line: 1
      column: 6
    ]
  ,
    code: '1 || \n 1'
    # output: '1 ||  1'
    options: ['none']
    errors: [
      message: util.format NONE_MSG, '||'
      type: 'LogicalExpression'
      line: 1
      column: 5
    ]
  ,
    code: '1 or \n 1'
    # output: '1 ||  1'
    options: ['none']
    errors: [
      message: util.format NONE_MSG, 'or'
      type: 'LogicalExpression'
      line: 1
      column: 5
    ]
  ,
    # ,
    #   code: '1 \n || 1'
    #   # output: '1  || 1'
    #   options: ['none']
    #   errors: [
    #     message: util.format NONE_MSG, '||'
    #     type: 'LogicalExpression'
    #     line: 2
    #     column: 4
    #   ]
    code: 'a += \n1'
    # output: 'a += 1'
    options: ['none']
    errors: [
      message: util.format NONE_MSG, '+='
      type: 'AssignmentExpression'
      line: 1
      column: 5
    ]
  ,
    code: 'a = \n1'
    # output: 'a = 1'
    options: ['none']
    errors: [
      message: util.format NONE_MSG, '='
      type: 'AssignmentExpression'
      line: 1
      column: 4
    ]
  ,
    code: 'foo +=\n42\nbar -=\n12'
    # output: 'foo +=42\nbar -=\n12\n+ 5'
    options: ['after', {overrides: '+=': 'none'}]
    errors: [
      message: util.format NONE_MSG, '+='
      type: 'AssignmentExpression'
      line: 1
      column: 7
    ]
    # ,
    #   code: 'foo #comment\n&& bar'
    #   # output: 'foo && #comment\nbar'
    #   errors: [
    #     message: util.format AFTER_MSG, '&&'
    #     type: 'LogicalExpression'
    #     line: 2
    #     column: 3
    #   ]
    # ,
    #   code: 'foo #comment\nand bar'
    #   # output: 'foo && #comment\nbar'
    #   errors: [
    #     message: util.format AFTER_MSG, 'and'
    #     type: 'LogicalExpression'
    #     line: 2
    #     column: 3
    #   ]
  ]
