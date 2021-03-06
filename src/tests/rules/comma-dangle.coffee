###*
# @fileoverview Tests for comma-dangle rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

### eslint-disable ###

rule = require 'eslint/lib/rules/comma-dangle'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Gets the path to the parser of the given name.
#
# @param {string} name - The name of a parser to get.
# @returns {string} The path to the specified parser.
###
# parser = (name) ->
#   path.resolve __dirname, "../../fixtures/parsers/comma-dangle/#{name}.js"

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

###
ruleTester.run 'comma-dangle', rule,
  valid: [
    "foo = { bar: 'baz' }"
    "foo = bar: 'baz'"
    "foo = {\n  bar: 'baz'\n}"
    "foo = [ 'baz' ]"
    "foo = [\n  'baz'\n]"
    '[,,]'
    '[\n,\n,\n]'
    '[,]'
    '[\n,\n]'
    '[]'
    '[\n]'
  ,
    code: 'foo = [\n      (if bar then baz else qux),\n    ]'
    options: ['always-multiline']
  ,
    code: "foo = { bar: 'baz' }", options: ['never']
  ,
    code: "foo = {\n  bar: 'baz'\n}", options: ['never']
  ,
    code: "foo = [ 'baz' ]", options: ['never']
  ,
    code: '{ a, b } = foo'
    options: ['never']
  ,
    code: '[ a, b ] = foo'
    options: ['never']
  ,
    code: '{ a,\n b, \n} = foo'
    options: ['only-multiline']
  ,
    code: '[ a,\n b, \n] = foo'
    options: ['only-multiline']
  ,
    code: '[(1),]', options: ['always']
  ,
    code: 'x = { foo: (1),}', options: ['always']
  ,
    code: "foo = { bar: 'baz', }", options: ['always']
  ,
    code: "foo = {\n  bar: 'baz',\n}", options: ['always']
  ,
    code: "foo = \n  bar: 'baz',\n", options: ['always']
  ,
    code: "foo = {\n  bar: 'baz'\n,}", options: ['always']
  ,
    code: "foo = [ 'baz', ]", options: ['always']
  ,
    code: "foo = [\n  'baz',\n]", options: ['always']
  ,
    code: "foo = [\n  'baz'\n,]", options: ['always']
  ,
    code: '[,,]', options: ['always']
  ,
    code: '[\n,\n,\n]', options: ['always']
  ,
    code: '[,]', options: ['always']
  ,
    code: '[\n,\n]', options: ['always']
  ,
    code: '[]', options: ['always']
  ,
    code: '[\n]', options: ['always']
  ,
    code: "foo = { bar: 'baz' }", options: ['always-multiline']
  ,
    code: "foo = { bar: 'baz' }", options: ['only-multiline']
  ,
    code: "foo = {\nbar: 'baz',\n}", options: ['always-multiline']
  ,
    code: "foo = {\nbar: 'baz',\n}", options: ['only-multiline']
  ,
    code: "foo = [ 'baz' ]", options: ['always-multiline']
  ,
    code: "foo = [ 'baz' ]", options: ['only-multiline']
  ,
    code: "foo = [\n  'baz',\n]", options: ['always-multiline']
  ,
    code: "foo = [\n  'baz',\n]", options: ['only-multiline']
  ,
    code: 'foo = {a: 1, b: 2, c: 3, d: 4}', options: ['always-multiline']
  ,
    code: 'foo = {a: 1, b: 2, c: 3, d: 4}', options: ['only-multiline']
  ,
    code: 'foo = {a: 1, b: 2,\nc: 3, d: 4}'
    options: ['always-multiline']
  ,
    code: 'foo = {a: 1, b: 2,\nc: 3, d: 4}', options: ['only-multiline']
  ,
    code: "foo = {x: {\nfoo: 'bar',\n}}", options: ['always-multiline']
  ,
    code: "foo = {x: {\nfoo: 'bar',\n}}", options: ['only-multiline']
  ,
    code: 'foo = new Map([\n  [key, {\n  a: 1,\n  b: 2,\n  c: 3,\n  }],\n])'
    options: ['always-multiline']
  ,
    code: 'foo = new Map([\n  [key, {\n  a: 1,\n  b: 2,\n  c: 3,\n  }],\n])'
    options: ['only-multiline']
  ,
    # https://github.com/eslint/eslint/issues/3627
    code: '[a, ...rest] = []'
    options: ['always']
  ,
    code: '[\n    a,\n    ...rest\n] = []'
    options: ['always']
  ,
    code: '[\n    a,\n    ...rest\n] = []'
    options: ['always-multiline']
  ,
    code: '[\n    a,\n    ...rest\n] = []'
    options: ['only-multiline']
  ,
    code: '[a, ...rest] = []'
    options: ['always']
  ,
    code: 'for [a, ...rest] in [] then ;'
    options: ['always']
  ,
    code: 'a = [b, ...spread,]'
    options: ['always']
  ,
    # https://github.com/eslint/eslint/issues/7297
    code: '{foo, ...bar} = baz'
    options: ['always']
  ,
    # https://github.com/eslint/eslint/issues/3794
    code: "import {foo,} from 'foo'"
    options: ['always']
  ,
    code: "import foo from 'foo'"
    options: ['always']
  ,
    code: "import foo, {abc,} from 'foo'"
    options: ['always']
  ,
    code: "import * as foo from 'foo'"
    options: ['always']
  ,
    code: "export {foo,} from 'foo'"
    options: ['always']
  ,
    code: "import {foo} from 'foo'"
    options: ['never']
  ,
    code: "import foo from 'foo'"
    options: ['never']
  ,
    code: "import foo, {abc} from 'foo'"
    options: ['never']
  ,
    code: "import * as foo from 'foo'"
    options: ['never']
  ,
    code: "export {foo} from 'foo'"
    options: ['never']
  ,
    code: "import {foo} from 'foo'"
    options: ['always-multiline']
  ,
    code: "import {foo} from 'foo'"
    options: ['only-multiline']
  ,
    code: "export {foo} from 'foo'"
    options: ['always-multiline']
  ,
    code: "export {foo} from 'foo'"
    options: ['only-multiline']
  ,
    code: "import {\n  foo,\n} from 'foo'"
    options: ['always-multiline']
  ,
    code: "import {\n  foo,\n} from 'foo'"
    options: ['only-multiline']
  ,
    code: "export {\n  foo,\n} from 'foo'"
    options: ['always-multiline']
  ,
    code: "export {\n  foo,\n} from 'foo'"
    options: ['only-multiline']
  ,
    code: '(a) ->'
    options: ['always']
  ,
    code: '(a) ->'
    options: ['always']
  ,
    code: '(\na,\nb\n) ->'
    options: ['always-multiline']
  ,
    code: 'foo(\na,b)'
    options: ['always-multiline']
  ,
    code: 'foo(a,b,)'
    options: ['always-multiline']
  ,
    # trailing comma in functions
    code: '(a) ->'
    options: [functions: 'never']
  ,
    code: '(a) ->'
    options: [functions: 'always']
  ,
    code: 'foo(a)'
    options: [functions: 'never']
  ,
    code: '(a, ...b) ->'
    options: [functions: 'always']
  ,
    code: 'foo(a,)'
    options: [functions: 'always']
  ,
    code: 'bar(...a,)'
    options: [functions: 'always']
  ,
    code: '(a) -> '
    options: [functions: 'always-multiline']
  ,
    code: 'foo(a)'
    options: [functions: 'always-multiline']
  ,
    code: 'foo a'
    options: [functions: 'always-multiline']
  ,
    code: '(\na,\nb,\n) -> '
    options: [functions: 'always-multiline']
  ,
    code: '(\na,\n...b\n) -> '
    options: [functions: 'always-multiline']
  ,
    code: 'foo(\na,\nb,\n)'
    options: [functions: 'always-multiline']
  ,
    code: 'foo(\na,\n...b,\n)'
    options: [functions: 'always-multiline']
  ,
    code: 'function foo(a) {} '
    options: [functions: 'only-multiline']
  ,
    code: 'foo(a)'
    options: [functions: 'only-multiline']
  ,
    code: 'function foo(\na,\nb,\n) {} '
    options: [functions: 'only-multiline']
  ,
    code: 'foo(\na,\nb,\n)'
    options: [functions: 'only-multiline']
  ,
    code: 'function foo(\na,\nb\n) {} '
    options: [functions: 'only-multiline']
  ,
    code: 'foo(\na,\nb\n)'
    options: [functions: 'only-multiline']
  ]
  invalid: [
    code: "foo = { bar: 'baz', }"
    output: "foo = { bar: 'baz' }"
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 23
    ]
  ,
    code: "foo = {\nbar: 'baz',\n}"
    output: "foo = {\nbar: 'baz'\n}"
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 2
      column: 11
    ]
  ,
    code: "foo({ bar: 'baz', qux: 'quux', })"
    output: "foo({ bar: 'baz', qux: 'quux' })"
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 30
    ]
  ,
    code: "foo({\nbar: 'baz',\nqux: 'quux',\n})"
    output: "foo({\nbar: 'baz',\nqux: 'quux'\n})"
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 3
      column: 12
    ]
  ,
    code: "foo = [ 'baz', ]"
    output: "foo = [ 'baz' ]"
    errors: [
      messageId: 'unexpected'
      type: 'Literal'
      line: 1
      column: 18
    ]
  ,
    code: "foo = [ 'baz',\n]"
    output: "foo = [ 'baz'\n]"
    errors: [
      messageId: 'unexpected'
      type: 'Literal'
      line: 1
      column: 18
    ]
  ,
    code: "foo = { bar: 'bar'\n\n, }"
    output: "foo = { bar: 'bar'\n\n }"
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 3
      column: 1
    ]
  ,
    code: "foo = { bar: 'baz', }"
    output: "foo = { bar: 'baz' }"
    options: ['never']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 23
    ]
  ,
    code: "foo = { bar: 'baz', }"
    output: "foo = { bar: 'baz' }"
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 23
    ]
  ,
    code: "foo = {\nbar: 'baz',\n}"
    output: "foo = {\nbar: 'baz'\n}"
    options: ['never']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 2
      column: 11
    ]
  ,
    code: "foo({ bar: 'baz', qux: 'quux', })"
    output: "foo({ bar: 'baz', qux: 'quux' })"
    options: ['never']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 30
    ]
  ,
    code: "foo({ bar: 'baz', qux: 'quux', })"
    output: "foo({ bar: 'baz', qux: 'quux' })"
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 30
    ]
  ,
    code: "foo = { bar: 'baz' }"
    output: "foo = { bar: 'baz', }"
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 1
      column: 23
    ]
  ,
    code: "foo = {\nbar: 'baz'\n}"
    output: "foo = {\nbar: 'baz',\n}"
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 2
      column: 11
    ]
  ,
    code: "foo({ bar: 'baz', qux: 'quux' })"
    output: "foo({ bar: 'baz', qux: 'quux', })"
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 1
      column: 30
    ]
  ,
    code: "foo({\nbar: 'baz',\nqux: 'quux'\n})"
    output: "foo({\nbar: 'baz',\nqux: 'quux',\n})"
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 3
      column: 12
    ]
  ,
    code: "foo = [ 'baz' ]"
    output: "foo = [ 'baz', ]"
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Literal'
      line: 1
      column: 18
    ]
  ,
    code: "foo = [ 'baz'\n]"
    output: "foo = [ 'baz',\n]"
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Literal'
      line: 1
      column: 18
    ]
  ,
    code: "foo = { bar:\n\n'bar' }"
    output: "foo = { bar:\n\n'bar', }"
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 3
      column: 6
    ]
  ,
    code: "foo = {\nbar: 'baz'\n}"
    output: "foo = {\nbar: 'baz',\n}"
    options: ['always-multiline']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 2
      column: 11
    ]
  ,
    code:
      'foo = [\n' + '  bar,\n' + '  (\n' + '    baz\n' + '  )\n' + ']'
    output:
      'foo = [\n' + '  bar,\n' + '  (\n' + '    baz\n' + '  ),\n' + ']'
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Identifier'
      line: 5
      column: 4
    ]
  ,
    code:
      'foo = {\n' +
      "  foo: 'bar',\n" +
      '  baz: (\n' +
      '    qux\n' +
      '  )\n' +
      '}'
    output:
      'foo = {\n' +
      "  foo: 'bar',\n" +
      '  baz: (\n' +
      '    qux\n' +
      '  ),\n' +
      '}'
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 5
      column: 4
    ]
  ,
    # https://github.com/eslint/eslint/issues/7291
    code:
      'foo = [\n' + '  (bar\n' + '    ? baz\n' + '    : qux\n' + '  )\n' + ']'
    output:
      'foo = [\n' + '  (bar\n' + '    ? baz\n' + '    : qux\n' + '  ),\n' + ']'
    options: ['always']
    errors: [
      messageId: 'missing'
      type: 'ConditionalExpression'
      line: 5
      column: 4
    ]
  ,
    code: "foo = { bar: 'baz', }"
    output: "foo = { bar: 'baz' }"
    options: ['always-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 23
    ]
  ,
    code: "foo({\nbar: 'baz',\nqux: 'quux'\n})"
    output: "foo({\nbar: 'baz',\nqux: 'quux',\n})"
    options: ['always-multiline']
    errors: [
      messageId: 'missing'
      type: 'Property'
      line: 3
      column: 12
    ]
  ,
    code: "foo({ bar: 'baz', qux: 'quux', })"
    output: "foo({ bar: 'baz', qux: 'quux' })"
    options: ['always-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 30
    ]
  ,
    code: "foo = [\n'baz'\n]"
    output: "foo = [\n'baz',\n]"
    options: ['always-multiline']
    errors: [
      messageId: 'missing'
      type: 'Literal'
      line: 2
      column: 6
    ]
  ,
    code: "foo = ['baz',]"
    output: "foo = ['baz']"
    options: ['always-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Literal'
      line: 1
      column: 17
    ]
  ,
    code: "foo = ['baz',]"
    output: "foo = ['baz']"
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Literal'
      line: 1
      column: 17
    ]
  ,
    code: "foo = {x: {\nfoo: 'bar',\n},}"
    output: "foo = {x: {\nfoo: 'bar',\n}}"
    options: ['always-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 3
      column: 2
    ]
  ,
    code: 'foo = {a: 1, b: 2,\nc: 3, d: 4,}'
    output: 'foo = {a: 1, b: 2,\nc: 3, d: 4}'
    options: ['always-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 2
      column: 11
    ]
  ,
    code: 'foo = {a: 1, b: 2,\nc: 3, d: 4,}'
    output: 'foo = {a: 1, b: 2,\nc: 3, d: 4}'
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 2
      column: 11
    ]
  ,
    code: 'foo = [{\na: 1,\nb: 2,\nc: 3,\nd: 4,\n},]'
    output: 'foo = [{\na: 1,\nb: 2,\nc: 3,\nd: 4,\n}]'
    options: ['always-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'ObjectExpression'
      line: 6
      column: 2
    ]
  ,
    code: '{ a, b, } = foo'
    output: '{ a, b } = foo'
    options: ['never']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 11
    ]
  ,
    code: '{ a, b, } = foo'
    output: '{ a, b } = foo'
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 11
    ]
  ,
    code: '[ a, b, ] = foo'
    output: '[ a, b ] = foo'
    options: ['never']
    errors: [
      messageId: 'unexpected'
      type: 'Identifier'
      line: 1
      column: 11
    ]
  ,
    code: '[ a, b, ] = foo'
    output: '[ a, b ] = foo'
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Identifier'
      line: 1
      column: 11
    ]
  ,
    code: '[(1),]'
    output: '[(1)]'
    options: ['never']
    errors: [
      messageId: 'unexpected'
      type: 'Literal'
      line: 1
      column: 5
    ]
  ,
    code: '[(1),]'
    output: '[(1)]'
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Literal'
      line: 1
      column: 5
    ]
  ,
    code: 'x = { foo: (1),}'
    output: 'x = { foo: (1)}'
    options: ['never']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 19
    ]
  ,
    code: 'x = { foo: (1),}'
    output: 'x = { foo: (1)}'
    options: ['only-multiline']
    errors: [
      messageId: 'unexpected'
      type: 'Property'
      line: 1
      column: 19
    ]
  ,
    # https://github.com/eslint/eslint/issues/3794
    code: "import {foo} from 'foo'"
    output: "import {foo,} from 'foo'"
    options: ['always']
    errors: [messageId: 'missing', type: 'ImportSpecifier']
  ,
    code: "import foo, {abc} from 'foo'"
    output: "import foo, {abc,} from 'foo'"
    options: ['always']
    errors: [messageId: 'missing', type: 'ImportSpecifier']
  ,
    code: "export {foo} from 'foo'"
    output: "export {foo,} from 'foo'"
    options: ['always']
    errors: [messageId: 'missing', type: 'ExportSpecifier']
  ,
    code: "import {foo,} from 'foo'"
    output: "import {foo} from 'foo'"
    options: ['never']
    errors: [messageId: 'unexpected', type: 'ImportSpecifier']
  ,
    code: "import {foo,} from 'foo'"
    output: "import {foo} from 'foo'"
    options: ['only-multiline']
    errors: [messageId: 'unexpected', type: 'ImportSpecifier']
  ,
    code: "import foo, {abc,} from 'foo'"
    output: "import foo, {abc} from 'foo'"
    options: ['never']
    errors: [messageId: 'unexpected', type: 'ImportSpecifier']
  ,
    code: "import foo, {abc,} from 'foo'"
    output: "import foo, {abc} from 'foo'"
    options: ['only-multiline']
    errors: [messageId: 'unexpected', type: 'ImportSpecifier']
  ,
    code: "export {foo,} from 'foo'"
    output: "export {foo} from 'foo'"
    options: ['never']
    errors: [messageId: 'unexpected', type: 'ExportSpecifier']
  ,
    code: "export {foo,} from 'foo'"
    output: "export {foo} from 'foo'"
    options: ['only-multiline']
    errors: [messageId: 'unexpected', type: 'ExportSpecifier']
  ,
    code: "import {foo,} from 'foo'"
    output: "import {foo} from 'foo'"
    options: ['always-multiline']
    errors: [messageId: 'unexpected', type: 'ImportSpecifier']
  ,
    code: "export {foo,} from 'foo'"
    output: "export {foo} from 'foo'"
    options: ['always-multiline']
    errors: [messageId: 'unexpected', type: 'ExportSpecifier']
  ,
    code: "import {\n  foo\n} from 'foo'"
    output: "import {\n  foo,\n} from 'foo'"
    options: ['always-multiline']
    errors: [messageId: 'missing', type: 'ImportSpecifier']
  ,
    code: "export {\n  foo\n} from 'foo'"
    output: "export {\n  foo,\n} from 'foo'"
    options: ['always-multiline']
    errors: [messageId: 'missing', type: 'ExportSpecifier']
  ,
    # https://github.com/eslint/eslint/issues/6233
    code: 'foo = {a: (1)}'
    output: 'foo = {a: (1),}'
    options: ['always']
    errors: [messageId: 'missing', type: 'Property']
  ,
    code: 'foo = [(1)]'
    output: 'foo = [(1),]'
    options: ['always']
    errors: [messageId: 'missing', type: 'Literal']
  ,
    code: 'foo = [\n1,\n(2)\n]'
    output: 'foo = [\n1,\n(2),\n]'
    options: ['always-multiline']
    errors: [messageId: 'missing', type: 'Literal']
  ,
    # trailing commas in functions
    code: 'function foo(a,) {}'
    output: 'function foo(a) {}'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '(function foo(a,) {})'
    output: '(function foo(a) {})'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '(a,) => a'
    output: '(a) => a'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '(a,) => (a)'
    output: '(a) => (a)'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '({foo(a,) {}})'
    output: '({foo(a) {}})'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: 'class A {foo(a,) {}}'
    output: 'class A {foo(a) {}}'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: 'foo(a,)'
    output: 'foo(a)'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: 'foo(...a,)'
    output: 'foo(...a)'
    options: [functions: 'never']
    errors: [messageId: 'unexpected', type: 'SpreadElement']
  ,
    code: 'function foo(a) {}'
    output: 'function foo(a,) {}'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: '(function foo(a) {})'
    output: '(function foo(a,) {})'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: '(a) => a'
    output: '(a,) => a'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: '(a) => (a)'
    output: '(a,) => (a)'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: '({foo(a) {}})'
    output: '({foo(a,) {}})'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: 'class A {foo(a) {}}'
    output: 'class A {foo(a,) {}}'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: 'foo(a)'
    output: 'foo(a,)'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: 'foo(...a)'
    output: 'foo(...a,)'
    options: [functions: 'always']
    errors: [messageId: 'missing', type: 'SpreadElement']
  ,
    code: 'function foo(a,) {}'
    output: 'function foo(a) {}'
    options: [functions: 'always-multiline']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '(function foo(a,) {})'
    output: '(function foo(a) {})'
    options: [functions: 'always-multiline']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: 'foo(a,)'
    output: 'foo(a)'
    options: [functions: 'always-multiline']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: 'foo(...a,)'
    output: 'foo(...a)'
    options: [functions: 'always-multiline']
    errors: [messageId: 'unexpected', type: 'SpreadElement']
  ,
    code: 'function foo(\na,\nb\n) {}'
    output: 'function foo(\na,\nb,\n) {}'
    options: [functions: 'always-multiline']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: 'foo(\na,\nb\n)'
    output: 'foo(\na,\nb,\n)'
    options: [functions: 'always-multiline']
    errors: [messageId: 'missing', type: 'Identifier']
  ,
    code: 'foo(\n...a,\n...b\n)'
    output: 'foo(\n...a,\n...b,\n)'
    options: [functions: 'always-multiline']
    errors: [messageId: 'missing', type: 'SpreadElement']
  ,
    code: 'function foo(a,) {}'
    output: 'function foo(a) {}'
    options: [functions: 'only-multiline']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: '(function foo(a,) {})'
    output: '(function foo(a) {})'
    options: [functions: 'only-multiline']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: 'foo(a,)'
    output: 'foo(a)'
    options: [functions: 'only-multiline']
    errors: [messageId: 'unexpected', type: 'Identifier']
  ,
    code: 'foo(...a,)'
    output: 'foo(...a)'
    options: [functions: 'only-multiline']
    errors: [messageId: 'unexpected', type: 'SpreadElement']
  ,
    # separated options
    code: """{a,} = {a: 1,}
[b,] = [1,]
import {c,} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    output: """{a} = {a: 1}
[b,] = [1,]
import {c,} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    options: [
      objects: 'never'
      arrays: 'ignore'
      imports: 'ignore'
      exports: 'ignore'
      functions: 'ignore'
    ]
    errors: [
      messageId: 'unexpected', line: 1
    ,
      messageId: 'unexpected', line: 1
    ]
  ,
    code: """{a,} = {a: 1,}
[b,] = [1,]
import {c,} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    output: """{a,} = {a: 1,}
[b] = [1]
import {c,} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    options: [
      objects: 'ignore'
      arrays: 'never'
      imports: 'ignore'
      exports: 'ignore'
      functions: 'ignore'
    ]
    errors: [
      messageId: 'unexpected', line: 2
    ,
      messageId: 'unexpected', line: 2
    ]
  ,
    code: """{a,} = {a: 1,}
[b,] = [1,]
import {c,} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    output: """{a,} = {a: 1,}
[b,] = [1,]
import {c} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    options: [
      objects: 'ignore'
      arrays: 'ignore'
      imports: 'never'
      exports: 'ignore'
      functions: 'ignore'
    ]
    errors: [messageId: 'unexpected', line: 3]
  ,
    code: """{a,} = {a: 1,}
[b,] = [1,]
import {c,} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    output: """{a,} = {a: 1,}
[b,] = [1,]
import {c,} from "foo"
export {d}
(function foo(e,) {})(f,)"""
    options: [
      objects: 'ignore'
      arrays: 'ignore'
      imports: 'ignore'
      exports: 'never'
      functions: 'ignore'
    ]
    errors: [messageId: 'unexpected', line: 4]
  ,
    code: """{a,} = {a: 1,}
[b,] = [1,]
import {c,} from "foo"
export {d,}
(function foo(e,) {})(f,)"""
    output: """{a,} = {a: 1,}
[b,] = [1,]
import {c,} from "foo"
export {d,}
(function foo(e) {})(f)"""
    options: [
      objects: 'ignore'
      arrays: 'ignore'
      imports: 'ignore'
      exports: 'ignore'
      functions: 'never'
    ]
    errors: [
      messageId: 'unexpected', line: 5
    ,
      messageId: 'unexpected', line: 5
    ]
  ]
###
