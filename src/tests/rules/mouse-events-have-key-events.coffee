### eslint-env jest ###
###*
# @fileoverview Enforce onmouseover/onmouseout are accompanied
#  by onfocus/onblur.
# @author Ethan Cohen
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/mouse-events-have-key-events'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

mouseOverError =
  message: 'onMouseOver must be accompanied by onFocus for accessibility.'
  type: 'JSXOpeningElement'
mouseOutError =
  message: 'onMouseOut must be accompanied by onBlur for accessibility.'
  type: 'JSXOpeningElement'

ruleTester.run 'mouse-events-have-key-events', rule,
  valid: [
    code: '<div onMouseOver={() => undefined} onFocus={() => undefined} />'
  ,
    code:
      '<div onMouseOver={() => undefined} onFocus={() => undefined} {...props} />'
  ,
    code: '<div onMouseOver={handleMouseOver} onFocus={handleFocus} />'
  ,
    code:
      '<div onMouseOver={handleMouseOver} onFocus={handleFocus} {...props} />'
  ,
    code: '<div />'
  ,
    code: '<div onMouseOut={() => undefined} onBlur={() => undefined} />'
  ,
    code:
      '<div onMouseOut={() => undefined} onBlur={() => undefined} {...props} />'
  ,
    code: '<div onMouseOut={handleMouseOut} onBlur={handleOnBlur} />'
  ,
    code: '<div onMouseOut={handleMouseOut} onBlur={handleOnBlur} {...props} />'
  ].map parserOptionsMapper
  invalid: [
    code: '<div onMouseOver={() => undefined} />', errors: [mouseOverError]
  ,
    code: '<div onMouseOut={() => undefined} />', errors: [mouseOutError]
  ,
    code: '<div onMouseOver={() => undefined} onFocus={undefined} />'
    errors: [mouseOverError]
  ,
    code: '<div onMouseOut={() => undefined} onBlur={undefined} />'
    errors: [mouseOutError]
  ,
    code: '<div onMouseOver={() => undefined} {...props} />'
    errors: [mouseOverError]
  ,
    code: '<div onMouseOut={() => undefined} {...props} />'
    errors: [mouseOutError]
  ].map parserOptionsMapper
