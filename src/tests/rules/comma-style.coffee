###*
# @fileoverview Comma style
# @author Vignesh Anand aka vegetableman
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/comma-style'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'comma-style', rule,
  valid: [
    "foo = {'a': 1, 'b': 2}"
    'foo = [1, 2]'
    'foo = [, 2]'
    'foo = [1, ]'
    "foo = ['apples', \n 'oranges']"
    "foo = \n {'a': 1, \n 'b': 2, \n 'c': 3}"
    "foo = \n {'a': 1, \n 'b': 2, 'c': [{'d': 1}, \n {'e': 2}, \n {'f': 3}]}"
    'foo = [1, \n2, \n3]'
    '-> a=[1,\n 2]'
    "-> return {'a': 1,\n'b': 2}"
    'foo = [\n  (bar),\n  baz\n]'
    'foo = [\n  (bar\n  ),\n  baz\n]'
    'foo = [\n  (\n    bar\n  ),\n  baz\n]'
    'new Foo(a\n,b)'
  ,
    code: 'foo = [\n  (bar\n  )\n  ,baz\n]', options: ['first']
  ,
    code: "foo = ['apples'\n,'oranges']", options: ['first']
  ,
    code: "foo = {'a': 1 \n ,'b': 2 \n,'c': 3}", options: ['first']
  ,
    code: 'foo = [1 \n ,2 \n, 3]', options: ['first']
  ,
    code: "-> return {'a': 1\n,'b': 2}", options: ['first']
  ,
    code: '-> a=[1\n, 2]', options: ['first']
  ,
    code: 'new Foo(a,\nb)', options: ['first']
  ,
    'f(1\n, 2)'
    '(a\n, b) -> return a + b'
  ,
    code: "arr = ['a',\n'o']"
    options: ['first', {exceptions: ArrayExpression: yes}]
  ,
    code: "obj = {a: 'a',\nb: 'b'}"
    options: ['first', {exceptions: ObjectExpression: yes}]
  ,
    code: 'ar ={fst:1,\nsnd: [1,\n2]}'
    options: [
      'first'
    ,
      exceptions: ArrayExpression: yes, ObjectExpression: yes
    ]
  ,
    code: 'foo = (a\n, b) => return a + b'
  ,
    code: '([a\n, b]) -> return a + b'
  ,
    code: 'foo = ([a\n, b]) => return a + b'
  ,
    code: "import { a\n, b } from './source'"
  ,
    code: 'foo = (a\n, b) -> return a + b'
  ,
    code: "{foo\n, bar} = {foo:'apples', bar:'oranges'}"
  ,
    code: "{foo\n, bar} = {foo:'apples', bar:'oranges'}"
    options: [
      'first'
    ,
      exceptions:
        ObjectPattern: yes
    ]
  ,
    code: 'new Foo(a,\nb)'
    options: [
      'first'
    ,
      exceptions:
        NewExpression: yes
    ]
  ,
    code: 'f(1\n, 2)'
    options: [
      'last'
    ,
      exceptions:
        CallExpression: yes
    ]
  ,
    code: '(a\n, b) -> return a + b'
    options: [
      'last'
    ,
      exceptions:
        FunctionExpression: yes
    ]
  ,
    code: '([a\n, b]) -> return a + b'
    options: [
      'last'
    ,
      exceptions:
        ArrayPattern: yes
    ]
    parserOptions:
      ecmaVersion: 6
  ,
    code: 'foo = (a\n, b) => return a + b'
    options: [
      'last'
    ,
      exceptions:
        FunctionExpression: yes
    ]
  ,
    code: 'foo = ([a\n, b]) => return a + b'
    options: [
      'last'
    ,
      exceptions:
        ArrayPattern: yes
    ]
  ,
    code: "import { a\n, b } from './source'"
    options: [
      'last'
    ,
      exceptions:
        ImportDeclaration: yes
    ]
  ,
    code: "{foo\n, bar} = {foo:'apples', bar:'oranges'}"
    options: [
      'last'
    ,
      exceptions:
        ObjectPattern: yes
    ]
  ,
    code: 'new Foo(a,\nb)'
    options: [
      'last'
    ,
      exceptions:
        NewExpression: no
    ]
  ,
    code: 'new Foo(a\n,b)'
    options: [
      'last'
    ,
      exceptions:
        NewExpression: yes
    ]
  ]

  invalid: [
    code: 'foo = { a: 1.0 #comment \n, b: 2\n}'
    # output: 'foo = { a: 1., #comment \n b: 2\n}'
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Property'
    ]
  ,
    code: 'foo = { a: 1.0 #comment \n #comment1 \n #comment2 \n, b: 2\n}'
    # output:
    #   'foo = { a: 1., #comment \n #comment1 \n #comment2 \n b: 2\n}'
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Property'
    ]
  ,
    code: 'new Foo(a\n,\nb)'
    # output: 'new Foo(a,\nb)'
    options: [
      'last'
    ,
      exceptions:
        NewExpression: no
    ]
    errors: [messageId: 'unexpectedLineBeforeAndAfterComma']
  ,
    code: 'f([1,2\n,3])'
    # output: 'f([1,2,\n3])'
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Literal'
    ]
  ,
    code: 'f([1,2\n,])'
    # output: 'f([1,2,\n])'
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Punctuator'
    ]
  ,
    code: 'f([,2\n,3])'
    # output: 'f([,2,\n3])'
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Literal'
    ]
  ,
    code: "foo = ['apples'\n, 'oranges']"
    # output: "foo = ['apples',\n 'oranges']"
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Literal'
    ]
  ,
    code: "[foo\n, bar] = ['apples', 'oranges']"
    # output: "[foo,\n bar] = ['apples', 'oranges']"
    options: [
      'last'
    ,
      exceptions:
        ArrayPattern: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Identifier'
    ]
  ,
    code: 'f(1\n, 2)'
    # output: 'f(1,\n 2)'
    options: [
      'last'
    ,
      exceptions:
        CallExpression: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Literal'
    ]
  ,
    code: '(a\n, b) -> return a + b'
    # output: '(a,\n b) -> return a + b'
    options: [
      'last'
    ,
      exceptions:
        FunctionExpression: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Identifier'
    ]
  ,
    code: 'foo = (a\n, b) -> return a + b'
    # output: 'foo = function (a,\n b) { return a + b }'
    options: [
      'last'
    ,
      exceptions:
        FunctionExpression: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Identifier'
    ]
  ,
    code: '([a\n, b]) -> return a + b'
    # output: 'function foo([a,\n b]) { return a + b }'
    options: [
      'last'
    ,
      exceptions:
        ArrayPattern: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Identifier'
    ]
  ,
    code: 'foo = (a\n, b) => return a + b'
    # output: 'foo = (a,\n b) => return a + b'
    options: [
      'last'
    ,
      exceptions:
        FunctionExpression: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Identifier'
    ]
  ,
    code: 'foo = ([a\n, b]) => return a + b'
    # output: 'foo = ([a,\n b]) => return a + b'
    options: [
      'last'
    ,
      exceptions:
        ArrayPattern: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Identifier'
    ]
  ,
    code: "import { a\n, b } from './source'"
    # output: "import { a,\n b } from './source'"
    options: [
      'last'
    ,
      exceptions:
        ImportDeclaration: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'ImportSpecifier'
    ]
  ,
    code: "{foo\n, bar} = {foo:'apples', bar:'oranges'}"
    # output: "{foo,\n bar} = {foo:'apples', bar:'oranges'}"
    options: [
      'last'
    ,
      exceptions:
        ObjectPattern: no
    ]
    errors: [
      messageId: 'expectedCommaLast'
      type: 'Property'
    ]
  ,
    code: 'f([1,\n2,3])'
    # output: 'f([1\n,2,3])'
    options: ['first']
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'Literal'
    ]
  ,
    code: "foo = ['apples', \n 'oranges']"
    # output: "foo = ['apples' \n ,'oranges']"
    options: ['first']
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'Literal'
    ]
  ,
    code: "foo = \n {'a': 1, \n 'b': 2\n ,'c': 3}"
    # output: "foo = {'a': 1 \n ,'b': 2\n ,'c': 3}"
    options: ['first']
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'Property'
    ]
  ,
    code: "foo = \n 'a': 1, \n 'b': 2\n ,'c': 3"
    # output: "foo = {'a': 1 \n ,'b': 2\n ,'c': 3}"
    options: ['first']
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'Property'
    ]
  ,
    code: "ar =[1,\n{a: 'a',\nb: 'b'}]"
    # output: "ar =[1,\n{a: 'a'\n,b: 'b'}]"
    options: ['first', {exceptions: ArrayExpression: yes}]
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'Property'
    ]
  ,
    code: "ar =[1,\n{a: 'a',\nb: 'b'}]"
    # output: "ar =[1\n,{a: 'a',\nb: 'b'}]"
    options: ['first', {exceptions: ObjectExpression: yes}]
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'ObjectExpression'
    ]
  ,
    code: 'ar ={fst:1,\nsnd: [1,\n2]}'
    # output: 'ar ={fst:1,\nsnd: [1\n,2]}'
    options: ['first', {exceptions: ObjectExpression: yes}]
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'Literal'
    ]
  ,
    code: 'ar ={fst:1,\nsnd: [1,\n2]}'
    # output: 'ar ={fst:1\n,snd: [1,\n2]}'
    options: ['first', {exceptions: ArrayExpression: yes}]
    errors: [
      messageId: 'expectedCommaFirst'
      type: 'Property'
    ]
  ,
    code: 'new Foo(a,\nb)'
    # output: 'new Foo(a\n,b)'
    options: [
      'first'
    ,
      exceptions:
        NewExpression: no
    ]
    errors: [messageId: 'expectedCommaFirst']
  ,
    code: 'foo = [\n  (bar\n  )\n  ,\n  baz\n]'
    # output: 'foo = [\n(bar\n),\nbaz\n]'
    errors: [
      messageId: 'unexpectedLineBeforeAndAfterComma'
      type: 'Identifier'
    ]
  ,
    code: '[(foo),\n,\nbar]'
    # output: '[(foo),,\nbar]'
    errors: [messageId: 'unexpectedLineBeforeAndAfterComma']
  ,
    code: 'new Foo(a\n,b)'
    # output: 'new Foo(a,\nb)'
    options: [
      'last'
    ,
      exceptions:
        NewExpression: no
    ]
    errors: [messageId: 'expectedCommaLast']
  ,
    code: '[\n  [foo(3)],\n  ,\n  bar\n]'
    # output: '[\n[foo(3)],,\nbar\n]'
    errors: [messageId: 'unexpectedLineBeforeAndAfterComma']
  ]
