###*
# @fileoverview Disallow parenthesesisng higher precedence subexpressions.
# @author Michael Ficarra
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-extra-parens'
{RuleTester} = require 'eslint'

###*
# Create error message object for failure cases
# @param {string} code source code
# @param {string} output fixed source code
# @param {string} type node type
# @param {int} line line number
# @param {Object} config rule configuration
# @returns {Object} result object
# @private
###
invalid = (code, output, type, line, config) ->
  result = {
    code
    output
    parserOptions: config?.parserOptions ? {}
    errors: [
      {
        messageId: 'unexpected'
        type
      }
    ]
    options: config?.options ? []
  }

  result.errors[0].line = line if line
  result

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-extra-parens', rule,
  valid: [
    # all precedence boundaries
    'foo'
    'a = b; c = d'
    'a = if b then c else d'
    'a = (b; c)'
    'if a or b then c = d else e = f'
    'a and b or c and d'
    '(if a then b else c) or (if d then e else f)'
    'a | b and c | d'
    '(a || b) && (c || d)'
    '(a or b) and (c or d)'
    'a ^ b | c ^ d'
    '(a and b) | (c and d)'
    'a & b ^ c & d'
    '(a | b) ^ (c | d)'
    'a == b & c != d'
    '(a ^ b) & (c ^ d)'
    '(a < b) is (c in d)'
    '(a & b) isnt (c & d)'
    'a << b >= c >>> d'
    '(a == b) instanceof (c != d)'
    'a + b << c - d'
    '(a <= b) >> (c > d)'
    'a * b + c / d'
    '(a << b) - (c >> d)'
    '+a % !b'
    '(a + b) * (c - d)'
    # '-void+delete~typeof!a'
    '''
      !(a * b)
      typeof (a / b)
      +(a % b)
      delete (a * b)
      ~(a / b)
      -(a * b)
    '''
    'a(b = c, (d; e))'
    '''
      (++a)(b)
      (c++)(d)
    '''
    'new (A())'
    'new (foo.Baz().foo)'
    'new (foo.baz.bar().foo.baz)'
    'new ({}.baz.bar.foo().baz)'
    'new (doSomething().baz.bar().foo)'
    'new ([][0].baz.foo().bar.foo)'
    'new (foo\n.baz\n.bar()\n.foo.baz)'
    'new A()()'
    '(new A)()'
    '(new (Foo || Bar))()'
    '(2 + 3) ** 4'
    '2 ** (2 + 3)'

    # same precedence
    'a, b, c'
    'a = b = c'
    'if a then if b then c else d else e'
    'if a then b else if c then d else e'
    'a || b || c'
    'a or b || c'
    'a || (b || c)'
    'a or (b || c)'
    'a && b && c'
    'a and b && c'
    'a && (b && c)'
    'a && (b and c)'
    'a | b | c'
    'a | (b | c)'
    'a ^ b ^ c'
    'a ^ (b ^ c)'
    'a & b & c'
    'a & (b & c)'
    'a == b == c'
    'a == (b == c)'
    'a < b < c'
    'a < (b < c)'
    'a << b << c'
    'a << (b << c)'
    'a + b + c'
    'a + (b + c)'
    'a * b * c'
    'a * (b * c)'
    '''
      !!a
      typeof +b
      ~delete d
    '''
    'a(b)'
    'a(b)(c)'
    'a((b; c))'
    'new new A'
    '2 ** 3 ** 4'
    '(2 ** 3) ** 4'

    # constructs that contain expressions
    'if a then ;'
    '''
      switch a
        when 0
          break
    '''
    'a = -> return b'
    'throw a'
    'while a then ;'
    'for a in b then ;'
    'for a in (b; c) then ;'
    'for a of b then ;'
    'for a of (b; c) then ;'
    'for a from b then ;'
    'for a from (b; c) then ;'
    '[]'
    '[a, b]'
    '!{a: 0, b: 1}'

    '(do ->).b'
    '((-> bar)())'
    # RegExp literal is allowed to have parens (#1589)
    "isA = (/^a$/).test('a')"
    'regex = (/^a$/)'
    '-> return (/^a$/)'
    "a = -> return (/^a$/).test('a')"

    'foo = (-> return bar())()'
    'o = foo: ((-> bar())())'
    'o.foo = (-> bar())()'
    '(-> return bar())(); (-> return bar())()'

    # parens are required around yield
    'foo = (-> if (yield foo()) + 1 then return)()'

    # arrow functions have the precedence of an assignment expression
    '(() => 0)()'
    '((_) => 0)()'
    '((_) => 0); ((_) => 1)'
    'a = () => b = 0'
    'if 0 then (_) => 0 else (_) => 0'
    'if 0 then ((_) => if 0 then 1) else (_) => 0'
    '((_) => 0) or ((_) => 0)'

    # Exponentiation operator `**`
    '1 + 2 ** 3'
    '1 - 2 ** 3'
    '2 ** -3'
    '(-2) ** 3'
    '(+2) ** 3'
    '+ (2 ** 3)'
  ,
    # "functions" enables reports for function nodes only
    code: '(0)', options: ['functions']
  ,
    code: 'a + (b * c)', options: ['functions']
  ,
    code: '(a)(b)', options: ['functions']
  ,
    code: 'a; (b = c)', options: ['functions']
  ,
    code: 'for a in (0) then ;', options: ['functions']
  ,
    code: 'a = (b = c)', options: ['functions']
  ,
    code: '(_) => (a = 0)', options: ['functions']
  ,
    # ["all", {conditionalAssign: false}] enables extra parens around conditional assignments
    code: 'while ((foo = bar())) {}'
    options: ['all', {conditionalAssign: no}]
  ,
    code: 'if ((foo = bar())) {}', options: ['all', {conditionalAssign: no}]
  ,
    code: 'do; while ((foo = bar()))'
    options: ['all', {conditionalAssign: no}]
  ,
    code: 'for (;(a = b););', options: ['all', {conditionalAssign: no}]
  ,
    # ["all", { nestedBinaryExpressions: false }] enables extra parens around conditional assignments
    code: 'a + (b * c)', options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: '(a * b) + c', options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: '(a * b) / c', options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: 'a || (b && c)', options: ['all', {nestedBinaryExpressions: no}]
  ,
    # ["all", { returnAssign: false }] enables extra parens around expressions returned by return statements
    code: 'function a(b) { return b || c; }'
    options: ['all', {returnAssign: no}]
  ,
    code: 'function a(b) { return; }', options: ['all', {returnAssign: no}]
  ,
    code: 'function a(b) { return (b = 1); }'
    options: ['all', {returnAssign: no}]
  ,
    code: 'function a(b) { return (b = c) || (b = d); }'
    options: ['all', {returnAssign: no}]
  ,
    code: 'function a(b) { return c ? (d = b) : (e = b); }'
    options: ['all', {returnAssign: no}]
  ,
    code: 'b => b || c;', options: ['all', {returnAssign: no}]
  ,
    code: 'b => (b = 1);', options: ['all', {returnAssign: no}]
  ,
    code: 'b => (b = c) || (b = d);', options: ['all', {returnAssign: no}]
  ,
    code: 'b => c ? (d = b) : (e = b);', options: ['all', {returnAssign: no}]
  ,
    code: 'b => { return b || c };', options: ['all', {returnAssign: no}]
  ,
    code: 'b => { return (b = 1) };', options: ['all', {returnAssign: no}]
  ,
    code: 'b => { return (b = c) || (b = d) };'
    options: ['all', {returnAssign: no}]
  ,
    code: 'b => { return c ? (d = b) : (e = b) };'
    options: ['all', {returnAssign: no}]
  ,
    # https://github.com/eslint/eslint/issues/3653
    '(function(){}).foo(), 1, 2;'
    '(function(){}).foo++;'
    '(function(){}).foo() || bar;'
    '(function(){}).foo() + 1;'
    '(function(){}).foo() ? bar : baz;'
    '(function(){}).foo.bar();'
    '(function(){}.foo());'
    '(function(){}.foo.bar);'

    '(class{}).foo(), 1, 2;'
    '(class{}).foo++;'
    '(class{}).foo() || bar;'
    '(class{}).foo() + 1;'
    '(class{}).foo() ? bar : baz;'
    '(class{}).foo.bar();'
    '(class{}.foo());'
    '(class{}.foo.bar);'

    # https://github.com/eslint/eslint/issues/4608
    'function *a() { yield b; }'
    'function *a() { yield yield; }'
    'function *a() { yield b, c; }'
    'function *a() { yield (b, c); }'
    'function *a() { yield b + c; }'
    'function *a() { (yield b) + c; }'

    # https://github.com/eslint/eslint/issues/4229
    ['function a() {', '    return (', '        b', '    );', '}'].join '\n'
    ['function a() {', '    return (', '        <JSX />', '    );', '}'].join(
      '\n'
    )
    ['function a() {', '    return (', '        <></>', '    );', '}'].join(
      '\n'
    )
    ['throw (', '    a', ');'].join '\n'
    ['function *a() {', '    yield (', '        b', '    );', '}'].join '\n'

    # async/await
    'async function a() { await (a + b) }'
    'async function a() { await (a + await b) }'
    'async function a() { (await a)() }'
    'async function a() { new (await a) }'
  ,
    code: '(foo instanceof bar) instanceof baz'
    options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: '(foo in bar) in baz'
    options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: '(foo + bar) + baz', options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: '(foo && bar) && baz'
    options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: 'foo instanceof (bar instanceof baz)'
    options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: 'foo in (bar in baz)'
    options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: 'foo + (bar + baz)', options: ['all', {nestedBinaryExpressions: no}]
  ,
    code: 'foo && (bar && baz)'
    options: ['all', {nestedBinaryExpressions: no}]
  ,
    # https://github.com/eslint/eslint/issues/9019
    '(async function() {});'
    '(async function () { }());'
  ,
    # ["all", { ignoreJSX: "all" }]
    code: 'const Component = (<div />)', options: ['all', {ignoreJSX: 'all'}]
  ,
    code: ['const Component = (<>', '  <p />', '</>);'].join '\n'
    options: ['all', {ignoreJSX: 'all'}]
  ,
    code: ['const Component = (<div>', '  <p />', '</div>);'].join '\n'
    options: ['all', {ignoreJSX: 'all'}]
  ,
    code: ['const Component = (', '  <div />', ');'].join '\n'
    options: ['all', {ignoreJSX: 'all'}]
  ,
    code: ['const Component =', '  (<div />)'].join '\n'
    options: ['all', {ignoreJSX: 'all'}]
  ,
    # ["all", { ignoreJSX: "single-line" }]
    code: 'const Component = (<div />);'
    options: ['all', {ignoreJSX: 'single-line'}]
  ,
    code: ['const Component = (', '  <div />', ');'].join '\n'
    options: ['all', {ignoreJSX: 'single-line'}]
  ,
    code: ['const Component =', '(<div />)'].join '\n'
    options: ['all', {ignoreJSX: 'single-line'}]
  ,
    # ["all", { ignoreJSX: "multi-line" }]
    code: ['const Component = (', '<div>', '  <p />', '</div>', ');'].join '\n'
    options: ['all', {ignoreJSX: 'multi-line'}]
  ,
    code: ['const Component = (<div>', '  <p />', '</div>);'].join '\n'
    options: ['all', {ignoreJSX: 'multi-line'}]
  ,
    code: ['const Component =', '(<div>', '  <p />', '</div>);'].join '\n'
    options: ['all', {ignoreJSX: 'multi-line'}]
  ,
    code: ['const Component = (<div', '  prop={true}', '/>)'].join '\n'
    options: ['all', {ignoreJSX: 'multi-line'}]
  ,
    # ["all", { enforceForArrowConditionals: false }]
    code: 'var a = b => 1 ? 2 : 3'
    options: ['all', {enforceForArrowConditionals: no}]
  ,
    code: 'var a = (b) => (1 ? 2 : 3)'
    options: ['all', {enforceForArrowConditionals: no}]
  ,
    'let a = [ ...b ]'
    'let a = { ...b }'
  ,
    code: 'let a = { ...b }'
    parserOptions: ecmaVersion: 2018
  ,
    'let a = [ ...(b, c) ]'
    'let a = { ...(b, c) }'
  ,
    code: 'let a = { ...(b, c) }'
    parserOptions: ecmaVersion: 2018
  ,
    'var [x = (1, foo)] = bar'
    'class A extends B {}'
    'const A = class extends B {}'
    'class A extends (B=C) {}'
    'const A = class extends (B=C) {}'
    '() => ({ foo: 1 })'
    '() => ({ foo: 1 }).foo'
    '() => ({ foo: 1 }.foo().bar).baz.qux()'
    '() => ({ foo: 1 }.foo().bar + baz)'
  ,
    code: 'export default (function(){}).foo'
    parserOptions: sourceType: 'module'
  ,
    code: 'export default (class{}).foo'
    parserOptions: sourceType: 'module'
  ,
    '({}).hasOwnProperty.call(foo, bar)'
    '({}) ? foo() : bar()'
    '({}) + foo'
    '(function(){}) + foo'
    '(let[foo]) = 1' # setting the 'foo' property of the 'let' variable to 1
  ,
    code: '((function(){}).foo.bar)();'
    options: ['functions']
  ,
    code: '((function(){}).foo)();'
    options: ['functions']
  ,
    '(let)[foo]'
    'for ((let) in foo);'
    'for ((let[foo]) in bar);'
    'for ((let)[foo] in bar);'
    'for ((let[foo].bar) in baz);'
  ]

  invalid: [
    'if (a = b) then (c, d) else (e, f)'
    'if (a) then ;'
    '''
      switch (a)
        when 0
          break
    '''
    'while (a) then ;'
    'for a in (b) then ;'
    'for a of (b) then ;'
    'for a from (b) then ;'
    '({})'
    '(->)'
    '(class)'
    # special cases
    '(0).a'
    '(do ->)'
    '({a: ->}.a())'
    '(if {a: 0}.a then b else c)'

    'foo = ((-> return bar())())'
    'o = foo: ((-> bar())())'
    'o.foo = ((-> bar())())'
    '((-> return bar())()); ((-> return bar())())'
    'if 0 then ((_) => 0) else ((_) => 0)'

    '(x) => ({foo: 1})'
    '(a) => ({b: c}[d])'
    '(a) => ({b: c}.d())'
    '(a) => ({b: c}.d.e)'

    invalid '(0)', '0', 'Literal'
    invalid '(  0  )', '  0  ', 'Literal'
    invalid 'if((0));', 'if(0);', 'Literal'
    invalid 'if(( 0 ));', 'if( 0 );', 'Literal'
    invalid 'with((0)){}', 'with(0){}', 'Literal'
    invalid 'switch((0)){}', 'switch(0){}', 'Literal'
    invalid(
      'switch(0){ case (1): break; }'
      'switch(0){ case 1: break; }'
      'Literal'
    )
    invalid 'for((0);;);', 'for(0;;);', 'Literal'
    invalid 'for(;(0););', 'for(;0;);', 'Literal'
    invalid 'for(;;(0));', 'for(;;0);', 'Literal'
    invalid 'throw(0)', 'throw 0', 'Literal'
    invalid 'while((0));', 'while(0);', 'Literal'
    invalid 'do; while((0))', 'do; while(0)', 'Literal'
    invalid 'for(a in (0));', 'for(a in 0);', 'Literal'
    invalid 'for(a of (0));', 'for(a of 0);', 'Literal', 1
    invalid(
      'var foo = (function*() { if ((yield foo())) { return; } }())'
      'var foo = (function*() { if (yield foo()) { return; } }())'
      'YieldExpression'
      1
    )
    invalid 'f((0))', 'f(0)', 'Literal'
    invalid 'f(0, (1))', 'f(0, 1)', 'Literal'
    invalid '!(0)', '!0', 'Literal'
    invalid 'a[(1)]', 'a[1]', 'Literal'
    invalid '(a)(b)', 'a(b)', 'Identifier'
    invalid '(async)', 'async', 'Identifier'
    invalid '(a, b)', 'a, b', 'SequenceExpression'
    invalid 'var a = (b = c);', 'var a = b = c;', 'AssignmentExpression'
    invalid(
      'function f(){ return (a); }'
      'function f(){ return a; }'
      'Identifier'
    )
    invalid '[a, (b = c)]', '[a, b = c]', 'AssignmentExpression'
    invalid '!{a: (b = c)}', '!{a: b = c}', 'AssignmentExpression'
    invalid 'typeof(0)', 'typeof 0', 'Literal'
    invalid 'typeof (0)', 'typeof 0', 'Literal'
    invalid 'typeof([])', 'typeof[]', 'ArrayExpression'
    invalid 'typeof ([])', 'typeof []', 'ArrayExpression'
    invalid 'typeof( 0)', 'typeof 0', 'Literal'
    invalid 'typeof(typeof 5)', 'typeof typeof 5', 'UnaryExpression'
    invalid 'typeof (typeof 5)', 'typeof typeof 5', 'UnaryExpression'
    invalid '+(+foo)', '+ +foo', 'UnaryExpression'
    invalid '-(-foo)', '- -foo', 'UnaryExpression'
    invalid '+(-foo)', '+-foo', 'UnaryExpression'
    invalid '-(+foo)', '-+foo', 'UnaryExpression'
    invalid '++(foo)', '++foo', 'Identifier'
    invalid '--(foo)', '--foo', 'Identifier'
    invalid '(a || b) ? c : d', 'a || b ? c : d', 'LogicalExpression'
    invalid 'a ? (b = c) : d', 'a ? b = c : d', 'AssignmentExpression'
    invalid 'a ? b : (c = d)', 'a ? b : c = d', 'AssignmentExpression'
    invalid 'f((a = b))', 'f(a = b)', 'AssignmentExpression'
    invalid 'a, (b = c)', 'a, b = c', 'AssignmentExpression'
    invalid 'a = (b * c)', 'a = b * c', 'BinaryExpression'
    invalid 'a + (b * c)', 'a + b * c', 'BinaryExpression'
    invalid '(a * b) + c', 'a * b + c', 'BinaryExpression'
    invalid '(a * b) / c', 'a * b / c', 'BinaryExpression'
    invalid '(2) ** 3 ** 4', '2 ** 3 ** 4', 'Literal', null
    invalid '2 ** (3 ** 4)', '2 ** 3 ** 4', 'BinaryExpression', null
    invalid '(2 ** 3)', '2 ** 3', 'BinaryExpression', null
    invalid '(2 ** 3) + 1', '2 ** 3 + 1', 'BinaryExpression', null
    invalid '1 - (2 ** 3)', '1 - 2 ** 3', 'BinaryExpression', null

    invalid 'a = (b * c)', 'a = b * c', 'BinaryExpression', null,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid '(b * c)', 'b * c', 'BinaryExpression', null,
      options: ['all', {nestedBinaryExpressions: no}]

    invalid 'a = (b = c)', 'a = b = c', 'AssignmentExpression'
    invalid '(a).b', 'a.b', 'Identifier'
    invalid '(0)[a]', '0[a]', 'Literal'
    invalid '(0.0).a', '0.0.a', 'Literal'
    invalid '(0xBEEF).a', '0xBEEF.a', 'Literal'
    invalid '(1e6).a', '1e6.a', 'Literal'
    invalid '(0123).a', '0123.a', 'Literal'
    invalid 'a[(function() {})]', 'a[function() {}]', 'FunctionExpression'
    invalid 'new (function(){})', 'new function(){}', 'FunctionExpression'
    invalid(
      'new (\nfunction(){}\n)'
      'new \nfunction(){}\n'
      'FunctionExpression'
      1
    )
    invalid(
      '((function foo() {return 1;}))()'
      '(function foo() {return 1;})()'
      'FunctionExpression'
    )
    invalid(
      '((function(){ return bar(); })())'
      '(function(){ return bar(); })()'
      'CallExpression'
    )
    invalid '(foo()).bar', 'foo().bar', 'CallExpression'
    invalid '(foo.bar()).baz', 'foo.bar().baz', 'CallExpression'
    invalid '(foo\n.bar())\n.baz', 'foo\n.bar()\n.baz', 'CallExpression'

    invalid 'new (A)', 'new A', 'Identifier'
    invalid '(new A())()', 'new A()()', 'NewExpression'
    invalid '(new A(1))()', 'new A(1)()', 'NewExpression'
    invalid '((new A))()', '(new A)()', 'NewExpression'
    invalid(
      'new (foo\n.baz\n.bar\n.foo.baz)'
      'new foo\n.baz\n.bar\n.foo.baz'
      'MemberExpression'
    )
    invalid 'new (foo.baz.bar.baz)', 'new foo.baz.bar.baz', 'MemberExpression'

    invalid '0, (_ => 0)', '0, _ => 0', 'ArrowFunctionExpression', 1
    invalid '(_ => 0), 0', '_ => 0, 0', 'ArrowFunctionExpression', 1
    invalid 'a = (_ => 0)', 'a = _ => 0', 'ArrowFunctionExpression', 1
    invalid '_ => (a = 0)', '_ => a = 0', 'AssignmentExpression', 1
    invalid 'x => (({}))', 'x => ({})', 'ObjectExpression', 1

    invalid(
      'new (function(){})'
      'new function(){}'
      'FunctionExpression'
      null
      options: ['functions']
    )
    invalid(
      'new (\nfunction(){}\n)'
      'new \nfunction(){}\n'
      'FunctionExpression'
      1
      options: ['functions']
    )
    invalid(
      '((function foo() {return 1;}))()'
      '(function foo() {return 1;})()'
      'FunctionExpression'
      null
      options: ['functions']
    )
    invalid(
      'a[(function() {})]'
      'a[function() {}]'
      'FunctionExpression'
      null
      options: ['functions']
    )
    invalid '0, (_ => 0)', '0, _ => 0', 'ArrowFunctionExpression', 1,
      options: ['functions']
    invalid '(_ => 0), 0', '_ => 0, 0', 'ArrowFunctionExpression', 1,
      options: ['functions']
    invalid 'a = (_ => 0)', 'a = _ => 0', 'ArrowFunctionExpression', 1,
      options: ['functions']

    invalid(
      'while ((foo = bar())) {}'
      'while (foo = bar()) {}'
      'AssignmentExpression'
    )
    invalid(
      'while ((foo = bar())) {}'
      'while (foo = bar()) {}'
      'AssignmentExpression'
      1
      options: ['all', {conditionalAssign: yes}]
    )
    invalid(
      'if ((foo = bar())) {}'
      'if (foo = bar()) {}'
      'AssignmentExpression'
    )
    invalid(
      'do; while ((foo = bar()))'
      'do; while (foo = bar())'
      'AssignmentExpression'
    )
    invalid 'for (;(a = b););', 'for (;a = b;);', 'AssignmentExpression'

    # https://github.com/eslint/eslint/issues/3653
    invalid(
      '((function(){})).foo();'
      '(function(){}).foo();'
      'FunctionExpression'
    )
    invalid(
      '((function(){}).foo());'
      '(function(){}).foo();'
      'CallExpression'
    )
    invalid '((function(){}).foo);', '(function(){}).foo;', 'MemberExpression'
    invalid(
      '0, (function(){}).foo();'
      '0, function(){}.foo();'
      'FunctionExpression'
    )
    invalid(
      'void (function(){}).foo();'
      'void function(){}.foo();'
      'FunctionExpression'
    )
    invalid(
      '++(function(){}).foo;'
      '++function(){}.foo;'
      'FunctionExpression'
    )
    invalid(
      'bar || (function(){}).foo();'
      'bar || function(){}.foo();'
      'FunctionExpression'
    )
    invalid(
      '1 + (function(){}).foo();'
      '1 + function(){}.foo();'
      'FunctionExpression'
    )
    invalid(
      'bar ? (function(){}).foo() : baz;'
      'bar ? function(){}.foo() : baz;'
      'FunctionExpression'
    )
    invalid(
      'bar ? baz : (function(){}).foo();'
      'bar ? baz : function(){}.foo();'
      'FunctionExpression'
    )
    invalid(
      'bar((function(){}).foo(), 0);'
      'bar(function(){}.foo(), 0);'
      'FunctionExpression'
    )
    invalid(
      'bar[(function(){}).foo()];'
      'bar[function(){}.foo()];'
      'FunctionExpression'
    )
    invalid(
      'var bar = (function(){}).foo();'
      'var bar = function(){}.foo();'
      'FunctionExpression'
    )

    invalid '((class{})).foo();', '(class{}).foo();', 'ClassExpression', null
    invalid '((class{}).foo());', '(class{}).foo();', 'CallExpression', null
    invalid '((class{}).foo);', '(class{}).foo;', 'MemberExpression', null
    invalid '0, (class{}).foo();', '0, class{}.foo();', 'ClassExpression', null
    invalid(
      'void (class{}).foo();'
      'void class{}.foo();'
      'ClassExpression'
      null
    )
    invalid '++(class{}).foo;', '++class{}.foo;', 'ClassExpression', null
    invalid(
      'bar || (class{}).foo();'
      'bar || class{}.foo();'
      'ClassExpression'
      null
    )
    invalid(
      '1 + (class{}).foo();'
      '1 + class{}.foo();'
      'ClassExpression'
      null
    )
    invalid(
      'bar ? (class{}).foo() : baz;'
      'bar ? class{}.foo() : baz;'
      'ClassExpression'
      null
    )
    invalid(
      'bar ? baz : (class{}).foo();'
      'bar ? baz : class{}.foo();'
      'ClassExpression'
      null
    )
    invalid(
      'bar((class{}).foo(), 0);'
      'bar(class{}.foo(), 0);'
      'ClassExpression'
      null
    )
    invalid(
      'bar[(class{}).foo()];'
      'bar[class{}.foo()];'
      'ClassExpression'
      null
    )
    invalid(
      'var bar = (class{}).foo();'
      'var bar = class{}.foo();'
      'ClassExpression'
      null
    )

    # https://github.com/eslint/eslint/issues/4608
    invalid(
      'function *a() { yield (b); }'
      'function *a() { yield b; }'
      'Identifier'
      null
    )
    invalid(
      'function *a() { (yield b), c; }'
      'function *a() { yield b, c; }'
      'YieldExpression'
      null
    )
    invalid(
      'function *a() { yield ((b, c)); }'
      'function *a() { yield (b, c); }'
      'SequenceExpression'
      null
    )
    invalid(
      'function *a() { yield (b + c); }'
      'function *a() { yield b + c; }'
      'BinaryExpression'
      null
    )

    # https://github.com/eslint/eslint/issues/4229
    invalid(
      ['function a() {', '    return (b);', '}'].join '\n'
      ['function a() {', '    return b;', '}'].join '\n'
      'Identifier'
    )
    invalid(
      ['function a() {', '    return', '    (b);', '}'].join '\n'
      ['function a() {', '    return', '    b;', '}'].join '\n'
      'Identifier'
    )
    invalid(
      ['function a() {', '    return ((', '       b', '    ));', '}'].join '\n'
      ['function a() {', '    return (', '       b', '    );', '}'].join '\n'
      'Identifier'
    )
    invalid(
      ['function a() {', '    return (<JSX />);', '}'].join '\n'
      ['function a() {', '    return <JSX />;', '}'].join '\n'
      'JSXElement'
      null
    )
    invalid(
      ['function a() {', '    return', '    (<JSX />);', '}'].join '\n'
      ['function a() {', '    return', '    <JSX />;', '}'].join '\n'
      'JSXElement'
      null
    )
    invalid(
      [
        'function a() {'
        '    return (('
        '       <JSX />'
        '    ));'
        '}'
      ].join '\n'
      ['function a() {', '    return (', '       <JSX />', '    );', '}'].join(
        '\n'
      )
      'JSXElement'
      null
    )
    invalid(
      ['function a() {', '    return ((', '       <></>', '    ));', '}'].join(
        '\n'
      )
      ['function a() {', '    return (', '       <></>', '    );', '}'].join(
        '\n'
      )
      'JSXFragment'
      null
    )
    invalid 'throw (a);', 'throw a;', 'Identifier'
    invalid(
      ['throw ((', '   a', '));'].join '\n'
      ['throw (', '   a', ');'].join '\n'
      'Identifier'
    )
    invalid(
      ['function *a() {', '    yield (b);', '}'].join '\n'
      ['function *a() {', '    yield b;', '}'].join '\n'
      'Identifier'
      null
    )
    invalid(
      ['function *a() {', '    yield', '    (b);', '}'].join '\n'
      ['function *a() {', '    yield', '    b;', '}'].join '\n'
      'Identifier'
      null
    )
    invalid(
      ['function *a() {', '    yield ((', '       b', '    ));', '}'].join '\n'
      ['function *a() {', '    yield (', '       b', '    );', '}'].join '\n'
      'Identifier'
      null
    )
  ,
    # returnAssign option
    code: 'function a(b) { return (b || c); }'
    output: 'function a(b) { return b || c; }'
    options: ['all', {returnAssign: no}]
    errors: [
      messgeId: 'unexpected'
      type: 'LogicalExpression'
    ]
  ,
    code: 'function a(b) { return ((b = c) || (d = e)); }'
    output: 'function a(b) { return (b = c) || (d = e); }'
    errors: [
      messgeId: 'unexpected'
      type: 'LogicalExpression'
    ]
  ,
    code: 'function a(b) { return (b = 1); }'
    output: 'function a(b) { return b = 1; }'
    errors: [
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'function a(b) { return c ? (d = b) : (e = b); }'
    output: 'function a(b) { return c ? d = b : e = b; }'
    errors: [
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ,
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'b => (b || c);'
    output: 'b => b || c;'
    options: ['all', {returnAssign: no}]

    errors: [
      messgeId: 'unexpected'
      type: 'LogicalExpression'
    ]
  ,
    code: 'b => ((b = c) || (d = e));'
    output: 'b => (b = c) || (d = e);'
    errors: [
      messgeId: 'unexpected'
      type: 'LogicalExpression'
    ]
  ,
    code: 'b => (b = 1);'
    output: 'b => b = 1;'
    errors: [
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'b => c ? (d = b) : (e = b);'
    output: 'b => c ? d = b : e = b;'
    errors: [
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ,
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'b => { return (b || c); }'
    output: 'b => { return b || c; }'
    options: ['all', {returnAssign: no}]
    errors: [
      messgeId: 'unexpected'
      type: 'LogicalExpression'
    ]
  ,
    code: 'b => { return ((b = c) || (d = e)) };'
    output: 'b => { return (b = c) || (d = e) };'
    errors: [
      messgeId: 'unexpected'
      type: 'LogicalExpression'
    ]
  ,
    code: 'b => { return (b = 1) };'
    output: 'b => { return b = 1 };'
    errors: [
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'b => { return c ? (d = b) : (e = b); }'
    output: 'b => { return c ? d = b : e = b; }'
    errors: [
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ,
      messgeId: 'unexpected'
      type: 'AssignmentExpression'
    ]
  ,
    # async/await
    code: 'async function a() { (await a) + (await b); }'
    output: 'async function a() { await a + await b; }'
    errors: [
      messgeId: 'unexpected'
      type: 'AwaitExpression'
    ,
      messgeId: 'unexpected'
      type: 'AwaitExpression'
    ]
  ,
    invalid(
      'async function a() { await (a); }'
      'async function a() { await a; }'
      'Identifier'
      null
    )
    invalid(
      'async function a() { await (a()); }'
      'async function a() { await a(); }'
      'CallExpression'
      null
    )
    invalid(
      'async function a() { await (+a); }'
      'async function a() { await +a; }'
      'UnaryExpression'
      null
    )
    invalid(
      'async function a() { +(await a); }'
      'async function a() { +await a; }'
      'AwaitExpression'
      null
    )
    invalid '(foo) instanceof bar', 'foo instanceof bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid '(foo) in bar', 'foo in bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid '(foo) + bar', 'foo + bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid '(foo) && bar', 'foo && bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid 'foo instanceof (bar)', 'foo instanceof bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid 'foo in (bar)', 'foo in bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid 'foo + (bar)', 'foo + bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]
    invalid 'foo && (bar)', 'foo && bar', 'Identifier', 1,
      options: ['all', {nestedBinaryExpressions: no}]

    # ["all", { ignoreJSX: "multi-line" }]
    invalid(
      'const Component = (<div />);'
      'const Component = <div />;'
      'JSXElement'
      1
      options: ['all', {ignoreJSX: 'multi-line'}]
    )
    invalid(
      ['const Component = (', '  <div />', ');'].join '\n'
      'const Component = \n  <div />\n;'
      'JSXElement'
      1
      options: ['all', {ignoreJSX: 'multi-line'}]
    )
    invalid(
      ['const Component = (', '  <></>', ');'].join '\n'
      'const Component = \n  <></>\n;'
      'JSXFragment'
      1
      options: ['all', {ignoreJSX: 'multi-line'}]
    )

    # ["all", { ignoreJSX: "single-line" }]
    invalid(
      ['const Component = (', '<div>', '  <p />', '</div>', ');'].join '\n'
      'const Component = \n<div>\n  <p />\n</div>\n;'
      'JSXElement'
      1
      options: ['all', {ignoreJSX: 'single-line'}]
    )
    invalid(
      ['const Component = (<div>', '  <p />', '</div>);'].join '\n'
      'const Component = <div>\n  <p />\n</div>;'
      'JSXElement'
      1
      options: ['all', {ignoreJSX: 'single-line'}]
    )
    invalid(
      ['const Component = (<div', '  prop={true}', '/>)'].join '\n'
      'const Component = <div\n  prop={true}\n/>'
      'JSXElement'
      1
      options: ['all', {ignoreJSX: 'single-line'}]
    )

    # ["all", { ignoreJSX: "none" }] default, same as unspecified
    invalid(
      'const Component = (<div />);'
      'const Component = <div />;'
      'JSXElement'
      1
      options: ['all', {ignoreJSX: 'none'}]
    )
    invalid(
      ['const Component = (<div>', '<p />', '</div>)'].join '\n'
      'const Component = <div>\n<p />\n</div>'
      'JSXElement'
      1
      options: ['all', {ignoreJSX: 'none'}]
    )
  ,
    # ["all", { enforceForArrowConditionals: true }]
    code: 'var a = (b) => (1 ? 2 : 3)'
    output: 'var a = (b) => 1 ? 2 : 3'
    options: ['all', {enforceForArrowConditionals: yes}]
    errors: [messgeId: 'unexpected']
  ,
    # ["all", { enforceForArrowConditionals: false }]
    code: 'var a = (b) => ((1 ? 2 : 3))'
    output: 'var a = (b) => (1 ? 2 : 3)'
    options: ['all', {enforceForArrowConditionals: no}]
    errors: [messgeId: 'unexpected']
  ,
    # https://github.com/eslint/eslint/issues/8175
    invalid 'let a = [...(b)]', 'let a = [...b]', 'Identifier', 1
    invalid 'let a = {...(b)}', 'let a = {...b}', 'Identifier', 1
    invalid 'let a = {...(b)}', 'let a = {...b}', 'Identifier', 1,
      parserOptions: ecmaVersion: 2018
    invalid(
      'let a = [...((b, c))]'
      'let a = [...(b, c)]'
      'SequenceExpression'
      1
    )
    invalid(
      'let a = {...((b, c))}'
      'let a = {...(b, c)}'
      'SequenceExpression'
      1
    )
    invalid(
      'let a = {...((b, c))}'
      'let a = {...(b, c)}'
      'SequenceExpression'
      1
      parserOptions: ecmaVersion: 2018
    )
    invalid 'class A extends (B) {}', 'class A extends B {}', 'Identifier', 1
    invalid(
      'const A = class extends (B) {}'
      'const A = class extends B {}'
      'Identifier'
      1
    )
    invalid(
      'class A extends ((B=C)) {}'
      'class A extends (B=C) {}'
      'AssignmentExpression'
      1
    )
    invalid(
      'const A = class extends ((B=C)) {}'
      'const A = class extends (B=C) {}'
      'AssignmentExpression'
      1
    )
    invalid 'for (foo of(bar));', 'for (foo of bar);', 'Identifier', 1
    invalid 'for ((foo) of bar);', 'for (foo of bar);', 'Identifier', 1
    invalid 'for ((foo)in bar);', 'for (foo in bar);', 'Identifier', 1
    invalid(
      "for ((foo['bar'])of baz);"
      "for (foo['bar']of baz);"
      'MemberExpression'
      1
    )
    invalid(
      '() => (({ foo: 1 }).foo)'
      '() => ({ foo: 1 }).foo'
      'MemberExpression'
      1
    )
    invalid '(let).foo', 'let.foo', 'Identifier', 1
    invalid(
      'for ((let.foo) in bar);'
      'for (let.foo in bar);'
      'MemberExpression'
      1
    )
    invalid(
      'for ((let).foo.bar in baz);'
      'for (let.foo.bar in baz);'
      'Identifier'
      1
    )
    invalid(
      'for (a in (b, c));'
      'for (a in b, c);'
      'SequenceExpression'
      null
    )
  ]