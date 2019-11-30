###*
# @fileoverview Tests for complexity rule.
# @author Gyandeep Singh
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/accessor-pairs'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

missingGetterInPropertyDescriptorError =
  messageId: 'missingGetterInPropertyDescriptor'
# setterError = messageId: 'setter'

ruleTester.run 'accessor-pairs', rule,
  valid: [
    'o = { a: 1 }'
    # 'o = {\n get a() {\n return val \n} \n}'
    # 'o = {\n set a(value) {\n val = value \n},\n get a() {\n return val \n} \n}'
    '''
      o = {a: 1}
      Object.defineProperty(o, 'b', {
        set: (value) -> val = value
        get: -> val
      })
    '''
    # ,
    #   code: "expr = 'foo'  o = { set [expr](value) { val = value }, get [expr]() { return val } }"
    # ,
    #   code: 'o = {\n set a(value) {\n val = value \n} \n}'
    #   options: [
    #     setWithoutGet: no
    #   ]
    # https://github.com/eslint/eslint/issues/3262
    'o = set: ->'
    'Object.defineProperties obj, set: value: ->'
    'Object.create null, set: value: ->'
  ,
    code: 'o = get: ->', options: [getWithoutSet: yes]
  ,
    code: 'o = {[set]: ->}'
  ,
    code: '''
      set = 'value'
      Object.defineProperty(obj, 'foo', {[set]: (value) ->})
    '''
  ]
  invalid: [
    # code: 'o = {\n set a(value) {\n val = value \n} \n}'
    # errors: [getterError]
    # ,
    # code: 'o = {\n get a() {\n return val \n} \n}'
    # options: [
    #   getWithoutSet: yes
    # ]
    # errors: [setterError]
    # ,
    code: '''
      o = {d: 1}
      Object.defineProperty o, 'c',
        set: (value) -> val = value
    '''
    errors: [missingGetterInPropertyDescriptorError]
  ,
    code: '''
      Reflect.defineProperty obj, 'foo',
        set: (value) ->
    '''
    errors: [missingGetterInPropertyDescriptorError]
  ,
    code: '''
      Object.defineProperties obj,
        foo:
          set: (value) ->
    '''
    errors: [missingGetterInPropertyDescriptorError]
  ,
    code: '''
      Object.create null,
        foo: set: (value) ->
    '''
    errors: [missingGetterInPropertyDescriptorError]
    # ,
    #   code: "expr = 'foo'  o = { set [expr](value) { val = value } }"
    #   parserOptions: ecmaVersion: 6
    #   errors: [getterError]
  ]
