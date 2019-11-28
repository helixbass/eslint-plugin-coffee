###*
# @fileoverview Tests for no-else-return rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-else-return'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-else-return', rule,
  valid: [
    '''
      foo = ->
        if yes
          if no
            return x
        else
          return y
    '''
    '''
      ->
        if yes
          return x
        return y
    '''
    '''
      ->
        if yes
          loop
            return x
        else
          return y
    '''
    '''
      ->
        x = yes
        if x 
          return x
        else if x is no
          return no
    '''
    '''
      ->
        if yes
          notAReturn()
        else
          return y
    '''
    '''
      ->
        if x
          notAReturn()
        else if y
          return true
        else
          notAReturn()
    '''
    '''
      ->
        if x
          return true
        else if y
          notAReturn()
        else
          notAReturn()
    '''
    '''
      if 0
        if 0
          ;
        else
          ;
      else
        ;
    '''
  ,
    code: '''
      ->
        if true
          return x
        else if false
          return y
    '''
    options: [allowElseIf: yes]
  ,
    code: '''
      ->
        if (x)
          return true
        else if (y)
          notAReturn()
        else
          notAReturn()
    '''
    options: [allowElseIf: yes]
  ,
    code: '''
      ->
        x = true
        if (x)
          return x
        else if (x is false)
          return false
    '''
    options: [allowElseIf: yes]
  ]
  invalid: [
    code: '''
      ->
        if (true)
          return x
        else
          return y
    '''
    # output: 'function foo1() { if (true) { return x; }  return y;  }'
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (true)
          x = bar
          return x
        else
          y = baz
          return y
    '''
    # output:
    #   'function foo2() { if (true) { var x = bar; return x; }  var y = baz; return y;  }'
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (true) then return x else return y
    '''
    # output: 'function foo3() { if (true) return x; return y; }'
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (true)
          if (false)
            return x
          else
            return y
        else
          return z
    '''
    # output:
    #   'function foo4() { if (true) { if (false) return x; return y; } else { return z; } }' # Other case is fixed in the second pass.
    errors: [
      messageId: 'unexpected', type: 'BlockStatement'
    ,
      messageId: 'unexpected', type: 'BlockStatement'
    ]
  ,
    code: '''
      ->
        if (true)
          if (false)
            if (true)
              return x
            else
              w = y
          else
            w = x
        else
          return z
    '''
    # output:
    #   'function foo5() { if (true) { if (false) { if (true) return x;  w = y;  } else { w = x; } } else { return z; } }'
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (true)
          if (false)
            if (true)
              return x
            else
              return y
        else
          return z
    '''
    # output:
    #   'function foo6() { if (true) { if (false) { if (true) return x; return y; } } else { return z; } }'
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (true)
          if (false)
            if (true)
              return x
            else
              return y
          return w
        else
          return z
    '''
    # output:
    #   'function foo7() { if (true) { if (false) { if (true) return x; return y; } return w; } else { return z; } }' # Other case is fixed in the second pass.
    errors: [
      messageId: 'unexpected', type: 'BlockStatement'
    ,
      messageId: 'unexpected', type: 'BlockStatement'
    ]
  ,
    code: '''
      ->
        if (true)
          if (false)
            if (true)
              return x
            else
              return y
          else
            w = x
        else
          return z
    '''
    # output:
    #   'function foo8() { if (true) { if (false) { if (true) return x; return y; } else { w = x; } } else { return z; } }' # Other case is fixed in the second pass.
    errors: [
      messageId: 'unexpected', type: 'BlockStatement'
    ,
      messageId: 'unexpected', type: 'BlockStatement'
    ]
  ,
    code: '''
      ->
        if (x)
          return true
        else if (y)
          return true
        else
          notAReturn()
    '''
    # output:
    #   'function foo9() {if (x) { return true; } else if (y) { return true; }  notAReturn();  }'
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (x)
          return true
        else if (y)
          return true
        else
          notAReturn()
    '''
    # output:
    #   'function foo9a() {if (x) { return true; } if (y) { return true; } else { notAReturn(); } }'
    options: [allowElseIf: no]
    errors: [
      messageId: 'unexpected'
      type: 'IfStatement'
    ,
      messageId: 'unexpected'
      type: 'BlockStatement'
    ]
  ,
    code: '''
      ->
        if (x)
          return true
        if (y)
          return true
        else
          notAReturn()
    '''
    # output:
    #   'function foo9b() {if (x) { return true; } if (y) { return true; }  notAReturn();  }'
    options: [allowElseIf: no]
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (foo)
          return bar
        else
          (foo).bar()
    '''
    # output: 'function foo10() { if (foo) return bar; (foo).bar(); }'
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (foo) then return bar else [1, 2, 3].map(foo)
    '''
    # output: null
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if (true)
          return x
        else if (false)
          return y
    '''
    # output:
    #   'function foo19() { if (true) { return x; } if (false) { return y; } }'
    options: [allowElseIf: no]
    errors: [messageId: 'unexpected', type: 'IfStatement']
  ,
    code: '''
      ->
        if (x)
          return true
        else if (y)
          notAReturn()
        else
          notAReturn()
    '''
    # output:
    #   'function foo20() {if (x) { return true; } if (y) { notAReturn() } else { notAReturn(); } }'
    options: [allowElseIf: no]
    errors: [messageId: 'unexpected', type: 'IfStatement']
  ,
    code: '''
      ->
        x = true
        if (x)
          return x
        else if x is false
          return false
    '''
    # output:
    #   'function foo21() { var x = true; if (x) { return x; } if (x === false) { return false; } }'
    options: [allowElseIf: no]
    errors: [messageId: 'unexpected', type: 'IfStatement']
  ,
    code: '''
      ->
        while foo
          if bar
            return
          else
            baz
    '''
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if foo
          if bar
            return
          else
            baz
        else
          qux
    '''
    errors: [messageId: 'unexpected', type: 'BlockStatement']
  ,
    code: '''
      ->
        if foo
          return
        else
          if bar
            no
    '''
    errors: [messageId: 'unexpected', type: 'IfStatement']
  ]
