###*
# @fileoverview Tests for no-catch-shadow rule.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-catch-shadow'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-catch-shadow', rule,
  valid: [
    '''
      foo = 1
      try
        bar()
      catch baz
    '''
    '''
      'use strict'

      broken = ->
         try
           throw new Error()
         catch e
           #

      module.exports = broken
    '''
  ,
    code: '''
      try
      catch error
    '''
    env: shelljs: no
  ,
    code: '''
      try
      catch
    '''
    parserOptions: ecmaVersion: 2019
  ]
  invalid: [
    code: '''
      foo = 1
      try
        bar()
      catch foo
    '''
    errors: [messageId: 'mutable', data: {name: 'foo'}, type: 'CatchClause']
  ,
    code: '''
      foo = ->
      try
        bar()
      catch foo
    '''
    errors: [messageId: 'mutable', data: {name: 'foo'}, type: 'CatchClause']
  ,
    code: '''
      foo = ->
        try
          bar()
        catch foo
    '''
    errors: [messageId: 'mutable', data: {name: 'foo'}, type: 'CatchClause']
  ]
