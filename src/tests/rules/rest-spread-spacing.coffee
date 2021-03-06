###*
# @fileoverview Enforce spacing between rest and spread operators and their expressions.
# @author Kai Cataldo
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/rest-spread-spacing'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'rest-spread-spacing', rule,
  valid: [
    'fn(...args)'
    'fn(args...)'
    'fn(...(args))'
    'fn((args)...)'
    'fn(...( args ))'
    'fn(( args )...)'
  ,
    code: 'fn(...args)', options: ['never']
  ,
    code: 'fn(args...)', options: ['never']
  ,
    code: 'fn(... args)', options: ['always']
  ,
    code: 'fn(args ...)', options: ['always']
  ,
    code: 'fn(...\targs)', options: ['always']
  ,
    code: 'fn(args\t...)', options: ['always']
  ,
    '[...arr, 4, 5, 6]'
    '[arr..., 4, 5, 6]'
    '[...(arr), 4, 5, 6]'
    '[(arr)..., 4, 5, 6]'
    '[...( arr ), 4, 5, 6]'
    '[( arr )..., 4, 5, 6]'
  ,
    code: '[...arr, 4, 5, 6]', options: ['never']
  ,
    code: '[arr..., 4, 5, 6]', options: ['never']
  ,
    code: '[... arr, 4, 5, 6]', options: ['always']
  ,
    code: '[arr ..., 4, 5, 6]', options: ['always']
  ,
    code: '[...\tarr, 4, 5, 6]', options: ['always']
  ,
    code: '[arr\t..., 4, 5, 6]', options: ['always']
  ,
    '[a, b, ...arr] = [1, 2, 3, 4, 5]'
    '[a, b, arr...] = [1, 2, 3, 4, 5]'
  ,
    code: '[a, b, ...arr] = [1, 2, 3, 4, 5]', options: ['never']
  ,
    code: '[a, b, arr...] = [1, 2, 3, 4, 5]', options: ['never']
  ,
    code: '[a, b, ... arr] = [1, 2, 3, 4, 5]', options: ['always']
  ,
    code: '[a, b, arr ...] = [1, 2, 3, 4, 5]', options: ['always']
  ,
    code: '[a, b, ...\tarr] = [1, 2, 3, 4, 5]', options: ['always']
  ,
    code: '[a, b, arr\t...] = [1, 2, 3, 4, 5]', options: ['always']
  ,
    code: 'n = { x, y, ...z }'
  ,
    code: 'n = { x, y, z... }'
  ,
    code: 'n = { x, y, ...(z) }'
  ,
    code: 'n = { x, y, (z)... }'
  ,
    code: 'n = { x, y, ...( z ) }'
  ,
    code: 'n = { x, y, ( z )... }'
  ,
    code: 'n = { x, y, ...z }'
    options: ['never']
  ,
    code: 'n = { x, y, z... }'
    options: ['never']
  ,
    code: 'n = { x, y, z ... }'
    options: ['always']
  ,
    code: 'n = { x, y, ...\tz }'
    options: ['always']
  ,
    code: 'n = { x, y, z\t... }'
    options: ['always']
  ,
    code: '{ x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }'
  ,
    code: '{ x, y, z... } = { x: 1, y: 2, a: 3, b: 4 }'
  ,
    code: '{ x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['never']
  ,
    code: '{ x, y, z... } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['never']
  ,
    code: '{ x, y, ... z } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['always']
  ,
    code: '{ x, y, z ... } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['always']
  ,
    code: '{ x, y, ...\tz } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['always']
  ,
    code: '{ x, y, z\t... } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['always']
  ]

  invalid: [
    code: 'fn(... args)'
    output: 'fn(...args)'
    errors: [
      line: 1
      column: 7
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn ... args'
    output: 'fn ...args'
    errors: [
      line: 1
      column: 7
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(args ...)'
    output: 'fn(args...)'
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(...\targs)'
    output: 'fn(...args)'
    errors: [
      line: 1
      column: 7
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(args\t...)'
    output: 'fn(args...)'
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(... args)'
    output: 'fn(...args)'
    options: ['never']
    errors: [
      line: 1
      column: 7
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(args ...)'
    output: 'fn(args...)'
    options: ['never']
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(...\targs)'
    output: 'fn(...args)'
    options: ['never']
    errors: [
      line: 1
      column: 7
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(args\t...)'
    output: 'fn(args...)'
    options: ['never']
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(...args)'
    output: 'fn(... args)'
    options: ['always']
    errors: [
      line: 1
      column: 7
      message: 'Expected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(args...)'
    output: 'fn(args ...)'
    options: ['always']
    errors: [
      line: 1
      column: 11
      message: 'Expected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(... (args))'
    output: 'fn(...(args))'
    errors: [
      line: 1
      column: 7
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn((args) ...)'
    output: 'fn((args)...)'
    errors: [
      line: 1
      column: 14
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(... ( args ))'
    output: 'fn(...( args ))'
    errors: [
      line: 1
      column: 7
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(( args ) ...)'
    output: 'fn(( args )...)'
    errors: [
      line: 1
      column: 16
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(...(args))'
    output: 'fn(... (args))'
    options: ['always']
    errors: [
      line: 1
      column: 7
      message: 'Expected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn((args)...)'
    output: 'fn((args) ...)'
    options: ['always']
    errors: [
      line: 1
      column: 13
      message: 'Expected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(...( args ))'
    output: 'fn(... ( args ))'
    options: ['always']
    errors: [
      line: 1
      column: 7
      message: 'Expected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'fn(( args )...)'
    output: 'fn(( args ) ...)'
    options: ['always']
    errors: [
      line: 1
      column: 15
      message: 'Expected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[... arr, 4, 5, 6]'
    output: '[...arr, 4, 5, 6]'
    errors: [
      line: 1
      column: 5
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[arr ..., 4, 5, 6]'
    output: '[arr..., 4, 5, 6]'
    errors: [
      line: 1
      column: 9
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[...\tarr, 4, 5, 6]'
    output: '[...arr, 4, 5, 6]'
    errors: [
      line: 1
      column: 5
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[arr\t..., 4, 5, 6]'
    output: '[arr..., 4, 5, 6]'
    errors: [
      line: 1
      column: 9
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[... arr, 4, 5, 6]'
    output: '[...arr, 4, 5, 6]'
    options: ['never']
    errors: [
      line: 1
      column: 5
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[arr ..., 4, 5, 6]'
    output: '[arr..., 4, 5, 6]'
    options: ['never']
    errors: [
      line: 1
      column: 9
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[...\tarr, 4, 5, 6]'
    output: '[...arr, 4, 5, 6]'
    options: ['never']
    errors: [
      line: 1
      column: 5
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[arr\t..., 4, 5, 6]'
    output: '[arr..., 4, 5, 6]'
    options: ['never']
    errors: [
      line: 1
      column: 9
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[...arr, 4, 5, 6]'
    output: '[... arr, 4, 5, 6]'
    options: ['always']
    errors: [
      line: 1
      column: 5
      message: 'Expected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[arr..., 4, 5, 6]'
    output: '[arr ..., 4, 5, 6]'
    options: ['always']
    errors: [
      line: 1
      column: 8
      message: 'Expected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[... (arr), 4, 5, 6]'
    output: '[...(arr), 4, 5, 6]'
    errors: [
      line: 1
      column: 5
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[(arr) ..., 4, 5, 6]'
    output: '[(arr)..., 4, 5, 6]'
    errors: [
      line: 1
      column: 11
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[... ( arr ), 4, 5, 6]'
    output: '[...( arr ), 4, 5, 6]'
    errors: [
      line: 1
      column: 5
      message: 'Unexpected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[( arr ) ..., 4, 5, 6]'
    output: '[( arr )..., 4, 5, 6]'
    errors: [
      line: 1
      column: 13
      message: 'Unexpected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[...(arr), 4, 5, 6]'
    output: '[... (arr), 4, 5, 6]'
    options: ['always']
    errors: [
      line: 1
      column: 5
      message: 'Expected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[(arr)..., 4, 5, 6]'
    output: '[(arr) ..., 4, 5, 6]'
    options: ['always']
    errors: [
      line: 1
      column: 10
      message: 'Expected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[...( arr ), 4, 5, 6]'
    output: '[... ( arr ), 4, 5, 6]'
    options: ['always']
    errors: [
      line: 1
      column: 5
      message: 'Expected whitespace after spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[( arr )..., 4, 5, 6]'
    output: '[( arr ) ..., 4, 5, 6]'
    options: ['always']
    errors: [
      line: 1
      column: 12
      message: 'Expected whitespace before spread operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '[a, b, ... arr] = [1, 2, 3, 4, 5]'
    output: '[a, b, ...arr] = [1, 2, 3, 4, 5]'
    errors: [
      line: 1
      column: 11
      message: 'Unexpected whitespace after rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, arr ...] = [1, 2, 3, 4, 5]'
    output: '[a, b, arr...] = [1, 2, 3, 4, 5]'
    errors: [
      line: 1
      column: 15
      message: 'Unexpected whitespace before rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, ...\tarr] = [1, 2, 3, 4, 5]'
    output: '[a, b, ...arr] = [1, 2, 3, 4, 5]'
    errors: [
      line: 1
      column: 11
      message: 'Unexpected whitespace after rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, arr\t...] = [1, 2, 3, 4, 5]'
    output: '[a, b, arr...] = [1, 2, 3, 4, 5]'
    errors: [
      line: 1
      column: 15
      message: 'Unexpected whitespace before rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, ... arr] = [1, 2, 3, 4, 5]'
    output: '[a, b, ...arr] = [1, 2, 3, 4, 5]'
    options: ['never']
    errors: [
      line: 1
      column: 11
      message: 'Unexpected whitespace after rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, arr ...] = [1, 2, 3, 4, 5]'
    output: '[a, b, arr...] = [1, 2, 3, 4, 5]'
    options: ['never']
    errors: [
      line: 1
      column: 15
      message: 'Unexpected whitespace before rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, ...\tarr] = [1, 2, 3, 4, 5]'
    output: '[a, b, ...arr] = [1, 2, 3, 4, 5]'
    options: ['never']
    errors: [
      line: 1
      column: 11
      message: 'Unexpected whitespace after rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, arr\t...] = [1, 2, 3, 4, 5]'
    output: '[a, b, arr...] = [1, 2, 3, 4, 5]'
    options: ['never']
    errors: [
      line: 1
      column: 15
      message: 'Unexpected whitespace before rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, ...arr] = [1, 2, 3, 4, 5]'
    output: '[a, b, ... arr] = [1, 2, 3, 4, 5]'
    options: ['always']
    errors: [
      line: 1
      column: 11
      message: 'Expected whitespace after rest operator.'
      type: 'RestElement'
    ]
  ,
    code: '[a, b, arr...] = [1, 2, 3, 4, 5]'
    output: '[a, b, arr ...] = [1, 2, 3, 4, 5]'
    options: ['always']
    errors: [
      line: 1
      column: 14
      message: 'Expected whitespace before rest operator.'
      type: 'RestElement'
    ]
  ,
    code: 'n = { x, y, ... z }'
    output: 'n = { x, y, ...z }'
    errors: [
      line: 1
      column: 16
      message: 'Unexpected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, z ... }'
    output: 'n = { x, y, z... }'
    errors: [
      line: 1
      column: 18
      message: 'Unexpected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ...\tz }'
    output: 'n = { x, y, ...z }'
    errors: [
      line: 1
      column: 16
      message: 'Unexpected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, z\t... }'
    output: 'n = { x, y, z... }'
    errors: [
      line: 1
      column: 18
      message: 'Unexpected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ... z }'
    output: 'n = { x, y, ...z }'
    options: ['never']
    errors: [
      line: 1
      column: 16
      message: 'Unexpected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, z ... }'
    output: 'n = { x, y, z... }'
    options: ['never']
    errors: [
      line: 1
      column: 18
      message: 'Unexpected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ...\tz }'
    output: 'n = { x, y, ...z }'
    options: ['never']
    errors: [
      line: 1
      column: 16
      message: 'Unexpected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, z\t... }'
    output: 'n = { x, y, z... }'
    options: ['never']
    errors: [
      line: 1
      column: 18
      message: 'Unexpected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ...z }'
    output: 'n = { x, y, ... z }'
    options: ['always']
    errors: [
      line: 1
      column: 16
      message: 'Expected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, z... }'
    output: 'n = { x, y, z ... }'
    options: ['always']
    errors: [
      line: 1
      column: 17
      message: 'Expected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ... (z) }'
    output: 'n = { x, y, ...(z) }'
    options: ['never']
    errors: [
      line: 1
      column: 16
      message: 'Unexpected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, (z) ... }'
    output: 'n = { x, y, (z)... }'
    options: ['never']
    errors: [
      line: 1
      column: 20
      message: 'Unexpected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ... ( z ) }'
    output: 'n = { x, y, ...( z ) }'
    options: ['never']
    errors: [
      line: 1
      column: 16
      message: 'Unexpected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ( z ) ... }'
    output: 'n = { x, y, ( z )... }'
    options: ['never']
    errors: [
      line: 1
      column: 22
      message: 'Unexpected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ...(z) }'
    output: 'n = { x, y, ... (z) }'
    options: ['always']
    errors: [
      line: 1
      column: 16
      message: 'Expected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, (z)... }'
    output: 'n = { x, y, (z) ... }'
    options: ['always']
    errors: [
      line: 1
      column: 19
      message: 'Expected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ...( z ) }'
    output: 'n = { x, y, ... ( z ) }'
    options: ['always']
    errors: [
      line: 1
      column: 16
      message: 'Expected whitespace after spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: 'n = { x, y, ( z )... }'
    output: 'n = { x, y, ( z ) ... }'
    options: ['always']
    errors: [
      line: 1
      column: 21
      message: 'Expected whitespace before spread property operator.'
      type: 'SpreadElement'
    ]
  ,
    code: '{ x, y, ... z } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }'
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace after rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, z ... } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, z... } = { x: 1, y: 2, a: 3, b: 4 }'
    errors: [
      line: 1
      column: 14
      message: 'Unexpected whitespace before rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, ...\tz } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }'
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace after rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, z\t... } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, z... } = { x: 1, y: 2, a: 3, b: 4 }'
    errors: [
      line: 1
      column: 14
      message: 'Unexpected whitespace before rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, ... z } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['never']
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace after rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, z ... } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, z... } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['never']
    errors: [
      line: 1
      column: 14
      message: 'Unexpected whitespace before rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, ...\tz } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['never']
    errors: [
      line: 1
      column: 12
      message: 'Unexpected whitespace after rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, z\t... } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, z... } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['never']
    errors: [
      line: 1
      column: 14
      message: 'Unexpected whitespace before rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, ... z } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['always']
    errors: [
      line: 1
      column: 12
      message: 'Expected whitespace after rest property operator.'
      type: 'RestElement'
    ]
  ,
    code: '{ x, y, z... } = { x: 1, y: 2, a: 3, b: 4 }'
    output: '{ x, y, z ... } = { x: 1, y: 2, a: 3, b: 4 }'
    options: ['always']
    errors: [
      line: 1
      column: 13
      message: 'Expected whitespace before rest property operator.'
      type: 'RestElement'
    ]
  ]
