###*
# @fileoverview Test enforcement of lines around comments.
# @author Jamund Ferguson
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/lines-around-comment'
{RuleTester} = require 'eslint'
path = require 'path'

afterMessage = 'Expected line after comment.'
beforeMessage = 'Expected line before comment.'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'lines-around-comment', rule,
  valid: [
    # default rules
    'bar()\n\n###* block block block\n * block \n ###\n\na = 1'
    'bar()\n\n###* block block block\n * block \n ###\na = 1'
    'bar()\n# line line line \na = 1'
    'bar()\n\n# line line line\na = 1'
    'bar()\n# line line line\n\na = 1'
  ,
    # line comments
    code: 'bar()\n# line line line\n\na = 1'
    options: [afterLineComment: yes]
  ,
    code: 'foo()\n\n# line line line\na = 1'
    options: [beforeLineComment: yes]
  ,
    code: 'foo()\n\n# line line line\n\na = 1'
    options: [beforeLineComment: yes, afterLineComment: yes]
  ,
    code: 'foo()\n\n# line line line\n# line line\n\na = 1'
    options: [beforeLineComment: yes, afterLineComment: yes]
  ,
    code: '# line line line\n# line line'
    options: [beforeLineComment: yes, afterLineComment: yes]
  ,
    # block comments
    code:
      'bar()\n\n###* A Block comment with a an empty line after\n *\n ###\na = 1'
    options: [afterBlockComment: no, beforeBlockComment: yes]
  ,
    code: 'bar()\n\n###* block block block\n * block \n ###\na = 1'
    options: [afterBlockComment: no]
  ,
    code: '###* \nblock \nblock block\n ###\n### block \n block \n ###'
    options: [afterBlockComment: yes, beforeBlockComment: yes]
  ,
    code: 'bar()\n\n###* block block block\n * block \n ###\n\na = 1'
    options: [afterBlockComment: yes, beforeBlockComment: yes]
  ,
    # inline comments (should not ever warn)
    code: 'foo() # An inline comment with a an empty line after\na = 1'
    options: [afterLineComment: yes, beforeLineComment: yes]
  ,
    code:
      'foo()\nbar() ### An inline block comment with a an empty line after\n *\n ###\na = 1'
    options: [beforeBlockComment: yes]
  ,
    # mixed comment (some block & some line)
    code:
      'bar()\n\n###* block block block\n * block \n ###\n#line line line\na = 1'
    options: [afterBlockComment: yes]
  ,
    code:
      'bar()\n\n###* block block block\n * block \n ###\n#line line line\na = 1'
    options: [beforeLineComment: yes]
  ,
    # check for block start comments
    code: 'a\n\n# line\nb'
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      ->   
        # line at block start
        g = 1
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      -># line at block start
        g = 1
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      foo = ->
        # line at block start
        g = 1
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      foo = ->
        # line at block start
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      if yes
        # line at block start
        g = 1
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      if yes
      
        # line at block start
        g = 1
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      if yes
        bar()
      else
        # line at block start
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      switch 'foo'
        when 'foo'
          # line at switch case start
          break
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      switch 'foo'
        when 'foo'
        
          # line at switch case start
          break
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      switch 'foo'
        when 'foo'
          break
          
        else
          # line at switch case start
          break
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      switch 'foo'
        when 'foo'
          break
          
        else
        
          # line at switch case start
          break
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      ->   
        ### block comment at block start ###
        g = 1
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      ->### block comment at block start ###
        g = 1
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      foo = ->
        ### block comment at block start ###
        g = 1
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      if yes
        ### block comment at block start ###
        g = 1
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      if yes
        
        ### block comment at block start ###
        g = 1
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      while yes
        
        ### 
          block comment at block start
        ###
        g = 1
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      class A
        ###*
          * hi
        ###
        constructor: ->
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      class A
        ###*
          * hi
        ###
        constructor: ->
    '''
    options: [allowClassStart: yes]
  ,
    code: '''
      class A
        ###*
          * hi
        ###
        constructor: ->
    '''
    options: [
      allowBlockStart: no
      allowClassStart: yes
    ]
  ,
    code: '''
      switch 'foo'
        when 'foo'
          ### block comment at switch case start ###
          break
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      switch 'foo'
        when 'foo'
        
          ### block comment at switch case start ###
          break
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      switch 'foo'
        when 'foo'
          break
        
        else
          ### block comment at switch case start ###
          break
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          break
          
        else
        
          ### block comment at switch case start ###
          break
    '''
    options: [allowBlockStart: yes]
  ,
    code: '''
      ->
        g = 91
        # line at block end
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      ->
        g = 61
        
        
        # line at block end
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      foo = ->
        g = 1
        
        
        # line at block end
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      if yes
        g = 1
        # line at block end
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      if yes
        g = 1
        
        # line at block end
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          g = 1
          
          # line at switch case end
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          g = 1
          
          # line at switch case end
          
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          break
          
        else
          g = 1
          
          # line at switch case end
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          break
          
        else
          g = 1
          
          # line at switch case end

    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      try
        # line at block start and end
      catch
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      try
        # line at block start and end
      catch
    '''
    options: [
      afterLineComment: yes
      allowBlockStart: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      try
        # line at block start and end
      catch
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      try
        # line at block start and end
      catch
    '''
    options: [
      afterLineComment: yes
      beforeLineComment: yes
      allowBlockStart: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      try
        # line at block start and end
      catch
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
  ,
    code: '''
      ->
        g = 1
        ### block comment at block end ###
    '''
    options: [
      beforeBlockComment: no
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      foo = ->
        g = 1
        ### block comment at block end ###
    '''
    options: [
      beforeBlockComment: no
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      if yes
        g = 1
        ### block comment at block end ###
    '''
    options: [
      beforeBlockComment: no
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      if yes
        g = 1
        
        ### block comment at block end ###
    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      while yes
      
        g = 1
        
        ### 
          block comment at block end
        ###
    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      class B
        constructor: ->
        
        ###*
          * hi
        ###
    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      class B
        constructor: ->
        
        ###*
        * hi
        ###
    '''
    options: [
      afterBlockComment: yes
      allowClassEnd: yes
    ]
  ,
    code: '''
      class B
        constructor: ->
        
        ###*
        * hi
        ###
    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: no
      allowClassEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          g = 1
          
          ### block comment at switch case end ###
    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          g = 1
          
          ### block comment at switch case end ###
    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          break
          
        else
          g = 1
          
          ### block comment at switch case end ###
    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          break
          
        else
          g = 1
          
          ### block comment at switch case end ###

    '''
    options: [
      afterBlockComment: yes
      allowBlockEnd: yes
    ]
  ,
    # check for object start comments
    code: '''
      obj = {
        # line at object start
        g: 1
      }
    '''
    options: [
      beforeLineComment: yes
      allowObjectStart: yes
    ]
  ,
    code: '''
      ->
        return {
          # hi
          test: ->
        }
    '''
    options: [
      beforeLineComment: yes
      allowObjectStart: yes
    ]
  ,
    # ,
    #   code: '''
    #     obj =
    #       ### block comment at object start###
    #       g: 1
    #   '''
    #   options: [
    #     beforeBlockComment: yes
    #     allowObjectStart: yes
    #   ]
    # ,
    code: '''
      ->
        return {
          ###*
          * hi
          ###
          test: ->
        }
    '''
    options: [
      beforeLineComment: yes
      allowObjectStart: yes
    ]
  ,
    code: '''
      {
        # line at object start
        g: a
      } = {}
    '''
    options: [
      beforeLineComment: yes
      allowObjectStart: yes
    ]
  ,
    code: '''
      {
      
        # line at object start
        g
      } = {}
    '''
    options: [
      beforeLineComment: yes
      allowObjectStart: yes
    ]
  ,
    code: '''
      {
        ### block comment at object-like start###
        g: a
      } = {}
    '''
    options: [
      beforeBlockComment: yes
      allowObjectStart: yes
    ]
  ,
    code: '''
      {
        ### block comment at object-like start###
        g
      } = {}
    '''
    options: [
      beforeBlockComment: yes
      allowObjectStart: yes
    ]
  ,
    # check for object end comments
    code: '''
      obj = {
        g: 1
        # line at object end
      }
    '''
    options: [
      afterLineComment: yes
      allowObjectEnd: yes
    ]
  ,
    # ,
    #   code: '''
    #     obj =
    #       g: 1
    #       # line at object end
    #   '''
    #   options: [
    #     afterLineComment: yes
    #     allowObjectEnd: yes
    #   ]
    code: '''
      ->
        return {
          test: ->
          # hi
        }
    '''
    options: [
      afterLineComment: yes
      allowObjectEnd: yes
    ]
  ,
    code: '''
      obj = {
        g: 1
        
        ### block comment at object end###
      }
    '''
    options: [
      afterBlockComment: yes
      allowObjectEnd: yes
    ]
  ,
    code: '''
      ->
        return {
          test: ->

          ###*
          * hi
          ###
        }
    '''
    options: [
      afterBlockComment: yes
      allowObjectEnd: yes
    ]
  ,
    code: '''
      {
        g: a
        # line at object end
      } = {}
    '''
    options: [
      afterLineComment: yes
      allowObjectEnd: yes
    ]
  ,
    code: '''
      {
        g
        # line at object end
      } = {}
    '''
    options: [
      afterLineComment: yes
      allowObjectEnd: yes
    ]
  ,
    code: '''
      {
        g: a
        
        ### block comment at object-like end###
      } = {}
    '''
    options: [
      afterBlockComment: yes
      allowObjectEnd: yes
    ]
  ,
    code: '''
      {
        g
        
        ### block comment at object-like end###
      } = {}
    '''
    options: [
      afterBlockComment: yes
      allowObjectEnd: yes
    ]
  ,
    # check for array start comments
    code: '''
      arr = [
        # line at array start
        1\
      ]
    '''
    options: [
      beforeLineComment: yes
      allowArrayStart: yes
    ]
  ,
    code: '''
      arr = [
        ### block comment at array start###
        1
      ]
    '''
    options: [
      beforeBlockComment: yes
      allowArrayStart: yes
    ]
  ,
    code: '''
      [
        # line at array start
        a
      ] = []
    '''
    options: [
      beforeLineComment: yes
      allowArrayStart: yes
    ]
  ,
    code: '''
      [
        ### block comment at array start###
        a
      ] = []
    '''
    options: [
      beforeBlockComment: yes
      allowArrayStart: yes
    ]
  ,
    # check for array end comments
    code: '''
      arr = [
        1
        # line at array end
      ]
    '''
    options: [
      afterLineComment: yes
      allowArrayEnd: yes
    ]
  ,
    code: '''
      arr = [
        1
        
        ### block comment at array end###
      ]
    '''
    options: [
      afterBlockComment: yes
      allowArrayEnd: yes
    ]
  ,
    code: '''
      [
        a
        # line at array end
      ] = []
    '''
    options: [
      afterLineComment: yes
      allowArrayEnd: yes
    ]
  ,
    code: '''
      [
        a
        
        ### block comment at array end###
      ] = []
    '''
    options: [
      afterBlockComment: yes
      allowArrayEnd: yes
    ]
  ,
    # ignorePattern
    code: '''
      foo

      ### eslint-disable no-underscore-dangle ###

      this._values = values
      this._values2 = true
      ### eslint-enable no-underscore-dangle ###
      bar
    '''
    options: [
      beforeBlockComment: yes
      afterBlockComment: yes
    ]
  ,
    'foo\n### eslint ###'
    'foo\n### jshint ###'
    'foo\n### jslint ###'
    'foo\n### istanbul ###'
    'foo\n### global ###'
    'foo\n### globals ###'
    'foo\n### exported ###'
    'foo\n### jscs ###'
  ,
    code: 'foo\n### this is pragmatic ###'
    options: [ignorePattern: 'pragma']
  ,
    code: 'foo\n### this is pragmatic ###'
    options: [applyDefaultIgnorePatterns: no, ignorePattern: 'pragma']
  ]

  invalid: [
    # default rules
    code: 'bar()\n###* block block block\n * block \n ###\na = 1'
    output: 'bar()\n\n###* block block block\n * block \n ###\na = 1'
    errors: [message: beforeMessage, type: 'Block']
  ,
    # line comments
    code: 'baz()\n# A line comment with no empty line after\na = 1'
    output: 'baz()\n# A line comment with no empty line after\n\na = 1'
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line']
  ,
    code: 'baz()\n# A line comment with no empty line after\na = 1'
    output: 'baz()\n\n# A line comment with no empty line after\na = 1'
    options: [beforeLineComment: yes, afterLineComment: no]
    errors: [message: beforeMessage, type: 'Line']
  ,
    code: '# A line comment with no empty line after\na = 1'
    output: '# A line comment with no empty line after\n\na = 1'
    options: [beforeLineComment: yes, afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 1, column: 1]
  ,
    code: 'baz()\n# A line comment with no empty line after\na = 1'
    output: 'baz()\n\n# A line comment with no empty line after\n\na = 1'
    options: [beforeLineComment: yes, afterLineComment: yes]
    errors: [
      message: beforeMessage, type: 'Line', line: 2
    ,
      message: afterMessage, type: 'Line', line: 2
    ]
  ,
    # block comments
    code: 'bar()\n###*\n * block block block\n ###\na = 1'
    output: 'bar()\n\n###*\n * block block block\n ###\n\na = 1'
    options: [afterBlockComment: yes, beforeBlockComment: yes]
    errors: [
      message: beforeMessage, type: 'Block', line: 2
    ,
      message: afterMessage, type: 'Block', line: 2
    ]
  ,
    code:
      'bar()\n### first block comment ### ### second block comment ###\na = 1'
    output:
      'bar()\n\n### first block comment ### ### second block comment ###\n\na = 1'
    options: [afterBlockComment: yes, beforeBlockComment: yes]
    errors: [
      message: beforeMessage, type: 'Block', line: 2
    ,
      message: afterMessage, type: 'Block', line: 2
    ]
  ,
    code:
      'bar()\n### first block comment ### ### second block\n comment ###\na = 1'
    output:
      'bar()\n\n### first block comment ### ### second block\n comment ###\n\na = 1'
    options: [afterBlockComment: yes, beforeBlockComment: yes]
    errors: [
      message: beforeMessage, type: 'Block', line: 2
    ,
      message: afterMessage, type: 'Block', line: 2
    ]
  ,
    code: 'bar()\n###*\n * block block block\n ###\na = 1'
    output: 'bar()\n###*\n * block block block\n ###\n\na = 1'
    options: [afterBlockComment: yes, beforeBlockComment: no]
    errors: [message: afterMessage, type: 'Block', line: 2]
  ,
    code: 'bar()\n###*\n * block block block\n ###\na = 1'
    output: 'bar()\n\n###*\n * block block block\n ###\na = 1'
    options: [afterBlockComment: no, beforeBlockComment: yes]
    errors: [message: beforeMessage, type: 'Block', line: 2]
  ,
    code: '''
      ->
        a = 1
        # line at block start
        g = 1
    '''
    output: '''
      ->
        a = 1

        # line at block start
        g = 1
    '''
    options: [
      beforeLineComment: yes
      allowBlockStart: yes
    ]
    errors: [message: beforeMessage, type: 'Line', line: 3]
  ,
    code: '''
      ->
        a = 1
        
        # line at block start
        g = 1
    '''
    output: '''
      ->
        a = 1
        
        # line at block start

        g = 1
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
    ]
    errors: [message: afterMessage, type: 'Line', line: 4]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          # line at switch case start
          break
    '''
    output: '''
      switch ('foo')
        when 'foo'

          # line at switch case start
          break
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 3]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          break
          
        else
          # line at switch case start
          break
    '''
    output: '''
      switch ('foo')
        when 'foo'
          break
          
        else

          # line at switch case start
          break
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 6]
  ,
    code: '''
      try
        # line at block start and end
      catch
    '''
    output: '''
      try
        # line at block start and end

      catch
    '''
    options: [
      afterLineComment: yes
      allowBlockStart: yes
    ]
    errors: [message: afterMessage, type: 'Line', line: 2]
  ,
    code: '''
      try
        # line at block start and end
      catch
    '''
    output: '''
      try

        # line at block start and end
      catch
    '''
    options: [
      beforeLineComment: yes
      allowBlockEnd: yes
    ]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      class A
        # line at class start
        constructor: ->
    '''
    output: '''
      class A

        # line at class start
        constructor: ->
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      class A
        # line at class start
        constructor: ->
    '''
    output: '''
      class A

        # line at class start
        constructor: ->
    '''
    options: [
      allowBlockStart: yes
      allowClassStart: no
      beforeLineComment: yes
    ]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      class B
        constructor: ->

        # line at class end
      d
    '''
    output: '''
      class B
        constructor: ->

        # line at class end

      d
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 4]
  ,
    code: '''
      class B
        constructor: ->

        # line at class end
      d
    '''
    output: '''
      class B
        constructor: ->

        # line at class end

      d
    '''
    options: [
      afterLineComment: yes
      allowBlockEnd: yes
      allowClassEnd: no
    ]
    errors: [message: afterMessage, type: 'Line', line: 4]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          g = 1

          # line at switch case end
      d
    '''
    output: '''
      switch ('foo')
        when 'foo'
          g = 1

          # line at switch case end

      d
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 5]
  ,
    code: '''
      switch ('foo')
        when 'foo'
          break

        else
          g = 1

          # line at switch case end
      d
    '''
    output: '''
      switch ('foo')
        when 'foo'
          break

        else
          g = 1

          # line at switch case end

      d
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 8]
  ,
    # object start comments
    code: '''
      obj = {
        # line at object start
        g: 1
      }
    '''
    output: '''
      obj = {

        # line at object start
        g: 1
      }
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      obj =
        # line at object start
        g: 1
    '''
    output: '''
      obj =

        # line at object start
        g: 1
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      ->
        return {
          # hi
          test: ->
        }
    '''
    output: '''
      ->
        return {

          # hi
          test: ->
        }
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 3]
  ,
    code: '''
      obj = {
        ### block comment at object start###
        g: 1
      }
    '''
    output: '''
      obj = {
      
        ### block comment at object start###
        g: 1
      }
    '''
    options: [beforeBlockComment: yes]
    errors: [message: beforeMessage, type: 'Block', line: 2]
  ,
    code: '''
      ->
        return
          ###*
          * hi
          ###
          test: ->
    '''
    output: '''
      ->
        return

          ###*
          * hi
          ###
          test: ->
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Block', line: 3]
  ,
    code: '''
      {
        # line at object start
        g: a
      } = {}
    '''
    output: '''
      {

        # line at object start
        g: a
      } = {}
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      {
        # line at object start
        g
      } = {}
    '''
    output: '''
      {

        # line at object start
        g
      } = {}
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      {
        ### block comment at object-like start###
        g: a
      } = {}
    '''
    output: '''
      {

        ### block comment at object-like start###
        g: a
      } = {}
    '''
    options: [beforeBlockComment: yes]
    errors: [message: beforeMessage, type: 'Block', line: 2]
  ,
    code: '''
      {
        ### block comment at object-like start###
        g
      } = {}
    '''
    output: '''
      {

        ### block comment at object-like start###
        g
      } = {}
    '''
    options: [beforeBlockComment: yes]
    errors: [message: beforeMessage, type: 'Block', line: 2]
  ,
    # object end comments
    code: '''
      obj = {
        g: 1
        # line at object end
      }
    '''
    output: '''
      obj = {
        g: 1
        # line at object end

      }
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 3]
  ,
    code: '''
      obj =
        g: 1
        # line at object end
      d
    '''
    output: '''
      obj =
        g: 1
        # line at object end

      d
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 3]
  ,
    code: '''
      ->
        return {
          test: ->
          # hi
        }
    '''
    output: '''
      ->
        return {
          test: ->
          # hi

        }
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 4]
  ,
    code: '''
      obj = {
        g: 1
        
        ### block comment at object end###
      }
    '''
    output: '''
      obj = {
        g: 1
        
        ### block comment at object end###

      }
    '''
    options: [afterBlockComment: yes]
    errors: [message: afterMessage, type: 'Block', line: 4]
  ,
    code: '''
      ->
        return {
          test: ->

          ###*
          * hi
          ###
        }
    '''
    output: '''
      ->
        return {
          test: ->

          ###*
          * hi
          ###

        }
    '''
    options: [afterBlockComment: yes]
    errors: [message: afterMessage, type: 'Block', line: 5]
  ,
    code: '''
      {
        g: a
        # line at object end
      } = {}
    '''
    output: '''
      {
        g: a
        # line at object end

      } = {}
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 3]
  ,
    code: '''
      {
        g
        # line at object end
      } = {}
    '''
    output: '''
      {
        g
        # line at object end

      } = {}
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 3]
  ,
    code: '''
      {
        g: a
        
        ### block comment at object-like end###
      } = {}
    '''
    output: '''
      {
        g: a
        
        ### block comment at object-like end###

      } = {}
    '''
    options: [afterBlockComment: yes]
    errors: [message: afterMessage, type: 'Block', line: 4]
  ,
    code: '''
      {
        g
        
        ### block comment at object-like end###
      } = {}
    '''
    output: '''
      {
        g
        
        ### block comment at object-like end###

      } = {}
    '''
    options: [afterBlockComment: yes]
    errors: [message: afterMessage, type: 'Block', line: 4]
  ,
    # array start comments
    code: '''
      arr = [
        # line at array start
        1
      ]
    '''
    output: '''
      arr = [

        # line at array start
        1
      ]
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      arr = [
        ### block comment at array start###
        1
      ]
    '''
    output: '''
      arr = [

        ### block comment at array start###
        1
      ]
    '''
    options: [beforeBlockComment: yes]
    errors: [message: beforeMessage, type: 'Block', line: 2]
  ,
    code: '''
      [
        # line at array start
        a
      ] = []
    '''
    output: '''
      [

        # line at array start
        a
      ] = []
    '''
    options: [beforeLineComment: yes]
    errors: [message: beforeMessage, type: 'Line', line: 2]
  ,
    code: '''
      [
        ### block comment at array start###
        a
      ] = []
    '''
    output: '''
      [

        ### block comment at array start###
        a
      ] = []
    '''
    options: [beforeBlockComment: yes]
    errors: [message: beforeMessage, type: 'Block', line: 2]
  ,
    # array end comments
    code: '''
      arr = [
        1
        # line at array end
      ]
    '''
    output: '''
      arr = [
        1
        # line at array end

      ]
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 3]
  ,
    code: '''
      arr = [
        1
        
        ### block comment at array end###
      ]
    '''
    output: '''
      arr = [
        1
        
        ### block comment at array end###

      ]
    '''
    options: [afterBlockComment: yes]
    errors: [message: afterMessage, type: 'Block', line: 4]
  ,
    code: '''
      [
        a
        # line at array end
      ] = []
    '''
    output: '''
      [
        a
        # line at array end

      ] = []
    '''
    options: [afterLineComment: yes]
    errors: [message: afterMessage, type: 'Line', line: 3]
  ,
    code: '''
      [
        a

        ### block comment at array end###
      ] = []
    '''
    output: '''
      [
        a

        ### block comment at array end###

      ] = []
    '''
    options: [afterBlockComment: yes]
    errors: [message: afterMessage, type: 'Block', line: 4]
  ,
    # ignorePattern
    code: '''
      foo

      ### eslint-disable no-underscore-dangle ###

      this._values = values
      this._values2 = true
      ### eslint-enable no-underscore-dangle ###
      bar
    '''
    output: '''
      foo

      ### eslint-disable no-underscore-dangle ###

      this._values = values
      this._values2 = true

      ### eslint-enable no-underscore-dangle ###

      bar
    '''
    options: [
      beforeBlockComment: yes
      afterBlockComment: yes
      applyDefaultIgnorePatterns: no
    ]
    errors: [
      message: beforeMessage, type: 'Block', line: 7
    ,
      message: afterMessage, type: 'Block', line: 7
    ]
  ,
    code: 'foo\n### eslint ###'
    output: 'foo\n\n### eslint ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### jshint ###'
    output: 'foo\n\n### jshint ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### jslint ###'
    output: 'foo\n\n### jslint ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### istanbul ###'
    output: 'foo\n\n### istanbul ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### global ###'
    output: 'foo\n\n### global ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### globals ###'
    output: 'foo\n\n### globals ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### exported ###'
    output: 'foo\n\n### exported ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### jscs ###'
    output: 'foo\n\n### jscs ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### something else ###'
    output: 'foo\n\n### something else ###'
    options: [ignorePattern: 'pragma']
    errors: [message: beforeMessage, type: 'Block']
  ,
    code: 'foo\n### eslint ###'
    output: 'foo\n\n### eslint ###'
    options: [applyDefaultIgnorePatterns: no]
    errors: [message: beforeMessage, type: 'Block']
  ,
    # "fallthrough" patterns are not ignored by default
    code: 'foo\n### fallthrough ###'
    output: 'foo\n\n### fallthrough ###'
    options: []
    errors: [message: beforeMessage, type: 'Block']
  ]
