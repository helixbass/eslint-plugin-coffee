###*
# @fileoverview Tests for no-magic-numbers rule.
# @author Vincent Lemeunier
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-magic-numbers'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-magic-numbers', rule,
  valid: [
    'x = parseInt(y, 10)'
    'x = parseInt(y, -10)'
    'x = Number.parseInt(y, 10)'
    'foo = 42'
    'foo = -42'
  ,
    code: 'foo = 0 + 1 - 2 + -2'
    options: [ignore: [0, 1, 2, -2]]
  ,
    code: 'foo = 0 + 1 + 2 + 3 + 4'
    options: [ignore: [0, 1, 2, 3, 4]]
  ,
    'foo = { bar:10 }'
  ,
    code: 'setTimeout((-> 1), 0)'
    options: [ignore: [0, 1]]
  ,
    code: """
      data = ['foo', 'bar', 'baz']
      third = data[3]
    """
    options: [ignoreArrayIndexes: yes]
  ,
    'a = <input maxLength={10} />'
    'a = <div objectProp={{ test: 1}}></div>'
  ]
  invalid: [
    code: 'foo = 0 + 1'
    errors: [
      messageId: 'noMagic', data: raw: '0'
    ,
      messageId: 'noMagic', data: raw: '1'
    ]
  ,
    code: 'a = a + 5'
    errors: [messageId: 'noMagic', data: raw: '5']
  ,
    code: 'a += 5'
    errors: [messageId: 'noMagic', data: raw: '5']
  ,
    code: 'foo = 0 + 1 + -2 + 2'
    errors: [
      messageId: 'noMagic', data: raw: '0'
    ,
      messageId: 'noMagic', data: raw: '1'
    ,
      messageId: 'noMagic', data: raw: '-2'
    ,
      messageId: 'noMagic', data: raw: '2'
    ]
  ,
    code: 'foo = 0 + 1 + 2'
    options: [ignore: [0, 1]]
    errors: [messageId: 'noMagic', data: raw: '2']
  ,
    code: 'foo = { bar:10 }'
    options: [detectObjects: yes]
    errors: [messageId: 'noMagic', data: raw: '10']
  ,
    code: '''
      console.log(0x1A + 0x02)
      console.log(0o71)
    '''
    errors: [
      messageId: 'noMagic', data: raw: '0x1A'
    ,
      messageId: 'noMagic', data: raw: '0x02'
    ,
      messageId: 'noMagic', data: raw: '0o71'
    ]
  ,
    code: 'stats = {avg: 42}'
    options: [detectObjects: yes]
    errors: [messageId: 'noMagic', data: raw: '42']
  ,
    code: '''
      colors = {}
      colors.RED = 2
      colors.YELLOW = 3
      colors.BLUE = 4 + 5
    '''
    errors: [
      messageId: 'noMagic', data: raw: '4'
    ,
      messageId: 'noMagic', data: raw: '5'
    ]
  ,
    code: 'getSecondsInMinute = -> return 60'
    errors: [message: 'No magic number: 60.']
  ,
    code: 'getSecondsInMinute = -> 60'
    errors: [message: 'No magic number: 60.']
  ,
    code: 'getNegativeSecondsInMinute = -> -60'
    errors: [messageId: 'noMagic', data: raw: '-60']
  ,
    code: """
      Promise = require('bluebird')
      MINUTE = 60
      HOUR = 3600
      DAY = 86400
      configObject = {
        key: 90,
        another: 10 * 10,
        10: 'an "integer" key'
      }
      getSecondsInDay = ->
        return 24 * HOUR
      getMillisecondsInDay = ->
        (getSecondsInDay() *
          (1000)
        )
      callSetTimeoutZero = (func) ->
        setTimeout(func, 0)
      invokeInTen = (func) ->
        setTimeout(func, 10)
    """
    errors: [
      messageId: 'noMagic', data: {raw: '10'}, line: 7
    ,
      messageId: 'noMagic', data: {raw: '10'}, line: 7
    ,
      messageId: 'noMagic', data: {raw: '24'}, line: 11
    ,
      messageId: 'noMagic', data: {raw: '1000'}, line: 14
    ,
      messageId: 'noMagic', data: {raw: '0'}, line: 17
    ,
      messageId: 'noMagic', data: {raw: '10'}, line: 19
    ]
  ,
    code: """
      data = ['foo', 'bar', 'baz']
      third = data[3]
    """
    options: [{}]
    errors: [
      messageId: 'noMagic'
      data: raw: '3'
      line: 2
    ]
  ,
    code: 'a = <div arrayProp={[1,2,3]}></div>'
    errors: [
      messageId: 'noMagic', data: {raw: '1'}, line: 1
    ,
      messageId: 'noMagic', data: {raw: '2'}, line: 1
    ,
      messageId: 'noMagic', data: {raw: '3'}, line: 1
    ]
  ,
    code: '''
      min = max = mean = null
      min = 1
      max = 10
      mean = 4
    '''
    options: [{}]
    errors: [
      messageId: 'noMagic', data: {raw: '1'}, line: 2
    ,
      messageId: 'noMagic', data: {raw: '10'}, line: 3
    ,
      messageId: 'noMagic', data: {raw: '4'}, line: 4
    ]
  ]
