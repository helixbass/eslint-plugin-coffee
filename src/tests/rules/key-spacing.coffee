###*
# @fileoverview Tests for key-spacing rule.
# @author Brandon Mills
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/key-spacing'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'key-spacing', rule,
  valid: [
    '''
      {
      }
    '''
    '''
      {
        a: b
      }
    '''
    '''
      {
        a:
          b
      }
    '''
    '''
      a: b
    '''
    '''
      a:
        b
    '''
  ,
    code: '''
      {
      }
    '''
    options: [align: 'colon']
  ,
    code: '''
      {
        a: b
      }
    '''
    options: [align: 'value']
  ,
    code: 'obj = key: value'
    options: [{}]
  ,
    code: 'obj = { [(a + b)]: value }'
    options: [{}]
  ,
    code: 'foo = a:bar'
    options: [
      beforeColon: no
      afterColon: no
    ]
  ,
    code: 'foo = a: bar'
    options: [
      beforeColon: no
      afterColon: yes
    ]
  ,
    code: "foo 'default': ->"
    options: [
      beforeColon: no
      afterColon: yes
    ]
  ,
    code: '''
      ->
        return {
          key: (foo is 4)
        }
    '''
    options: [
      beforeColon: no
      afterColon: yes
    ]
  ,
    code: "obj = {'key' :42 }"
    options: [
      beforeColon: yes
      afterColon: no
    ]
  ,
    code: "({a : foo, b : bar})['a']"
    options: [
      beforeColon: yes
      afterColon: yes
    ]
  ,
    code: '''
      obj = {
        'a'     : (42 - 12)
        foobar  : 'value'
        [(expr)]: val
      }
    '''
    options: [align: 'colon']
  ,
    code: '''
      callExpr arg,
        key       :val
        'another' :false
        [compute] :'value'
    '''
    options: [
      align: 'colon'
      beforeColon: yes
      afterColon: no
    ]
  ,
    code: '''
      obj =
        a:        (42 - 12)
        'foobar': 'value'
        bat:      ->
            return this.a
        baz: 42
    '''
    options: [align: 'value']
  ,
    code: '''
      callExpr arg,
        'asdf' :val
        foobar :false
        key :   value
    '''
    options: [
      align: 'value'
      beforeColon: yes
      afterColon: no
    ]
  ,
    code: '''
      a  : 0
      # same group
      bcd: 0, ###
      end of group ###

      # different group
      e: 0
      ### group b ###
      f: 0
    '''
    options: [align: 'colon']
  ,
    code: 'obj = { key     :longName }'
    options: [
      beforeColon: yes
      afterColon: no
      mode: 'minimum'
    ]
  ,
    code: "obj = {foo: 'fee', bar: 'bam'}"
    options: [align: 'colon']
  ,
    code: "obj = a: 'foo', bar: 'bam'"
    options: [align: 'colon']
  ,
    code: '''
      a = 'a'
      b = 'b'

      export default {
        a,
        b
      }
    '''
    options: [align: 'value']
  ,
    code: '''
      test = {
        prop: 123,
        a,
        b
      }
   '''
  ,
    code: '''
      test = {
        prop: 456,
        c,
        d
      }
    '''
    options: [align: 'value']
  ,
    code: '''
      obj = {
        foobar: 123
        prop
        baz:    456
      }
    '''
    options: [align: 'value']
  ,
    code: '''
      obj =
        foo : foo
        bar : bar
        cats: cats
    '''
    options: [align: 'colon']
  ,
    code: '''
      obj =
        foo :  foo
        bar :  bar
        cats : cats
    '''
    options: [
      align: 'value'
      beforeColon: yes
    ]
  ,
    # https:#github.com/eslint/eslint/issues/4763
    code: "({a : foo, ...x, b : bar})['a']"
    options: [
      beforeColon: yes
      afterColon: yes
    ]
  ,
    code: '''
      obj = {
        'a'     : (42 - 12)
        ...x
        foobar  : 'value'
        [(expr)]: val
      }
    '''
    options: [align: 'colon']
  ,
    code: '''
      callExpr arg, {
          key       :val
          ...x
          ...y
          'another' :false
          [compute] :'value'
      }
    '''
    options: [
      align: 'colon'
      beforeColon: yes
      afterColon: no
    ]
  ,
    code: '''
      obj = {
        a:        (42 - 12)
        ...x
        'foobar': 'value'
        bat:      ->
            return this.a
        baz: 42
      }
    '''
    options: [align: 'value']
  ,
    code: '''
      {
         ...x
         a  : 0
         # same group
         bcd: 0 ###
         end of group ###

         # different group
         e: 0
         ...y
         ### group b ###
         f: 0
      }
    '''
    options: [align: 'colon']
  ,
    code: '''
      obj = {
        foobar: 42
        bat:    2
      }
    '''
    options: [
      singleLine:
        beforeColon: no
        afterColon: yes
        mode: 'strict'
      multiLine:
        beforeColon: no
        afterColon: yes
        mode: 'minimum'
    ]
  ,
    # https:#github.com/eslint/eslint/issues/5724
    code: '{...object}'
    options: [align: 'colon']
  ,
    # https:#github.com/eslint/eslint/issues/5613

    # if `align` is an object, but `on` is not declared, `on` defaults to `colon`
    code: '''
      {
         longName: 1
         small   : 2
         f       : ->
           b
         xs :3
      }
    '''
    options: [
      align:
        afterColon: yes
      beforeColon: yes
      afterColon: no
    ]
  ,
    code: '''
      longName: 1
      small:    2
      f:        ->
        b
      xs :3
    '''
    options: [
      align:
        on: 'value'
        afterColon: yes
      beforeColon: yes
      afterColon: no
    ]
  ,
    code: '''
      {
         longName : 1
         small :    2
         xs :       3
      }
    '''
    options: [
      multiLine:
        align:
          on: 'value'
          beforeColon: yes
          afterColon: yes
    ]
  ,
    code: '''
      longName :1
      small    :2
      xs       :3
    '''
    options: [
      align:
        on: 'colon'
        beforeColon: yes
        afterColon: no
    ]
  ,
    code: '''
      longName: 1
      small   : 2
      xs      :        3
    '''
    options: [
      align:
        on: 'colon'
        beforeColon: no
        afterColon: yes
        mode: 'minimum'
    ]
  ,
    code: '''
      longName: 1
      small   : 2
      xs      : 3
    '''
    options: [
      multiLine:
        align:
          on: 'colon'
          beforeColon: no
          afterColon: yes
    ]
  ,
    code: '''
      func: ->
        test = true
      longName : 1
      small    : 2
      xs       : 3
      func2    : ->
        test2 = true
      internalGroup:
        internal : true
        ext      : false
    '''
    options: [
      singleLine:
        beforeColon: no
        afterColon: yes
      multiLine:
        beforeColon: no
        afterColon: yes
      align:
        on: 'colon'
        beforeColon: yes
        afterColon: yes
    ]
  ,
    code: '''
      {
        func: ->
          test = true
        longName: 1
        small:    2
        xs:       3
        func2:    ->
          test2 = true
        final: 10
      }
    '''
    options: [
      singleLine:
        beforeColon: no
        afterColon: yes
      multiLine:
        align:
          on: 'value'
          beforeColon: no
          afterColon: yes
        beforeColon: no
        afterColon: yes
    ]
  ,
    code: '''
      f:->
        test = true
      stateName : 'NY'
      borough   : 'Brooklyn'
      zip       : 11201
      f2        : ->
        test2 = true
      final:10
    '''
    options: [
      multiLine:
        align:
          on: 'colon'
          beforeColon: yes
          afterColon: yes
          mode: 'strict'
        beforeColon: no
        afterColon: no
    ]
  ,
    code: '''
      obj =
        key1: 1

        key2:    2
        key3:    3

        key4: 4
    '''
    options: [
      multiLine:
        beforeColon: no
        afterColon: yes
        mode: 'strict'
        align:
          beforeColon: no
          afterColon: yes
          on: 'colon'
          mode: 'minimum'
    ]
  ,
    code: '''
      obj = {
        key1: 1,

        key2:    2,
        key3:    3,

        key4: 4
      }
    '''
    options: [
      multiLine:
        beforeColon: no
        afterColon: yes
        mode: 'strict'
      align:
        beforeColon: no
        afterColon: yes
        on: 'colon'
        mode: 'minimum'
    ]
  ]

  invalid: [
    code: "bat = -> return { foo:bar, 'key': value }"
    output: "bat = -> return { foo:bar, 'key':value }"
    options: [
      beforeColon: no
      afterColon: no
    ]
    errors: [
      message: "Extra space before value for key 'key'."
      type: 'Identifier'
      line: 1
      column: 35
    ]
  ,
    code: 'obj = { [ (a + b) ]:value }'
    output: 'obj = { [ (a + b) ]: value }'
    options: [{}]
    errors: [
      message: "Missing space before value for computed key 'a + b'."
      type: 'Identifier'
      line: 1
      column: 21
    ]
  ,
    code: "fn({ foo:bar, 'key' :value })"
    output: "fn({ foo:bar, 'key':value })"
    options: [
      beforeColon: no
      afterColon: no
    ]
    errors: [
      message: "Extra space after key 'key'."
      type: 'Literal'
      line: 1
      column: 15
    ]
  ,
    code: 'obj = prop :(42)'
    output: 'obj = prop : (42)'
    options: [
      beforeColon: yes
      afterColon: yes
    ]
    errors: [
      message: "Missing space before value for key 'prop'."
      type: 'Literal'
      line: 1
      column: 13
    ]
  ,
    code: "({'a' : foo, b: bar() }).b()"
    output: "({'a' : foo, b : bar() }).b()"
    options: [
      beforeColon: yes
      afterColon: yes
    ]
    errors: [
      message: "Missing space after key 'b'."
      type: 'Identifier'
      line: 1
      column: 14
    ]
  ,
    code: "({'a'  :foo(), b:  bar() }).b()"
    output: "({'a' : foo(), b : bar() }).b()"
    options: [
      beforeColon: yes
      afterColon: yes
    ]
    errors: [
      message: "Extra space after key 'a'."
      type: 'Literal'
      line: 1
      column: 3
    ,
      message: "Missing space before value for key 'a'."
      type: 'CallExpression'
      line: 1
      column: 9
    ,
      message: "Missing space after key 'b'."
      type: 'Identifier'
      line: 1
      column: 16
    ,
      message: "Extra space before value for key 'b'."
      type: 'CallExpression'
      line: 1
      column: 20
    ]
  ,
    code: 'bar = { key:value }'
    output: 'bar = { key: value }'
    options: [
      beforeColon: no
      afterColon: yes
    ]
    errors: [
      message: "Missing space before value for key 'key'."
      type: 'Identifier'
      line: 1
      column: 13
    ]
  ,
    code: '''
      obj =
        key:   value
        foobar:fn()
        'a'   : (2 * 2)
    '''
    output: '''
      obj =
        key   : value
        foobar: fn()
        'a'   : (2 * 2)
    '''
    options: [align: 'colon']
    errors: [
      message: "Missing space after key 'key'."
      type: 'Identifier'
      line: 2
      column: 3
    ,
      message: "Extra space before value for key 'key'."
      type: 'Identifier'
      line: 2
      column: 10
    ,
      message: "Missing space before value for key 'foobar'."
      type: 'CallExpression'
      line: 3
      column: 10
    ]
  ,
    code: '''
      ({
        'a' : val
        foo:fn()
        b    :[42]
        c   :call()
      }).a()
    '''
    output: '''
      ({
        'a' :val
        foo :fn()
        b   :[42]
        c   :call()
      }).a()
    '''
    options: [
      align: 'colon'
      beforeColon: yes
      afterColon: no
    ]
    errors: [
      message: "Extra space before value for key 'a'."
      type: 'Identifier'
      line: 2
      column: 9
    ,
      message: "Missing space after key 'foo'."
      type: 'Identifier'
      line: 3
      column: 3
    ,
      message: "Extra space after key 'b'."
      type: 'Identifier'
      line: 4
      column: 3
    ]
  ,
    code: '''
      obj =
        a:    fn()
        'b' : 42
        foo:(bar)
        bat: 'valid'
        [a] : value
    '''
    output: '''
      obj =
        a:   fn()
        'b': 42
        foo: (bar)
        bat: 'valid'
        [a]: value
    '''
    options: [align: 'value']
    errors: [
      message: "Extra space before value for key 'a'."
      type: 'CallExpression'
      line: 2
      column: 9
    ,
      message: "Extra space after key 'b'."
      type: 'Literal'
      line: 3
      column: 3
    ,
      message: "Missing space before value for key 'foo'."
      type: 'Identifier'
      line: 4
      column: 7
    ,
      message: "Extra space after computed key 'a'."
      type: 'Identifier'
      line: 6
      column: 5
    ]
  ,
    code: '''
      foo =
        a:  value,
        b :  42,
        foo :['a'],
        bar : call(),
    '''
    output: '''
      foo =
        a :  value,
        b :  42,
        foo :['a'],
        bar :call(),
    '''
    options: [
      align: 'value'
      beforeColon: yes
      afterColon: no
    ]
    errors: [
      message: "Missing space after key 'a'."
      type: 'Identifier'
      line: 2
      column: 3
    ,
      message: "Extra space before value for key 'bar'."
      type: 'CallExpression'
      line: 5
      column: 9
    ]
  ,
    code: '''
      a : 0
      bcd: 0

      e: 0
      fg:0
    '''
    output: '''
      a  : 0
      bcd: 0

      e : 0
      fg: 0
    '''
    options: [align: 'colon']
    errors: [
      message: "Missing space after key 'a'."
      type: 'Identifier'
      line: 1
      column: 1
    ,
      message: "Missing space after key 'e'."
      type: 'Identifier'
      line: 4
      column: 1
    ,
      message: "Missing space before value for key 'fg'."
      type: 'Literal'
      line: 5
      column: 4
    ]
  ,
    code: '''
      foo =
        key1: 42
        # still the same group
        key12: '42' ###

        ###
        key123: 'forty two'
    '''
    output: '''
      foo =
        key1:   42
        # still the same group
        key12:  '42' ###

        ###
        key123: 'forty two'
    '''
    options: [align: 'value']
    errors: [
      message: "Missing space before value for key 'key1'.", type: 'Literal'
    ,
      message: "Missing space before value for key 'key12'.", type: 'Literal'
    ]
  ,
    code: 'foo = { key:(1+2) }'
    output: 'foo = { key: (1+2) }'
    errors: [
      message: "Missing space before value for key 'key'."
      line: 1
      column: 13
      type: 'BinaryExpression'
    ]
  ,
    code: 'foo = { key:( ( (1+2) ) ) }'
    output: 'foo = { key: ( ( (1+2) ) ) }'
    errors: [
      message: "Missing space before value for key 'key'."
      line: 1
      column: 13
      type: 'BinaryExpression'
    ]
  ,
    code: "obj = {a  : 'foo', bar: 'bam'}"
    output: "obj = {a: 'foo', bar: 'bam'}"
    options: [align: 'colon']
    errors: [
      message: "Extra space after key 'a'."
      line: 1
      column: 8
      type: 'Identifier'
    ]
  ,
    code: '''
      obj = {
        foobar: 123
        prop
        baz: 456
      }
    '''
    output: '''
      obj = {
        foobar: 123
        prop
        baz:    456
      }
    '''
    options: [align: 'value']
    errors: [
      message: "Missing space before value for key 'baz'."
      line: 4
      column: 8
      type: 'Literal'
    ]
  ,
    code: '''
      obj = {
        foobar:  123
        prop
        baz:    456
      }
    '''
    output: '''
      obj = {
        foobar: 123
        prop
        baz:    456
      }
    '''
    options: [align: 'value']
    errors: [
      message: "Extra space before value for key 'foobar'."
      line: 2
      column: 12
      type: 'Literal'
    ]
  ,
    # https:#github.com/eslint/eslint/issues/4763
    code: '''
      {
        ...x
        a : 0
        # same group
        bcd: 0 ###
        end of group ###

        # different group
        e: 0
        ...y
        ### group b ###
        f : 0
      }
    '''
    output: '''
      {
        ...x
        a  : 0
        # same group
        bcd: 0 ###
        end of group ###

        # different group
        e: 0
        ...y
        ### group b ###
        f: 0
      }
    '''
    options: [align: 'colon']
    errors: [
      message: "Missing space after key 'a'."
      line: 3
      column: 3
      type: 'Identifier'
    ,
      message: "Extra space after key 'f'."
      line: 12
      column: 3
      type: 'Identifier'
    ]
  ,
    # https:#github.com/eslint/eslint/issues/5724
    code: '({ a:b, ...object, c : d })'
    output: '({ a: b, ...object, c: d })'
    options: [align: 'colon']
    errors: [
      message: "Missing space before value for key 'a'."
      line: 1
      column: 6
      type: 'Identifier'
    ,
      message: "Extra space after key 'c'."
      line: 1
      column: 20
      type: 'Identifier'
    ]
  ,
    # https:#github.com/eslint/eslint/issues/5613
    code: '''
      longName:1
      small    :2
      xs      : 3
    '''
    output: '''
      longName : 1
      small    : 2
      xs       : 3
    '''
    options: [
      align:
        on: 'colon'
        beforeColon: yes
        afterColon: yes
        mode: 'strict'
    ]
    errors: [
      message: "Missing space after key 'longName'."
      line: 1
      column: 1
      type: 'Identifier'
    ,
      message: "Missing space before value for key 'longName'."
      line: 1
      column: 10
      type: 'Literal'
    ,
      message: "Missing space before value for key 'small'."
      line: 2
      column: 11
      type: 'Literal'
    ,
      message: "Missing space after key 'xs'."
      line: 3
      column: 1
      type: 'Identifier'
    ]
  ,
    code: '''
      func:->
        test = true
      longName: 1
      small: 2
      xs            : 3
      func2    : ->
        test2 = true
      singleLine : 10
    '''
    output: '''
      func: ->
        test = true
      longName : 1
      small    : 2
      xs       : 3
      func2    : ->
        test2 = true
      singleLine: 10
    '''
    options: [
      multiLine:
        beforeColon: no
        afterColon: yes
      align:
        on: 'colon'
        beforeColon: yes
        afterColon: yes
        mode: 'strict'
    ]
    errors: [
      message: "Missing space before value for key 'func'."
      line: 1
      column: 6
      type: 'FunctionExpression'
    ,
      message: "Missing space after key 'longName'."
      line: 3
      column: 1
      type: 'Identifier'
    ,
      message: "Missing space after key 'small'."
      line: 4
      column: 1
      type: 'Identifier'
    ,
      message: "Extra space after key 'xs'."
      line: 5
      column: 1
      type: 'Identifier'
    ,
      message: "Extra space after key 'singleLine'."
      line: 8
      column: 1
      type: 'Identifier'
    ]
  ,
    code: '''
      func:->
        test = no
      longName :1
      small :2
      xs            : 3
      func2    : ->
        test2 = true
      singleLine : 10
    '''
    output: '''
      func: ->
        test = no
      longName :1
      small    :2
      xs       :3
      func2    :->
        test2 = true
      singleLine: 10
    '''
    options: [
      multiLine:
        beforeColon: no
        afterColon: yes
        align:
          on: 'colon'
          beforeColon: yes
          afterColon: no
          mode: 'strict'
    ]
    errors: [
      message: "Missing space before value for key 'func'."
      line: 1
      column: 6
      type: 'FunctionExpression'
    ,
      message: "Missing space after key 'small'."
      line: 4
      column: 1
      type: 'Identifier'
    ,
      message: "Extra space after key 'xs'."
      line: 5
      column: 1
      type: 'Identifier'
    ,
      message: "Extra space before value for key 'xs'."
      line: 5
      column: 17
      type: 'Literal'
    ,
      message: "Extra space before value for key 'func2'."
      line: 6
      column: 12
      type: 'FunctionExpression'
    ,
      message: "Extra space after key 'singleLine'."
      line: 8
      column: 1
      type: 'Identifier'
    ]
  ,
    code: '''
      obj =
        key1: 1

        key2:    2
        key3:    3

        key4: 4
    '''
    output: '''
      obj =
        key1: 1

        key2: 2
        key3: 3

        key4: 4
    '''
    options: [
      multiLine:
        beforeColon: no
        afterColon: yes
        mode: 'strict'
        align:
          beforeColon: no
          afterColon: yes
          on: 'colon'
    ]
    errors: [
      message: "Extra space before value for key 'key2'."
      line: 4
      column: 12
      type: 'Literal'
    ,
      message: "Extra space before value for key 'key3'."
      line: 5
      column: 12
      type: 'Literal'
    ]
  ,
    code: '''
      obj =
        key1: 1

        key2:    2
        key3:    3

        key4: 4
    '''
    output: '''
      obj =
        key1: 1

        key2: 2
        key3: 3

        key4: 4
    '''
    options: [
      multiLine:
        beforeColon: no
        afterColon: yes
        mode: 'strict'
      align:
        beforeColon: no
        afterColon: yes
        on: 'colon'
    ]
    errors: [
      message: "Extra space before value for key 'key2'."
      line: 4
      column: 12
      type: 'Literal'
    ,
      message: "Extra space before value for key 'key3'."
      line: 5
      column: 12
      type: 'Literal'
    ]
  ,
    # https://github.com/eslint/eslint/issues/7603
    code: '({ foo### comment ### : bar })'
    output: '({ foo### comment ###: bar })'
    errors: [
      message: "Extra space after key 'foo'."
      line: 1
      column: 7
      type: 'Identifier'
    ]
  ,
    code: '({ foo: ### comment ###bar })'
    output: '({ foo:### comment ###bar })'
    options: [afterColon: no]
    errors: [
      message: "Extra space before value for key 'foo'."
      line: 1
      column: 9
      type: 'Identifier'
    ]
  ,
    code: '({ foo###comment###:###comment###bar })'
    output: '({ foo###comment### : ###comment###bar })'
    options: [beforeColon: yes, afterColon: yes]
    errors: [
      message: "Missing space after key 'foo'."
      line: 1
      column: 7
      type: 'Identifier'
    ,
      message: "Missing space before value for key 'foo'."
      line: 1
      column: 21
      type: 'Identifier'
    ]
  ]
