###*
# @fileoverview Tests for the no-new-symbol rule
# @author Alberto Rodríguez
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-new-symbol'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester(
  parser: path.join(__dirname, '../../..'), env: es6: yes
)

ruleTester.run 'no-new-symbol', rule,
  valid: [
    "foo = Symbol('foo')"
    "(Symbol) -> baz = new Symbol 'baz'"
    '''
      Symbol = ->
      new Symbol()
    '''
  ]
  invalid: [
    code: "foo = new Symbol('foo')"
    errors: [message: '`Symbol` cannot be called as a constructor.']
  ,
    code: '''
      ->
        Symbol = ->
      baz = new Symbol('baz')
    '''
    errors: [message: '`Symbol` cannot be called as a constructor.']
  ]
