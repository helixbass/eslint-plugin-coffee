###*
# @fileoverview Prevent extra closing tags for components without children
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/self-closing-comp'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'self-closing-comp', rule,
  valid: [
    code: 'HelloJohn = <Hello name="John" />'
  ,
    code: 'Profile = <Hello name="John"><img src="picture.png" /></Hello>'
  ,
    code: """
        <Hello>
          <Hello name="John" />
        </Hello>
      """
  ,
    code: 'HelloJohn = <div>&nbsp;</div>'
  ,
    code: "HelloJohn = <div>{' '}</div>"
  ,
    code: 'HelloJohn = <Hello name="John">&nbsp;</Hello>'
  ,
    code: 'HelloJohn = <Hello name="John" />'
    options: []
  ,
    code: 'Profile = <Hello name="John"><img src="picture.png" /></Hello>'
    options: []
  ,
    code: """
        <Hello>
          <Hello name="John" />
        </Hello>
      """
    options: []
  ,
    code: 'HelloJohn = <div>&nbsp;</div>'
    options: []
  ,
    code: "HelloJohn = <div>{' '}</div>"
    options: []
  ,
    code: 'HelloJohn = <Hello name="John">&nbsp;</Hello>'
    options: []
  ,
    code: 'HelloJohn = <Hello name="John"></Hello>'
    options: [component: no]
  ,
    code: 'HelloJohn = <Hello name="John">\n</Hello>'
    options: [component: no]
  ,
    code: 'HelloJohn = <Hello name="John"> </Hello>'
    options: [component: no]
  ,
    code: 'contentContainer = <div className="content" />'
    options: [html: yes]
  ,
    code:
      'contentContainer = <div className="content"><img src="picture.png" /></div>'
    options: [html: yes]
  ,
    code: """
        <div>
          <div className="content" />
        </div>
      """
    options: [html: yes]
  ]

  invalid: [
    code: 'contentContainer = <div className="content"></div>'
    output: 'contentContainer = <div className="content" />'
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'contentContainer = <div className="content"></div>'
    output: 'contentContainer = <div className="content" />'
    options: []
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'HelloJohn = <Hello name="John"></Hello>'
    output: 'HelloJohn = <Hello name="John" />'
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'HelloJohn = <Hello name="John">\n</Hello>'
    output: 'HelloJohn = <Hello name="John" />'
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'HelloJohn = <Hello name="John"> </Hello>'
    output: 'HelloJohn = <Hello name="John" />'
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'HelloJohn = <Hello name="John"></Hello>'
    output: 'HelloJohn = <Hello name="John" />'
    options: []
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'HelloJohn = <Hello name="John">\n</Hello>'
    output: 'HelloJohn = <Hello name="John" />'
    options: []
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'HelloJohn = <Hello name="John"> </Hello>'
    output: 'HelloJohn = <Hello name="John" />'
    options: []
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'contentContainer = <div className="content"></div>'
    output: 'contentContainer = <div className="content" />'
    options: [html: yes]
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'contentContainer = <div className="content">\n</div>'
    output: 'contentContainer = <div className="content" />'
    options: [html: yes]
    errors: [message: 'Empty components are self-closing']
  ,
    code: 'contentContainer = <div className="content"> </div>'
    output: 'contentContainer = <div className="content" />'
    options: [html: yes]
    errors: [message: 'Empty components are self-closing']
  ]
