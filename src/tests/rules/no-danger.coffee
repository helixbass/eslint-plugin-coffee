###*
# @fileoverview Tests for no-danger
# @author Scott Andrews
###

'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/no-danger'
{RuleTester} = require 'eslint'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-danger', rule,
  valid: [
    code: '<App />'
  ,
    code: '<App dangerouslySetInnerHTML={{ __html: "" }} />'
  ,
    code: '<div className="bar"></div>'
  ]
  invalid: [
    code: '<div dangerouslySetInnerHTML={{ __html: "" }}></div>'
    errors: [message: "Dangerous property 'dangerouslySetInnerHTML' found"]
  ]
