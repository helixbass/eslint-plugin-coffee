###*
# @fileoverview Tests for no-self-assign rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-self-assign'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-self-assign', rule,
  valid: [
    'a = a'
    'a = b'
    'a += a'
    'a = +a'
    'a = [a]'
    '[a] = a'
    '[a = 1] = [a]'
    '[a, b] = [b, a]'
    '[a,, b] = [, b, a]'
    '[x, a] = [...x, a]'
    '[a, b] = {a, b}'
    '({a} = a)'
    '({a = 1} = {a})'
    '({a: b} = {a})'
    '({a} = {a: b})'
    '({a} = {a: ->})'
    '({a} = {[a]: a})'
    '({a, ...b} = {a, ...b})'
  ,
    code: 'a.b = a.c', options: [props: yes]
  ,
    code: 'a.b = c.b', options: [props: yes]
  ,
    code: 'a.b = a[b]', options: [props: yes]
  ,
    code: 'a[b] = a.b', options: [props: yes]
  ,
    code: 'a.b().c = a.b().c', options: [props: yes]
  ,
    code: 'b().c = b().c', options: [props: yes]
  ,
    code: 'a[b + 1] = a[b + 1]', options: [props: yes] # it ignores non-simple computed properties.
  ,
    code: 'a.b = a.b'
    options: [props: no]
  ,
    code: 'a.b.c = a.b.c'
    options: [props: no]
  ,
    code: 'a[b] = a[b]'
    options: [props: no]
  ,
    code: "a['b'] = a['b']"
    options: [props: no]
  ]
  invalid: [
    code: '''
      a = null
      a = a
    '''
    errors: ["'a' is assigned to itself."]
  ,
    code: '[a] = [a]'
    errors: ["'a' is assigned to itself."]
  ,
    code: '[a, b] = [a, b]'
    errors: ["'a' is assigned to itself.", "'b' is assigned to itself."]
  ,
    code: '[a, b] = [a, c]'
    errors: ["'a' is assigned to itself."]
  ,
    code: '[a, b] = [, b]'
    errors: ["'b' is assigned to itself."]
  ,
    code: '[a, ...b] = [a, ...b]'
    errors: ["'a' is assigned to itself.", "'b' is assigned to itself."]
  ,
    code: '[[a], {b}] = [[a], {b}]'
    errors: ["'a' is assigned to itself.", "'b' is assigned to itself."]
  ,
    code: '({a} = {a})'
    errors: ["'a' is assigned to itself."]
  ,
    code: '({a: b} = {a: b})'
    errors: ["'b' is assigned to itself."]
  ,
    code: '({a, b} = {a, b})'
    errors: ["'a' is assigned to itself.", "'b' is assigned to itself."]
  ,
    code: '({a, b} = {b, a})'
    errors: ["'b' is assigned to itself.", "'a' is assigned to itself."]
  ,
    code: '({a, b} = {c, a})'
    errors: ["'a' is assigned to itself."]
  ,
    code: '({a: {b}, c: [d]} = {a: {b}, c: [d]})'
    errors: ["'b' is assigned to itself.", "'d' is assigned to itself."]
  ,
    code: '({a, b} = {a, ...x, b})'
    errors: ["'b' is assigned to itself."]
  ,
    code: 'a.b = a.b'
    errors: ["'a.b' is assigned to itself."]
  ,
    code: 'a.b.c = a.b.c'
    errors: ["'a.b.c' is assigned to itself."]
  ,
    code: 'a[b] = a[b]'
    errors: ["'a[b]' is assigned to itself."]
  ,
    code: "a['b'] = a['b']"
    errors: ["'a['b']' is assigned to itself."]
  ,
    code: 'a.b = a.b'
    options: [props: yes]
    errors: ["'a.b' is assigned to itself."]
  ,
    code: 'a.b.c = a.b.c'
    options: [props: yes]
    errors: ["'a.b.c' is assigned to itself."]
  ,
    code: 'a[b] = a[b]'
    options: [props: yes]
    errors: ["'a[b]' is assigned to itself."]
  ,
    code: "a['b'] = a['b']"
    options: [props: yes]
    errors: ["'a['b']' is assigned to itself."]
  ]
