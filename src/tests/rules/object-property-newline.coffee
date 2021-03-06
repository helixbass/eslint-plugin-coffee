###*
# @fileoverview Rule to enforce placing object properties on separate lines.
# @author Vitor Balocco
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/object-property-newline'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'object-property-newline', rule,
  valid: [
    # default-case
    '''
      obj = {
        k1: 'val1',
        k2: 'val2',
        k3: 'val3',
        k4: 'val4'
      }
    '''
    '''
      obj =
        k1: 'val1'
        k2: 'val2'
        k3: 'val3'
        k4: 'val4'
    '''
    '''
      obj = {
        k1: 'val1'
        , k2: 'val2'
        , k3: 'val3'
        , k4: 'val4'
      }
    '''
    '''
      obj = {
        k1: 'val1',
        k2: 'val2',
        k3: 'val3',
        k4: 'val4' }
    '''
    '''
      obj = { k1: 'val1'
        , k2: 'val2'
        , k3: 'val3'
        , k4: 'val4' }
    '''
    "obj = { k1: 'val1' }"
    '''
      obj = {
        k1: 'val1'
      }
    '''
    'obj = {}'
  ,
    code: '''
      obj = {
        [bar]: 'baz'
        baz
      }
    '''
  ,
    code: '''
      obj = {
        k1: 'val1',
        k2: 'val2',
        ...{}
      }
    '''
  ,
    code: '''
      obj = {
        k1: 'val1'
        k2: 'val2'
        ...{}
      }
    '''
  ,
    code: 'obj = { ...{} }'
  ,
    '''
      foo({ k1: 'val1',
      k2: 'val2' })
    '''
    '''
      foo({
        k1: 'val1',
        k2: 'val2'
      })
    '''
  ,
    code: '''
      foo({
        a,
        b
      })
    '''
  ,
    code: '''
      foo({
        a,
        b,
        })
    '''
  ,
    code: '''
      foo({
        bar: ->
        baz
      })
    '''
  ,
    code: '''
      foo({
        [bar]: 'baz',
        baz
      })
    '''
  ,
    code: '''
      foo({
        k1: 'val1',
        k2: 'val2',
        ...{}
      })
    '''
  ,
    code: '''
      foo({ k1: 'val1',
      k2: 'val2',
      ...{} })
    '''
  ,
    code: 'foo({ ...{} })'
  ,
    # allowAllPropertiesOnSameLine: true
    code: "obj = { k1: 'val1', k2: 'val2', k3: 'val3' }"
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: '''
      obj =
        k1: 'val1', k2: 'val2', k3: 'val3'
    '''
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: "obj = { k1: 'val1' }"
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: '''
      obj = {
        k1: 'val1'
      }
    '''
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: 'obj = {}', options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: "obj = { 'k1': 'val1', k2: 'val2', ...{} }"
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: '''
      obj = {
        'k1': 'val1', k2: 'val2', ...{}
      }
    '''
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: "foo({ k1: 'val1', k2: 'val2' })"
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: '''
      foo
        k1: 'val1', k2: 'val2'
    '''
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: 'foo({ a, b })'
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: 'foo({ bar: ->, baz })'
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: "foo({ [bar]: 'baz', baz })"
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: "foo({ 'k1': 'val1', k2: 'val2', ...{} })"
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: '''
      foo({
        'k1': 'val1', k2: 'val2', ...{}
      })
    '''
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: "obj = {k1: ['foo', 'bar'], k2: 'val1', k3: 'val2'}"
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: '''
      obj = {
        k1: ['foo', 'bar'], k2: 'val1', k3: 'val2'
      }
    '''
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    code: '''
      obj = {
        k1: 'val1', k2: {e1: 'foo', e2: 'bar'}, k3: 'val2'
      }
    '''
    options: [allowAllPropertiesOnSameLine: yes]
  ,
    # allowMultiplePropertiesPerLine: true (deprecated)
    code: "obj = { k1: 'val1', k2: 'val2', k3: 'val3' }"
    options: [allowMultiplePropertiesPerLine: yes]
  ]

  invalid: [
    # default-case
    code: "obj = { k1: 'val1', k2: 'val2', k3: 'val3' }"
    # output: "obj = { k1: 'val1',\nk2: 'val2',\nk3: 'val3' }"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 21
    ,
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 33
    ]
  ,
    code: '''
      obj = {
        k1: 'val1', k2: 'val2'
      }
    '''
    # output: "obj = {\nk1: 'val1',\nk2: 'val2'\n}"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 15
    ]
  ,
    code: '''
      obj = {
        k1: 'val1', k2: 'val2',
        k3: 'val3', k4: 'val4'
      }
    '''
    # output: "obj = {\nk1: 'val1',\nk2: 'val2',\nk3: 'val3',\nk4: 'val4'\n}"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 15
    ,
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 3
      column: 15
    ]
  ,
    code: "obj = {k1: ['foo', 'bar'], k2: 'val1'}"
    # output: "obj = {k1: ['foo', 'bar'],\nk2: 'val1'}"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 28
    ]
  ,
    code: '''
      obj = {k1: [
        'foo', 'bar'
      ], k2: 'val1'}
    '''
    # output: "obj = {k1: [\n'foo', 'bar'\n],\nk2: 'val1'}"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 3
      column: 4
    ]
  ,
    code: '''
      obj = {
        k1: 'val1', k2: {e1: 'foo', e2: 'bar'}, k3: 'val2'
      }
    '''
    # output:
    #   "obj = {\nk1: 'val1',\nk2: {e1: 'foo',\ne2: 'bar'},\nk3: 'val2'\n}"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 15
    ,
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 31
    ,
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 43
    ]
  ,
    code: '''
      obj = {
        k1: 'val1',
        k2: {e1: 'foo', e2: 'bar'},
        k3: 'val2'
      }
    '''
    # output:
    #   "obj = {\nk1: 'val1',\nk2: {e1: 'foo',\ne2: 'bar'},\nk3: 'val2'\n}"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 3
      column: 19
    ]
  ,
    code: '''
      obj = {
        k1: 'val1',
        k2: [
          'val2a', 'val2b', 'val2c'
        ], k3: 'val3' }
    '''
    # output:
    #   "obj = { k1: 'val1',\nk2: [\n'val2a', 'val2b', 'val2c'\n],\nk3: 'val3' }"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 5
      column: 6
    ]
  ,
    code: "obj = { k1: 'val1', ...{} }"
    # output: "obj = { k1: 'val1',\n...{} }"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 21
    ]
  ,
    code: '''
      obj = {
        k1: 'val1', ...{}
      }
    '''
    # output: "obj = {\nk1: 'val1',\n...{}\n}"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 15
    ]
  ,
    code: "foo({ k1: 'val1', k2: 'val2' })"
    # output: "foo({ k1: 'val1',\nk2: 'val2' })"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 19
    ]
  ,
    code: '''
      foo
        k1: 'val1', k2: 'val2'
    '''
    # output: "foo({\nk1: 'val1',\nk2: 'val2'\n})"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 15
    ]
  ,
    code: 'foo({ a, b })'
    # output: 'foo({ a,\nb })'
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 10
    ]
  ,
    code: '''
      foo({
        a, b
      })
    '''
    # output: 'foo({\na,\nb\n})'
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 6
    ]
  ,
    code: '''
      foo({
        bar: ->, baz
      })
    '''
    # output: 'foo({\nbar() {},\nbaz\n})'
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 12
    ]
  ,
    code: '''
      foo({
        [bar]: 'baz', baz
      })
    '''
    # output: "foo({\n[bar]: 'baz',\nbaz\n})"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 17
    ]
  ,
    code: "foo({ k1: 'val1', ...{} })"
    # output: "foo({ k1: 'val1',\n...{} })"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 19
    ]
  ,
    code: '''
      foo {
        k1: 'val1', ...{}
      }
    '''
    # output: "foo({\nk1: 'val1',\n...{}\n})"
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 2
      column: 15
    ]
  ,
    code: '''
      obj = {
        a: {
          b: 1,
          c: 2
        }, d: 2
      }
    '''
    # output: 'obj = {\na: {\nb: 1,\nc: 2\n},\nd: 2\n}'
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 5
      column: 6
    ]
  ,
    code: '({ foo: 1 ### comment ###, bar: 2 })'
    # output: '({ foo: 1 ### comment ###,\nbar: 2 })'
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 28
    ]
  ,
    code: '({ foo: 1, ### comment ### bar: 2 })'
    # output: null # not fixed due to comment
    errors: [
      message: 'Object properties must go on a new line.'
      type: 'ObjectExpression'
      line: 1
      column: 28
    ]
  ,
    # allowAllPropertiesOnSameLine: true
    code: '''
      obj = {
        k1: 'val1',
        k2: 'val2', k3: 'val3'
      }
    '''
    # output: "obj = {\nk1: 'val1',\nk2: 'val2',\nk3: 'val3'\n}"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 3
      column: 15
    ]
  ,
    code: '''
      obj = {
        k1:
          'val1'
        k2: 'val2', k3:
            'val3'
      }
    '''
    # output: "obj = {\nk1:\n'val1',\nk2: 'val2',\nk3:\n'val3'\n}"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 4
      column: 15
    ]
  ,
    code: '''
      obj = {k1: [
        'foo'
        'bar'
      ], k2: 'val1'}
    '''
    # output: "obj = {k1: [\n'foo',\n'bar'\n],\nk2: 'val1'}"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 4
      column: 4
    ]
  ,
    code: '''
      obj = {k1: [
        'foo', 'bar'
      ], k2: 'val1'}
    '''
    # output: "obj = {k1: [\n'foo', 'bar'\n],\nk2: 'val1'}"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 3
      column: 4
    ]
  ,
    code: '''
      obj = {
        k1: 'val1', k2: {
          e1: 'foo', e2: 'bar'
        }, k3: 'val2'
      }
    '''
    # output:
    #   "obj = {\nk1: 'val1',\nk2: {\ne1: 'foo', e2: 'bar'\n},\nk3: 'val2'\n}"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 2
      column: 15
    ,
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 4
      column: 6
    ]
  ,
    code: '''
      obj = {
        k1: 'val1',
        k2: [
          'val2a', 'val2b', 'val2c'
        ], k3: 'val3' }
    '''
    # output:
    #   "obj = { k1: 'val1',\nk2: [\n'val2a', 'val2b', 'val2c'\n],\nk3: 'val3' }"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 5
      column: 6
    ]
  ,
    code: '''
      obj = {
        k1: 'val1',
        k2: 'val2', ...{}
      }
    '''
    # output: "obj = {\nk1: 'val1',\nk2: 'val2',\n...{}\n}"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 3
      column: 15
    ]
  ,
    code: '''
      obj = {
        ...{},
        k1: 'val1', k2: 'val2'
      }
    '''
    # output: "obj = {\n...{},\nk1: 'val1',\nk2: 'val2'\n}"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 3
      column: 15
    ]
  ,
    code: '''
      foo({
        k1: 'val1',
        k2: 'val2', ...{}
      })
    '''
    # output: "foo({\nk1: 'val1',\nk2: 'val2',\n...{}\n})"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 3
      column: 15
    ]
  ,
    code: '''
      foo({
        ...{},
        k1: 'val1', k2: 'val2'
      })
    '''
    # output: "foo({\n...{},\nk1: 'val1',\nk2: 'val2'\n})"
    options: [allowAllPropertiesOnSameLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 3
      column: 15
    ]
  ,
    # allowMultiplePropertiesPerLine: true (deprecated)
    code: '''
      obj = {
        k1: 'val1',
        k2: 'val2', k3: 'val3'
      }
    '''
    # output: "obj = {\nk1: 'val1',\nk2: 'val2',\nk3: 'val3'\n}"
    options: [allowMultiplePropertiesPerLine: yes]
    errors: [
      message:
        "Object properties must go on a new line if they aren't all on the same line."
      type: 'ObjectExpression'
      line: 3
      column: 15
    ]
  ]
