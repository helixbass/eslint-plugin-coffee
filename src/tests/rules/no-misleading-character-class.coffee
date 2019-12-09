###*
# @author Toru Nagashima <https://github.com/mysticatea>
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-misleading-character-class'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

###
# /[👍]/ // ERROR: a surrogate pair in a character class without u flag.
# /[❇️]/u // ERROR: variation selectors in a character class.
# /[👨‍👩‍👦]/u // ERROR: ZWJ in a character class.
# /[🇯🇵]/u // ERROR: a U+1F1E6-1F1FF pair in a character class.
# /[👶🏻]/u // ERROR: an emoji which is made with an emoji and skin tone selector, in a character class.
###

ruleTester.run 'no-misleading-character-class', rule,
  valid: [
    'r = /[👍]/u'
    'r = /[\\uD83D\\uDC4D]/u'
    'r = /[\\u{1F44D}]/u'
    'r = /❇️/'
    'r = /Á/'
    'r = /[❇]/'
    'r = /👶🏻/'
    'r = /[👶]/u'
    'r = /🇯🇵/'
    'r = /[JP]/'
    'r = /👨‍👩‍👦/'

    # Ignore solo lead/tail surrogate.
    'r = /[\\uD83D]/'
    'r = /[\\uDC4D]/'
    'r = /[\\uD83D]/u'
    'r = /[\\uDC4D]/u'

    # Ignore solo combining char.
    'r = /[\\u0301]/'
    'r = /[\\uFE0F]/'
    'r = /[\\u0301]/u'
    'r = /[\\uFE0F]/u'

    # Ignore solo emoji modifier.
    'r = /[\\u{1F3FB}]/u'
    'r = /[\u{1F3FB}]/u'

    # Ignore solo regional indicator symbol.
    'r = /[🇯]/u'
    'r = /[🇵]/u'

    # Ignore solo ZWJ.
    'r = /[\\u200D]/'
    'r = /[\\u200D]/u'
  ]
  invalid: [
    # RegExp Literals.
    code: 'r = /[👍]/'
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: 'r = /[\\uD83D\\uDC4D]/'
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: 'r = /[Á]/'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[Á]/u'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[\\u0041\\u0301]/'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[\\u0041\\u0301]/u'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[\\u{41}\\u{301}]/u'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[❇️]/'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[❇️]/u'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[\\u2747\\uFE0F]/'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[\\u2747\\uFE0F]/u'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[\\u{2747}\\u{FE0F}]/u'
    errors: [messageId: 'combiningClass']
  ,
    code: 'r = /[👶🏻]/'
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: 'r = /[👶🏻]/u'
    errors: [messageId: 'emojiModifier']
  ,
    code: 'r = /[\\uD83D\\uDC76\\uD83C\\uDFFB]/u'
    errors: [messageId: 'emojiModifier']
  ,
    code: 'r = /[\\u{1F476}\\u{1F3FB}]/u'
    errors: [messageId: 'emojiModifier']
  ,
    code: 'r = /[🇯🇵]/'
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: 'r = /[🇯🇵]/u'
    errors: [messageId: 'regionalIndicatorSymbol']
  ,
    code: 'r = /[\\uD83C\\uDDEF\\uD83C\\uDDF5]/u'
    errors: [messageId: 'regionalIndicatorSymbol']
  ,
    code: 'r = /[\\u{1F1EF}\\u{1F1F5}]/u'
    errors: [messageId: 'regionalIndicatorSymbol']
  ,
    code: 'r = /[👨‍👩‍👦]/'
    errors: [{messageId: 'surrogatePairWithoutUFlag'}, {messageId: 'zwj'}]
  ,
    code: 'r = /[👨‍👩‍👦]/u'
    errors: [messageId: 'zwj']
  ,
    code:
      'r = /[\\uD83D\\uDC68\\u200D\\uD83D\\uDC69\\u200D\\uD83D\\uDC66]/u'
    errors: [messageId: 'zwj']
  ,
    code: 'r = /[\\u{1F468}\\u{200D}\\u{1F469}\\u{200D}\\u{1F466}]/u'
    errors: [messageId: 'zwj']
  ,
    # RegExp constructors.
    code: String.raw'''r = new RegExp("[👍]", "")'''
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: String.raw'''r = new RegExp("[\uD83D\uDC4D]", "")'''
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: String.raw'''r = new RegExp("[Á]", "")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[Á]", "u")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[\u0041\u0301]", "")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[\u0041\u0301]", "u")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[\u{41}\u{301}]", "u")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[❇️]", "")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[❇️]", "u")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[\u2747\uFE0F]", "")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[\u2747\uFE0F]", "u")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[\u{2747}\u{FE0F}]", "u")'''
    errors: [messageId: 'combiningClass']
  ,
    code: String.raw'''r = new RegExp("[👶🏻]", "")'''
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: String.raw'''r = new RegExp("[👶🏻]", "u")'''
    errors: [messageId: 'emojiModifier']
  ,
    code: String.raw'''r = new RegExp("[\uD83D\uDC76\uD83C\uDFFB]", "u")'''
    errors: [messageId: 'emojiModifier']
  ,
    code: String.raw'''r = new RegExp("[\u{1F476}\u{1F3FB}]", "u")'''
    errors: [messageId: 'emojiModifier']
  ,
    code: String.raw'''r = new RegExp("[🇯🇵]", "")'''
    errors: [messageId: 'surrogatePairWithoutUFlag']
  ,
    code: String.raw'''r = new RegExp("[🇯🇵]", "u")'''
    errors: [messageId: 'regionalIndicatorSymbol']
  ,
    code: String.raw'''r = new RegExp("[\uD83C\uDDEF\uD83C\uDDF5]", "u")'''
    errors: [messageId: 'regionalIndicatorSymbol']
  ,
    code: String.raw'''r = new RegExp("[\u{1F1EF}\u{1F1F5}]", "u")'''
    errors: [messageId: 'regionalIndicatorSymbol']
  ,
    code: String.raw'''r = new RegExp("[👨‍👩‍👦]", "")'''
    errors: [{messageId: 'surrogatePairWithoutUFlag'}, {messageId: 'zwj'}]
  ,
    code: String.raw'''r = new RegExp("[👨‍👩‍👦]", "u")'''
    errors: [messageId: 'zwj']
  ,
    code: String.raw'''r = new RegExp("[\uD83D\uDC68\u200D\uD83D\uDC69\u200D\uD83D\uDC66]", "u")'''
    errors: [messageId: 'zwj']
  ,
    code: String.raw'''r = new RegExp("[\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F466}]", "u")'''
    errors: [messageId: 'zwj']
  ]
