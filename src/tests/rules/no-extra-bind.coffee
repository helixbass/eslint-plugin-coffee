###*
# @fileoverview Tests for no-extra-bind rule
# @author Bence Dányi <bence@danyi.me>
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-extra-bind'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
errors = [messageId: 'unexpected', type: 'CallExpression']

ruleTester.run 'no-extra-bind', rule,
  valid: [
    'a = ((b) -> b).bind(c, d)'
    'a = (-> @b)()'
    'a = do -> @b'
    'a = (-> this.b).foo()'
    'a = f.bind(a)'
    'a = (-> @b).bind(c)'
    'a = ((@b) ->).bind(c)'
  ,
    code: 'a = (=> b).bind(c, d)'
  ,
    '(-> (-> @b).bind @).bind(c)'
    'a = (-> 1)[bind](b)'
  ,
    # eslint-disable-next-line coffee/no-template-curly-in-string
    code: 'a = (-> 1)["bi#{n}d"](b)'
  ,
    code: 'a = (-> => @).bind(b)'
  ]
  invalid: [
    {
      code: 'a = (-> 1).bind(b)'
      output: 'a = (-> 1)'
      errors
    }
    # ,
    #   {
    #     code: 'a = (-> 1).bind(b++)'
    #     output: null
    #     errors
    #   }
    {
      code: "a = (-> 1)['bind'](b)"
      output: 'a = (-> 1)'
      errors
    }
    {
      code: 'a = (() => 1).bind(b)'
      output: 'a = (() => 1)'
      errors
    }
    {
      code: 'a = (() => @).bind(b)'
      output: 'a = (() => @)'
      errors
    }
    {
      code: 'a = (-> -> @c).bind(b)'
      output: 'a = (-> -> @c)'
      errors
    }
    {
      code: 'a = (-> c = -> @d).bind(b)'
      output: 'a = (-> c = -> @d)'
      errors
    }
  ,
    code:
      'a = (-> -> (-> @d).bind(c)).bind(b)'
    output:
      'a = (-> -> (-> @d).bind(c))'
    errors: [messageId: 'unexpected', type: 'CallExpression', column: 29]
  ]
