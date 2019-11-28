###*
# @fileoverview Disallows unnecessary `return await`
# @author Jordan Harband
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-return-await'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

# pending https://github.com/eslint/espree/issues/304, the type should be "Keyword"
errors = [
  message: 'Redundant use of `await` on a return value.', type: 'Identifier'
]

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-return-await', rule,
  valid: [
    '''
      ->
        await bar()
        return
    '''
    '''
      ->
        x = await bar()
        return x
    '''
    '''
      ->
        return bar()
    '''
    '''
      () => bar()
    '''
    '''
      ->
        if a
          if b
            return bar()
    '''
    '''
      ->
        if a
          if b
            bar()
    '''
    '''
      ->
        return (await bar() and a)
    '''
    '''
      ->
        return (await bar() or a)
    '''
  ,
    code: '''
      ->
        await bar()
    '''
    options: [implicit: no]
  ,
    code: '''
      ->
        a && await bar()
    '''
    options: [implicit: no]
  ,
    code: '''
      ->
        if b then await bar()
    '''
    options: [implicit: no]
  ,
    code: '''
      ->
        (await bar() ? a)
    '''
    options: [implicit: yes]
  ,
    '''
      ->
        return a && await baz() && b
    '''
    '''
      ->
        return (await bar(); a)
    '''
    '''
      ->
        return (await baz(); await bar(); a)
    '''
    '''
      ->
        return (a; b; (await bar(); c))
    '''
    '''
      ->
        return (if await bar() then a else b)
    '''
    '''
      ->
        return (if a && await bar() then b else c)
    '''
    '''
      ->
        return (if baz() then (await bar(); a) else b)
    '''
    '''
      ->
        return (if baz() then (await bar() && a) else b)
    '''
    '''
      ->
        return (if baz() then a else (await bar(); b))
    '''
    '''
      ->
        return (if baz() then a else (await bar() && b))
    '''
    '() => (await bar(); a)\n'
    '() => (await bar() && a)\n'
    '() => (await bar() || a)\n'
    '() => (a && await bar() && b)\n'
    '() => (await baz(); await bar(); a)\n'
    '() => (a; b; (await bar(); c))\n'
    '() => (if await bar() then a else b)\n'
    '() => (if (a && await bar()) then b else c)\n'
    '() => (if baz() then (await bar(); a) else b)\n'
    '() => (if baz() then (await bar() && a) else b)\n'
    '() => (if baz() then a : (await bar(); b))\n'
    '() => (if baz() then a : (await bar() && b))\n'
    '''
      ->
        try
          return await bar()
        catch e
          baz()
    '''
    '''
      ->
        try
          return await bar()
        finally
          baz()
    '''
    '''
      ->
        try
        catch e
          return await bar()
        finally
          baz()
    '''
    '''
      ->
        try
          try
          finally
            return await bar()
        finally
          baz()
    '''
    '''
      ->
        try
          try
          catch e
            return await bar()
        finally
          baz()
    '''
    '''
      ->
        try
          return (a; await bar())
        catch e
          baz()
    '''
    '''
      ->
        try
          return (if qux() then await bar() else b)
        catch e
          baz()
    '''
    '''
      ->
        try
          return (a && await bar())
        catch e
          baz()
    '''
  ]

  invalid: [
    {
      code: '''
        ->
          return await bar()
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (a; await bar())
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (a; b; await bar())
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (a && await bar())
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (a and b and await bar())
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (a or await bar())
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (a; b; (c; d; await bar()))
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (a; b; (c && await bar()))
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (await baz(); b; await bar())
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (if baz() then await bar() else b)
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (if baz() then a else await bar())
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (if baz() then (a; await bar()) else b)
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (if baz() then a else (b; await bar()))
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (if baz() then (a && await bar()) else b)
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return (if baz() then a else (b && await bar()))
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          return await bar()
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '=> return await bar()'
      errors
      options: [implicit: no]
    }
    {
      code: '=> return await bar()'
      errors
      options: [implicit: yes]
    }
    {
      code: '''
        ->
          (await baz(); b; await bar())
      '''
      errors
      options: [implicit: yes]
    }
    {
      code: '''
        ->
          (if baz() then a else (b && await bar()))
      '''
      errors
      options: [implicit: yes]
    }
    {
      code: '=> await bar()'
      errors
      options: [implicit: yes]
    }
    {
      code: '''
        ->
          if a
            if b
              await bar()
      '''
      errors
      options: [implicit: yes]
    }
    {
      code: '''
        ->
          await bar() unless a
      '''
      errors
      options: [implicit: yes]
    }
    {
      code: '''
        ->
          await bar() unless a
      '''
      errors
    }
    {
      code: '''
        ->
          if a
            if b
              return await bar()
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          if a
            if b
              return await bar
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          try
          finally
            return await bar()
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          try
          catch e
            return await bar()
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        try
          ->
            return await bar()
        catch e
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        try
          () => return await bar()
        catch e
      '''
      errors
      options: [implicit: no]
    }
    {
      code: '''
        ->
          try
          catch e
            try
            catch e
              return await bar()
      '''
      errors
      options: [implicit: no]
    }
  ]
