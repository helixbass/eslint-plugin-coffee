###*
# @fileoverview Tests for no-restricted-properties rule.
# @author Will Klein & Eli White
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-restricted-properties'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-restricted-properties', rule,
  valid: [
    code: 'someObject.someProperty'
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
    ]
  ,
    code: 'anotherObject.disallowedProperty'
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
    ]
  ,
    code: 'someObject.someProperty()'
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
    ]
  ,
    code: 'anotherObject.disallowedProperty()'
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
    ]
  ,
    code: 'anotherObject.disallowedProperty()'
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
      message: 'Please use someObject.allowedProperty instead.'
    ]
  ,
    code: "anotherObject['disallowedProperty']()"
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
    ]
  ,
    code: 'obj.toString'
    options: [
      object: 'obj'
      property: '__proto__'
    ]
  ,
    code: 'toString.toString'
    options: [
      object: 'obj'
      property: 'foo'
    ]
  ,
    code: 'obj.toString'
    options: [
      object: 'obj'
      property: 'foo'
    ]
  ,
    code: 'foo.bar'
    options: [property: 'baz']
  ,
    code: 'foo.bar'
    options: [object: 'baz']
  ,
    code: 'foo()'
    options: [object: 'foo']
  ,
    code: 'foo'
    options: [object: 'foo']
  ,
    code: 'bar = foo'
    options: [object: 'foo', property: 'bar']
  ,
    code: '{baz: bar} = foo'
    options: [object: 'foo', property: 'bar']
  ,
    code: '{unrelated} = foo'
    options: [object: 'foo', property: 'bar']
  ,
    code: '{baz: {bar: qux}} = foo'
    options: [object: 'foo', property: 'bar']
  ,
    code: '{bar} = foo.baz'
    options: [object: 'foo', property: 'bar']
  ,
    code: '{baz: bar} = foo'
    options: [property: 'bar']
  ,
    code: 'baz ({baz: bar} = foo)'
    options: [object: 'foo', property: 'bar']
  ,
    code: 'bar'
    options: [object: 'foo', property: 'bar']
  ,
    code: '([bar = 5] = foo)'
    options: [object: 'foo', property: '1']
  ,
    code: '({baz: bar} = foo) ->'
    options: [object: 'foo', property: 'bar']
  ,
    code: '[bar, baz] = foo'
    options: [object: 'foo', property: '1']
  ,
    code: '[, bar] = foo'
    options: [object: 'foo', property: '0']
  ,
    code: '[, bar = 5] = foo'
    options: [object: 'foo', property: '1']
  ,
    code: '([bar = 5] = foo)'
    options: [object: 'foo', property: '0']
  ,
    code: '([bar] = foo) ->'
    options: [object: 'foo', property: '0']
  ,
    code: '([, bar] = foo) ->'
    options: [object: 'foo', property: '0']
  ,
    code: '([, bar] = foo) ->'
    options: [object: 'foo', property: '1']
  ]

  invalid: [
    code: 'someObject.disallowedProperty'
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
    ]
    errors: [
      message: "'someObject.disallowedProperty' is restricted from being used."
      type: 'MemberExpression'
    ]
  ,
    code: 'someObject.disallowedProperty'
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
      message: 'Please use someObject.allowedProperty instead.'
    ]
    errors: [
      message:
        "'someObject.disallowedProperty' is restricted from being used. Please use someObject.allowedProperty instead."
      type: 'MemberExpression'
    ]
  ,
    code: '''
        someObject.disallowedProperty
        anotherObject.anotherDisallowedProperty()
      '''
    options: [
      object: 'someObject'
      property: 'disallowedProperty'
    ,
      object: 'anotherObject'
      property: 'anotherDisallowedProperty'
    ]
    errors: [
      message: "'someObject.disallowedProperty' is restricted from being used."
      type: 'MemberExpression'
    ,
      message:
        "'anotherObject.anotherDisallowedProperty' is restricted from being used."
      type: 'MemberExpression'
    ]
  ,
    code: 'foo.__proto__'
    options: [
      property: '__proto__'
      message: 'Please use Object.getPrototypeOf instead.'
    ]
    errors: [
      message:
        "'__proto__' is restricted from being used. Please use Object.getPrototypeOf instead."
      type: 'MemberExpression'
    ]
  ,
    code: "foo['__proto__']"
    options: [
      property: '__proto__'
      message: 'Please use Object.getPrototypeOf instead.'
    ]
    errors: [
      message:
        "'__proto__' is restricted from being used. Please use Object.getPrototypeOf instead."
      type: 'MemberExpression'
    ]
  ,
    code: 'foo.bar.baz'
    options: [object: 'foo']
    errors: [
      message: "'foo.bar' is restricted from being used."
      type: 'MemberExpression'
    ]
  ,
    code: 'foo.bar()'
    options: [object: 'foo']
    errors: [
      message: "'foo.bar' is restricted from being used."
      type: 'MemberExpression'
    ]
  ,
    code: 'foo.bar.baz()'
    options: [object: 'foo']
    errors: [
      message: "'foo.bar' is restricted from being used."
      type: 'MemberExpression'
    ]
  ,
    code: 'foo.bar.baz'
    options: [property: 'bar']
    errors: [
      message: "'bar' is restricted from being used.", type: 'MemberExpression'
    ]
  ,
    code: 'foo.bar()'
    options: [property: 'bar']
    errors: [
      message: "'bar' is restricted from being used.", type: 'MemberExpression'
    ]
  ,
    code: 'foo.bar.baz()'
    options: [property: 'bar']
    errors: [
      message: "'bar' is restricted from being used.", type: 'MemberExpression'
    ]
  ,
    code: "require.call({}, 'foo')"
    options: [
      object: 'require'
      message: 'Please call require() directly.'
    ]
    errors: [
      message:
        "'require.call' is restricted from being used. Please call require() directly."
      type: 'MemberExpression'
    ]
  ,
    code: "require['resolve']"
    options: [object: 'require']
    errors: [
      message: "'require.resolve' is restricted from being used."
      type: 'MemberExpression'
    ]
  ,
    code: '{bar} = foo'
    options: [object: 'foo', property: 'bar']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: '{bar: baz} = foo'
    options: [object: 'foo', property: 'bar']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: "{'bar': baz} = foo"
    options: [object: 'foo', property: 'bar']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: '{bar: {baz: qux}} = foo'
    options: [object: 'foo', property: 'bar']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: '{bar} = foo'
    options: [object: 'foo']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: '{bar: baz} = foo'
    options: [object: 'foo']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: '{bar} = foo'
    options: [property: 'bar']
    errors: [
      message: "'bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: '''
      bar = null
      ({bar: baz = 1} = foo)
    '''
    options: [object: 'foo', property: 'bar']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: 'qux = ({bar} = foo) ->'
    options: [object: 'foo', property: 'bar']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: '({bar: baz} = foo) ->'
    options: [object: 'foo', property: 'bar']
    errors: [
      message: "'foo.bar' is restricted from being used.", type: 'ObjectPattern'
    ]
  ,
    code: "{['foo']: qux, bar} = baz"
    options: [object: 'baz', property: 'foo']
    errors: [
      message: "'baz.foo' is restricted from being used.", type: 'ObjectPattern'
    ]
  ]
