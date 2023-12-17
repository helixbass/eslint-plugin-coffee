###*
# @fileoverview Tests for no-alert rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-alert'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-alert', rule,
  valid: [
    'a[o.k](1)'
    'foo.alert(foo)'
    'foo.confirm(foo)'
    'foo.prompt(foo)'
    '''
      alert = ->
      alert()
    '''
    '''
      ->
        alert = bar
        alert()
    '''
    '(alert) -> alert()'
    '''
      alert = ->
      ->
        alert()
    '''
    '''
      ->
        alert = ->
        ->
          alert()
    '''
    '''
      confirm = ->
      confirm()
    '''
    '''
      prompt = ->
      prompt()
    '''
    'window[alert]()'
    '-> @alert()'
    '''
      ->
        window = bar
        window.alert()
    '''
  ]
  invalid: [
    code: 'alert(foo)'
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: 'window.alert(foo)'
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: "window['alert'](foo)"
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: 'confirm(foo)'
    errors: [
      messageId: 'unexpected'
      data: name: 'confirm'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: 'window.confirm(foo)'
    errors: [
      messageId: 'unexpected'
      data: name: 'confirm'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: "window['confirm'](foo)"
    errors: [
      messageId: 'unexpected'
      data: name: 'confirm'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: 'prompt(foo)'
    errors: [
      messageId: 'unexpected'
      data: name: 'prompt'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: 'window.prompt(foo)'
    errors: [
      messageId: 'unexpected'
      data: name: 'prompt'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: "window['prompt'](foo)"
    errors: [
      messageId: 'unexpected'
      data: name: 'prompt'
      type: 'CallExpression'
      line: 1
      column: 1
    ]
  ,
    code: '''
      alert = ->
      window.alert(foo)
    '''
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 2
      column: 1
    ]
  ,
    code: '(alert) -> window.alert()'
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 1
      column: 12
    ]
  ,
    code: '-> alert()'
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 1
      column: 4
    ]
  ,
    code: '''
      ->
        alert = ->
      alert()
    '''
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 3
      column: 1
    ]
  ,
    # TODO: uncomment if not always parsing as module
    # ,
    #   code: '@alert(foo)'
    #   errors: [
    #     messageId: 'unexpected'
    #     data: name: 'alert'
    #     type: 'CallExpression'
    #     line: 1
    #     column: 1
    #   ]
    # ,
    #   code: "this['alert'](foo)"
    #   errors: [
    #     messageId: 'unexpected'
    #     data: name: 'alert'
    #     type: 'CallExpression'
    #     line: 1
    #     column: 1
    #   ]
    code: '''
        ->
          window = bar
          window.alert()
        window.alert()
      '''
    errors: [
      messageId: 'unexpected'
      data: name: 'alert'
      type: 'CallExpression'
      line: 4
      column: 1
    ]
  ]
