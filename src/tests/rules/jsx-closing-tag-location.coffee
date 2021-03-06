###*
# @fileoverview Validate closing tag location in JSX
# @author Ross Solomon
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/jsx-closing-tag-location'
{RuleTester} = require 'eslint'
path = require 'path'
MESSAGE_MATCH_INDENTATION = [
  message: 'Expected closing tag to match indentation of opening.'
]
MESSAGE_OWN_LINE = [
  message: 'Closing tag of a multiline JSX expression must be on its own line.'
]

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'jsx-closing-tag-location', rule,
  valid: [
    code: '''
      <App>
        foo
      </App>
    '''
  ,
    code: '''
      <App>foo</App>
    '''
  ,
    code: '''
      <>
        foo
      </>
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      <>foo</>
    '''
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: '''
      <App>
        foo
        </App>
    '''
    output: '''
      <App>
        foo
      </App>
    '''
    errors: MESSAGE_MATCH_INDENTATION
  ,
    code: '''
      <App>
        foo</App>
    '''
    output: '''
      <App>
        foo
      </App>
    '''
    errors: MESSAGE_OWN_LINE
    # ,
    #   code: """
    #     <>
    #       foo
    #       </>
    #   """
    #   # parser: 'babel-eslint'
    #   output: """
    #     <>
    #       foo
    #     </>
    #   """
    #   errors: MESSAGE_MATCH_INDENTATION
    # ,
    #   code: """
    #     <>
    #       foo</>
    #   """
    #   # parser: 'babel-eslint'
    #   output: """
    #     <>
    #       foo
    #     </>
    #   """
    #   errors: MESSAGE_OWN_LINE
  ]
