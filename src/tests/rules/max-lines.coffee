###*
# @fileoverview enforce a maximum file length
# @author Alberto Rodríguez
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/max-lines'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

###*
# Returns the error message with the specified max number of lines
# @param {number} limitLines Maximum number of lines
# @param {number} actualLines Actual number of lines
# @returns {string} error message
###
errorMessage = (limitLines, actualLines) ->
  "File has too many lines (#{actualLines}). Maximum allowed is #{limitLines}."

ruleTester.run 'max-lines', rule,
  valid: [
    'x'
    '''
      xy
      xy
    '''
  ,
    code: '''
      xy
      xy
    '''
    options: [2]
  ,
    code: '''
      xy
      xy
    '''
    options: [max: 2]
  ,
    code: '''
      #a single line comment
      xy
      xy
      ### a multiline
       really really
       long comment###
    '''
    options: [max: 2, skipComments: yes]
  ,
    code: '''
      x y, ### inline comment
       spanning multiple lines ### z
    '''
    options: [max: 2, skipComments: yes]
  ,
    code: '''
      x ### inline comment
       spanning multiple lines ###
      z
    '''
    options: [max: 2, skipComments: yes]
  ,
    code: '''
      x
      
      \t
      \t  
      y
    '''
    options: [max: 2, skipBlankLines: yes]
  ,
    code: '''
      #a single line comment
      xy
       
      xy
       
       ### a multiline
       really really
       long comment###
    '''
    options: [max: 2, skipComments: yes, skipBlankLines: yes]
  ]
  invalid: [
    code: '''
      xyz
      xyz
      xyz
    '''
    options: [2]
    errors: [message: errorMessage 2, 3]
  ,
    code: '''
      ### a multiline comment
        that goes to many lines###
      xy
      xy
    '''
    options: [2]
    errors: [message: errorMessage 2, 4]
  ,
    code: '''
      #a single line comment
      xy
      xy
    '''
    options: [2]
    errors: [message: errorMessage 2, 3]
  ,
    code: '''
      x
      
      

      y
    '''
    options: [max: 2]
    errors: [message: errorMessage 2, 5]
  ,
    code: '''
      #a single line comment
      xy
       
      xy
       
      ### a multiline
       really really
       long comment###
    '''
    options: [max: 2, skipComments: yes]
    errors: [message: errorMessage 2, 4]
  ,
    code: '''
      x # inline comment
      y
      z
    '''
    options: [max: 2, skipComments: yes]
    errors: [message: errorMessage 2, 3]
  ,
    code: '''
      x ### inline comment
       spanning multiple lines ###
      y
      z
    '''
    options: [max: 2, skipComments: yes]
    errors: [message: errorMessage 2, 3]
  ,
    code: '''
      #a single line comment
      xy
       
      xy
       
       ### a multiline
       really really
       long comment###
    '''
    options: [max: 2, skipBlankLines: yes]
    errors: [message: errorMessage 2, 6]
  ]
