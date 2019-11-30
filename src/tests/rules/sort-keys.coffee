###*
# @fileoverview Tests for sort-keys rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/sort-keys'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'sort-keys', rule,
  valid: [
    # default (asc)
    code: 'obj = {_:2, a:1, b:3} # default', options: []
  ,
    code: 'obj = {a:1, b:3, c:2}', options: []
  ,
    code: 'obj = {a:2, b:3, b_:1}', options: []
  ,
    code: 'obj = {C:3, b_:1, c:2}', options: []
  ,
    code: 'obj = {$:1, A:3, _:2, a:4}', options: []
  ,
    code: "obj = {1:1, '11':2, 2:4, A:3}", options: []
  ,
    code: "obj = {'#':1, 'Z':2, À:3, è:4}", options: []
  ,
    # ignore non-simple computed properties.
    code: 'obj = {a:1, b:3, [a + b]: -1, c:2}'
    options: []
  ,
    # ignore spread properties.
    code: 'obj = {a:1, ...z, b:1}'
    options: []
  ,
    code: 'obj = {b:1, ...z, a:1}'
    options: []
  ,
    # ignore destructuring patterns.
    code: '{a, b} = {}', options: []
  ,
    # nested
    code: 'obj = {a:1, b:{x:1, y:1}, c:1}', options: []
  ,
    # asc
    code: 'obj = {_:2, a:1, b:3} # asc', options: ['asc']
  ,
    code: 'obj = {a:1, b:3, c:2}', options: ['asc']
  ,
    code: 'obj = {a:2, b:3, b_:1}', options: ['asc']
  ,
    code: 'obj = {C:3, b_:1, c:2}', options: ['asc']
  ,
    code: 'obj = {$:1, A:3, _:2, a:4}', options: ['asc']
  ,
    code: "obj = {1:1, '11':2, 2:4, A:3}", options: ['asc']
  ,
    code: "obj = {'#':1, 'Z':2, À:3, è:4}", options: ['asc']
  ,
    # asc, insensitive
    code: 'obj = {_:2, a:1, b:3} # asc, insensitive'
    options: ['asc', {caseSensitive: no}]
  ,
    code: 'obj = {a:1, b:3, c:2}', options: ['asc', {caseSensitive: no}]
  ,
    code: 'obj = {a:2, b:3, b_:1}', options: ['asc', {caseSensitive: no}]
  ,
    code: 'obj = {b_:1, C:3, c:2}', options: ['asc', {caseSensitive: no}]
  ,
    code: 'obj = {b_:1, c:3, C:2}', options: ['asc', {caseSensitive: no}]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    options: ['asc', {caseSensitive: no}]
  ,
    code: "obj = {1:1, '11':2, 2:4, A:3}"
    options: ['asc', {caseSensitive: no}]
  ,
    code: "obj = {'#':1, 'Z':2, À:3, è:4}"
    options: ['asc', {caseSensitive: no}]
  ,
    # asc, natural
    code: 'obj = {_:2, a:1, b:3} # asc, natural'
    options: ['asc', {natural: yes}]
  ,
    code: 'obj = {a:1, b:3, c:2}', options: ['asc', {natural: yes}]
  ,
    code: 'obj = {a:2, b:3, b_:1}', options: ['asc', {natural: yes}]
  ,
    code: 'obj = {C:3, b_:1, c:2}', options: ['asc', {natural: yes}]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}', options: ['asc', {natural: yes}]
  ,
    code: "obj = {1:1, 2:4, '11':2, A:3}"
    options: ['asc', {natural: yes}]
  ,
    code: "obj = {'#':1, 'Z':2, À:3, è:4}"
    options: ['asc', {natural: yes}]
  ,
    # asc, natural, insensitive
    code: 'obj = {_:2, a:1, b:3} # asc, natural, insensitive'
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {a:1, b:3, c:2}'
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {a:2, b:3, b_:1}'
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {b_:1, C:3, c:2}'
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {b_:1, c:3, C:2}'
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    code: "obj = {1:1, 2:4, '11':2, A:3}"
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    code: "obj = {'#':1, 'Z':2, À:3, è:4}"
    options: ['asc', {natural: yes, caseSensitive: no}]
  ,
    # desc
    code: 'obj = {b:3, a:1, _:2} # desc', options: ['desc']
  ,
    code: 'obj = {c:2, b:3, a:1}', options: ['desc']
  ,
    code: 'obj = {b_:1, b:3, a:2}', options: ['desc']
  ,
    code: 'obj = {c:2, b_:1, C:3}', options: ['desc']
  ,
    code: 'obj = {a:4, _:2, A:3, $:1}', options: ['desc']
  ,
    code: "obj = {A:3, 2:4, '11':2, 1:1}", options: ['desc']
  ,
    code: "obj = {è:4, À:3, 'Z':2, '#':1}", options: ['desc']
  ,
    # desc, insensitive
    code: 'obj = {b:3, a:1, _:2} # desc, insensitive'
    options: ['desc', {caseSensitive: no}]
  ,
    code: 'obj = {c:2, b:3, a:1}', options: ['desc', {caseSensitive: no}]
  ,
    code: 'obj = {b_:1, b:3, a:2}', options: ['desc', {caseSensitive: no}]
  ,
    code: 'obj = {c:2, C:3, b_:1}', options: ['desc', {caseSensitive: no}]
  ,
    code: 'obj = {C:2, c:3, b_:1}', options: ['desc', {caseSensitive: no}]
  ,
    code: 'obj = {a:4, A:3, _:2, $:1}'
    options: ['desc', {caseSensitive: no}]
  ,
    code: "obj = {A:3, 2:4, '11':2, 1:1}"
    options: ['desc', {caseSensitive: no}]
  ,
    code: "obj = {è:4, À:3, 'Z':2, '#':1}"
    options: ['desc', {caseSensitive: no}]
  ,
    # desc, natural
    code: 'obj = {b:3, a:1, _:2} # desc, natural'
    options: ['desc', {natural: yes}]
  ,
    code: 'obj = {c:2, b:3, a:1}', options: ['desc', {natural: yes}]
  ,
    code: 'obj = {b_:1, b:3, a:2}', options: ['desc', {natural: yes}]
  ,
    code: 'obj = {c:2, b_:1, C:3}', options: ['desc', {natural: yes}]
  ,
    code: 'obj = {a:4, A:3, _:2, $:1}', options: ['desc', {natural: yes}]
  ,
    code: "obj = {A:3, '11':2, 2:4, 1:1}"
    options: ['desc', {natural: yes}]
  ,
    code: "obj = {è:4, À:3, 'Z':2, '#':1}"
    options: ['desc', {natural: yes}]
  ,
    # desc, natural, insensitive
    code: 'obj = {b:3, a:1, _:2} # desc, natural, insensitive'
    options: ['desc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {c:2, b:3, a:1}'
    options: ['desc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {b_:1, b:3, a:2}'
    options: ['desc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {c:2, C:3, b_:1}'
    options: ['desc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {C:2, c:3, b_:1}'
    options: ['desc', {natural: yes, caseSensitive: no}]
  ,
    code: 'obj = {a:4, A:3, _:2, $:1}'
    options: ['desc', {natural: yes, caseSensitive: no}]
  ,
    code: "obj = {A:3, '11':2, 2:4, 1:1}"
    options: ['desc', {natural: yes, caseSensitive: no}]
  ,
    code: "obj = {è:4, À:3, 'Z':2, '#':1}"
    options: ['desc', {natural: yes, caseSensitive: no}]
  ]
  invalid: [
    # default (asc)
    code: 'obj = {a:1, _:2, b:3} # default'
    errors: [
      "Expected object keys to be in ascending order. '_' should be before 'a'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    errors: [
      "Expected object keys to be in ascending order. 'b' should be before 'c'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    errors: [
      "Expected object keys to be in ascending order. 'a' should be before 'b_'."
    ]
  ,
    code: 'obj = {b_:1, c:2, C:3}'
    errors: [
      "Expected object keys to be in ascending order. 'C' should be before 'c'."
    ]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    errors: [
      "Expected object keys to be in ascending order. 'A' should be before '_'."
    ]
  ,
    code: "obj = {1:1, 2:4, A:3, '11':2}"
    errors: [
      "Expected object keys to be in ascending order. '11' should be before 'A'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    errors: [
      "Expected object keys to be in ascending order. 'Z' should be before 'À'."
    ]
  ,
    # not ignore simple computed properties.
    code: 'obj = {a:1, b:3, [a]: -1, c:2}'
    errors: [
      "Expected object keys to be in ascending order. 'a' should be before 'b'."
    ]
  ,
    # nested
    code: 'obj = {a:1, c:{y:1, x:1}, b:1}'
    errors: [
      "Expected object keys to be in ascending order. 'x' should be before 'y'."
      "Expected object keys to be in ascending order. 'b' should be before 'c'."
    ]
  ,
    # asc
    code: 'obj = {a:1, _:2, b:3} # asc'
    options: ['asc']
    errors: [
      "Expected object keys to be in ascending order. '_' should be before 'a'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['asc']
    errors: [
      "Expected object keys to be in ascending order. 'b' should be before 'c'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['asc']
    errors: [
      "Expected object keys to be in ascending order. 'a' should be before 'b_'."
    ]
  ,
    code: 'obj = {b_:1, c:2, C:3}'
    options: ['asc']
    errors: [
      "Expected object keys to be in ascending order. 'C' should be before 'c'."
    ]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    options: ['asc']
    errors: [
      "Expected object keys to be in ascending order. 'A' should be before '_'."
    ]
  ,
    code: "obj = {1:1, 2:4, A:3, '11':2}"
    options: ['asc']
    errors: [
      "Expected object keys to be in ascending order. '11' should be before 'A'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['asc']
    errors: [
      "Expected object keys to be in ascending order. 'Z' should be before 'À'."
    ]
  ,
    # asc, insensitive
    code: 'obj = {a:1, _:2, b:3} # asc, insensitive'
    options: ['asc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive ascending order. '_' should be before 'a'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['asc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive ascending order. 'b' should be before 'c'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['asc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive ascending order. 'a' should be before 'b_'."
    ]
  ,
    code: 'obj = {$:1, A:3, _:2, a:4}'
    options: ['asc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive ascending order. '_' should be before 'A'."
    ]
  ,
    code: "obj = {1:1, 2:4, A:3, '11':2}"
    options: ['asc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive ascending order. '11' should be before 'A'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['asc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive ascending order. 'Z' should be before 'À'."
    ]
  ,
    # asc, natural
    code: 'obj = {a:1, _:2, b:3} # asc, natural'
    options: ['asc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural ascending order. '_' should be before 'a'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['asc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural ascending order. 'b' should be before 'c'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['asc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural ascending order. 'a' should be before 'b_'."
    ]
  ,
    code: 'obj = {b_:1, c:2, C:3}'
    options: ['asc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural ascending order. 'C' should be before 'c'."
    ]
  ,
    code: 'obj = {$:1, A:3, _:2, a:4}'
    options: ['asc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural ascending order. '_' should be before 'A'."
    ]
  ,
    code: "obj = {1:1, 2:4, A:3, '11':2}"
    options: ['asc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural ascending order. '11' should be before 'A'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['asc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural ascending order. 'Z' should be before 'À'."
    ]
  ,
    # asc, natural, insensitive
    code: 'obj = {a:1, _:2, b:3} # asc, natural, insensitive'
    options: ['asc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive ascending order. '_' should be before 'a'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['asc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive ascending order. 'b' should be before 'c'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['asc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive ascending order. 'a' should be before 'b_'."
    ]
  ,
    code: 'obj = {$:1, A:3, _:2, a:4}'
    options: ['asc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive ascending order. '_' should be before 'A'."
    ]
  ,
    code: "obj = {1:1, '11':2, 2:4, A:3}"
    options: ['asc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive ascending order. '2' should be before '11'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['asc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive ascending order. 'Z' should be before 'À'."
    ]
  ,
    # desc
    code: 'obj = {a:1, _:2, b:3} # desc'
    options: ['desc']
    errors: [
      "Expected object keys to be in descending order. 'b' should be before '_'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['desc']
    errors: [
      "Expected object keys to be in descending order. 'c' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['desc']
    errors: [
      "Expected object keys to be in descending order. 'b' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, c:2, C:3}'
    options: ['desc']
    errors: [
      "Expected object keys to be in descending order. 'c' should be before 'b_'."
    ]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    options: ['desc']
    errors: [
      "Expected object keys to be in descending order. '_' should be before '$'."
      "Expected object keys to be in descending order. 'a' should be before 'A'."
    ]
  ,
    code: "obj = {1:1, 2:4, A:3, '11':2}"
    options: ['desc']
    errors: [
      "Expected object keys to be in descending order. '2' should be before '1'."
      "Expected object keys to be in descending order. 'A' should be before '2'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['desc']
    errors: [
      "Expected object keys to be in descending order. 'À' should be before '#'."
      "Expected object keys to be in descending order. 'è' should be before 'Z'."
    ]
  ,
    # desc, insensitive
    code: 'obj = {a:1, _:2, b:3} # desc, insensitive'
    options: ['desc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive descending order. 'b' should be before '_'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['desc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive descending order. 'c' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['desc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive descending order. 'b' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, c:2, C:3}'
    options: ['desc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive descending order. 'c' should be before 'b_'."
    ]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    options: ['desc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive descending order. '_' should be before '$'."
      "Expected object keys to be in insensitive descending order. 'A' should be before '_'."
    ]
  ,
    code: "obj = {1:1, 2:4, A:3, '11':2}"
    options: ['desc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive descending order. '2' should be before '1'."
      "Expected object keys to be in insensitive descending order. 'A' should be before '2'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['desc', {caseSensitive: no}]
    errors: [
      "Expected object keys to be in insensitive descending order. 'À' should be before '#'."
      "Expected object keys to be in insensitive descending order. 'è' should be before 'Z'."
    ]
  ,
    # desc, natural
    code: 'obj = {a:1, _:2, b:3} # desc, natural'
    options: ['desc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural descending order. 'b' should be before '_'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['desc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural descending order. 'c' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['desc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural descending order. 'b' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, c:2, C:3}'
    options: ['desc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural descending order. 'c' should be before 'b_'."
    ]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    options: ['desc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural descending order. '_' should be before '$'."
      "Expected object keys to be in natural descending order. 'A' should be before '_'."
      "Expected object keys to be in natural descending order. 'a' should be before 'A'."
    ]
  ,
    code: "obj = {1:1, 2:4, A:3, '11':2}"
    options: ['desc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural descending order. '2' should be before '1'."
      "Expected object keys to be in natural descending order. 'A' should be before '2'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['desc', {natural: yes}]
    errors: [
      "Expected object keys to be in natural descending order. 'À' should be before '#'."
      "Expected object keys to be in natural descending order. 'è' should be before 'Z'."
    ]
  ,
    # desc, natural, insensitive
    code: 'obj = {a:1, _:2, b:3} # desc, natural, insensitive'
    options: ['desc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive descending order. 'b' should be before '_'."
    ]
  ,
    code: 'obj = {a:1, c:2, b:3}'
    options: ['desc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive descending order. 'c' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, a:2, b:3}'
    options: ['desc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive descending order. 'b' should be before 'a'."
    ]
  ,
    code: 'obj = {b_:1, c:2, C:3}'
    options: ['desc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive descending order. 'c' should be before 'b_'."
    ]
  ,
    code: 'obj = {$:1, _:2, A:3, a:4}'
    options: ['desc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive descending order. '_' should be before '$'."
      "Expected object keys to be in natural insensitive descending order. 'A' should be before '_'."
    ]
  ,
    code: "obj = {1:1, 2:4, '11':2, A:3}"
    options: ['desc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive descending order. '2' should be before '1'."
      "Expected object keys to be in natural insensitive descending order. '11' should be before '2'."
      "Expected object keys to be in natural insensitive descending order. 'A' should be before '11'."
    ]
  ,
    code: "obj = {'#':1, À:3, 'Z':2, è:4}"
    options: ['desc', {natural: yes, caseSensitive: no}]
    errors: [
      "Expected object keys to be in natural insensitive descending order. 'À' should be before '#'."
      "Expected object keys to be in natural insensitive descending order. 'è' should be before 'Z'."
    ]
  ]
