###*
# @fileoverview Tests for no-irregular-whitespace rule.
# @author Jonathan Kingston
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-irregular-whitespace'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedErrors = [
  message: 'Irregular whitespace not allowed.'
  type: 'Program'
]
expectedCommentErrors = [
  message: 'Irregular whitespace not allowed.'
  type: 'Program'
  line: 1
]

ruleTester.run 'no-irregular-whitespace', rule,
  valid: [
    "'\\u000B'"
    "'\\u000C'"
    "'\\u0085'"
    "'\\u00A0'"
    "'\\u180E'"
    "'\\ufeff'"
    "'\\u2000'"
    "'\\u2001'"
    "'\\u2002'"
    "'\\u2003'"
    "'\\u2004'"
    "'\\u2005'"
    "'\\u2006'"
    "'\\u2007'"
    "'\\u2008'"
    "'\\u2009'"
    "'\\u200A'"
    "'\\u200B'"
    "'\\u2028'"
    "'\\u2029'"
    "'\\u202F'"
    "'\\u205f'"
    "'\\u3000'"
    "'\u000B'"
    "'\u000C'"
    "'\u0085'"
    "'\u00A0'"
    "'\u180E'"
    "'\ufeff'"
    "'\u2000'"
    "'\u2001'"
    "'\u2002'"
    "'\u2003'"
    "'\u2004'"
    "'\u2005'"
    "'\u2006'"
    "'\u2007'"
    "'\u2008'"
    "'\u2009'"
    "'\u200A'"
    "'\u200B'"
    "'\\\u2028'" # multiline string
    "'\\\u2029'" # multiline string
    "'\u202F'"
    "'\u205f'"
    "'\u3000'"
  ,
    code: '# \u000B\nb', options: [skipComments: yes]
  ,
    code: '# \u000C\nb', options: [skipComments: yes]
  ,
    code: '# \u0085\nb', options: [skipComments: yes]
  ,
    code: '# \u00A0\nb', options: [skipComments: yes]
  ,
    code: '# \u180E\nb', options: [skipComments: yes]
  ,
    code: '# \ufeff\nb', options: [skipComments: yes]
  ,
    code: '# \u2000\nb', options: [skipComments: yes]
  ,
    code: '# \u2001\nb', options: [skipComments: yes]
  ,
    code: '# \u2002\nb', options: [skipComments: yes]
  ,
    code: '# \u2003\nb', options: [skipComments: yes]
  ,
    code: '# \u2004\nb', options: [skipComments: yes]
  ,
    code: '# \u2005\nb', options: [skipComments: yes]
  ,
    code: '# \u2006\nb', options: [skipComments: yes]
  ,
    code: '# \u2007\nb', options: [skipComments: yes]
  ,
    code: '# \u2008\nb', options: [skipComments: yes]
  ,
    code: '# \u2009\nb', options: [skipComments: yes]
  ,
    code: '# \u200A\nb', options: [skipComments: yes]
  ,
    code: '# \u200B\nb', options: [skipComments: yes]
  ,
    code: '# \u202F\nb', options: [skipComments: yes]
  ,
    code: '# \u205f\nb', options: [skipComments: yes]
  ,
    code: '# \u3000\nb', options: [skipComments: yes]
  ,
    code: '### \u000B ###', options: [skipComments: yes]
  ,
    code: '### \u000C ###', options: [skipComments: yes]
  ,
    code: '### \u0085 ###', options: [skipComments: yes]
  ,
    code: '### \u00A0 ###', options: [skipComments: yes]
  ,
    code: '### \u180E ###', options: [skipComments: yes]
  ,
    code: '### \ufeff ###', options: [skipComments: yes]
  ,
    code: '### \u2000 ###', options: [skipComments: yes]
  ,
    code: '### \u2001 ###', options: [skipComments: yes]
  ,
    code: '### \u2002 ###', options: [skipComments: yes]
  ,
    code: '### \u2003 ###', options: [skipComments: yes]
  ,
    code: '### \u2004 ###', options: [skipComments: yes]
  ,
    code: '### \u2005 ###', options: [skipComments: yes]
  ,
    code: '### \u2006 ###', options: [skipComments: yes]
  ,
    code: '### \u2007 ###', options: [skipComments: yes]
  ,
    code: '### \u2008 ###', options: [skipComments: yes]
  ,
    code: '### \u2009 ###', options: [skipComments: yes]
  ,
    code: '### \u200A ###', options: [skipComments: yes]
  ,
    code: '### \u200B ###', options: [skipComments: yes]
  ,
    code: '### \u2028 ###', options: [skipComments: yes]
  ,
    code: '### \u2029 ###', options: [skipComments: yes]
  ,
    code: '### \u202F ###', options: [skipComments: yes]
  ,
    code: '### \u205f ###', options: [skipComments: yes]
  ,
    code: '### \u3000 ###', options: [skipComments: yes]
  ,
    code: '/\u000B/', options: [skipRegExps: yes]
  ,
    code: '/\u000C/', options: [skipRegExps: yes]
  ,
    code: '/\u0085/', options: [skipRegExps: yes]
  ,
    code: '/\u00A0/', options: [skipRegExps: yes]
  ,
    code: '/\u180E/', options: [skipRegExps: yes]
  ,
    code: '/\ufeff/', options: [skipRegExps: yes]
  ,
    code: '/\u2000/', options: [skipRegExps: yes]
  ,
    code: '/\u2001/', options: [skipRegExps: yes]
  ,
    code: '/\u2002/', options: [skipRegExps: yes]
  ,
    code: '/\u2003/', options: [skipRegExps: yes]
  ,
    code: '/\u2004/', options: [skipRegExps: yes]
  ,
    code: '/\u2005/', options: [skipRegExps: yes]
  ,
    code: '/\u2006/', options: [skipRegExps: yes]
  ,
    code: '/\u2007/', options: [skipRegExps: yes]
  ,
    code: '/\u2008/', options: [skipRegExps: yes]
  ,
    code: '/\u2009/', options: [skipRegExps: yes]
  ,
    code: '/\u200A/', options: [skipRegExps: yes]
  ,
    code: '/\u200B/', options: [skipRegExps: yes]
  ,
    code: '/\u202F/', options: [skipRegExps: yes]
  ,
    code: '/\u205f/', options: [skipRegExps: yes]
  ,
    code: '/\u3000/', options: [skipRegExps: yes]
  ,
    code: '"\u000B"'
    options: [skipTemplates: yes]
  ,
    code: '"\u000C"'
    options: [skipTemplates: yes]
  ,
    code: '"\u0085"'
    options: [skipTemplates: yes]
  ,
    code: '"\u00A0"'
    options: [skipTemplates: yes]
  ,
    code: '"\u180E"'
    options: [skipTemplates: yes]
  ,
    code: '"\ufeff"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2000"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2001"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2002"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2003"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2004"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2005"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2006"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2007"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2008"'
    options: [skipTemplates: yes]
  ,
    code: '"\u2009"'
    options: [skipTemplates: yes]
  ,
    code: '"\u200A"'
    options: [skipTemplates: yes]
  ,
    code: '"\u200B"'
    options: [skipTemplates: yes]
  ,
    code: '"\u202F"'
    options: [skipTemplates: yes]
  ,
    code: '"\u205f"'
    options: [skipTemplates: yes]
  ,
    code: '"\u3000"'
    options: [skipTemplates: yes]
  ,
    # Unicode BOM.
    "\uFEFFconsole.log('hello BOM')"
  ]

  invalid: [
    code: "any \u000B = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u000C = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u00A0 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u180E = 'thing'"
    errors: expectedErrors
  ,
    code: "any \ufeff = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2000 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2001 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2002 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2003 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2004 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2005 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2006 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2007 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2008 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2009 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u200A = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2028 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u2029 = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u202F = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u205f = 'thing'"
    errors: expectedErrors
  ,
    code: "any \u3000 = 'thing'"
    errors: expectedErrors
  ,
    code: "a = 'b';\u2028c = 'd';\ne = 'f'\u2028"
    errors: [
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 9
    ,
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 3
      column: 8
    ]
  ,
    code:
      "any \u3000 = 'thing'; other \u3000 = 'thing'\nthird \u3000 = 'thing'"
    errors: [
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 5
    ,
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 24
    ,
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 2
      column: 7
    ]
  ,
    code: '# \u000B'
    errors: expectedCommentErrors
  ,
    code: '# \u000C'
    errors: expectedCommentErrors
  ,
    code: '# \u0085'
    errors: expectedCommentErrors
  ,
    code: '# \u00A0'
    errors: expectedCommentErrors
  ,
    code: '# \u180E'
    errors: expectedCommentErrors
  ,
    code: '# \ufeff'
    errors: expectedCommentErrors
  ,
    code: '# \u2000'
    errors: expectedCommentErrors
  ,
    code: '# \u2001'
    errors: expectedCommentErrors
  ,
    code: '# \u2002'
    errors: expectedCommentErrors
  ,
    code: '# \u2003'
    errors: expectedCommentErrors
  ,
    code: '# \u2004'
    errors: expectedCommentErrors
  ,
    code: '# \u2005'
    errors: expectedCommentErrors
  ,
    code: '# \u2006'
    errors: expectedCommentErrors
  ,
    code: '# \u2007'
    errors: expectedCommentErrors
  ,
    code: '# \u2008'
    errors: expectedCommentErrors
  ,
    code: '# \u2009'
    errors: expectedCommentErrors
  ,
    code: '# \u200A'
    errors: expectedCommentErrors
  ,
    code: '# \u200B'
    errors: expectedCommentErrors
  ,
    code: '# \u202F'
    errors: expectedCommentErrors
  ,
    code: '# \u205f'
    errors: expectedCommentErrors
  ,
    code: '# \u3000'
    errors: expectedCommentErrors
  ,
    code: '### \u000B ###'
    errors: expectedCommentErrors
  ,
    code: '### \u000C ###'
    errors: expectedCommentErrors
  ,
    code: '### \u0085 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u00A0 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u180E ###'
    errors: expectedCommentErrors
  ,
    code: '### \ufeff ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2000 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2001 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2002 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2003 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2004 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2005 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2006 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2007 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2008 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2009 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u200A ###'
    errors: expectedCommentErrors
  ,
    code: '### \u200B ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2028 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u2029 ###'
    errors: expectedCommentErrors
  ,
    code: '### \u202F ###'
    errors: expectedCommentErrors
  ,
    code: '### \u205f ###'
    errors: expectedCommentErrors
  ,
    code: '### \u3000 ###'
    errors: expectedCommentErrors
  ,
    code: 'any = /\u3000/; other = /\u000B/'
    errors: [
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 8
    ,
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 21
    ]
  ,
    code: "any = '\u3000'; other = '\u000B'"
    options: [skipStrings: no]
    errors: [
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 8
    ,
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 21
    ]
  ,
    code: 'any = "\u3000#{}"; other = "\u000B#{}"'
    options: [skipTemplates: no]
    errors: [
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 8
    ,
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 24
    ]
  ,
    # eslint-disable-next-line coffee/no-template-curly-in-string
    code: '"something #{\u3000 10} another thing"'
    options: [skipTemplates: yes]
    errors: [
      message: 'Irregular whitespace not allowed.'
      type: 'Program'
      line: 1
      column: 14
    ]
  ]
