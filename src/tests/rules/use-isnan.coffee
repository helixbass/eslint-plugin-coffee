###*
# @fileoverview Tests for use-isnan rule.
# @author James Allardice, Michael Paulukonis
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/use-isnan'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------


ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'use-isnan', rule,
  valid: [
    "x = NaN",
    "isNaN(NaN) == true",
    "isNaN(123) != true",
    "isNaN(NaN) is true",
    "isNaN(123) isnt true",
    "Number.isNaN(NaN) == true",
    "Number.isNaN(123) != true",
    "foo(NaN + 1)",
    "foo(1 + NaN)",
    "foo(NaN - 1)",
    "foo(1 - NaN)",
    "foo(NaN * 2)",
    "foo(2 * NaN)",
    "foo(NaN / 2)",
    "foo(2 / NaN)",
    "yes if x = NaN"
  ],
  invalid: [
    {
      code: "123 == NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "123 is NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN is \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN == \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "123 != NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "123 isnt NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN isnt \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN != \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN < \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "\"abc\" < NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN > \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "\"abc\" > NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN <= \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "\"abc\" <= NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "NaN >= \"abc\"",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    },
    {
      code: "\"abc\" >= NaN",
      errors: [{ message: "Use the isNaN function to compare with NaN.", type: "BinaryExpression" }]
    }
  ]
