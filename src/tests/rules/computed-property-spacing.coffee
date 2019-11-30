###*
# @fileoverview Disallows or enforces spaces inside computed properties.
# @author Jamund Ferguson
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/computed-property-spacing'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'computed-property-spacing', rule,
  valid: [
    # default - never
    'obj[foo]'
    "obj['foo']"
  ,
    code: 'x = {[b]: a}'
  ,
    # always
    code: 'obj[ foo ]', options: ['always']
  ,
    code: "obj[ 'foo' ]", options: ['always']
  ,
    code: "obj[ 'foo' + 'bar' ]", options: ['always']
  ,
    code: 'obj[ obj2[ foo ] ]', options: ['always']
  ,
    code: '''
      obj.map (item) -> return [
        1
        2
        3
        4
      ]
    '''
    options: ['always']
  ,
    code: '''
      obj[ 'map' ] (item) -> [
        1,
        2,
        3,
        4
      ]
    '''
    options: ['always']
  ,
    code: '''
      obj[ 'for' + 'Each' ] (item) -> return [
        1,
        2,
        3,
        4
      ]
    '''
    options: ['always']
  ,
    code: 'foo = obj[ 1 ]', options: ['always']
  ,
    code: "foo = obj[ 'foo' ]", options: ['always']
  ,
    code: 'foo = obj[ [1, 1] ]', options: ['always']
  ,
    # always - objectLiteralComputedProperties
    code: 'x = {[ "a" ]: a}'
    options: ['always']
  ,
    code: 'x = [ "a" ]: a'
    options: ['always']
  ,
    code: 'y = {[ x ]: a}'
    options: ['always']
  ,
    code: 'x = {[ "a" ]: ->}'
    options: ['always']
  ,
    code: 'y = {[ x ]: ->}'
    options: ['always']
  ,
    # always - unrelated cases
    code: 'foo = {}', options: ['always']
  ,
    code: 'foo = []', options: ['always']
  ,
    # never
    code: 'obj[foo]', options: ['never']
  ,
    code: "obj['foo']", options: ['never']
  ,
    code: "obj['foo' + 'bar']", options: ['never']
  ,
    code: "obj['foo'+'bar']", options: ['never']
  ,
    code: 'obj[obj2[foo]]', options: ['never']
  ,
    code: '''
      obj.map (item) -> return [
        1
        2
        3
        4
      ]
    '''
    options: ['never']
  ,
    code: '''
      obj['map'] (item) -> [
        1
        2
        3
        4
      ]
    '''
    options: ['never']
  ,
    code: '''
      obj['for' + 'Each'] (item) -> return [
        1,
        2,
        3,
        4
      ]
    '''
    options: ['never']
  ,

  ,
    code: 'foo = obj[1]', options: ['never']
  ,
    code: "foo = obj['foo']", options: ['never']
  ,
    code: 'foo = obj[[ 1, 1 ]]', options: ['never']
  ,
    # never - objectLiteralComputedProperties
    code: 'x = {["a"]: a}'
    options: ['never']
  ,
    code: 'y = {[x]: a}'
    options: ['never']
  ,
    code: 'y = [x]: a'
    options: ['never']
  ,
    code: 'x = {["a"]: ->}'
    options: ['never']
  ,
    code: 'y = {[x]: ->}'
    options: ['never']
  ,
    # never - unrelated cases
    code: 'foo = {}', options: ['never']
  ,
    code: 'foo = []', options: ['never']
  ]

  invalid: [
    code: 'foo = obj[ 1]'
    output: 'foo = obj[ 1 ]'
    options: ['always']
    errors: [
      messageId: 'missingSpaceBefore'
      data: tokenValue: ']'
      type: 'MemberExpression'
      column: 13
      line: 1
    ]
  ,
    code: 'foo = obj[1 ]'
    output: 'foo = obj[ 1 ]'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data: tokenValue: '['
      type: 'MemberExpression'
      column: 10
      line: 1
    ]
  ,
    code: 'foo = obj[ 1]'
    output: 'foo = obj[1]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data: tokenValue: '['
      type: 'MemberExpression'
      column: 10
      line: 1
    ]
  ,
    code: 'foo = obj[1 ]'
    output: 'foo = obj[1]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data: tokenValue: ']'
      type: 'MemberExpression'
    ]
  ,
    code: 'obj[ foo ]'
    output: 'obj[foo]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data: tokenValue: '['
      type: 'MemberExpression'
      column: 4
      line: 1
    ,
      messageId: 'unexpectedSpaceBefore'
      data: tokenValue: ']'
      type: 'MemberExpression'
      column: 10
      line: 1
    ]
  ,
    code: 'obj[foo ]'
    output: 'obj[foo]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data: tokenValue: ']'
      type: 'MemberExpression'
      column: 9
      line: 1
    ]
  ,
    code: 'obj[ foo]'
    output: 'obj[foo]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data: tokenValue: '['
      type: 'MemberExpression'
      column: 4
      line: 1
    ]
  ,
    code: 'foo = obj[1]'
    output: 'foo = obj[ 1 ]'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data: tokenValue: '['
      type: 'MemberExpression'
      column: 10
      line: 1
    ,
      messageId: 'missingSpaceBefore'
      data: tokenValue: ']'
      type: 'MemberExpression'
      column: 12
      line: 1
    ]
  ,
    # always - objectLiteralComputedProperties
    code: 'x = {[a]: b}'
    output: 'x = {[ a ]: b}'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data: tokenValue: '['
      type: 'Property'
      column: 6
      line: 1
    ,
      messageId: 'missingSpaceBefore'
      data: tokenValue: ']'
      type: 'Property'
      column: 8
      line: 1
    ]
  ,
    code: 'x = [a]: b'
    output: 'x = [ a ]: b'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data: tokenValue: '['
      type: 'Property'
      column: 5
      line: 1
    ,
      messageId: 'missingSpaceBefore'
      data: tokenValue: ']'
      type: 'Property'
      column: 7
      line: 1
    ]
  ,
    code: 'x = {[a ]: b}'
    output: 'x = {[ a ]: b}'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data: tokenValue: '['
      type: 'Property'
      column: 6
      line: 1
    ]
  ,
    code: 'x = {[ a]: b}'
    output: 'x = {[ a ]: b}'
    options: ['always']
    errors: [
      messageId: 'missingSpaceBefore'
      data: tokenValue: ']'
      type: 'Property'
      column: 9
      line: 1
    ]
  ,
    # never - objectLiteralComputedProperties
    code: 'x = {[ a ]: b}'
    output: 'x = {[a]: b}'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data: tokenValue: '['
      type: 'Property'
      column: 6
      line: 1
    ,
      messageId: 'unexpectedSpaceBefore'
      data: tokenValue: ']'
      type: 'Property'
      column: 10
      line: 1
    ]
  ,
    code: 'x = {[a ]: b}'
    output: 'x = {[a]: b}'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data: tokenValue: ']'
      type: 'Property'
      column: 9
      line: 1
    ]
  ,
    code: 'x = {[ a]: b}'
    output: 'x = {[a]: b}'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data: tokenValue: '['
      type: 'Property'
      column: 6
      line: 1
    ]
  ,
    code: 'x = {[ a\n]: b}'
    output: 'x = {[a\n]: b}'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data: tokenValue: '['
      type: 'Property'
      column: 6
      line: 1
    ]
  ]
