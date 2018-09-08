###*
# @fileoverview Tests for no-eval rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-eval'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-eval', rule,
  valid: [
    'Eval(foo)'
    'Eval foo'
    "setTimeout('foo')"
    "setInterval('foo')"
    "window.setTimeout('foo')"
    "window.setInterval('foo')"

    # User-defined eval methods.
    "window.eval('foo')"
  ,
    code: "window.eval('foo')", env: node: yes
  ,
    code: "window.noeval('foo')", env: browser: yes
  ,
    "global.eval('foo')"
  ,
    code: "global.eval('foo')", env: browser: yes
  ,
    code: "global.noeval('foo')", env: node: yes
  ,
    "this.noeval('foo')"
    "@noeval 'foo'"
    """
      foo = ->
        'use strict'
        @eval('foo')
    """
  ,
    code: """
      foo = -> this.eval('foo')
    """
  ,
    """
      obj = {
        foo: -> this.eval('foo')
      }
    """
    """
      obj = {}
      obj.foo = -> this.eval('foo')
    """
    '''
      class A
        foo: -> this.eval()
    '''
    '''
      class A
        @foo: -> this.eval()
    '''
  ,
    # Allows indirect eval
    code: "(0; eval)('foo')", options: [allowIndirect: yes]
  ,
    code: "(0; window.eval)('foo')"
    options: [allowIndirect: yes]
    env: browser: yes
  ,
    code: "(0; window['eval'])('foo')"
    options: [allowIndirect: yes]
    env: browser: yes
  ,
    code: """
      EVAL = eval
      EVAL('foo')
    """
    options: [allowIndirect: yes]
  ,
    code: """
      EVAL = @eval
      EVAL('foo')
    """
    options: [allowIndirect: yes]
  ,
    code: """
      ((exe) -> exe('foo'))(eval)
    """
    options: [allowIndirect: yes]
  ,
    code: """
      do (exe = eval) -> exe('foo')
    """
    options: [allowIndirect: yes]
  ,
    code: "window.eval('foo')"
    options: [allowIndirect: yes]
    env: browser: yes
  ,
    code: "window.window.eval('foo')"
    options: [allowIndirect: yes]
    env: browser: yes
  ,
    code: "window.window['eval']('foo')"
    options: [allowIndirect: yes]
    env: browser: yes
  ,
    code: "global.eval('foo')", options: [allowIndirect: yes], env: node: yes
  ,
    code: "global.global.eval('foo')"
    options: [allowIndirect: yes]
    env: node: yes
  ,
    code: "this.eval('foo')", options: [allowIndirect: yes]
  ,
    code: """
      foo = -> this.eval('foo')
    """
    options: [allowIndirect: yes]
  ]

  invalid: [
    # Direct eval
    code: 'eval(foo)'
    errors: [messageId: 'unexpected', type: 'CallExpression']
  ,
    code: "eval('foo')"
    errors: [messageId: 'unexpected', type: 'CallExpression']
  ,
    code: 'eval(foo)'
    options: [allowIndirect: yes]
    errors: [messageId: 'unexpected', type: 'CallExpression']
  ,
    code: "eval('foo')"
    options: [allowIndirect: yes]
    errors: [messageId: 'unexpected', type: 'CallExpression']
  ,
    # Indirect eval
    code: "(0; eval)('foo')"
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: "(0; window.eval)('foo')"
    errors: [messageId: 'unexpected', type: 'MemberExpression']
    env: browser: yes
  ,
    code: "(0; window['eval'])('foo')"
    errors: [messageId: 'unexpected', type: 'MemberExpression']
    env: browser: yes
  ,
    code: """
      EVAL = eval
      EVAL 'foo'
    """
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    # ,
    #   code: """
    #     EVAL = @eval
    #     EVAL('foo')
    #   """
    #   errors: [messageId: 'unexpected', type: 'MemberExpression']
    code: """
      ((exe) -> exe('foo'))(eval)
    """
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: """
      do (exe = eval) -> exe('foo')
    """
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: "window.eval('foo')"
    errors: [messageId: 'unexpected', type: 'CallExpression']
    env: browser: yes
  ,
    code: "window.window.eval('foo')"
    errors: [messageId: 'unexpected', type: 'CallExpression']
    env: browser: yes
  ,
    code: "window.window['eval']('foo')"
    errors: [messageId: 'unexpected', type: 'CallExpression']
    env: browser: yes
  ,
    code: "global.eval('foo')"
    errors: [messageId: 'unexpected', type: 'CallExpression']
    env: node: yes
  ,
    code: "global.global.eval('foo')"
    errors: [messageId: 'unexpected', type: 'CallExpression']
    env: node: yes
  ,
    code: "global.global['eval']('foo')"
    errors: [messageId: 'unexpected', type: 'CallExpression']
    env: node: yes
    # ,
    #   code: "this.eval('foo')"
    #   errors: [messageId: 'unexpected', type: 'CallExpression']
    # ,
    #   code: "foo = -> this.eval('foo')"
    #   errors: [messageId: 'unexpected', type: 'CallExpression']
  ]
