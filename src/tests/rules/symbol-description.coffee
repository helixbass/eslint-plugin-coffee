###*
# @fileoverview Tests for symbol-description rule.
# @author Jarek Rencz
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/symbol-description'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join(__dirname, '../../..'), env: es6: yes

ruleTester.run 'symbol-description', rule,
  valid: [
    'Symbol("Foo")'
    '''
      foo = "foo"
      Symbol(foo)
    '''

    # Ignore if it's shadowed.
    '''
      Symbol = ->
      Symbol()
    '''
    '''
      Symbol()
      Symbol = ->
    '''
    '''
      ->
        Symbol = ->
        Symbol()
    '''

    # Ignore if it's an argument.
    '(Symbol) -> Symbol()'
  ]

  invalid: [
    code: 'Symbol()'
    errors: [
      message: 'Expected Symbol to have a description.'
      type: 'CallExpression'
    ]
  ]
