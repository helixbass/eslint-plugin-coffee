path = require 'path'
{test} = require '../eslint-plugin-import-utils'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-dynamic-require'

error =
  ruleId: 'no-dynamic-require'
  message: 'Calls to require() should use string literals'

### eslint-disable coffee/no-template-curly-in-string ###

ruleTester.run 'no-dynamic-require', rule,
  valid: [
    test code: 'import _ from "lodash"'
    test code: 'require("foo")'
    # test code: 'require(`foo`)'
    test code: 'require("./foo")'
    test code: 'require("@scope/foo")'
    test code: 'require()'
    test code: 'require("./foo", "bar" + "okay")'
    test code: 'foo = require("foo")'
    # test code: 'foo = require(`foo`)'
    test code: 'foo = require("./foo")'
    test code: 'foo = require("@scope/foo")'
  ]
  invalid: [
    test
      code: 'require("../" + name)'
      errors: [error]
    test
      code: 'require("../#{name}")'
      errors: [error]
    test
      code: 'require(name)'
      errors: [error]
    test
      code: 'require(name())'
      errors: [error]
    test
      code: 'require(name + "foo", "bar")'
      errors: [error]
  ]
