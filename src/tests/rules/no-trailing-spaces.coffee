###*
# @fileoverview Disallow trailing spaces at the end of lines.
# @author Nodeca Team <https:#github.com/nodeca>
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-trailing-spaces'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'no-trailing-spaces', rule,
  valid: [
    code: 'a = 5'
    options: [{}]
  ,
    code: '''
      a = 5
      b = 3
    '''
    options: [{}]
  ,
    'a = 5'
    '''
      a = 5
      b = 3
    '''
  ,
    code: '''
      a = 5
      b = 3
    '''
    options: [skipBlankLines: yes]
  ,
    code: '     '
    options: [skipBlankLines: yes]
  ,
    code: '\t'
    options: [skipBlankLines: yes]
  ,
    code: '     \n    c = 1'
    options: [skipBlankLines: yes]
  ,
    code: '\t\n\tc = 2'
    options: [skipBlankLines: yes]
  ,
    code: '\n   c = 3'
    options: [skipBlankLines: yes]
  ,
    code: '\n\tc = 4'
    options: [skipBlankLines: yes]
  ,
    code: 'str = "#{a}\n   \n#{b}"'
    parserOptions: ecmaVersion: 6
  ,
    code: 'str = "#{a}\n   \n#{b}"\n   \n   '
    options: [skipBlankLines: yes]
  ,
    code: '# Trailing comment test. '
    options: [ignoreComments: yes]
  ,
    code: '# Trailing comment test.'
    options: [ignoreComments: no]
  ,
    code: '# Trailing comment test.'
    options: []
  ,
    code: '### \nTrailing comments test. \n###'
    options: [ignoreComments: yes]
  ,
    code: '#!/usr/bin/env node '
    options: [ignoreComments: yes]
  ]

  invalid: [
    code: '''
      short2 = true\r
      \r
      module.exports =\r
        short: short    \r
        short2: short\r
    '''
    output: '''
      short2 = true\r
      \r
      module.exports =\r
        short: short\r
        short2: short\r
    '''
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: '''
      short2 = true
      \r
      module.exports = {\r
        short: short,    \r
        short2: short
      }
    '''
    output: '''
      short2 = true
      \r
      module.exports = {\r
        short: short,\r
        short2: short
      }
    '''
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: '''
      short2 = true

      module.exports = {
        short: short,    
        short2: short
      }
    '''
    output: '''
      short2 = true

      module.exports = {
        short: short,
        short2: short
      }
    '''
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: '''
      short2 = true
      
      module.exports = {
        short,    
        short2
      }
    '''
    output: '''
      short2 = true
      
      module.exports = {
        short,
        short2
      }
    '''
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: '''
      
      measAr.push("<dl></dl>",  
               " </dt><dd class ='pta-res'>")
    '''
    output: '''
      
      measAr.push("<dl></dl>",
               " </dt><dd class ='pta-res'>")
    '''
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: '''
      measAr.push "<dl></dl>",  
               " </dt><dd class ='pta-res'>" 
    '''
    output: '''
      measAr.push "<dl></dl>",
               " </dt><dd class ='pta-res'>"
    '''
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: 'a = 5      \n'
    output: 'a = 5\n'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: 'a = 5 \nb = 3 '
    output: 'a = 5\nb = 3'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: 'a = 5 \n\nb = 3 '
    output: 'a = 5\n\nb = 3'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: 'a = 5\t\nb = 3'
    output: 'a = 5\nb = 3'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: '     \n    c = 1'
    output: '\n    c = 1'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: '\t\n\tc = 2'
    output: '\n\tc = 2'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: 'a = 5      \n'
    output: 'a = 5\n'
    options: [{}]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: 'a = 5 \nb = 3 '
    output: 'a = 5\nb = 3'
    options: [{}]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 6
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 2
      column: 6
    ]
  ,
    code: 'a = 5\t\nb = 3'
    output: 'a = 5\nb = 3'
    options: [{}]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 6
    ]
  ,
    code: '     \n    c = 1'
    output: '\n    c = 1'
    options: [{}]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 1
    ]
  ,
    code: '\t\n\tc = 2'
    output: '\n\tc = 2'
    options: [{}]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
    ]
  ,
    code: "a = 'bar'  \n \n\t"
    output: "a = 'bar'\n \n\t"
    options: [skipBlankLines: yes]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 10 # there are invalid spaces in columns 15 and 16
    ]
  ,
    code: "a = 'foo'   \nb = 'bar'  \n  \n"
    output: "a = 'foo'\nb = 'bar'\n  \n"
    options: [skipBlankLines: yes]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 10
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 2
      column: 10
    ]
  ,
    code: 'str = "#{a}\n  \n#{b}"  \n'
    output: 'str = "#{a}\n  \n#{b}"\n'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 3
      column: 6
    ]
  ,
    code: 'str = "\n#{a}\n  \n#{b}"  \n\t'
    output: 'str = "\n#{a}\n  \n#{b}"\n'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 4
      column: 6
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 5
      column: 1
    ]
  ,
    code: 'str = "  \n  #{a}\n  \n#{b}"  \n'
    output: 'str = "  \n  #{a}\n  \n#{b}"\n'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 4
      column: 6
    ]
  ,
    code: 'str = "#{a}\n  \n#{b}"  \n  \n'
    output: 'str = "#{a}\n  \n#{b}"\n  \n'
    options: [skipBlankLines: yes]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 3
      column: 6
    ]
  ,
    # https:#github.com/eslint/eslint/issues/6933
    code: '    \nabcdefg '
    output: '    \nabcdefg'
    options: [skipBlankLines: yes]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 2
      column: 8
    ]
  ,
    code: '    \nabcdefg '
    output: '\nabcdefg'
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 1
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 2
      column: 8
    ]
  ,
    # Tests for ignoreComments flag.
    code: "foo = 'bar' "
    output: "foo = 'bar'"
    options: [ignoreComments: yes]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 12
    ]
  ,
    code: '# Trailing comment test. '
    output: '# Trailing comment test.'
    options: [ignoreComments: no]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 25
    ]
  ,
    code: '### \nTrailing comments test. \n###'
    output: '###\nTrailing comments test.\n###'
    options: [ignoreComments: no]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 4
    ,
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 2
      column: 24
    ]
  ,
    code: '#!/usr/bin/env node '
    output: '#!/usr/bin/env node'
    options: [ignoreComments: no]
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 20
    ]
  ,
    code: '# Trailing comment default test. '
    output: '# Trailing comment default test.'
    options: []
    errors: [
      message: 'Trailing spaces not allowed.'
      type: 'Program'
      line: 1
      column: 33
    ]
  ]
