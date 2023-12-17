###*
# @fileoverview Tests for new-parens rule.
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/new-parens'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'new-parens', rule,
  valid: [
    'a = new Date()'
    'a = new Date(() ->)'
    'a = new (Date)()'
    'a = new ((Date))()'
    'a = (new Date())'
    'a = new foo.Bar()'
    'a = (new Foo()).bar'
  ]
  invalid: [
    code: 'a = new Date'
    output: 'a = new Date()'
    errors: [
      message: "Missing '()' invoking a constructor.", type: 'NewExpression'
    ]
  ,
    code: 'a = new Date'
    output: 'a = new Date()'
    errors: [
      message: "Missing '()' invoking a constructor.", type: 'NewExpression'
    ]
  ,
    code: 'a = new (Date)'
    output: 'a = new (Date)()'
    errors: [
      message: "Missing '()' invoking a constructor.", type: 'NewExpression'
    ]
  ,
    code: 'a = new (Date)'
    output: 'a = new (Date)()'
    errors: [
      message: "Missing '()' invoking a constructor.", type: 'NewExpression'
    ]
  ,
    code: 'a = (new Date)'
    output: 'a = (new Date())'
    errors: [
      message: "Missing '()' invoking a constructor."
      type: 'NewExpression'
    ]
  ,
    # This `()` is `CallExpression`'s. This is a call of the result of `new Date`.
    code: 'a = (new Date)()'
    output: 'a = (new Date())()'
    errors: [
      message: "Missing '()' invoking a constructor.", type: 'NewExpression'
    ]
  ,
    code: 'a = new foo.Bar'
    output: 'a = new foo.Bar()'
    errors: [
      message: "Missing '()' invoking a constructor.", type: 'NewExpression'
    ]
  ,
    code: 'a = (new Foo).bar'
    output: 'a = (new Foo()).bar'
    errors: [
      message: "Missing '()' invoking a constructor.", type: 'NewExpression'
    ]
  ]
