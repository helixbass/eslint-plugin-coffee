###*
# @fileoverview Report when a DOM element is using both children and dangerouslySetInnerHTML
# @author David Petersen
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-danger-with-children'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'no-danger-with-children', rule,
  valid: [
    code: '<div>Children</div>'
  ,
    code: '<div {...props} />'
    globals:
      props: yes
  ,
    code: '<div dangerouslySetInnerHTML={{ __html: "HTML" }} />'
  ,
    code: '<div children="Children" />'
  ,
    code: '''
      props = { dangerouslySetInnerHTML: { __html: "HTML" } }
      <div {...props} />
    '''
  ,
    code: '''
      moreProps = { className: "eslint" }
      props = { children: "Children", ...moreProps }
      <div {...props} />
    '''
  ,
    code: '''
      otherProps = { children: "Children" }
      { a, b, ...props } = otherProps
      <div {...props} />
    '''
  ,
    code: '<Hello>Children</Hello>'
  ,
    code: '<Hello dangerouslySetInnerHTML={{ __html: "HTML" }} />'
  ,
    code: '''
      <Hello dangerouslySetInnerHTML={{ __html: "HTML" }}>
      </Hello>
    '''
  ,
    code:
      'React.createElement("div", { dangerouslySetInnerHTML: { __html: "HTML" } })'
  ,
    code: 'React.createElement("div", {}, "Children")'
  ,
    code:
      'React.createElement("Hello", { dangerouslySetInnerHTML: { __html: "HTML" } })'
  ,
    code: 'React.createElement("Hello", {}, "Children")'
  ,
    # ,
    #   code: '<Hello {...undefined}>Children</Hello>'
    code: 'React.createElement("Hello", undefined, "Children")'
  ,
    code: '''
      props = {...props, scratch: {mode: 'edit'}}
      component = shallow(<TaskEditableTitle {...props} />)
    '''
  ,
    # #35
    '''
      import React from 'react'

      export default class ReactView
        props: label: 'test'

        render: ->
          <div>
            <span {@props...}>test</span>
          </div>
    '''
    '''
      import React from 'react'

      render = ->
        <div>
          <span {foo...}>test</span>
        </div>
    '''
  ]
  invalid: [
    code: '''
      <div dangerouslySetInnerHTML={{ __html: "HTML" }}>
        Children
      </div>
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code:
      '<div dangerouslySetInnerHTML={{ __html: "HTML" }} children="Children" />'
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      props = { dangerouslySetInnerHTML: { __html: "HTML" } }
      <div {...props}>Children</div>
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      props = { children: "Children", dangerouslySetInnerHTML: { __html: "HTML" } }
      <div {...props} />
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      <Hello dangerouslySetInnerHTML={{ __html: "HTML" }}>
        Children
      </Hello>
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code:
      '<Hello dangerouslySetInnerHTML={{ __html: "HTML" }} children="Children" />'
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '<Hello dangerouslySetInnerHTML={{ __html: "HTML" }}> </Hello>'
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      React.createElement(
        "div",
        { dangerouslySetInnerHTML: { __html: "HTML" } },
        "Children"
      )
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      React.createElement(
        "div",
        {
          dangerouslySetInnerHTML: { __html: "HTML" },
          children: "Children",
        }
      )
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      React.createElement(
        "Hello",
        { dangerouslySetInnerHTML: { __html: "HTML" } },
        "Children"
      )
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      React.createElement(
        "Hello",
        {
          dangerouslySetInnerHTML: { __html: "HTML" },
          children: "Children",
        }
      )
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      props = { dangerouslySetInnerHTML: { __html: "HTML" } }
      React.createElement("div", props, "Children")
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      props = { children: "Children", dangerouslySetInnerHTML: { __html: "HTML" } }
      React.createElement("div", props)
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ,
    code: '''
      moreProps = { children: "Children" }
      otherProps = { ...moreProps }
      props = { ...otherProps, dangerouslySetInnerHTML: { __html: "HTML" } }
      React.createElement("div", props)
    '''
    errors: [
      message: 'Only set one of `children` or `props.dangerouslySetInnerHTML`'
    ]
  ]
