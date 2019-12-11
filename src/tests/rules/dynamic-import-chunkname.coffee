# import {SYNTAX_CASES} from '../utils'
{RuleTester} = require 'eslint'
path = require 'path'

rule = require '../../rules/dynamic-import-chunkname'
ruleTester = new RuleTester parser: path.join __dirname, '../../..'

commentFormat = '[0-9a-zA-Z-_/.]+'
pickyCommentFormat = '[a-zA-Z-_/.]+'
options = [importFunctions: ['dynamicImport']]
pickyCommentOptions = [
  importFunctions: ['dynamicImport']
  webpackChunknameFormat: pickyCommentFormat
]
multipleImportFunctionOptions = [
  importFunctions: ['dynamicImport', 'definitelyNotStaticImport']
]
# parser = 'babel-eslint'

noLeadingCommentError =
  'dynamic imports require a leading comment with the webpack chunkname'
nonBlockCommentError =
  'dynamic imports require a ### foo ### style comment, not a # foo comment'
noPaddingCommentError =
  'dynamic imports require a block comment padded with spaces - ### foo ###'
invalidSyntaxCommentError =
  'dynamic imports require a "webpack" comment with valid syntax'
commentFormatError = """dynamic imports require a leading comment in the form ### webpackChunkName: "#{commentFormat}",? ###"""
pickyCommentFormatError = """dynamic imports require a leading comment in the form ### webpackChunkName: "#{pickyCommentFormat}",? ###"""

ruleTester.run 'dynamic-import-chunkname', rule,
  valid: [
    {
      code: '''
        dynamicImport(
          ### webpackChunkName: "someModule" ###
          'test'
        )
      '''
      options
    }
    {
      code: '''
        dynamicImport(
          ### webpackChunkName: "Some_Other_Module" ###
          "test"
        )
      '''
      options
    }
    {
      code: '''
        dynamicImport(
          ### webpackChunkName: "SomeModule123" ###
          "test"
        )
      '''
      options
    }
  ,
    code: '''
      dynamicImport(
        ### webpackChunkName: "someModule" ###
        'someModule'
      )
    '''
    options: pickyCommentOptions
    errors: [
      message: pickyCommentFormatError
      type: 'CallExpression'
    ]
  ,
    {
      code: '''
        import(
          ### webpackChunkName: "someModule" ###
          'test'
        )
      '''
      options
    }
    {
      code: '''
          import(
            ### webpackChunkName: "Some_Other_Module" ###
            "test"
          )
        '''
      options
    }
    {
      code: '''
          import(
            ### webpackChunkName: "SomeModule123" ###
            "test"
          )
        '''
      options
    }
    {
      code: '''import(
          ### webpackChunkName: "someModule", webpackPrefetch: true ###
          'test'
        )'''
      options
    }
    {
      code: '''import(
          ### webpackChunkName: "someModule", webpackPrefetch: true, ###
          'test'
        )'''
      options
    }
    {
      code: '''import(
          ### webpackPrefetch: true, webpackChunkName: "someModule" ###
          'test'
        )'''
      options
    }
    {
      code: '''import(
          ### webpackPrefetch: true, webpackChunkName: "someModule", ###
          'test'
        )'''
      options
    }
    {
      code: '''import(
          ### webpackPrefetch: true ###
          ### webpackChunkName: "someModule" ###
          'test'
        )'''
      options
    }
    {
      code: '''import(
          ### webpackChunkName: "someModule" ###
          ### webpackPrefetch: true ###
          'test'
        )'''
      options
    }
  ,
    code: '''import(
          ### webpackChunkName: "someModule" ###
          'someModule'
        )'''
    options: pickyCommentOptions
    errors: [
      message: pickyCommentFormatError
      type: 'CallExpression'
    ]
  ]

  invalid: [
    {
      code: '''import(
        # webpackChunkName: "someModule"
        'someModule'
      )'''
      options
      errors: [
        message: nonBlockCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: "import('test')"
      options
      errors: [
        message: noLeadingCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
        ### webpackChunkName: someModule ###
        'someModule'
      )'''
      options
      errors: [
        message: invalidSyntaxCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### webpackChunkName: 'someModule' ###
          'someModule'
        )'''
      options
      errors: [
        message: commentFormatError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### webpackChunkName "someModule" ###
          'someModule'
        )'''
      options
      errors: [
        message: invalidSyntaxCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### webpackChunkName:"someModule" ###
          'someModule'
        )'''
      options
      errors: [
        message: commentFormatError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ###webpackChunkName: "someModule"###
          'someModule'
        )'''
      options
      errors: [
        message: noPaddingCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### webpackChunkName  :  "someModule" ###
          'someModule'
        )'''
      options
      errors: [
        message: commentFormatError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### webpackChunkName: "someModule" ; ###
          'someModule'
        )'''
      options
      errors: [
        message: invalidSyntaxCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### totally not webpackChunkName: "someModule" ###
          'someModule'
        )'''
      options
      errors: [
        message: invalidSyntaxCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### webpackPrefetch: true ###
          ### webpackChunk: "someModule" ###
          'someModule'
        )'''
      options
      errors: [
        message: commentFormatError
        type: 'CallExpression'
      ]
    }
    {
      code: '''import(
          ### webpackPrefetch: true, webpackChunk: "someModule" ###
          'someModule'
        )'''
      options
      errors: [
        message: commentFormatError
        type: 'CallExpression'
      ]
    }
  ,
    code: '''import(
          ### webpackChunkName: "someModule123" ###
          'someModule'
        )'''
    options: pickyCommentOptions
    errors: [
      message: pickyCommentFormatError
      type: 'CallExpression'
    ]
  ,
    code: '''
      dynamicImport(
        ### webpackChunkName "someModule" ###
        'someModule'
      )
    '''
    options: multipleImportFunctionOptions
    errors: [
      message: invalidSyntaxCommentError
      type: 'CallExpression'
    ]
  ,
    code: '''
      definitelyNotStaticImport(
        ### webpackChunkName "someModule" ###
        'someModule'
      )
    '''
    options: multipleImportFunctionOptions
    errors: [
      message: invalidSyntaxCommentError
      type: 'CallExpression'
    ]
  ,
    {
      code: '''
        dynamicImport(
          # webpackChunkName: "someModule"
          'someModule'
        )
      '''
      options
      errors: [
        message: nonBlockCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: "dynamicImport('test')"
      options
      errors: [
        message: noLeadingCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''
        dynamicImport(
          ### webpackChunkName: someModule ###
          'someModule'
        )
      '''
      options
      errors: [
        message: invalidSyntaxCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''
        dynamicImport(
          ### webpackChunkName: 'someModule' ###
          'someModule'
        )
      '''
      options
      errors: [
        message: commentFormatError
        type: 'CallExpression'
      ]
    }
    {
      code: '''
        dynamicImport(
          ### webpackChunkName "someModule" ###
          'someModule'
        )
      '''
      options
      errors: [
        message: invalidSyntaxCommentError
        type: 'CallExpression'
      ]
    }
    {
      code: '''
        dynamicImport(
          ### webpackChunkName:"someModule" ###
          'someModule'
        )
      '''
      options
      errors: [
        message: commentFormatError
        type: 'CallExpression'
      ]
    }
  ,
    code: '''
      dynamicImport(
        ### webpackChunkName: "someModule123" ###
        'someModule'
      )
    '''
    options: pickyCommentOptions
    errors: [
      message: pickyCommentFormatError
      type: 'CallExpression'
    ]
  ]
