###*
# @fileoverview Enforce style prop value is an object
# @author David Petersen
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/style-prop-object'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'style-prop-object', rule,
  valid: [
    code: '<div style={{ color: "red" }} />'
  ,
    code: '<Hello style={color: "red"} />'
  ,
    code: [
      'redDiv = ->'
      '  styles = { color: "red" }'
      '  <div style={styles} />'
    ].join '\n'
  ,
    code: [
      'redDiv = ->'
      '  styles = { color: "red" }'
      '  <Hello style={styles} />'
    ].join '\n'
  ,
    code: [
      'styles = { color: "red" }'
      'redDiv = ->'
      '  return <div style={styles} />'
    ].join '\n'
  ,
    code: ['redDiv = (props) ->', '  return <div style={props.styles} />'].join(
      '\n'
    )
  ,
    code: [
      "import styles from './styles'"
      'redDiv = ->'
      '  return <div style={styles} />'
    ].join '\n'
  ,
    code: [
      "import mystyles from './styles'"
      "styles = Object.assign({ color: 'red' }, mystyles)"
      'redDiv = ->'
      '  return <div style={styles} />'
    ].join '\n'
  ,
    code: [
      'otherProps = { style: { color: "red" } }'
      '{ a, b, ...props } = otherProps'
      '<div {...props} />'
    ].join '\n'
  ,
    code: [
      "styles = Object.assign({ color: 'red' }, mystyles)"
      'React.createElement("div", { style: styles })'
    ].join '\n'
  ,
    code: '<div style></div>'
  ,
    code: [
      'React.createElement(MyCustomElem, {'
      '  [style]: true'
      "}, 'My custom Elem')"
    ].join '\n'
  ,
    code: ['style = null', '<div style={style}></div>'].join '\n'
  ,
    code: ['style = undefined', '<div style={style}></div>'].join '\n'
  ,
    code: '<div style={undefined}></div>'
  ,
    code: ['props = { style: undefined }', '<div {...props} />'].join '\n'
  ,
    code: [
      'otherProps = { style: undefined }'
      '{ a, b, ...props } = otherProps'
      '<div {...props} />'
    ].join '\n'
  ,
    code: ['React.createElement("div", {', '  style: undefined', '})'].join '\n'
  ,
    code: [
      'style = null'
      'React.createElement("div", {'
      '  style'
      '})'
    ].join '\n'
  ,
    code: '<div style={null}></div>'
  ,
    code: ['props = { style: null }', '<div {...props} />'].join '\n'
  ,
    code: [
      'otherProps = { style: null }'
      '{ a, b, ...props } = otherProps'
      '<div {...props} />'
    ].join '\n'
  ,
    code: ['React.createElement("div", {', '  style: null', '})'].join '\n'
  ,
    code: [
      'MyComponent = (props) =>'
      '  React.createElement(MyCustomElem, {'
      '    ...props'
      '  })'
    ].join '\n'
  ]
  invalid: [
    code: '<div style="color: \'red\'" />'
    errors: [
      message: 'Style prop value must be an object'
      line: 1
      column: 6
      type: 'JSXAttribute'
    ]
  ,
    code: '<Hello style="color: \'red\'" />'
    errors: [
      message: 'Style prop value must be an object'
      line: 1
      column: 8
      type: 'JSXAttribute'
    ]
  ,
    code: '<div style={true} />'
    errors: [
      message: 'Style prop value must be an object'
      line: 1
      column: 6
      type: 'JSXAttribute'
    ]
  ,
    code: [
      'styles = \'color: "red"\''
      'redDiv2 = ->'
      '  return <div style={styles} />'
    ].join '\n'
    errors: [
      message: 'Style prop value must be an object'
      line: 3
      column: 22
      type: 'Identifier'
    ]
  ,
    code: [
      'styles = \'color: "red"\''
      'redDiv2 = ->'
      '  return <Hello style={styles} />'
    ].join '\n'
    errors: [
      message: 'Style prop value must be an object'
      line: 3
      column: 24
      type: 'Identifier'
    ]
  ,
    code: [
      'styles = true'
      'redDiv = ->'
      '  return <div style={styles} />'
    ].join '\n'
    errors: [
      message: 'Style prop value must be an object'
      line: 3
      column: 22
      type: 'Identifier'
    ]
  ]
