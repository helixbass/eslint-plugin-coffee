path = require 'path'
{RuleTester} = require 'eslint'
rule = require 'eslint-plugin-import/lib/rules/no-internal-modules'

{test, testFilePath} = require '../eslint-plugin-import-utils'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-internal-modules', rule,
  valid: [
    test
      code: 'import a from "./plugin2"'
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
      options: []
    test
      code: 'a = require("./plugin2")'
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
    test
      code: 'a = require("./plugin2/")'
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
    test
      code: '''
        dynamic = "./plugin2/"
        a = require(dynamic)
      '''
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
    test
      code: 'import b from "./internal.coffee"'
      filename: testFilePath './internal-modules/plugins/plugin2/index.coffee'
    test
      code: 'import get from "lodash.get"'
      filename: testFilePath './internal-modules/plugins/plugin2/index.coffee'
    test
      code: 'import b from "@org/package"'
      filename: testFilePath(
        './internal-modules/plugins/plugin2/internal.coffee'
      )
    test
      code: 'import b from "../../api/service"'
      filename: testFilePath(
        './internal-modules/plugins/plugin2/internal.coffee'
      )
      options: [allow: ['**/api/*']]
    test
      code: 'import "jquery/dist/jquery"'
      filename: testFilePath(
        './internal-modules/plugins/plugin2/internal.coffee'
      )
      options: [allow: ['jquery/dist/*']]
    test
      code: '''
        import "./app/index.coffee"
        import "./app/index"
      '''
      filename: testFilePath(
        './internal-modules/plugins/plugin2/internal.coffee'
      )
      options: [allow: ['**/index{.coffee,}']]
  ]

  invalid: [
    test
      code: '''
        import "./plugin2/index.coffee"
        import "./plugin2/app/index"
      '''
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
      options: [allow: ['*/index.coffee']]
      errors: [
        message: 'Reaching to "./plugin2/app/index" is not allowed.'
        line: 2
        column: 8
      ]
    test
      code: 'import "./app/index.coffee"'
      filename: testFilePath(
        './internal-modules/plugins/plugin2/internal.coffee'
      )
      errors: [
        message: 'Reaching to "./app/index.coffee" is not allowed.'
        line: 1
        column: 8
      ]
    test
      code: 'import b from "./plugin2/internal"'
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
      errors: [
        message: 'Reaching to "./plugin2/internal" is not allowed.'
        line: 1
        column: 15
      ]
    test
      code: 'import a from "../api/service/index"'
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
      options: [allow: ['**/internal-modules/*']]
      errors: [
        message: 'Reaching to "../api/service/index" is not allowed.'
        line: 1
        column: 15
      ]
    test
      code: 'import b from "@org/package/internal"'
      filename: testFilePath(
        './internal-modules/plugins/plugin2/internal.coffee'
      )
      errors: [
        message: 'Reaching to "@org/package/internal" is not allowed.'
        line: 1
        column: 15
      ]
    test
      code: 'import get from "debug/node"'
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
      errors: [
        message: 'Reaching to "debug/node" is not allowed.'
        line: 1
        column: 17
      ]
  ]
