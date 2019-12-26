###*
# @fileoverview Tests for jsx-props-no-spreading
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
rule = require 'eslint-plugin-react/lib/rules/jsx-props-no-spreading'

# parserOptions =
#   ecmaVersion: 2018
#   sourceType: 'module'
#   ecmaFeatures:
#     jsx: yes

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
expectedError = message: 'Prop spreading is forbidden'

ruleTester.run 'jsx-props-no-spreading', rule,
  valid: [
    code: [
      '{one_prop, two_prop} = props'
      '<App one_prop={one_prop} two_prop={two_prop}/>'
    ].join '\n'
  ,
    code: [
      '{one_prop, two_prop} = props'
      '<div one_prop={one_prop} two_prop={two_prop}></div>'
    ].join '\n'
  ,
    code: [
      'newProps = {...props}'
      '<App one_prop={newProps.one_prop} two_prop={newProps.two_prop} style={{...styles}}/>'
    ].join '\n'
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '<App>'
      '   <Image {...props}/>'
      '   <img {...props}/>'
      '</App>'
    ].join '\n'
    options: [exceptions: ['Image', 'img']]
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '{ src, alt } = props'
      '<App>'
      '   <Image {...props}/>'
      '   <img src={src} alt={alt}/>'
      '</App>'
    ].join '\n'
    options: [custom: 'ignore']
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '{ src, alt } = props'
      '<App>'
      '   <Image {...props}/>'
      '   <img {...props}/>'
      '</App>'
    ].join '\n'
    options: [custom: 'enforce', html: 'ignore', exceptions: ['Image']]
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '{ src, alt } = props'
      '<App>'
      '   <img {...props}/>'
      '   <Image src={src} alt={alt}/>'
      '   <div {...someOtherProps}/>'
      '</App>'
    ].join '\n'
    options: [html: 'ignore']
  ,
    code: '''
      <App>
        <Foo {...{ prop1, prop2, prop3 }} />
      </App>
    '''
    options: [explicitSpread: 'ignore']
  ]

  invalid: [
    code: ['<App {...props}/>'].join '\n'
    errors: [expectedError]
  ,
    code: ['<div {...props}></div>'].join '\n'
    errors: [expectedError]
  ,
    code: ['<App {...props} some_other_prop={some_other_prop}/>'].join '\n'
    errors: [expectedError]
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '<App>'
      '   <Image {...props}/>'
      '   <span {...props}/>'
      '</App>'
    ].join '\n'
    options: [exceptions: ['Image', 'img']]
    errors: [expectedError]
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '{ src, alt } = props'
      '<App>'
      '   <Image {...props}/>'
      '   <img {...props}/>'
      '</App>'
    ].join '\n'
    options: [custom: 'ignore']
    errors: [expectedError]
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '{ src, alt } = props'
      '<App>'
      '   <Image {...props}/>'
      '   <img {...props}/>'
      '</App>'
    ].join '\n'
    options: [html: 'ignore', exceptions: ['Image', 'img']]
    errors: [expectedError]
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '{ src, alt } = props'
      '<App>'
      '   <Image {...props}/>'
      '   <img {...props}/>'
      '   <div {...props}/>'
      '</App>'
    ].join '\n'
    options: [custom: 'ignore', html: 'ignore', exceptions: ['Image', 'img']]
    errors: [expectedError, expectedError]
  ,
    code: [
      'props = {src: "dummy.jpg", alt: "dummy"}'
      '{ src, alt } = props'
      '<App>'
      '   <img {...props}/>'
      '   <Image {...props}/>'
      '</App>'
    ].join '\n'
    options: [html: 'ignore']
    errors: [expectedError]
  ,
    code: '''
      <App>
        <Foo {...{ prop1, prop2, prop3 }} />
      </App>
    '''
    errors: [expectedError]
  ,
    code: '''
      <App>
        <Foo {...{ prop1, ...rest }} />
      </App>
    '''
    options: [explicitSpread: 'ignore']
    errors: [expectedError]
  ,
    code: '''
      <App>
        <Foo {...{ ...props }} />
      </App>
    '''
    options: [explicitSpread: 'ignore']
    errors: [expectedError]
  ,
    code: '''
      <App>
        <Foo {...props } />
      </App>
    '''
    options: [explicitSpread: 'ignore']
    errors: [expectedError]
  ]
