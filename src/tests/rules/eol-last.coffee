###*
# @fileoverview Tests for eol-last rule.
# @author Nodeca Team <https://github.com/nodeca>
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/eol-last'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'eol-last', rule,
  valid: [
    ''
    '\n'
    'a = 123\n'
    'a = 123\n\n'
    'a = 123\n   \n'

    '\r\n'
    'a = 123\r\n'
    'a = 123\r\n\r\n'
    'a = 123\r\n   \r\n'
  ,
    code: 'a = 123', options: ['never']
  ,
    code: 'a = 123\nb = 456', options: ['never']
  ,
    code: 'a = 123\r\nb = 456', options: ['never']
  ,
    # Deprecated: `"unix"` parameter
    code: '', options: ['unix']
  ,
    code: '\n', options: ['unix']
  ,
    code: 'a = 123\n', options: ['unix']
  ,
    code: 'a = 123\n\n', options: ['unix']
  ,
    code: 'a = 123\n   \n', options: ['unix']
  ,
    # Deprecated: `"windows"` parameter
    code: '', options: ['windows']
  ,
    code: '\n', options: ['windows']
  ,
    code: '\r\n', options: ['windows']
  ,
    code: 'a = 123\r\n', options: ['windows']
  ,
    code: 'a = 123\r\n\r\n', options: ['windows']
  ,
    code: 'a = 123\r\n   \r\n', options: ['windows']
  ]

  invalid: [
    code: 'a = 123'
    output: 'a = 123\n'
    errors: [messageId: 'missing', type: 'Program']
  ,
    code: 'a = 123\n   '
    output: 'a = 123\n   \n'
    errors: [messageId: 'missing', type: 'Program']
  ,
    code: 'a = 123\n'
    output: 'a = 123'
    options: ['never']
    errors: [messageId: 'unexpected', type: 'Program']
  ,
    code: 'a = 123\r\n'
    output: 'a = 123'
    options: ['never']
    errors: [messageId: 'unexpected', type: 'Program']
  ,
    code: 'a = 123\r\n\r\n'
    output: 'a = 123'
    options: ['never']
    errors: [messageId: 'unexpected', type: 'Program']
  ,
    code: 'a = 123\nb = 456\n'
    output: 'a = 123\nb = 456'
    options: ['never']
    errors: [messageId: 'unexpected', type: 'Program']
  ,
    code: 'a = 123\r\nb = 456\r\n'
    output: 'a = 123\r\nb = 456'
    options: ['never']
    errors: [messageId: 'unexpected', type: 'Program']
  ,
    code: 'a = 123\n\n'
    output: 'a = 123'
    options: ['never']
    errors: [messageId: 'unexpected', type: 'Program']
  ,
    # Deprecated: `"unix"` parameter
    code: 'a = 123'
    output: 'a = 123\n'
    options: ['unix']
    errors: [messageId: 'missing', type: 'Program']
  ,
    code: 'a = 123\n   '
    output: 'a = 123\n   \n'
    options: ['unix']
    errors: [messageId: 'missing', type: 'Program']
  ,
    # Deprecated: `"windows"` parameter
    code: 'a = 123'
    output: 'a = 123\r\n'
    options: ['windows']
    errors: [messageId: 'missing', type: 'Program']
  ,
    code: 'a = 123\r\n   '
    output: 'a = 123\r\n   \r\n'
    options: ['windows']
    errors: [messageId: 'missing', type: 'Program']
  ]
