###*
# @fileoverview This rule shoud require or disallow spaces before or after unary operations.
# @author Marcin Kumorek
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/space-unary-ops'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'space-unary-ops', rule,
  valid: [
    code: '++this.a'
    options: [words: yes]
  ,
    code: '++@a'
    options: [words: yes]
  ,
    code: '--this.a'
    options: [words: yes]
  ,
    code: 'this.a++'
    options: [words: yes]
  ,
    code: 'this.a--'
    options: [words: yes]
  ,
    'foo .bar++'
  ,
    code: 'delete foo.bar'
    options: [words: yes]
  ,
    code: 'delete foo["bar"]'
    options: [words: yes]
  ,
    code: 'delete foo.bar'
    options: [words: no]
  ,
    code: 'delete(foo.bar)'
    options: [words: no]
  ,
    code: 'new Foo'
    options: [words: yes]
  ,
    code: 'new Foo()'
    options: [words: yes]
  ,
    code: 'new [foo][0]'
    options: [words: yes]
  ,
    code: 'new[foo][0]'
    options: [words: no]
  ,
    code: 'not b'
    options: [words: no]
  ,
    code: 'typeof foo'
    options: [words: yes]
  ,
    code: 'typeof{foo:true}'
    options: [words: no]
  ,
    code: 'typeof {foo:true}'
    options: [words: yes]
  ,
    code: 'typeof (foo)'
    options: [words: yes]
  ,
    code: 'typeof(foo)'
    options: [words: no]
  ,
    code: 'typeof!foo'
    options: [words: no]
  ,
    code: '-1'
    options: [nonwords: no]
  ,
    code: '!foo'
    options: [nonwords: no]
  ,
    code: '!!foo'
    options: [nonwords: no]
  ,
    code: 'foo++'
    options: [nonwords: no]
  ,
    code: '++foo'
    options: [nonwords: no]
  ,
    code: '++ foo'
    options: [nonwords: yes]
  ,
    '-> yield (0)'
    '-> yield +1'
    '-> yield* 0'
    '-> yield * 0'
    '-> (yield)*0'
    '-> (yield) * 0'
    '-> yield*0'
    '-> yield *0'
    '-> await {foo: 1}'
    '-> await {bar: 2}'
  ,
    code: '-> await{baz: 3}'
    options: [words: no]
  ,
    code: '-> await {qux: 4}'
    options: [words: no, overrides: await: yes]
  ,
    code: '-> await{foo: 5}'
    options: [words: yes, overrides: await: no]
  ,
    code: 'foo++'
    options: [nonwords: yes, overrides: '++': no]
  ,
    code: 'foo++'
    options: [nonwords: no, overrides: '++': no]
  ,
    code: '++foo'
    options: [nonwords: yes, overrides: '++': no]
  ,
    code: '++foo'
    options: [nonwords: no, overrides: '++': no]
  ,
    code: '!foo'
    options: [nonwords: yes, overrides: '!': no]
  ,
    code: '!foo'
    options: [nonwords: no, overrides: '!': no]
  ,
    code: 'new foo'
    options: [words: yes, overrides: new: no]
  ,
    code: 'new foo'
    options: [words: no, overrides: new: no]
  ,
    code: '-> yield(0)'
    options: [words: yes, overrides: yield: no]
  ,
    code: '-> yield(0)'
    options: [words: no, overrides: yield: no]
  ,
    code: 'foo++'
    options: [nonwords: yes]
  ,
    code: 'foo .bar++'
    options: [nonwords: yes]
  ,
    code: 'b?'
    options: [nonwords: yes]
  ]

  invalid: [
    code: 'delete(foo.bar)'
    output: 'delete (foo.bar)'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'delete' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: 'delete(foo["bar"]);'
    output: 'delete (foo["bar"]);'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'delete' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: 'delete (foo.bar)'
    output: 'delete(foo.bar)'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'delete'."
      type: 'UnaryExpression'
    ]
  ,
    code: 'new(Foo)'
    output: 'new (Foo)'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'new' must be followed by whitespace."
      type: 'NewExpression'
    ]
  ,
    code: 'new (Foo)'
    output: 'new(Foo)'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'new'."
      type: 'NewExpression'
    ]
  ,
    code: 'new(Foo())'
    output: 'new (Foo())'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'new' must be followed by whitespace."
      type: 'NewExpression'
    ]
  ,
    code: 'new [foo][0]'
    output: 'new[foo][0]'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'new'."
      type: 'NewExpression'
    ]
  ,
    code: 'not{foo:true}'
    output: 'not {foo:true}'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'not' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: 'typeof(foo)'
    output: 'typeof (foo)'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'typeof' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: 'typeof (foo)'
    output: 'typeof(foo)'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'typeof'."
      type: 'UnaryExpression'
    ]
  ,
    code: 'typeof[foo]'
    output: 'typeof [foo]'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'typeof' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: 'typeof [foo]'
    output: 'typeof[foo]'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'typeof'."
      type: 'UnaryExpression'
    ]
  ,
    code: 'typeof{foo:true}'
    output: 'typeof {foo:true}'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'typeof' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: 'typeof {foo:true}'
    output: 'typeof{foo:true}'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'typeof'."
      type: 'UnaryExpression'
    ]
  ,
    code: 'typeof!foo'
    output: 'typeof !foo'
    options: [words: yes]
    errors: [
      message: "Unary word operator 'typeof' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: '! foo'
    output: '!foo'
    options: [nonwords: no]
    errors: [message: "Unexpected space after unary operator '!'."]
  ,
    code: '!foo'
    output: '! foo'
    options: [nonwords: yes]
    errors: [message: "Unary operator '!' must be followed by whitespace."]
  ,
    code: '!! foo'
    output: '!!foo'
    options: [nonwords: no]
    errors: [
      message: "Unexpected space after unary operator '!'."
      type: 'UnaryExpression'
      line: 1
      column: 2
    ]
  ,
    code: '!!foo'
    output: '!! foo'
    options: [nonwords: yes]
    errors: [
      message: "Unary operator '!' must be followed by whitespace."
      type: 'UnaryExpression'
      line: 1
      column: 2
    ]
  ,
    code: '- 1'
    output: '-1'
    options: [nonwords: no]
    errors: [
      message: "Unexpected space after unary operator '-'."
      type: 'UnaryExpression'
    ]
  ,
    code: '-1'
    output: '- 1'
    options: [nonwords: yes]
    errors: [
      message: "Unary operator '-' must be followed by whitespace."
      type: 'UnaryExpression'
    ]
  ,
    code: '++ foo'
    output: '++foo'
    options: [nonwords: no]
    errors: [message: "Unexpected space after unary operator '++'."]
  ,
    code: '++foo'
    output: '++ foo'
    options: [nonwords: yes]
    errors: [message: "Unary operator '++' must be followed by whitespace."]
  ,
    code: '+ +foo'
    output: null
    options: [nonwords: no]
    errors: [message: "Unexpected space after unary operator '+'."]
  ,
    code: '+ ++foo'
    output: null
    options: [nonwords: no]
    errors: [message: "Unexpected space after unary operator '+'."]
  ,
    code: '- -foo'
    output: null
    options: [nonwords: no]
    errors: [message: "Unexpected space after unary operator '-'."]
  ,
    code: '- --foo'
    output: null
    options: [nonwords: no]
    errors: [message: "Unexpected space after unary operator '-'."]
  ,
    code: '+ -foo'
    output: '+-foo'
    options: [nonwords: no]
    errors: [message: "Unexpected space after unary operator '+'."]
  ,
    code: '-> yield(0)'
    output: '-> yield (0)'
    errors: [
      message: "Unary word operator 'yield' must be followed by whitespace."
      type: 'YieldExpression'
      line: 1
      column: 4
    ]
  ,
    code: '-> yield (0)'
    output: '-> yield(0)'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'yield'."
      type: 'YieldExpression'
      line: 1
      column: 4
    ]
  ,
    code: '-> yield+0'
    output: '-> yield +0'
    errors: [
      message: "Unary word operator 'yield' must be followed by whitespace."
      type: 'YieldExpression'
      line: 1
      column: 4
    ]
  ,
    code: '++foo'
    output: '++ foo'
    options: [nonwords: yes, overrides: '++': yes]
    errors: [message: "Unary operator '++' must be followed by whitespace."]
  ,
    code: '++foo'
    output: '++ foo'
    options: [nonwords: no, overrides: '++': yes]
    errors: [message: "Unary operator '++' must be followed by whitespace."]
  ,
    code: '!foo'
    output: '! foo'
    options: [nonwords: yes, overrides: '!': yes]
    errors: [message: "Unary operator '!' must be followed by whitespace."]
  ,
    code: '!foo'
    output: '! foo'
    options: [nonwords: no, overrides: '!': yes]
    errors: [message: "Unary operator '!' must be followed by whitespace."]
  ,
    code: 'new(Foo)'
    output: 'new (Foo)'
    options: [words: yes, overrides: new: yes]
    errors: [
      message: "Unary word operator 'new' must be followed by whitespace."
    ]
  ,
    code: 'new(Foo)'
    output: 'new (Foo)'
    options: [words: no, overrides: new: yes]
    errors: [
      message: "Unary word operator 'new' must be followed by whitespace."
    ]
  ,
    code: '-> yield(0)'
    output: '-> yield (0)'
    options: [words: yes, overrides: yield: yes]
    errors: [
      message: "Unary word operator 'yield' must be followed by whitespace."
      type: 'YieldExpression'
      line: 1
      column: 4
    ]
  ,
    code: '-> yield(0)'
    output: '-> yield (0)'
    options: [words: no, overrides: yield: yes]
    errors: [
      message: "Unary word operator 'yield' must be followed by whitespace."
      type: 'YieldExpression'
      line: 1
      column: 4
    ]
  ,
    code: "-> await{foo: 'bar'}"
    output: "-> await {foo: 'bar'}"
    errors: [
      message: "Unary word operator 'await' must be followed by whitespace."
      type: 'AwaitExpression'
      line: 1
      column: 4
    ]
  ,
    code: "-> await{baz: 'qux'}"
    output: "-> await {baz: 'qux'}"
    options: [words: no, overrides: await: yes]
    errors: [
      message: "Unary word operator 'await' must be followed by whitespace."
      type: 'AwaitExpression'
      line: 1
      column: 4
    ]
  ,
    code: '-> await {foo: 1}'
    output: '-> await{foo: 1}'
    options: [words: no]
    errors: [
      message: "Unexpected space after unary word operator 'await'."
      type: 'AwaitExpression'
      line: 1
      column: 4
    ]
  ,
    code: '-> await {bar: 2}'
    output: '-> await{bar: 2}'
    options: [words: yes, overrides: await: no]
    errors: [
      message: "Unexpected space after unary word operator 'await'."
      type: 'AwaitExpression'
      line: 1
      column: 4
    ]
  ]
