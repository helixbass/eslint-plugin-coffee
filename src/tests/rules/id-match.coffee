###*
# @fileoverview Rule to flag non-matching identifiers
# @author Matthieu Larcher
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/id-match'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'id-match', rule,
  valid: [
    # code: '__foo = "Matthieu"'
    # options: ['^[a-z]+$', {onlyDeclarations: yes}]
    # ,
    code: 'firstname = "Matthieu"'
    options: ['^[a-z]+$']
  ,
    code: 'first_name = "Matthieu"'
    options: ['[a-z]+']
  ,
    code: 'firstname = "Matthieu"'
    options: ['^f']
  ,
    code: 'last_Name = "Larcher"'
    options: ['^[a-z]+(_[A-Z][a-z]+)*$']
  ,
    code: 'param = "none"'
    options: ['^[a-z]+(_[A-Z][a-z])*$']
  ,
    code: 'noUnder = ->'
    options: ['^[^_]+$']
  ,
    code: 'no_under()'
    options: ['^[^_]+$']
  ,
    code: 'foo.no_under2()'
    options: ['^[^_]+$']
  ,
    code: 'foo = bar.no_under3'
    options: ['^[^_]+$']
  ,
    code: 'foo = bar.no_under4.something'
    options: ['^[^_]+$']
  ,
    code: 'foo.no_under5.qux = bar.no_under6.something'
    options: ['^[^_]+$']
  ,
    code: 'if (bar.no_under7) then ;'
    options: ['^[^_]+$']
  ,
    code: 'obj = { key: foo.no_under8 }'
    options: ['^[^_]+$']
  ,
    code: 'arr = [foo.no_under9]'
    options: ['^[^_]+$']
  ,
    code: '[foo.no_under10]'
    options: ['^[^_]+$']
  ,
    code: 'arr = [foo.no_under11.qux]'
    options: ['^[^_]+$']
  ,
    code: '[foo.no_under12.nesting]'
    options: ['^[^_]+$']
  ,
    code: 'if (foo.no_under13 is boom.no_under14) then [foo.no_under15]'
    options: ['^[^_]+$']
  ,
    code: '''
      myArray = new Array()
      myDate = new Date()
    '''
    options: ['^[a-z$]+([A-Z][a-z]+)*$']
  ,
    code: 'x = obj._foo'
    options: ['^[^_]+$']
  ,
    code: 'obj = {key: no_under}'
    options: ['^[^_]+$', {properties: yes}]
  ,
    code: 'o = {key: 1}'
    options: ['^[^_]+$', {properties: yes}]
  ,
    code: 'o = {no_under16: 1}'
    options: ['^[^_]+$', {properties: no}]
  ,
    code: 'obj.no_under17 = 2'
    options: ['^[^_]+$', {properties: no}]
  ,
    code: 'obj = {\n no_under18: 1 \n}\nobj.no_under19 = 2'
    options: ['^[^_]+$', {properties: no}]
  ,
    code: 'obj.no_under20 = ->'
    options: ['^[^_]+$', {properties: no}]
  ,
    code: 'x = obj._foo2'
    options: ['^[^_]+$', {properties: no}]
  ]
  invalid: [
    code: '__foo = "Matthieu"'
    options: ['^[a-z]+$', {onlyDeclarations: yes}]
    errors: [
      message: "Identifier '__foo' does not match the pattern '^[a-z]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'class __foo'
    options: ['^[a-z]+$', {onlyDeclarations: yes}]
    errors: [
      message: "Identifier '__foo' does not match the pattern '^[a-z]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'first_name = "Matthieu"'
    options: ['^[a-z]+$']
    errors: [
      message: "Identifier 'first_name' does not match the pattern '^[a-z]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'first_name = "Matthieu"'
    options: ['^z']
    errors: [
      message: "Identifier 'first_name' does not match the pattern '^z'."
      type: 'Identifier'
    ]
  ,
    code: 'Last_Name = "Larcher"'
    options: ['^[a-z]+(_[A-Z][a-z])*$']
    errors: [
      message:
        "Identifier 'Last_Name' does not match the pattern '^[a-z]+(_[A-Z][a-z])*$'."
      type: 'Identifier'
    ]
  ,
    code: 'no_under21 = ->'
    options: ['^[^_]+$']
    errors: [
      message: "Identifier 'no_under21' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'obj.no_under22 = ->'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under22' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'no_under23.foo = ->'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under23' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: '[no_under24.baz]'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under24' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'if (foo.bar_baz is boom.bam_pow) then [no_under25.baz]'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under25' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'foo.no_under26 = boom.bam_pow'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under26' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'foo = { no_under27: boom.bam_pow }'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under27' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'foo.qux.no_under28 = { bar: boom.bam_pow }'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under28' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'o = {no_under29: 1}'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under29' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ,
    code: 'obj.no_under30 = 2'
    options: ['^[^_]+$', {properties: yes}]
    errors: [
      message: "Identifier 'no_under30' does not match the pattern '^[^_]+$'."
      type: 'Identifier'
    ]
  ]
