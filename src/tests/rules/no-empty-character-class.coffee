###*
# @fileoverview Tests for no-empty-class rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-empty-character-class'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable ###

ruleTester.run 'no-empty-character-class', rule,
  valid: [
    'foo = /^abc[a-zA-Z]/'
    'regExp = new RegExp("^abc[]")'
    'foo = /^abc/'
    'foo = /[\\[]/'
    'foo = /[\\]]/'
    'foo = /[a-zA-Z\\[]/'
    'foo = /[[]/'
    'foo = /[\\[a-z[]]/'
    'foo = /[\\-\\[\\]\\/\\{\\}\\(\\)\\*\\+\\?\\.\\\\^\\$\\|]/g'
    'foo = /\\s*:\\s*/gim'
    'foo = /[\\]]/uy'
    'foo = /[\\]]/s'
    'foo = /\\[]/'
    '''
      foo = ///
        x
        # []
      ///
    '''
    '''
      foo = ///
        x
        # []
        #{b []}
      ///
    '''
    '''
      ///#{a}\\ ///
    '''
  ]
  invalid: [
    code: 'foo = /^abc[]/'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'foo = ///^abc[]///'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'foo = /foo[]bar/'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'if foo.match(/^abc[]/) then yes'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'if /^abc[]/.test(foo) then yes'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'foo = /[]]/'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'foo = /\\[[]/'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: 'foo = /\\[\\[\\]a-z[]/'
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    code: '''
        foo = ///
          x
          []
        ///
      '''
    errors: [messageId: 'unexpected', type: 'Literal']
  ,
    # eslint-disable-next-line coffee/no-template-curly-in-string
    code: '''
        foo = ///
          x
          []
          #{b []}
        ///
      '''
    errors: [messageId: 'unexpected', type: 'InterpolatedRegExpLiteral']
  ]
