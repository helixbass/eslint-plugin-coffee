###*
# @fileoverview Tests for no-debugger rule.
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/no-debugger'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-debugger', rule,
  valid: [
    '''
    test = { debugger: 1 }
    test.debugger
  '''
  ]
  invalid: [
    code: 'if foo then debugger'
    output: null
    errors: [messageId: 'unexpected', type: 'DebuggerStatement']
  ]
