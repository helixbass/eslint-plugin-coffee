###*
# @fileoverview Tests for no-unsafe-negation rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-unsafe-negation'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-unsafe-negation', rule,
  valid: [
    'a in b'
    'a not in b'
    'a of b'
    'a not of b'
    'a in b is false'
    '!(a in b)'
    'not (a in b)'
    '!(a not in b)'
    '!(a of b)'
    '!(a not of b)'
    '(!a) in b'
    '(not a) in b'
    '(!a) not in b'
    '(!a) of b'
    '(!a) not of b'
    'a instanceof b'
    'a not instanceof b'
    'a instanceof b is false'
    '!(a instanceof b)'
    'not (a instanceof b)'
    '!(a not instanceof b)'
    '(!a) instanceof b'
    '(!a) not instanceof b'
  ]
  invalid: [
    code: '!a in b'
    # output: '!(a in b)'
    errors: ["Unexpected negating the left operand of 'in' operator."]
  ,
    code: 'not a in b'
    # output: 'not (a in b)'
    errors: ["Unexpected negating the left operand of 'in' operator."]
  ,
    code: '!a not in b'
    # output: '!(a not in b)'
    errors: ["Unexpected negating the left operand of 'not in' operator."]
  ,
    code: '!a of b'
    # output: '!(a of b)'
    errors: ["Unexpected negating the left operand of 'of' operator."]
  ,
    code: '!a not of b'
    # output: '!(a not of b)'
    errors: ["Unexpected negating the left operand of 'not of' operator."]
  ,
    code: 'not a not of b'
    # output: 'not (a not of b)'
    errors: ["Unexpected negating the left operand of 'not of' operator."]
  ,
    code: '(!a in b)'
    # output: '(!(a in b))'
    errors: ["Unexpected negating the left operand of 'in' operator."]
  ,
    code: '(not a in b)'
    # output: '(not (a in b))'
    errors: ["Unexpected negating the left operand of 'in' operator."]
  ,
    code: '(!a not in b)'
    # output: '(!(a not in b))'
    errors: ["Unexpected negating the left operand of 'not in' operator."]
  ,
    code: '(!a of b)'
    # output: '(!(a of b))'
    errors: ["Unexpected negating the left operand of 'of' operator."]
  ,
    code: '(!a not of b)'
    # output: '(!(a not of b))'
    errors: ["Unexpected negating the left operand of 'not of' operator."]
  ,
    code: '!(a) in b'
    # output: '!((a) in b)'
    errors: ["Unexpected negating the left operand of 'in' operator."]
  ,
    code: '!(a) not in b'
    # output: '!((a) not in b)'
    errors: ["Unexpected negating the left operand of 'not in' operator."]
  ,
    code: '!(a) of b'
    # output: '!((a) of b)'
    errors: ["Unexpected negating the left operand of 'of' operator."]
  ,
    code: '!(a) not of b'
    # output: '!((a) not of b)'
    errors: ["Unexpected negating the left operand of 'not of' operator."]
  ,
    code: '!a instanceof b'
    # output: '!(a instanceof b)'
    errors: ["Unexpected negating the left operand of 'instanceof' operator."]
  ,
    code: '!a not instanceof b'
    # output: '!(a not instanceof b)'
    errors: [
      "Unexpected negating the left operand of 'not instanceof' operator."
    ]
  ,
    code: 'not a not instanceof b'
    # output: 'not (a not instanceof b)'
    errors: [
      "Unexpected negating the left operand of 'not instanceof' operator."
    ]
  ,
    code: '(!a instanceof b)'
    # output: '(!(a instanceof b))'
    errors: ["Unexpected negating the left operand of 'instanceof' operator."]
  ,
    code: '(!a not instanceof b)'
    # output: '(!(a not instanceof b))'
    errors: [
      "Unexpected negating the left operand of 'not instanceof' operator."
    ]
  ,
    code: '!(a) instanceof b'
    # output: '!((a) instanceof b)'
    errors: ["Unexpected negating the left operand of 'instanceof' operator."]
  ,
    code: 'not (a) instanceof b'
    # output: 'not ((a) instanceof b)'
    errors: ["Unexpected negating the left operand of 'instanceof' operator."]
  ,
    code: '!(a) not instanceof b'
    # output: '!((a) not instanceof b)'
    errors: [
      "Unexpected negating the left operand of 'not instanceof' operator."
    ]
  ]
