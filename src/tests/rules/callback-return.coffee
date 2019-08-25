###*
# @fileoverview Tests for callback return rule.
# @author Jamund Ferguson
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/callback-return'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'callback-return', rule,
  valid: [
    # callbacks inside of functions should return
    '''
      (err) ->
        if err
          return callback(err)
    '''
    '''
      (err) ->
        if err
          return callback err
        callback()
    '''
    '''
      (err) ->
        if err
          return ### confusing comment ### callback(err)
        callback()
    '''
    '''
      (err) ->
        if err
          callback()
          return
    '''
    '''
      (err) ->
        if err
          log()
          callback()
          return
    '''
    '''
      (err) ->
        if err
          callback()
          return
        return callback()
    '''
    '''
      (err) ->
        if err
          return callback()
        else
          return callback()
    '''
    '''
      (err) ->
        if err
          return callback()
        else if x
          return callback()
    '''
    '''
      (cb) ->
        cb and cb()
    '''
    """
      (next) ->
        typeof next isnt 'undefined' and next()
    """
    """
      (next) ->
        return next() if typeof next is 'function'
    """
    """
      ->
        switch x
          when 'a'
            return next()
    """
    '''
      ->
        while x
          return next()
    '''
    '''
      (err) ->
        if err
          obj.method err
    '''

    # callback() all you want outside of a function
    'callback()'
    '''
      callback()
      callback()
    '''
    '''
      while x
        move()
    '''
    '''
      if x
        callback()
    '''
    # arrow functions
    '''
      x = (err) =>
        if err
          callback()
          return
    '''
    '''
      x = (err) => callback(err)
    '''
    '''
      x = (err) =>
        setTimeout => callback()
    '''
    # classes
    '''
      class x
        horse: -> callback()
    '''
    '''
      class x
        horse: ->
          if err
            return callback()
          callback()
    '''
  ,
    # options (only warns with the correct callback name)
    code: '''
      (err) ->
        if err
          callback err
    '''
    options: [['cb']]
  ,
    code: '''
      (err) ->
        if err
          callback err
        next()
    '''
    options: [['cb', 'next']]
  ,
    code: '''
      a = (err) ->
        if err then return next err else callback()
    '''
    options: [['cb', 'next']]
  ,
    # allow object methods (https://github.com/eslint/eslint/issues/4711)
    code: '''
      (err) ->
        if err
          return obj.method err
    '''
    options: [['obj.method']]
  ,
    code: '''
      (err) ->
        if err
          return obj.prop.method err
    '''
    options: [['obj.prop.method']]
  ,
    code: '''
      (err) ->
        if err
          return obj.prop.method err
        otherObj.prop.method()
    '''
    options: [['obj.prop.method', 'otherObj.prop.method']]
  ,
    code: '''
      (err) ->
        if err then callback err
    '''
    options: [['obj.method']]
  ,
    code: '''
      (err) -> otherObj.method err if err
    '''
    options: [['obj.method']]
  ,
    code: '''
      (err) ->
        if err
          #comment
          return obj.method(err)
    '''
    options: [['obj.method']]
  ,
    code: '''
      (err) ->
        if err
          return obj.method err #comment
    '''
    options: [['obj.method']]
  ,
    code: '''
      (err) ->
        if err
          return obj.method err ###comment###
    '''
    options: [['obj.method']]
  ,
    # only warns if object of MemberExpression is an Identifier
    code: '''
      (err) ->
        if err
          obj().method err
    '''
    options: [['obj().method']]
  ,
    code: '''
      (err) ->
        if err
          obj.prop().method err
    '''
    options: [['obj.prop().method']]
  ,
    code: '''
      (err) ->
        if (err) then obj().prop.method(err)
    '''
    options: [['obj().prop.method']]
  ,
    # does not warn if object of MemberExpression is invoked
    code: '''
      (err) -> if (err) then obj().method(err)
    '''
    options: [['obj.method']]
  ,
    code: '''
      (err) ->
        if err
          obj().method(err)
        obj.method()
    '''
    options: [['obj.method']]
  ,
    #  known bad examples that we know we are ignoring
    '''
      (err) ->
        if err
          setTimeout callback, 0
        callback()
    ''' # callback() called twice
    '''
      (err) ->
        if err
          process.nextTick (err) -> callback()
        callback()
    ''' # callback() called twice
  ]
  invalid: [
    code: '''
      (err) ->
        if err
          callback err
    '''
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: """
      (callback) ->
        if typeof callback isnt 'undefined'
          callback()
    """
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (callback) ->
        if err
          callback()
          horse && horse()
    '''
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      x =
        x: (err) ->
          if err
            callback err
    '''
    errors: [
      messageId: 'missingReturn'
      line: 4
      column: 7
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          log()
          callback err
    '''
    errors: [
      messageId: 'missingReturn'
      line: 4
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      x = {
        x: (err) ->
          if err
            callback && callback(err)
      }
    '''
    errors: [
      messageId: 'missingReturn'
      line: 4
      column: 19
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        callback(err)
        callback()
    '''
    errors: [
      messageId: 'missingReturn'
      line: 2
      column: 3
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        callback(err)
        horse()
    '''
    errors: [
      messageId: 'missingReturn'
      line: 2
      column: 3
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          callback(err)
          horse()
          return
    '''
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          callback(err)
        else if x
          callback(err)
          return
    '''
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if (err)
          return callback()
        else if (abc)
          callback()
        else
          return callback()
    '''
    errors: [
      messageId: 'missingReturn'
      line: 5
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      class x
        horse: ->
          if err
            callback()
          callback()
    '''
    errors: [
      messageId: 'missingReturn'
      line: 4
      column: 7
      nodeType: 'CallExpression'
    ]
  ,
    # generally good behavior which we must not allow to keep the rule simple
    code: '''
      (err) ->
        if err
          callback()
        else
          callback()
    '''
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ,
      messageId: 'missingReturn'
      line: 5
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          return callback()
        else
          callback()
    '''
    errors: [
      messageId: 'missingReturn'
      line: 5
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: """
      ->
        switch x
          when 'horse'
            callback()
    """
    errors: [
      messageId: 'missingReturn'
      line: 4
      column: 7
      nodeType: 'CallExpression'
    ]
  ,
    code: """
      a = ->
        switch x
          when 'horse'
            move()
    """
    options: [['move']]
    errors: [
      messageId: 'missingReturn'
      line: 4
      column: 7
      nodeType: 'CallExpression'
    ]
  ,
    # loops
    code: '''
      x = ->
        while x
          move()
    '''
    options: [['move']]
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          obj.method err
    '''
    options: [['obj.method']]
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        obj.prop.method err if err
    '''
    options: [['obj.prop.method']]
    errors: [
      messageId: 'missingReturn'
      line: 2
      column: 3
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          obj.prop.method err
        otherObj.prop.method()
    '''
    options: [['obj.prop.method', 'otherObj.prop.method']]
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if (err)
          #comment
          obj.method err
    '''
    options: [['obj.method']]
    errors: [
      messageId: 'missingReturn'
      line: 4
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          obj.method err ###comment###
    '''
    options: [['obj.method']]
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ,
    code: '''
      (err) ->
        if err
          obj.method err #comment
    '''
    options: [['obj.method']]
    errors: [
      messageId: 'missingReturn'
      line: 3
      column: 5
      nodeType: 'CallExpression'
    ]
  ]
