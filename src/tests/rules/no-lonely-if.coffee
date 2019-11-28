###*
# @fileoverview Tests for no-lonely-if rule.
# @author Brandon Mills
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-lonely-if'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
errors = [
  message: 'Unexpected if as the only statement in an else block.'
  type: 'IfStatement'
]

ruleTester.run 'no-lonely-if', rule,
  # Examples of code that should not trigger the rule
  valid: [
    '''
      if a
        ;
      else if b
        ;
    '''
    '''
      if a
        ;
      else
        if b
          ;
        b
    '''
    'if a then b else if c then d'
    'x = if a then b else if c then d'
  ]

  # Examples of code that should trigger the rule
  invalid: [
    {
      code: '''
        if a
          ;
        else
          if b
            ;
      '''
      # output: '''
      #   if a
      #     ;
      #   else if b
      #       ;
      # '''
      errors
    }
    {
      code: '''
        if a
          foo()
        else
          if b
            bar()
      '''
      # output: '''
      #   if a
      #     foo()
      #   else if b
      #       bar()
      # '''
      errors
    }
    {
      code: '''
        if a
          foo()
        else ### comment ###
          if b
            bar()
      '''
      # output: '''
      #   if a
      #     foo()
      #   else ### comment ### if b
      #       bar()
      # '''
      errors
    }
    {
      code: '''
        if a
          foo()
        else
          ### otherwise, do the other thing ### if b
            bar()
      '''
      # output: null
      errors
    }
    {
      code: '''
        if a
          foo()
        else
          if ### this comment is ok ### b
            bar()
      '''
      # output: '''
      #   if a
      #     foo()
      #   else if ### this comment is ok ### b
      #       bar()
      # '''
      errors
    }
    {
      code: '''
        if a
          foo()
        else
          if b
            bar()
          ### this comment will prevent this test case from being autofixed. ###
      '''
      # output: null
      errors
    }
    {
      code: '''
        if foo
          ;
        else
          if bar then baz()
      '''
      # output: '''
      #   if foo
      #     ;
      #   else if bar then baz()
      # '''
      errors
    }
    {
      # Not fixed; removing the braces would cause a SyntaxError.
      code: '''
        if foo
          ;
        else
          if bar
            baz()
        qux()
      '''
      # output: null
      errors
    }
    {
      code: '''
        if a
          foo()
        else
          if b
            bar()
          else if c
            baz()
          else
            qux()
      '''
      # output:
      #   'if (a) {\n' +
      #   '  foo();\n' +
      #   '} else if (b) {\n' +
      #   '    bar();\n' +
      #   '  } else if (c) {\n' +
      #   '    baz();\n' +
      #   '  } else {\n' +
      #   '    qux();\n' +
      #   '  }'
      errors
    }
  ]
