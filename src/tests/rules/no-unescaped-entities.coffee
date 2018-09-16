###*
# @fileoverview Tests for no-unescaped-entities
# @author Patrick Hayes
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-unescaped-entities'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-unescaped-entities', rule,
  valid: [
    code: """
        Hello = createReactClass({
          render: ->
            return (
              <div/>
            )
        })
      """
  ,
    code: """
        Hello = createReactClass
          render: ->
            <div>Here is some text!</div>
      """
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <div>I&rsquove escaped some entities: &gt &lt &amp</div>
        })
      """
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <div>first line is ok
            so is second
            and here are some escaped entities: &gt &lt &amp</div>
        })
      """
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <div>{">" + "<" + "&" + '"'}</div>
        })
      """
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <>Here is some text!</>
        })
      """
  ,
    # parser: 'babel-eslint'
    code: """
        Hello = createReactClass({
          render: ->
            return <>I&rsquove escaped some entities: &gt &lt &amp</>
        })
      """
  ,
    # parser: 'babel-eslint'
    code: """
        Hello = createReactClass({
          render: ->
            return <>{">" + "<" + "&" + '"'}</>
        })
      """
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: """
        Hello = createReactClass({
          render: ->
            return <div>></div>
        })
      """
    errors: [message: 'HTML entities must be escaped.']
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <>></>
        })
      """
    # parser: 'babel-eslint'
    errors: [message: 'HTML entities must be escaped.']
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <div>first line is ok
            so is second
            and here are some bad entities: ></div>
        })
      """
    errors: [message: 'HTML entities must be escaped.']
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <>first line is ok
            so is second
            and here are some bad entities: ></>
        })
      """
    # parser: 'babel-eslint'
    errors: [message: 'HTML entities must be escaped.']
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <div>'</div>
        })
      """
    errors: [message: 'HTML entities must be escaped.']
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <div>Multiple errors: '>></div>
        })
      """
    errors: [
      message: 'HTML entities must be escaped.'
    ,
      message: 'HTML entities must be escaped.'
    ,
      message: 'HTML entities must be escaped.'
    ]
  ,
    code: """
        Hello = createReactClass
          render: ->
            <div>{"Unbalanced braces"}}</div>
      """
    errors: [message: 'HTML entities must be escaped.']
  ,
    code: """
        Hello = createReactClass({
          render: ->
            return <>{"Unbalanced braces"}}</>
        })
      """
    # parser: 'babel-eslint'
    errors: [message: 'HTML entities must be escaped.']
  ]
