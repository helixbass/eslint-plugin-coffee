###*
# @fileoverview Look for useless escapes in strings and regexes
# @author Onur Temizkan
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-useless-escape'
{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'no-useless-escape', rule,
  valid: [
    'foo = /\\./'
    'foo = ///\\.///'
    'foo = ///#{a}\\.///'
    'foo = /\\//g'
    'foo = /""/'
    "foo = /''/"
    'foo = /([A-Z])\\t+/g'
    'foo = /([A-Z])\\n+/g'
    'foo = /([A-Z])\\v+/g'
    'foo = /\\D/'
    'foo = /\\W/'
    'foo = /\\w/'
    'foo = /\\B/'
    'foo = /\\\\/g'
    'foo = /\\w\\$\\*\\./'
    'foo = /\\^\\+\\./'
    'foo = /\\|\\}\\{\\./'
    'foo = /]\\[\\(\\)\\//'
    'foo = "\\x123"'
    'foo = "\\u00a9"'
    'foo = "\\""'
    'foo = "xs\\u2111"'
    'foo = "foo \\\\ bar"'
    'foo = "\\t"'
    'foo = "foo \\b bar"'
    "foo = '\\n'"
    "foo = 'foo \\r bar'"
    "foo = '\\v'"
    "foo = '\\f'"
    "foo = '\\\n'"
    "foo = '\\\r\n'"
  ,
    code: '<foo attr="\\d"/>'
  ,
    code: '<div> Testing: \\ </div>'
  ,
    code: '<div> Testing: &#x5C </div>'
  ,
    code: "<foo attr='\\d'></foo>"
  ,
    code: '<> Testing: \\ </>'
  ,
    code: '<> Testing: &#x5C </>'
  ,
    code: 'foo = "\\x123"'
  ,
    code: 'foo = "\\u00a9"'
  ,
    code: 'foo = "xs\\u2111"'
  ,
    code: 'foo = "foo \\\\ bar"'
  ,
    code: 'foo = "\\t"'
  ,
    code: 'foo = "foo \\b bar"'
  ,
    code: 'foo = "\\n"'
  ,
    code: 'foo = "foo \\r bar"'
  ,
    code: 'foo = "\\v"'
  ,
    code: 'foo = "\\f"'
  ,
    code: 'foo = "\\\n"'
  ,
    code: 'foo = "\\\r\n"'
  ,
    code: 'foo = "#{foo} \\x123"'
  ,
    code: 'foo = "#{foo} \\u00a9"'
  ,
    code: 'foo = "#{foo} xs\\u2111"'
  ,
    code: 'foo = "#{foo} \\\\ #{bar}"'
  ,
    code: 'foo = "#{foo} \\b #{bar}"'
  ,
    code: 'foo = "#{foo}\\t"'
  ,
    code: 'foo = "#{foo}\\n"'
  ,
    code: 'foo = "#{foo}\\r"'
  ,
    code: 'foo = "#{foo}\\v"'
  ,
    code: 'foo = "#{foo}\\f"'
  ,
    code: 'foo = "#{foo}\\\n"'
  ,
    code: 'foo = "#{foo}\\\r\n"'
  ,
    code: 'foo = "\\""'
  ,
    code: 'foo = "\\"#{foo}\\""'
  ,
    code: 'foo = "\\#{{#{foo}"'
  ,
    code: 'foo = "#\\{{#{foo}"'
  ,
    code: 'foo = String.raw"\\."'
  ,
    code: 'foo = myFunc"\\."'
  ,
    String.raw"foo = /[\d]/"
    String.raw"foo = /[a\-b]/"
    String.raw"foo = /foo\?/"
    String.raw"foo = /example\.com/"
    String.raw"foo = /foo\|bar/"
    String.raw"foo = /\^bar/"
    String.raw"foo = /[\^bar]/"
    String.raw"foo = /\(bar\)/"
    String.raw"foo = /[[\]]/" # A character class containing '[' and ']'
    String.raw"foo = /[[]\./" # A character class containing '[', followed by a '.' character
    String.raw"foo = /[\]\]]/" # A (redundant) character class containing ']'
    String.raw"foo = /\[abc]/" # Matches the literal string '[abc]'
    String.raw"foo = /\[foo\.bar]/" # Matches the literal string '[foo.bar]'
    String.raw"foo = /vi/m"
    String.raw"foo = /\B/"
    String.raw"foo = /[\\/]/"

    # https://github.com/eslint/eslint/issues/7472
    String.raw"foo = /\0/" # null character
    'foo = /\\1/' # \x01 character (octal literal)
    'foo = /(a)\\1/' # backreference
    'foo = /(a)\\12/' # backreference
    'foo = /[\\0]/' # null character in character class
    "foo = 'foo \\\u2028 bar'"
    "foo = 'foo \\\u2029 bar'"

    # https://github.com/eslint/eslint/issues/7789
    String.raw"/]/"
    String.raw"/\]/"
    String.raw"/\]/u"
    String.raw"foo = /foo\]/"
    String.raw"foo = /[[]\]/" # A character class containing '[', followed by a ']' character
    String.raw"foo = /\[foo\.bar\]/"
    # ES2018
    String.raw"foo = /(?<a>)\k<a>/"
    String.raw"foo = /(\\?<a>)/"
    String.raw"foo = /\p{ASCII}/u"
    String.raw"foo = /\P{ASCII}/u"
    String.raw"foo = /[\p{ASCII}]/u"
    String.raw"foo = /[\P{ASCII}]/u"

    '''
      foo = """
        \\"\\"\\"a\\"\\"\\"
      """
    '''
    """
      foo = '''
        \\'\\'\\'a\\'\\'\\'
      '''
    """
  ]

  invalid: [
    code: 'foo = /\\#/'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\#.'
      type: 'Literal'
    ]
  ,
    code: 'foo = /\\;/'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\;.'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\\'"'
    errors: [
      line: 1
      column: 8
      message: "Unnecessary escape character: \\'."
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\#/"'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\#.'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\`"'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\`.'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\a"'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\a.'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\B"'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\B.'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\@"'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\@.'
      type: 'Literal'
    ]
  ,
    code: 'foo = "foo \\a bar"'
    errors: [
      line: 1
      column: 12
      message: 'Unnecessary escape character: \\a.'
      type: 'Literal'
    ]
  ,
    code: "foo = '\\\"'"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\".'
      type: 'Literal'
    ]
  ,
    code: "foo = '\\#'"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\#.'
      type: 'Literal'
    ]
  ,
    code: "foo = '\\$'"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\$.'
      type: 'Literal'
    ]
  ,
    code: "foo = '\\p'"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\p.'
      type: 'Literal'
    ]
  ,
    code: "foo = '\\p\\a\\@'"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\p.'
      type: 'Literal'
    ,
      line: 1
      column: 10
      message: 'Unnecessary escape character: \\a.'
      type: 'Literal'
    ,
      line: 1
      column: 12
      message: 'Unnecessary escape character: \\@.'
      type: 'Literal'
    ]
  ,
    code: '<foo attr={"\\d"}/>'
    errors: [
      line: 1
      column: 13
      message: 'Unnecessary escape character: \\d.'
      type: 'Literal'
    ]
  ,
    code: "foo = '\\`'"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\`.'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\\'"'
    errors: [
      line: 1
      column: 8
      message: "Unnecessary escape character: \\'."
      type: 'Literal'
    ]
  ,
    code: '''
      foo = '\\`foo\\`'
    '''
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\`.'
      type: 'Literal'
    ,
      line: 1
      column: 13
      message: 'Unnecessary escape character: \\`.'
      type: 'Literal'
    ]
  ,
    code: '''
      foo = '\\"foo\\"'
    '''
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\".'
      type: 'Literal'
    ,
      line: 1
      column: 13
      message: 'Unnecessary escape character: \\".'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\\'#{foo}\\\'"'
    errors: [
      line: 1
      column: 8
      message: "Unnecessary escape character: \\'."
      type: 'TemplateElement'
    ,
      line: 1
      column: 16
      message: "Unnecessary escape character: \\'."
      type: 'TemplateElement'
    ]
  ,
    code: "foo = '\\ '"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\ .'
      type: 'Literal'
    ]
  ,
    code: 'foo = /\\ /'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\ .'
      type: 'Literal'
    ]
  ,
    code: 'foo = "\\${{#{foo}"'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\$.'
      type: 'TemplateElement'
    ]
  ,
    code: 'foo = "\\#a#{foo}"'
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\#.'
      type: 'TemplateElement'
    ]
  ,
    code: 'foo = "a\\{{#{foo}"'
    errors: [
      line: 1
      column: 9
      message: 'Unnecessary escape character: \\{.'
      type: 'TemplateElement'
    ]
  ,
    code: String.raw"foo = /[ab\-]/"
    errors: [
      line: 1
      column: 11
      message: 'Unnecessary escape character: \\-.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[\-ab]/"
    errors: [
      line: 1
      column: 9
      message: 'Unnecessary escape character: \\-.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[ab\?]/"
    errors: [
      line: 1
      column: 11
      message: 'Unnecessary escape character: \\?.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[ab\.]/"
    errors: [
      line: 1
      column: 11
      message: 'Unnecessary escape character: \\..'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[a\|b]/"
    errors: [
      line: 1
      column: 10
      message: 'Unnecessary escape character: \\|.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /\-/"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\-.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[\-]/"
    errors: [
      line: 1
      column: 9
      message: 'Unnecessary escape character: \\-.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[ab\$]/"
    errors: [
      line: 1
      column: 11
      message: 'Unnecessary escape character: \\$.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[\(paren]/"
    errors: [
      line: 1
      column: 9
      message: 'Unnecessary escape character: \\(.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[\[]/"
    errors: [
      line: 1
      column: 9
      message: 'Unnecessary escape character: \\[.'
      type: 'Literal'
    ]
  ,
    # ,
    #   code: String.raw"foo = /[\/]/" # A character class containing '/'
    #   errors: [
    #     line: 1
    #     column: 9
    #     message: 'Unnecessary escape character: \\/.'
    #     type: 'Literal'
    #   ]
    code: String.raw"foo = /[\B]/"
    errors: [
      line: 1
      column: 9
      message: 'Unnecessary escape character: \\B.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[a][\-b]/"
    errors: [
      line: 1
      column: 12
      message: 'Unnecessary escape character: \\-.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /\-[]/"
    errors: [
      line: 1
      column: 8
      message: 'Unnecessary escape character: \\-.'
      type: 'Literal'
    ]
  ,
    code: String.raw"foo = /[a\^]/"
    errors: [
      line: 1
      column: 10
      message: 'Unnecessary escape character: \\^.'
      type: 'Literal'
    ]
  ,
    code: '"multiline template\nliteral with useless \\escape"'
    errors: [
      line: 2
      column: 22
      message: 'Unnecessary escape character: \\e.'
      type: 'Literal'
    ]
  ,
    # ,
    #   code: '"\\a"""'
    #   errors: [
    #     line: 1
    #     column: 2
    #     message: 'Unnecessary escape character: \\a.'
    #     type: 'TemplateElement'
    #   ]
    code: """
      foo = '''
        \\"
      '''
    """
    errors: [
      line: 2
      column: 3
      message: 'Unnecessary escape character: \\".'
      type: 'TemplateElement'
    ]
  ,
    code: """
      foo = '''
        \\'
      '''
    """
    errors: [
      line: 2
      column: 3
      message: "Unnecessary escape character: \\'."
      type: 'TemplateElement'
    ]
  ,
    code: '''
      foo = """
        \\"
      """
    '''
    errors: [
      line: 2
      column: 3
      message: 'Unnecessary escape character: \\".'
      type: 'TemplateElement'
    ]
  ]
