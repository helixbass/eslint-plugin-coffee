###*
# @fileoverview Disallow redundant return statements
# @author Teddy Katz
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-useless-return'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-useless-return', rule,
  valid: [
    '-> return 5'
    '-> 5'
    '-> return null'
    '-> return doSomething()'
    """
      ->
        if bar
          doSomething()
          return
        else
          doSomethingElse()
        qux()
    """
    """
      foo = ->
        switch bar
          when 1
            doSomething()
            return
          else
            doSomethingElse()
    """
    """
      ->
        switch bar
          when 1
            if a
              doSomething()
              return
            else
              doSomething()
              return
          else
            doSomethingElse()
    """
    """
      ->
        for foo of bar
          return
    """
    """
      ->
        return for foo of bar
    """
    """
      ->
        try
          return 5
        finally
          return # This is allowed because it can override the returned value of 5
    """
    """
      ->
        return
        doSomething()
    """
    """
      ->
        for foo from bar
          return
    """
    '''
      ->
        return if foo
        bar()
    '''
    '-> 5'
    '''
      ->
        return
        doSomething()
    '''
    '''
      if foo
        return
      doSomething()
    '''
    # https://github.com/eslint/eslint/issues/7477
    """
      ->
        if bar
          return
        return baz
    """
    """
      ->
        if bar
          baz
        else
          return
        return 5
    """

    # https://github.com/eslint/eslint/issues/7583
    """
      ->
        return
        while foo
          return
        foo
    """

    # https://github.com/eslint/eslint/issues/7855
    """
      try
        throw new Error 'foo'
        while no
          ;
      catch err
    """
  ]

  invalid: [
    code: '-> return'
    output: '-> '
  ,
    code: '''
      ->
        return
    '''
    output: '''
      ->
        
    '''
  ,
    code: '''
      ->
        doSomething()
        return
    '''
    output: '''
      ->
        doSomething()
        
    '''
  ,
    code: '''
      foo = ->
        if condition
          bar()
          return
        else
          baz()
    '''
    output: '''
      foo = ->
        if condition
          bar()
          
        else
          baz()
    '''
  ,
    code: '-> if foo then return'
    output: '-> if foo then return'
  ,
    code: '''
      foo()
      return
    '''
    output: '''
      foo()
      
    '''
  ,
    code: '''
      if foo
        bar()
        return
      else
        baz()
    '''
    output: '''
      if foo
        bar()
        
      else
        baz()
    '''
  ,
    code: """
      ->
        if foo
          return
        return
    """
    output: """
      ->
        if foo
          return
        
    """
    errors: [
      message: 'Unnecessary return statement.', type: 'ReturnStatement'
    ,
      message: 'Unnecessary return statement.', type: 'ReturnStatement'
    ]
  ,
    code: """
      ->
        switch bar
          when 1
            doSomething()
          else
            doSomethingElse()
            return
    """
    output: """
      ->
        switch bar
          when 1
            doSomething()
          else
            doSomethingElse()
            
    """
  ,
    code: """
      ->
        switch bar
          when 1
            if a
              doSomething()
              return
            break
          else
            doSomethingElse()
    """
    output: """
      ->
        switch bar
          when 1
            if a
              doSomething()
              
            break
          else
            doSomethingElse()
    """
  ,
    code: """
      ->
        switch bar
          when 1
            if a
              doSomething()
              return
            else
              doSomething()
            break
          else
            doSomethingElse()
    """
    output: """
      ->
        switch bar
          when 1
            if a
              doSomething()
              
            else
              doSomething()
            break
          else
            doSomethingElse()
    """
  ,
    code: """
      ->
        try
        catch err
          return
    """
    output: """
      ->
        try
        catch err
          
    """
  ,
    ###
    # FIXME: Re-add this case (removed due to https://github.com/eslint/eslint/issues/7481):
    # https://github.com/eslint/eslint/blob/261d7287820253408ec87c344beccdba2fe829a4/tests/lib/rules/no-useless-return.js#L308-L329
    ###

    code: """
      ->
        try
        finally
        return
    """
    output: """
      ->
        try
        finally
        
    """
  ,
    code: """
      ->
        try
          return 5
        finally
          bar = ->
            return
    """
    output: """
      ->
        try
          return 5
        finally
          bar = ->
            
    """
  ,
    code: '() => return'
    output: '() => '
  ,
    code: '''
      ->
        return
        return
    '''
    output: '''
      ->
        
        return
    ''' # Other case is fixed in the second pass.
    errors: [
      message: 'Unnecessary return statement.', type: 'ReturnStatement'
    ,
      message: 'Unnecessary return statement.', type: 'ReturnStatement'
    ]
  ].map (invalidCase) ->
    {
      errors: [
        message: 'Unnecessary return statement.', type: 'ReturnStatement'
      ]
      ...invalidCase
    }
