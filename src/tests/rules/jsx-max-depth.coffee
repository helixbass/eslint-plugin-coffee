###*
# @fileoverview Validate JSX maximum depth
# @author Chris<wfsr@foxmail.com>
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/jsx-max-depth'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-max-depth', rule,
  valid: [
    code: ['<App />'].join('\n')
  ,
    code: ['<App>', '  <foo />', '</App>'].join '\n'
    options: [max: 1]
  ,
    code: ['<App>', '  <foo>', '    <bar />', '  </foo>', '</App>'].join('\n')
  ,
    code: ['<App>', '  <foo>', '    <bar />', '  </foo>', '</App>'].join '\n'
    options: [max: 2]
  ,
    code: ['x = <div><em>x</em></div>', '<div>{x}</div>'].join '\n'
    options: [max: 2]
  ,
    code: 'foo = (x) => <div><em>{x}</em></div>'
    options: [max: 2]
  ,
    code: ['<></>'].join('\n')
  ,
    # parser: 'babel-eslint'
    code: ['<>', '  <foo />', '</>'].join '\n'
    # parser: 'babel-eslint'
    options: [max: 1]
  ,
    code: ['x = <><em>x</em></>', '<>{x}</>'].join '\n'
    # parser: 'babel-eslint'
    options: [max: 2]
  ]

  invalid: [
    code: ['<App>', '  <foo />', '</App>'].join '\n'
    options: [max: 0]
    errors: [
      message:
        'Expected the depth of nested jsx elements to be <= 0, but found 1.'
    ]
  ,
    code: ['<App>', '  <foo>{bar}</foo>', '</App>'].join '\n'
    options: [max: 0]
    errors: [
      message:
        'Expected the depth of nested jsx elements to be <= 0, but found 1.'
    ]
  ,
    code: ['<App>', '  <foo>', '    <bar />', '  </foo>', '</App>'].join '\n'
    options: [max: 1]
    errors: [
      message:
        'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    ]
  ,
    code: ['x = <div><span /></div>', '<div>{x}</div>'].join '\n'
    options: [max: 1]
    errors: [
      message:
        'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    ]
  ,
    code: ['x = <div><span /></div>', 'y = x', '<div>{y}</div>'].join '\n'
    options: [max: 1]
    errors: [
      message:
        'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    ]
  ,
    code: ['x = <div><span /></div>', 'y = x', '<div>{x}-{y}</div>'].join '\n'
    options: [max: 1]
    errors: [
      message:
        'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    ,
      message:
        'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    ]
  ,
    code: ['<div>', '{<div><div><span /></div></div>}', '</div>'].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message:
        'Expected the depth of nested jsx elements to be <= 2, but found 3.'
    ]
    # ,
    #   code: ['<>', '  <foo />', '</>'].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [max: 0]
    #   errors: [
    #     message:
    #       'Expected the depth of nested jsx elements to be <= 0, but found 1.'
    #   ]
    # ,
    #   code: ['<>', '  <>', '    <bar />', '  </>', '</>'].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [max: 1]
    #   errors: [
    #     message:
    #       'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    #   ]
    # ,
    #   code: ['x = <><span /></>', 'y = x', '<>{x}-{y}</>'].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [max: 1]
    #   errors: [
    #     message:
    #       'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    #   ,
    #     message:
    #       'Expected the depth of nested jsx elements to be <= 1, but found 2.'
    #   ]
  ]
