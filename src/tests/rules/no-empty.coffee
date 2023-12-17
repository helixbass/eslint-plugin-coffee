###*
# @fileoverview Tests for no-empty rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-empty'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-empty', rule,
  valid: [
    '''
      if foo
        bar()
    '''
    '''
      while foo
        bar()
    '''
    '''
      try
        foo()
      catch ex
        foo()
    '''
    '''
      switch foo
        when 'foo'
          break
    '''
    'do ->'
    'foo = ->'
    '''
      if foo
        ;
        ### empty ###
    '''
    '''
      while foo
        ### empty ###
        ;
    '''
    '''
      for x in y
        ### empty ###
        ;
    '''
    '''
      try
        foo()
      catch ex
        ### empty ###
    '''
    '''
      try
        foo()
      catch ex
        # empty
    '''
    '''
      try
        foo()
      finally
        # empty
    '''
    '''
      try
        foo()
      finally
        # test
    '''
    '''
      try
        foo()
      finally

        # hi i am off no use
    '''
    '''
      try
        foo()
      catch ex
        ### test111 ###
    '''
    '''
      if foo
        bar()
      else
        # nothing in me
    '''
    '''
      if foo
        bar()
      else
        ### ###
    '''
    '''
      if foo
        bar()
      else
        #
    '''
  ,
    code: '''
      try
        foo()
      catch ex
    '''
    options: [allowEmptyCatch: yes]
  ,
    code: '''
      try
        foo()
      catch ex
      finally
        bar()
    '''
    options: [allowEmptyCatch: yes]
  ]
  invalid: [
    code: '''
      try
      catch ex
        throw ex
    '''
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      try
        foo()
      catch ex
    '''
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      try
        foo()
      catch ex
        throw ex
      finally
    '''
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      if foo
        ;
    '''
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      while foo
        ;
    '''
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      for x in y
        ;
    '''
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      try
      catch ex
    '''
    options: [allowEmptyCatch: yes]
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      try
        foo()
      catch ex
      finally
    '''
    options: [allowEmptyCatch: yes]
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      try
      catch ex
      finally
    '''
    options: [allowEmptyCatch: yes]
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ,
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ,
    code: '''
      try
        foo()
      catch ex
      finally
    '''
    errors: [
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ,
      messageId: 'unexpected', data: {type: 'block'}, type: 'BlockStatement'
    ]
  ]
