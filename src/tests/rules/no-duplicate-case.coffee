###*
# @fileoverview Tests for no-duplicate-when rule.
# @author Dieter Oberkofler
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-duplicate-case'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-duplicate-when', rule,
  valid: [
    '''
      a = 1
      switch a
        when 1
          ;
        when 2
          ;
        else
          ;
    '''
    """
      a = 1
      switch a
        when 1
          ;
        when '1'
          ;
        else
          ;
    """
    '''
      a = 1
      switch a
        when 1
          ;
        when yes
          ;
        else
          ;
    '''
    '''
      a = 1
      p = {p: {p1: 1, p2: 1}}
      switch a
        when p.p.p1
          ;
        when p.p.p2
          ;
        else
          ;
    '''
    '''
      a = 1
      f = (b) ->
        if b then { p1: 1 } else { p1: 2 }
      switch a
        when f(true).p1
          ;
        when f(true, false).p1
          ;
        else
          ;
    '''
    '''
      a = 1
      f = (s) -> { p1: s }
      switch a
        when f(a + 1).p1
          ;
        when f(a + 2).p1
          ;
        else
          ;
    '''
    '''
      a = 1
      f = (s) -> p1: s
      switch a
        when f(if a == 1 then 2 else 3).p1
          ;
        when f(if a is 1 then 2 else 3).p1
          ;
        else
          ;
    '''
    '''
      a = 1
      f1 = -> p1: 1
      f2 = -> p1: 2
      switch a
        when f1().p1
          ;
        when f2().p1
          ;
        else
          ;
    '''
    '''
      a = [1,2]
      switch a.toString()
        when ([1,2]).toString()
          ;
        when ([1]).toString()
          ;
        else
          ;
    '''
  ]
  invalid: [
    code: '''
      a = 1
      switch a
        when 1
          ;
        when 1
          ;
        when 2
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      switch a
        when 1, 1
          ;
        when 2
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      switch a
        when 1
          ;
        when 2, 1
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: """
      a = '1'
      switch a
        when '1'
          ;
        when '1'
          ;
        when '2'
          ;
        else
          ;
    """
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      one = 1
      switch a
        when one
          ;
        when one
          ;
        when 2
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      p = {p: {p1: 1, p2: 1}}
      switch a
        when p.p.p1
          ;
        when p.p.p1
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      f = (b) ->
        if b then { p1: 1 } else { p1: 2 }
      switch a
        when f(true).p1
          ;
        when f(true).p1
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      f = (s) -> p1: s
      switch a
        when f(a + 1).p1
          ;
        when f(a + 1).p1
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      f = (s) -> p1: s
      switch a
        when f(if a is 1 then 2 else 3).p1
          ;
        when f(if a is 1 then 2 else 3).p1
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = 1
      f1 = -> p1: 1
      switch a
        when f1().p1
          ;
        when f1().p1
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ,
    code: '''
      a = [1, 2]
      switch a.toString()
        when ([1, 2]).toString()
          ;
        when ([1, 2]).toString()
          ;
        else
          ;
    '''
    errors: [
      messageId: 'unexpected'
      type: 'SwitchCase'
    ]
  ]
