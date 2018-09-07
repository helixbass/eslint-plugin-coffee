###*
# @fileoverview Tests for no-global-assign rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-global-assign'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-global-assign', rule,
  valid: [
    "string = 'hello world'"
    'string'
  ,
    code: 'Object = 0', options: [exceptions: ['Object']]
  ,
    'top = 0'
  ,
    code: 'onload = 0', env: browser: yes
  ,
    'require = 0'
  ,
    code: 'a = 1', globals: a: yes
  ,
    '###global a:true### a = 1'
  ]
  invalid: [
    # code: "String = 'hello world'"
    # errors: [
    #   message: "Read-only global 'String' should not be modified."
    #   type: 'Identifier'
    # ]
    code: 'String++'
    errors: [
      message: "Read-only global 'String' should not be modified."
      type: 'Identifier'
    ]
  ,
    # ,
    #   code: '{Object = 0, String = 0} = {}'
    #   errors: [
    #     message: "Read-only global 'Object' should not be modified."
    #     type: 'Identifier'
    #   ,
    #     message: "Read-only global 'String' should not be modified."
    #     type: 'Identifier'
    #   ]
    # ,
    #   code: 'top = 0'
    #   errors: [
    #     message: "Read-only global 'top' should not be modified."
    #     type: 'Identifier'
    #   ]
    #   env: browser: yes
    # ,
    #   code: 'require = 0'
    #   errors: [
    #     message: "Read-only global 'require' should not be modified."
    #     type: 'Identifier'
    #   ]
    #   env: node: yes
    # ,
    #   # Notifications of readonly are moved from no-undef: https://github.com/eslint/eslint/issues/4504
    #   code: '###global b:false### f = -> b = 1'
    #   errors: [
    #     message: "Read-only global 'b' should not be modified."
    #     type: 'Identifier'
    #   ]
    # ,
    #   code: 'f = -> b = 1'
    #   errors: [
    #     message: "Read-only global 'b' should not be modified."
    #     type: 'Identifier'
    #   ]
    #   globals: b: no
    code: '###global b:false### f = -> b++'
    errors: [
      message: "Read-only global 'b' should not be modified."
      type: 'Identifier'
    ]
    # ,
    #   code: '###global b### b = 1'
    #   errors: [
    #     message: "Read-only global 'b' should not be modified."
    #     type: 'Identifier'
    #   ]
    # ,
    #   code: 'Array = 1'
    #   errors: [
    #     message: "Read-only global 'Array' should not be modified."
    #     type: 'Identifier'
    #   ]
  ]
