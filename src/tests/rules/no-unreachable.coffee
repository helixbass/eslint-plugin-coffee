###*
# @fileoverview Tests for no-unreachable rule.
# @author Joel Feenstra
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-unreachable'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-unreachable', rule,
  valid: [
    '''
      ->
        bar = -> return 1
        return bar()
    '''
    '''
      ->
        x = 1
        y = 2
    '''
    '''
      foo = ->
        x = 1
        y = 2
        return
    '''
    '''
      while yes
        switch foo
          when 1
            x = 1
            x = 2
    '''
    '''
      while true
        continue
    '''
    '''
      ->
        x = 1
        return if x
        x = 2
    '''
    '''
      ->
        x = 1
        if x
        else
          return
        x = 2
    '''
    '''
      ->
        x = 1
        switch x
          when 0
            break
          else
            return
        x = 2
    '''
    '''
      ->
        x = 1
        while x
          return
        x = 2
    '''
    '''
      x = 1
      for x of {}
        return
      x = 2
    '''
    '''
      x = 1
      for x in [1, 2, 3] when foo x
        return
      x = 2
    '''
    '''
      ->
        x = 1
        try
          return
        finally
          x = 2
    '''
    '''
      ->
        x = 1
        loop
          if x
            break
        x = 2
    '''
  ]
  invalid: [
    code: '''
      ->
        return x
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      while yes
        continue
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      until yes
        continue
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      loop
        continue
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        return
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        throw error
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      while yes
        break
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      switch foo
        when 1
          return
          x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      switch foo
        when 1
          throw e
          x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      while yes
        switch foo
          when 1
            break
            x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      while yes
        switch foo
          when 1
            continue
            x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      x = 1
      throw 'uh oh'
      y = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        if x
          return
        else
          throw e
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        if x
          return
        else
          throw -1
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        try
          return
        finally
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        try
        finally
          return
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      x = 1
      while x
        if x
          break
        else
          continue
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        loop
          continue if x
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        while true
          ;
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        loop
          ;
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        for item in list
          continue
          foo()
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    code: '''
      ->
        x = 1
        for key, val of obj
          break
          foo()
        x = 2
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
  ,
    # Merge the warnings of continuous unreachable nodes.
    code: '''
      ->
        return

        a()  # ← ERROR: Unreachable code. (no-unreachable)

        b()  # ↑ ';' token is included in the unreachable code, so this statement will be merged.
        # comment
        c()  # ↑ ')' token is included in the unreachable code, so this statement will be merged.
    '''
    errors: [
      message: 'Unreachable code.'
      type: 'ExpressionStatement'
      line: 4
      column: 3
      endLine: 8
      endColumn: 6
    ]
  ,
    code: '''
      ->
        return

        a()

        if b()
          c()
        else
          d()
    '''
    errors: [
      message: 'Unreachable code.'
      type: 'ExpressionStatement'
      line: 4
      column: 3
      endLine: 9
      endColumn: 8
    ]
  ,
    code: '''
      ->
        if a
          return
          b()
          c()
        else
          throw err
          d()
    '''
    errors: [
      message: 'Unreachable code.'
      type: 'ExpressionStatement'
      line: 4
      column: 5
      endLine: 5
      endColumn: 8
    ,
      message: 'Unreachable code.'
      type: 'ExpressionStatement'
      line: 8
      column: 5
      endLine: 8
      endColumn: 8
    ]
  ,
    code: '''
      ->
        if a
          return
          b()
          c()
        else
          throw err
          d()
        e()
    '''
    errors: [
      message: 'Unreachable code.'
      type: 'ExpressionStatement'
      line: 4
      column: 5
      endLine: 5
      endColumn: 8
    ,
      message: 'Unreachable code.'
      type: 'ExpressionStatement'
      line: 8
      column: 5
      endLine: 9
      endColumn: 6
    ]
  ]
