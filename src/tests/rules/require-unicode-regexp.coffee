###*
# @fileoverview Tests for require-unicode-regexp rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/require-unicode-regexp'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'require-unicode-regexp', rule,
  valid: [
    '/foo/u'
    '/foo/gimuy'
    "RegExp('', 'u')"
    "new RegExp('', 'u')"
    "RegExp '', 'gimuy'"
    "new RegExp('', 'gimuy')"
    """
      flags = 'u'
      new RegExp('', flags)
    """
    """
      flags = 'g'
      new RegExp('', flags + 'u')
    """
    """
      flags = 'gimu'
      new RegExp('foo', flags.slice(1))
    """
    "new RegExp('', flags)"
    "f = (flags) -> new RegExp('', flags)"
    "f = (RegExp) -> return new RegExp('foo')"
  ]
  invalid: [
    code: '/foo/'
    errors: [messageId: 'requireUFlag']
  ,
    code: '/foo/gimy'
    errors: [messageId: 'requireUFlag']
  ,
    code: "RegExp('foo')"
    errors: [messageId: 'requireUFlag']
  ,
    code: "RegExp('foo', '')"
    errors: [messageId: 'requireUFlag']
  ,
    code: "RegExp 'foo', 'gimy'"
    errors: [messageId: 'requireUFlag']
  ,
    code: "new RegExp('foo')"
    errors: [messageId: 'requireUFlag']
  ,
    code: "new RegExp('foo', '')"
    errors: [messageId: 'requireUFlag']
  ,
    code: "new RegExp('foo', 'gimy')"
    errors: [messageId: 'requireUFlag']
  ,
    # ,
    #   code: """
    #     flags = 'gi'
    #     new RegExp('foo', flags)
    #   """
    #   errors: [messageId: 'requireUFlag']
    # ,
    #   code: """
    #     flags = 'gimu'
    #     new RegExp('foo', flags.slice(0, -1))
    #   """
    #   errors: [messageId: 'requireUFlag']
    code: "new window.RegExp('foo')"
    errors: [messageId: 'requireUFlag']
    env: browser: yes
  ,
    code: "new global.RegExp('foo')"
    errors: [messageId: 'requireUFlag']
    env: node: yes
  ]
