###*
# @fileoverview Report missing `key` props in iterators/collection literals.
# @author Ben Mosher
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/jsx-key'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-key', rule,
  valid: [
    code: 'fn()'
  ,
    code: '[1, 2, 3].map(->)'
  ,
    code: '<App />'
  ,
    code: '[<App key={0} />, <App key={1} />]'
  ,
    code: '[1, 2, 3].map (x) -> <App key={x} />'
  ,
    code: '[1, 2, 3].map((x) => <App key={x} />)'
  ,
    code: '[1, 2, 3].map((x) => return <App key={x} />)'
  ,
    code: '[1, 2, 3].foo((x) => <App />)'
  ,
    code: 'App = () => <div />'
  ,
    code: '[1, 2, 3].map((x) -> return)'
  ,
    code: 'foo(() => <div />)'
  ]
  invalid: [
    code: '[<App />]'
    errors: [message: 'Missing "key" prop for element in array']
  ,
    code: '[<App {...key} />]'
    errors: [message: 'Missing "key" prop for element in array']
  ,
    code: '[<App key={0}/>, <App />]'
    errors: [message: 'Missing "key" prop for element in array']
  ,
    code: '[1, 2 ,3].map (x) -> return <App />'
    errors: [message: 'Missing "key" prop for element in iterator']
  ,
    code: '[1, 2 ,3].map((x) => <App />)'
    errors: [message: 'Missing "key" prop for element in iterator']
  ]
