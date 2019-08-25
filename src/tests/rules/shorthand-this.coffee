###*
# @fileoverview Usage of shorthand `@` for `this`
# @author Julian Rosse
###

'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/shorthand-this'
{RuleTester} = require 'eslint'
path = require 'path'

NO_SHORTHAND = "Use 'this' instead of '@'"
USE_SHORTHAND = "Use '@' instead of 'this'"
NO_STANDALONE = "Use 'this' instead of standalone '@'"

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'shorthand-this', rule,
  valid: [
    '@'
    '@b'
    '{@c}'
    '(@b) ->'
    '({@b}) ->'
    '@b.c = d'
    '''
      class A
        b: (@c) ->
    '''
  ,
    code: '@'
    options: ['allow']
  ,
    code: 'this'
    options: ['never']
  ,
    code: 'this'
    options: ['allow']
  ,
    code: 'this'
    options: ['allow', {forbidStandalone: yes}]
  ,
    code: 'this'
    options: ['always', {forbidStandalone: yes}]
  ,
    code: 'this.b'
    options: ['allow']
  ,
    code: 'this.b'
    options: ['never']
  ,
    code: '{@b}'
    options: ['never']
  ,
    code: '(@b) ->'
    options: ['never']
  ,
    code: '({@b}) ->'
    options: ['never']
  ,
    code: '''
      class A
        b: (@c) ->
    '''
    options: ['never']
  ]
  invalid: [
    code: '@'
    options: ['never']
    errors: [NO_SHORTHAND]
  ,
    code: '@'
    options: ['always', {forbidStandalone: yes}]
    errors: [NO_STANDALONE]
  ,
    code: '@'
    options: ['allow', {forbidStandalone: yes}]
    errors: [NO_STANDALONE]
  ,
    code: '@b'
    options: ['never']
    errors: [NO_SHORTHAND]
  ,
    code: '@b.c = d'
    options: ['never']
    errors: [NO_SHORTHAND]
  ,
    code: 'this'
    options: ['always']
    errors: [USE_SHORTHAND]
  ,
    code: 'this.b'
    options: ['always']
    errors: [USE_SHORTHAND]
  ]
