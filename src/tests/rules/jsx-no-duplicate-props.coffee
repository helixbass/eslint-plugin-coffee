###*
# @fileoverview Enforce no duplicate props
# @author Markus Ånöstam
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/jsx-no-duplicate-props'
{RuleTester} = require 'eslint'
path = require 'path'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError =
  message: 'No duplicate props allowed'
  type: 'JSXAttribute'

ignoreCaseArgs = [ignoreCase: yes]

ruleTester.run 'jsx-no-duplicate-props', rule,
  valid: [
    code: '<App />'
  ,
    code: '<App {...this.props} />'
  ,
    code: '<App a b c />'
  ,
    code: '<App a b c A />'
  ,
    code: '<App {...this.props} a b c />'
  ,
    code: '<App c {...this.props} a b />'
  ,
    code: '<App a="c" b="b" c="a" />'
  ,
    code: '<App {...this.props} a="c" b="b" c="a" />'
  ,
    code: '<App c="a" {...this.props} a="c" b="b" />'
  ,
    code: '<App A a />'
  ,
    code: '<App A b a />'
  ,
    code: '<App A="a" b="b" B="B" />'
    # ,
    #   code: '<App a:b="c" />', options: ignoreCaseArgs
  ]
  invalid: [
    code: '<App a a />', errors: [expectedError]
  ,
    code: '<App A b c A />', errors: [expectedError]
  ,
    code: '<App a="a" b="b" a="a" />', errors: [expectedError]
  ,
    code: '<App A a />', options: ignoreCaseArgs, errors: [expectedError]
  ,
    code: '<App a b c A />', options: ignoreCaseArgs, errors: [expectedError]
  ,
    code: '<App A="a" b="b" B="B" />'
    options: ignoreCaseArgs
    errors: [expectedError]
  ]
