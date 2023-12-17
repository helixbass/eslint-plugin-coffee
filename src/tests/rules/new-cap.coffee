###*
# @fileoverview Tests for new-cap rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/new-cap'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'new-cap', rule,
  valid: [
    'x = new Constructor()'
    'x = new a.b.Constructor()'
    "x = new a.b['Constructor']()"
    'x = new a.b[Constructor]()'
    'x = new a.b[constructor]()'
    'x = new ->'
    'x = new _'
    'x = new $'
    'x = new Σ'
    'x = new _x'
    'x = new $x'
    'x = new this'
    'x = Array(42)'
    'x = Boolean(42)'
    'x = Date(42)'
    'x = Date.UTC(2000, 0)'
    "x = Error('error')"
    "x = Function('return 0')"
    'x = Number(42)'
    'x = Object(null)'
    'x = RegExp(42)'
    'x = String(42)'
    "x = Symbol('symbol')"
    'x = _()'
    'x = $()'
  ,
    code: 'x = Foo(42)', options: [capIsNew: no]
  ,
    code: 'x = bar.Foo(42)', options: [capIsNew: no]
  ,
    code: 'x = Foo.bar(42)', options: [capIsNew: no]
  ,
    'x = bar[Foo](42)'
  ,
    code: "x = bar['Foo'](42)", options: [capIsNew: no]
  ,
    'x = Foo.bar(42)'
  ,
    code: 'x = new foo(42)', options: [newIsCap: no]
  ,
    '''
      o = { 1: -> }
      o[1]()
    '''
    '''
      o = { 1: -> }
      new o[1]()
    '''
  ,
    code: 'x = Foo(42)'
    options: [capIsNew: yes, capIsNewExceptions: ['Foo']]
  ,
    code: 'x = Foo(42)', options: [capIsNewExceptionPattern: '^Foo']
  ,
    code: 'x = new foo(42)'
    options: [newIsCap: yes, newIsCapExceptions: ['foo']]
  ,
    code: 'x = new foo(42)', options: [newIsCapExceptionPattern: '^foo']
  ,
    code: 'x = Object(42)', options: [capIsNewExceptions: ['Foo']]
  ,
    code: 'x = Foo.Bar(42)', options: [capIsNewExceptions: ['Bar']]
  ,
    code: 'x = Foo.Bar(42)', options: [capIsNewExceptions: ['Foo.Bar']]
  ,
    code: 'x = Foo.Bar(42)'
    options: [capIsNewExceptionPattern: '^Foo\\..']
  ,
    code: 'x = new foo.bar(42)', options: [newIsCapExceptions: ['bar']]
  ,
    code: 'x = new foo.bar(42)'
    options: [newIsCapExceptions: ['foo.bar']]
  ,
    code: 'x = new foo.bar(42)'
    options: [newIsCapExceptionPattern: '^foo\\..']
  ,
    code: 'x = new foo.bar(42)', options: [properties: no]
  ,
    code: 'x = Foo.bar(42)', options: [properties: no]
  ,
    code: 'x = foo.Bar(42)', options: [capIsNew: no, properties: no]
  ]
  invalid: [
    code: 'x = new c()'
    errors: [
      message: 'A constructor name should not start with a lowercase letter.'
      type: 'NewExpression'
    ]
  ,
    code: 'x = new φ'
    errors: [
      message: 'A constructor name should not start with a lowercase letter.'
      type: 'NewExpression'
    ]
  ,
    code: 'x = new a.b.c'
    errors: [
      message: 'A constructor name should not start with a lowercase letter.'
      type: 'NewExpression'
    ]
  ,
    code: "x = new a.b['c']"
    errors: [
      message: 'A constructor name should not start with a lowercase letter.'
      type: 'NewExpression'
    ]
  ,
    code: 'b = Foo()'
    errors: [
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
      type: 'CallExpression'
    ]
  ,
    code: 'b = a.Foo()'
    errors: [
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
      type: 'CallExpression'
    ]
  ,
    code: "b = a['Foo']()"
    errors: [
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
      type: 'CallExpression'
    ]
  ,
    code: 'b = a.Date.UTC()'
    errors: [
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
      type: 'CallExpression'
    ]
  ,
    code: 'b = UTC()'
    errors: [
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
      type: 'CallExpression'
    ]
  ,
    code: 'a = B.C()'
    errors: [
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
      type: 'CallExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'a = B\n.C()'
    errors: [
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
      type: 'CallExpression'
      line: 2
      column: 2
    ]
  ,
    code: 'a = new B.c()'
    errors: [
      message: 'A constructor name should not start with a lowercase letter.'
      type: 'NewExpression'
      line: 1
      column: 11
    ]
  ,
    code: 'a = new B.\nc()'
    errors: [
      message: 'A constructor name should not start with a lowercase letter.'
      type: 'NewExpression'
      line: 2
      column: 1
    ]
  ,
    code: 'a = new c()'
    errors: [
      message: 'A constructor name should not start with a lowercase letter.'
      type: 'NewExpression'
      line: 1
      column: 9
    ]
  ,
    code: 'x = Foo.Bar(42)'
    options: [capIsNewExceptions: ['Foo']]
    errors: [
      type: 'CallExpression'
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
    ]
  ,
    code: 'x = Bar.Foo(42)'

    options: [capIsNewExceptionPattern: '^Foo\\..']
    errors: [
      type: 'CallExpression'
      message:
        'A function with a name starting with an uppercase letter should only be used as a constructor.'
    ]
  ,
    code: 'x = new foo.bar(42)'
    options: [newIsCapExceptions: ['foo']]
    errors: [
      type: 'NewExpression'
      message: 'A constructor name should not start with a lowercase letter.'
    ]
  ,
    code: 'x = new bar.foo(42)'

    options: [newIsCapExceptionPattern: '^foo\\..']
    errors: [
      type: 'NewExpression'
      message: 'A constructor name should not start with a lowercase letter.'
    ]
  ]
