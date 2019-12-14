###*
# @fileoverview Tests for camelcase rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/camelcase'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'camelcase', rule,
  valid: [
    'firstName = "Nicholas"'
    'FIRST_NAME = "Nicholas"'
    '__myPrivateVariable = "Patrick"'
    'myPrivateVariable_ = "Patrick"'
    'doSomething = ->'
    'do_something()'
    'new do_something'
    'new do_something()'
    'foo.do_something()'
    'foo = bar.baz_boom'
    'foo = bar.baz_boom.something'
    'foo.boom_pow.qux = bar.baz_boom.something'
    'if (bar.baz_boom) then yes'
    'obj = { key: foo.bar_baz }'
    'arr = [foo.bar_baz]'
    '[foo.bar_baz]'
    'arr = [foo.bar_baz.qux]'
    '[foo.bar_baz.nesting]'
    'if foo.bar_baz is boom.bam_pow then [foo.baz_boom]'
  ,
    code: 'o = {key: 1}'
    options: [properties: 'always']
  ,
    code: 'o = {_leading: 1}'
    options: [properties: 'always']
  ,
    code: 'o = {trailing_: 1}'
    options: [properties: 'always']
  ,
    code: 'o = {bar_baz: 1}'
    options: [properties: 'never']
  ,
    code: 'o = {_leading: 1}'
    options: [properties: 'never']
  ,
    code: 'o = {trailing_: 1}'
    options: [properties: 'never']
  ,
    code: 'obj.a_b = 2'
    options: [properties: 'never']
  ,
    code: 'obj._a = 2'
    options: [properties: 'always']
  ,
    code: 'obj.a_ = 2'
    options: [properties: 'always']
  ,
    code: 'obj._a = 2'
    options: [properties: 'never']
  ,
    code: 'obj.a_ = 2'
    options: [properties: 'never']
  ,
    code: '''
      obj = {
        a_a: 1
      }
      obj.a_b = 2
    '''
    options: [properties: 'never']
  ,
    code: 'obj.foo_bar = ->'
    options: [properties: 'never']
  ,
    code: '{ category_id } = query'
    options: [ignoreDestructuring: yes]
  ,
    code: '{ category_id: category_id } = query'
    options: [ignoreDestructuring: yes]
  ,
    code: '{ category_id = 1 } = query'
    options: [ignoreDestructuring: yes]
  ,
    code: '{ category_id: category } = query'
  ,
    code: '{ _leading } = query'
  ,
    code: '{ trailing_ } = query'
  ,
    code: 'import { camelCased } from "external module"'
  ,
    code: 'import { _leading } from "external module"'
  ,
    code: 'import { trailing_ } from "external module"'
  ,
    code: 'import { no_camelcased as camelCased } from "external-module"'
  ,
    code: 'import { no_camelcased as _leading } from "external-module"'
  ,
    code: 'import { no_camelcased as trailing_ } from "external-module"'
  ,
    code:
      'import { no_camelcased as camelCased, anoterCamelCased } from "external-module"'
  ,
    code: 'foo = ({ no_camelcased: camelCased }) ->'
  ,
    code: 'foo = ({ no_camelcased: _leading }) ->'
  ,
    code: 'foo = ({ no_camelcased: trailing_ }) ->'
  ,
    code: "foo = ({ camelCased = 'default value' }) ->"
  ,
    code: "foo = ({ _leading = 'default value' }) ->"
  ,
    code: "foo = ({ trailing_ = 'default value' }) ->"
  ,
    code: 'foo = ({ camelCased }) ->'
  ,
    code: 'foo = ({ _leading }) ->'
  ,
    code: 'foo = ({ trailing_ }) ->'
  ]
  invalid: [
    code: 'first_name = "Nicholas"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'first_name'
      type: 'Identifier'
    ]
  ,
    code: '__private_first_name = "Patrick"'
    errors: [
      messageId: 'notCamelCase'
      data: name: '__private_first_name'
      type: 'Identifier'
    ]
  ,
    code: 'foo_bar = ->'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'foo_bar'
      type: 'Identifier'
    ]
  ,
    code: 'obj.foo_bar = ->'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'foo_bar'
      type: 'Identifier'
    ]
  ,
    code: 'bar_baz.foo = ->'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'bar_baz'
      type: 'Identifier'
    ]
  ,
    code: '[foo_bar.baz]'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'foo_bar'
      type: 'Identifier'
    ]
  ,
    code: 'if (foo.bar_baz is boom.bam_pow) then [foo_bar.baz]'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'foo_bar'
      type: 'Identifier'
    ]
  ,
    code: 'foo.bar_baz = boom.bam_pow'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'bar_baz'
      type: 'Identifier'
    ]
  ,
    code: 'foo = { bar_baz: boom.bam_pow }'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'bar_baz'
      type: 'Identifier'
    ]
  ,
    code: 'foo.qux.boom_pow = { bar: boom.bam_pow }'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'boom_pow'
      type: 'Identifier'
    ]
  ,
    code: 'o = {bar_baz: 1}'
    options: [properties: 'always']
    errors: [
      messageId: 'notCamelCase'
      data: name: 'bar_baz'
      type: 'Identifier'
    ]
  ,
    code: 'obj.a_b = 2'
    options: [properties: 'always']
    errors: [
      messageId: 'notCamelCase'
      data: name: 'a_b'
      type: 'Identifier'
    ]
  ,
    code: '{ category_id: category_alias } = query'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'category_alias'
      type: 'Identifier'
    ]
  ,
    code: '{ category_id: category_alias } = query'
    options: [ignoreDestructuring: yes]
    errors: [
      messageId: 'notCamelCase'
      data: name: 'category_alias'
      type: 'Identifier'
    ]
  ,
    code: '{ category_id: categoryId, ...other_props } = query'
    options: [ignoreDestructuring: yes]
    errors: [
      messageId: 'notCamelCase'
      data: name: 'other_props'
      type: 'Identifier'
    ]
  ,
    code: '{ category_id } = query'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'category_id'
      type: 'Identifier'
    ]
  ,
    code: '{ category_id: category_id } = query'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'category_id'
      type: 'Identifier'
    ]
  ,
    code: '{ category_id = 1 } = query'
    errors: [
      message: "Identifier 'category_id' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: 'import no_camelcased from "external-module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camelcased'
      type: 'Identifier'
    ]
  ,
    code: 'import * as no_camelcased from "external-module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camelcased'
      type: 'Identifier'
    ]
  ,
    code: 'import { no_camelcased } from "external-module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camelcased'
      type: 'Identifier'
    ]
  ,
    code: 'import { no_camelcased as no_camel_cased } from "external module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camel_cased'
      type: 'Identifier'
    ]
  ,
    code: 'import { camelCased as no_camel_cased } from "external module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camel_cased'
      type: 'Identifier'
    ]
  ,
    code: 'import { camelCased, no_camelcased } from "external-module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camelcased'
      type: 'Identifier'
    ]
  ,
    code:
      'import { no_camelcased as camelCased, another_no_camelcased } from "external-module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'another_no_camelcased'
      type: 'Identifier'
    ]
  ,
    code: 'import camelCased, { no_camelcased } from "external-module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camelcased'
      type: 'Identifier'
    ]
  ,
    code:
      'import no_camelcased, { another_no_camelcased as camelCased } from "external-module"'
    errors: [
      messageId: 'notCamelCase'
      data: name: 'no_camelcased'
      type: 'Identifier'
    ]
  ,
    code: '({ no_camelcased }) ->'
    errors: [
      message: "Identifier 'no_camelcased' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: "({ no_camelcased = 'default value' }) ->"
    errors: [
      message: "Identifier 'no_camelcased' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: '''
        no_camelcased = 0
        ({ camelcased_value = no_camelcased}) ->
      '''
    errors: [
      message: "Identifier 'no_camelcased' is not in camel case."
      type: 'Identifier'
    ,
      message: "Identifier 'camelcased_value' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: '{ bar: no_camelcased } = foo'
    errors: [
      message: "Identifier 'no_camelcased' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: '({ value_1: my_default }) ->'
    errors: [
      message: "Identifier 'my_default' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: '({ isCamelcased: no_camelcased }) ->'
    errors: [
      message: "Identifier 'no_camelcased' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: '{ foo: bar_baz = 1 } = quz'
    errors: [
      message: "Identifier 'bar_baz' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: '{ no_camelcased = false } = bar'
    errors: [
      message: "Identifier 'no_camelcased' is not in camel case."
      type: 'Identifier'
    ]
  ,
    code: '''
      class My_Class
    '''
    errors: [
      message: "Identifier 'My_Class' is not in camel case."
      type: 'Identifier'
    ]
  ]
