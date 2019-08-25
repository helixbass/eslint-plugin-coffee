###*
# @fileoverview Tests for global-require
# @author Jamund Ferguson
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/global-require'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------
ruleTester = new RuleTester parser: path.join __dirname, '../../..'

valid = [
  "x = require('y')"
  "if (x) then x.require('y')"
  "x; x = require('y')"
  """
    x = 1
    y = require('y')
  """
  """
    x = require('y')
    y = require('y')
    z = require('z')
  """
  "x = require('y').foo"
  "require('y').foo()"
  "require('y')"
  """
    x = ->
    x()
    if x > y
      doSomething()
    x = require('y').foo
  """
  "logger = require(if DEBUG then 'dev-logger' else 'logger')"
  "logger = if DEBUG then require('dev-logger') else require('logger')"
  "localScopedRequire = (require) -> require('y')"
  """
    someFunc = require './someFunc'
    someFunc (require) -> 'bananas'
  """
]

message = 'Unexpected require().'
type = 'CallExpression'

invalid = [
  # block statements
  code: """
    if process.env.NODE_ENV is 'DEVELOPMENT'
      require('debug')
  """
  errors: [
    {
      line: 2
      column: 3
      message
      type
    }
  ]
,
  code: """
    x = null
    if (y)
      x = require('debug')
  """
  errors: [
    {
      line: 3
      column: 7
      message
      type
    }
  ]
,
  code: """
    x = null
    if y
      x = require('debug').baz
  """
  errors: [
    {
      line: 3
      column: 7
      message
      type
    }
  ]
,
  code: "x = -> require('y')"
  errors: [
    {
      line: 1
      column: 8
      message
      type
    }
  ]
,
  code: """
    try
      require('x')
    catch e
      console.log e
  """
  errors: [
    {
      line: 2
      column: 3
      message
      type
    }
  ]
,
  # non-block statements
  code: 'getModule = (x) => require(x)'
  errors: [
    {
      line: 1
      column: 20
      message
      type
    }
  ]
,
  code: "x = ((x) => require(x))('weird')"
  errors: [
    {
      line: 1
      column: 13
      message
      type
    }
  ]
,
  code: """
    switch x
      when '1'
        require('1')
  """
  errors: [
    {
      line: 3
      column: 5
      message
      type
    }
  ]
]

ruleTester.run 'global-require', rule, {
  valid
  invalid
}
