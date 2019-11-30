###*
# @fileoverview Tests for consistent-this rule.
# @author Raphael Pigulla
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------
rule = require '../../rules/consistent-this'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# A destructuring Test
# @param {string} code source code
# @returns {Object} Suitable object
# @private
###
destructuringTest = (code) ->
  {
    code
    options: ['self']
  }

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'consistent-this', rule,
  valid: [
    '''
      foo = 42
      that = this
    '''
  ,
    code: '''
      foo = 42
      self = this
    '''
    options: ['self']
  ,
    code: 'self = 42', options: ['that']
  ,
    code: 'self', options: ['that']
  ,
    code: '''
      self = null
      self = this
    '''
    options: ['self']
  ,
    code: '''
      self = null
      self = @
    '''
    options: ['self']
  ,
    code: '''
      foo = self = null
      self = this
    '''
    options: ['self']
  ,
    code: '''
      self = foo = null
      foo = 42
      self = this
    '''
    options: ['self']
  ,
    code: 'self = 42', options: ['that']
  ,
    code: '''
      foo = {}
      foo.bar = this
    '''
    options: ['self']
  ,
    code: '''
      self = this
      vm = this
    '''
    options: ['self', 'vm']
  ,
    destructuringTest '{foo, bar} = this'
    destructuringTest '[foo, bar] = this'
  ]
  invalid: [
    code: 'context = this'
    errors: [
      messageId: 'unexpectedAlias'
      data: name: 'context'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'that = this'
    options: ['self']
    errors: [
      messageId: 'unexpectedAlias'
      data: name: 'that'
      type: 'AssignmentExpression'
    ]
  ,
    code: '''
      foo = 42
      self = this
    '''
    options: ['that']
    errors: [
      messageId: 'unexpectedAlias'
      data: name: 'self'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'self = 42'
    options: ['self']
    errors: [
      messageId: 'aliasNotAssignedToThis'
      data: name: 'self'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'self = null'
    options: ['self']
    errors: [
      messageId: 'aliasNotAssignedToThis'
      data: name: 'self'
      type: 'Identifier'
    ]
  ,
    code: '''
      self = null
      self = 42
    '''
    options: ['self']
    errors: [
      messageId: 'aliasNotAssignedToThis'
      data: name: 'self'
      type: 'Identifier'
    ,
      messageId: 'aliasNotAssignedToThis'
      data: name: 'self'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'context = this'
    options: ['that']
    errors: [
      messageId: 'unexpectedAlias'
      data: name: 'context'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'context = @'
    options: ['that']
    errors: [
      messageId: 'unexpectedAlias'
      data: name: 'context'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'that = this'
    options: ['self']
    errors: [
      messageId: 'unexpectedAlias'
      data: name: 'that'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'self = this'
    options: ['that']
    errors: [
      messageId: 'unexpectedAlias'
      data: name: 'self'
      type: 'AssignmentExpression'
    ]
  ,
    code: 'self += this'
    options: ['self']
    errors: [
      messageId: 'aliasNotAssignedToThis'
      data: name: 'self'
      type: 'AssignmentExpression'
    ]
  ,
    code: '''
      self = null
      do -> self = this
    '''
    options: ['self']
    errors: [
      messageId: 'aliasNotAssignedToThis'
      data: name: 'self'
      type: 'Identifier'
    ]
  ]
