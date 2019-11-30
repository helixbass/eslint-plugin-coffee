###*
# @fileoverview Validate strings passed to the RegExp constructor
# @author Michael Ficarra
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-invalid-regexp'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-invalid-regexp', rule,
  valid: [
    "RegExp('')"
    'RegExp()'
    "RegExp('.', 'g')"
    "new RegExp('.')"
    'new RegExp'
    "new RegExp('.', 'im')"
    "global.RegExp('\\\\')"
    "new RegExp('.', y)"
  ,
    code: "new RegExp('.', 'y')", options: [allowConstructorFlags: ['y']]
  ,
    code: "new RegExp('.', 'u')", options: [allowConstructorFlags: ['U']]
  ,
    code: "new RegExp('.', 'yu')"
    options: [allowConstructorFlags: ['y', 'u']]
  ,
    code: "new RegExp('/', 'yu')"
    options: [allowConstructorFlags: ['y', 'u']]
  ,
    code: "new RegExp('\\/', 'yu')"
    options: [allowConstructorFlags: ['y', 'u']]
  ,
    "new RegExp('.', 'y')"
    "new RegExp('.', 'u')"
    "new RegExp('.', 'yu')"
    "new RegExp('/', 'yu')"
    "new RegExp('\\/', 'yu')"
    "new RegExp('\\\\u{65}', 'u')"
    "new RegExp('[\\u{0}-\\u{1F}]', 'u')"
    "new RegExp('.', 's')"
    "new RegExp('(?<=a)b')"
    "new RegExp('(?<!a)b')"
    "new RegExp('(?<a>b)\\k<a>')"
    "new RegExp('(?<a>b)\\k<a>', 'u')"
    "new RegExp('\\p{Letter}', 'u')"
  ]
  invalid: [
    code: "RegExp('[')"
    errors: [
      message: 'Invalid regular expression: /[/: Unterminated character class.'
      type: 'CallExpression'
    ]
  ,
    code: "RegExp('.', 'z')"
    errors: [
      message: "Invalid flags supplied to RegExp constructor 'z'."
      type: 'CallExpression'
    ]
  ,
    code: "new RegExp(')')"
    errors: [
      message: "Invalid regular expression: /)/: Unmatched ')'."
      type: 'NewExpression'
    ]
  ]
