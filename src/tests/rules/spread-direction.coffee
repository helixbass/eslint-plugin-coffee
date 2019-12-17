###*
# @fileoverview Use postfix or prefix spread dots `...`
# @author Julian Rosse
###

'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/spread-direction'
{RuleTester} = require 'eslint'
path = require 'path'

USE_PREFIX = "Use the prefix form of '...'"
USE_POSTFIX = "Use the postfix form of '...'"

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'spread-direction', rule,
  valid: [
    '[...b]'
    '[...b] = c'
    '([...b]) ->'
    '{...b}'
    '{...b} = c'
    '({...b}) ->'
    '<div {...b} />'
  ,
    code: '[...b]'
    options: ['prefix']
  ,
    code: '[b...]'
    options: ['postfix']
  ,
    code: '[b...] = c'
    options: ['postfix']
  ,
    code: '[a..., b] = c'
    options: ['postfix']
  ,
    code: '([b...]) ->'
    options: ['postfix']
  ,
    code: '{b...}'
    options: ['postfix']
  ,
    code: '{b...} = c'
    options: ['postfix']
  ,
    code: '({b...}) ->'
    options: ['postfix']
  ,
    code: '<div {b...} />'
    options: ['postfix']
  ,
    '[..., b] = c'
  ,
    code: '[..., b] = c'
    options: ['postfix']
  ]
  invalid: [
    code: '[...b]'
    options: ['postfix']
    errors: [USE_POSTFIX]
  ,
    code: '[...b] = c'
    options: ['postfix']
    errors: [USE_POSTFIX]
  ,
    code: '([...b]) ->'
    options: ['postfix']
    errors: [USE_POSTFIX]
  ,
    code: '{...b}'
    options: ['postfix']
    errors: [USE_POSTFIX]
  ,
    code: '{...b} = c'
    options: ['postfix']
    errors: [USE_POSTFIX]
  ,
    code: '({...b}) ->'
    options: ['postfix']
    errors: [USE_POSTFIX]
  ,
    code: '<div {...b} />'
    options: ['postfix']
    errors: [USE_POSTFIX]
  ,
    code: '[b...]'
    options: ['prefix']
    errors: [USE_PREFIX]
  ,
    code: '[b...]'
    errors: [USE_PREFIX]
  ,
    code: '[b...] = c'
    options: ['prefix']
    errors: [USE_PREFIX]
  ,
    code: '([b...]) ->'
    options: ['prefix']
    errors: [USE_PREFIX]
  ,
    code: '{b...}'
    options: ['prefix']
    errors: [USE_PREFIX]
  ,
    code: '{b...} = c'
    options: ['prefix']
    errors: [USE_PREFIX]
  ,
    code: '({b...}) ->'
    options: ['prefix']
    errors: [USE_PREFIX]
  ,
    code: '<div {b...} />'
    options: ['prefix']
    errors: [USE_PREFIX]
  ]
