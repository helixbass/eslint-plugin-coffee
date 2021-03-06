path = require 'path'
{test, testFilePath} = require '../eslint-plugin-import-utils'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-self-import'

error =
  ruleId: 'no-self-import'
  message: 'Module imports itself.'

ruleTester.run 'no-self-import', rule,
  valid: [
    test
      code: 'import _ from "lodash"'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'import find from "lodash.find"'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'import foo from "./foo"'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'import foo from "../foo"'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'import foo from "foo"'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'import foo from "./"'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'import foo from "@scope/foo"'
      filename: testFilePath './no-self-import.coffee'
    test
      code: '_ = require("lodash")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'find = require("lodash.find")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'foo = require("./foo")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'foo = require("../foo")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'foo = require("foo")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'foo = require("./")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'foo = require("@scope/foo")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'bar = require("./bar/index")'
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'bar = require("./bar")'
      filename: testFilePath './bar/index.coffee'
    test
      code: 'bar = require("./bar")'
      filename: '<text>'
  ]
  invalid: [
    test
      code: 'import bar from "./no-self-import"'
      errors: [error]
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'bar = require("./no-self-import")'
      errors: [error]
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'bar = require("./no-self-import.coffee")'
      errors: [error]
      filename: testFilePath './no-self-import.coffee'
    test
      code: 'bar = require(".")'
      errors: [error]
      filename: testFilePath './index.coffee'
    test
      code: 'bar = require("./")'
      errors: [error]
      filename: testFilePath './index.coffee'
    test
      code: 'bar = require("././././")'
      errors: [error]
      filename: testFilePath './index.coffee'
    test
      code: 'bar = require("../no-self-import-folder")'
      errors: [error]
      filename: testFilePath './no-self-import-folder/index.coffee'
  ]
