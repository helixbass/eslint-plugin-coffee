###*
# @fileoverview Tests for complexity rule.
# @author Patrick Brosset
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/complexity'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Generates a code string with the amount of complexity specified in the parameter
# @param {int} complexity The level of complexity
# @returns {string} Code with the amount of complexity specified in the parameter
# @private
###
createComplexity = (complexity) ->
  funcString = '(a) -> if a is 1 then '

  for i in [2...complexity]
    funcString += "; else if a is #{i} then "

  funcString += ';'

  funcString

###*
# Create an expected error object
# @param   {string} name       The name of the symbol being tested
# @param   {number} complexity The cyclomatic complexity value of the symbol
# @returns {Object}            The error object
###
makeError = (name, complexity) ->
  messageId: 'complex'
  data: {name, complexity}

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'complexity', rule,
  valid: [
    'a = (x) ->'
  ,
    code: 'b = (x) ->', options: [1]
  ,
    code: 'a = (x) -> return x if yes', options: [2]
  ,
    code: '''
      (x) ->
        if yes
          x
        else
          x + 1
    '''
    options: [2]
  ,
    code: '''
      a = (x) ->
        if yes
          x
        else if no
          x + 1
        else
          4
    '''
    options: [3]
  ,
    code: '''
      (x) ->
        for [0...5]
          x++
        x
    '''
    options: [2]
  ,
    code: '''
      (obj) ->
        for i of obj
          obj[i] = 3
    '''
    options: [2]
  ,
    code: '''
      (x) ->
        for i in [0...5]
          if i % 2 is 0
            x++
        x
    '''
    options: [3]
  ,
    code: '''
      (obj) ->
        if obj
          for x of obj
            try x.getThis()
            catch e
              x.getThat()
        else
          return false
    '''
    options: [4]
  ,
    code: '''
      (x) ->
        try
          x.getThis()
        catch e
          x.getThat()
    '''
    options: [2]
  ,
    code: '(x) -> if x is 4 then 3 else 5', options: [2]
  ,
    code: '(x) -> if x is 4 then 3 else if x is 3 then 2 else 1'
    options: [3]
  ,
    code: '(x) -> x or 4', options: [2]
  ,
    code: '(x) -> x and 4', options: [2]
  ,
    code: '''
      (x) ->
        switch x
          when 1
            1
          when 2
            2
          else
            3
    '''
    options: [3]
  ,
    code: """
      (x) ->
        switch x
          when 1
            1
          when 2
            2
          else
            5 if x == 'foo'
    """
    options: [4]
  ,
    code: """
      (x) ->
        loop
          'foo'
    """
    options: [2]
  ,
    code: 'bar() if foo', options: [3]
  ,
    # object property options
    code: 'b = (x) ->', options: [max: 1]
  ]
  invalid: [
    code: 'a = (x) ->'
    options: [0]
    errors: [makeError 'Function', 1]
  ,
    code: 'func = ->'
    options: [0]
    errors: [makeError 'Function', 1]
  ,
    code: 'obj = { a: (x) -> }'
    options: [0]
    errors: [makeError "Method 'a'", 1]
  ,
    code: '''
      class Test
        a: (x) ->
    '''
    options: [0]
    errors: [makeError "Method 'a'", 1]
  ,
    code: 'a = (x) => if yes then return x'
    options: [1]
    errors: 1
  ,
    code: '''
      (x) ->
        if yes
          x
        else
          x + 1
    '''
    options: [1]
    errors: 1
  ,
    code: '''
      (x) ->
        if yes
          x
        else if no
          x + 1
        else
          4
    '''
    options: [2]
    errors: 1
  ,
    code: '''
      (x) ->
        for [0...5]
          x++
        x
    '''
    options: [1]
    errors: 1
  ,
    code: '''
      (obj) ->
        for i of obj
          obj[i] = 3
    '''
    options: [1]
    errors: 1
  ,
    code: '''
      (x) ->
        for i in [0...5]
          if i % 2 is 0
            x++
        return x
    '''
    options: [2]
    errors: 1
  ,
    code: '''
      (obj) ->
        if obj
          for x of obj
            try
              x.getThis()
            catch e
              x.getThat()
        else
          false
    '''
    options: [3]
    errors: 1
  ,
    code: '''
      (x) ->
        try
          x.getThis()
        catch e
          x.getThat
    '''
    options: [1]
    errors: 1
  ,
    code: '(x) -> if x is 4 then 3 else 5', options: [1], errors: 1
  ,
    code: '(x) -> if x is 4 then 3 else if x is 3 then 2 else 1'
    options: [2]
    errors: 1
  ,
    code: '(x) -> x or 4', options: [1], errors: 1
  ,
    code: '(x) -> x and 4', options: [1], errors: 1
  ,
    code: '''
      (x) ->
        switch x
          when 1
            1
          when 2
            2
          else
            3
    '''
    options: [2]
    errors: 1
  ,
    code: """
      (x) ->
        switch x
          when 1
            1
          when 2
            2
          else
            if x == 'foo' then 5
    """
    options: [3]
    errors: 1
  ,
    code: """
      (x) ->
        loop
          'foo'
    """
    options: [1]
    errors: 1
  ,
    code: """
      (x) ->
        do ->
          'foo' while yes
        do ->
          'bar' until no
    """
    options: [1]
    errors: 2
  ,
    code: """
      (x) ->
        do ->
          while true then 'foo'
        (-> 'bar')()
    """
    options: [1]
    errors: 1
  ,
    code: '''
      obj =
        a: (x) -> if x then 0 else 1
    '''
    options: [1]
    errors: [makeError "Method 'a'", 2]
  ,
    code: '''
      obj = a: (x) -> if x then 0 else 1
    '''
    options: [1]
    errors: [makeError "Method 'a'", 2]
  ,
    code: createComplexity 21
    errors: [makeError 'Function', 21]
  ,
    # object property options
    code: 'a = (x) ->'
    options: [max: 0]
    errors: [makeError 'Function', 1]
  ]
