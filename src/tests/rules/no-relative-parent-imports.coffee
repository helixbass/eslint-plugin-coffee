path = require 'path'
{RuleTester} = require 'eslint'
rule = require 'eslint-plugin-import/lib/rules/no-relative-parent-imports'
{test: _test, testFilePath} = require '../eslint-plugin-import-utils'

test = (def) ->
  _test(
    Object.assign def,
      filename: testFilePath './internal-modules/plugins/plugin2/index.coffee'
      # parser: require.resolve 'babel-eslint'
  )

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-relative-parent-imports', rule,
  valid: [
    test code: 'import foo from "./internal.coffee"'
    test code: 'import foo from "./app/index.coffee"'
    test code: 'import foo from "package"'
    test
      code: 'require("./internal.coffee")'
      options: [commonjs: yes]
    test
      code: 'require("./app/index.coffee")'
      options: [commonjs: yes]
    test
      code: 'require("package")'
      options: [commonjs: yes]
    test code: 'import("./internal.coffee")'
    test code: 'import("./app/index.coffee")'
    test code: 'import(".")'
    test code: 'import("path")'
    test code: 'import("package")'
    test code: 'import("@scope/package")'
  ]

  invalid: [
    test
      code: 'import foo from "../plugin.coffee"'
      errors: [
        message:
          "Relative imports from parent directories are not allowed. Please either pass what you're importing through at runtime (dependency injection), move `index.coffee` to same directory as `../plugin.coffee` or consider making `../plugin.coffee` a package."
        line: 1
        column: 17
      ]
    test
      code: 'require("../plugin.coffee")'
      options: [commonjs: yes]
      errors: [
        message:
          "Relative imports from parent directories are not allowed. Please either pass what you're importing through at runtime (dependency injection), move `index.coffee` to same directory as `../plugin.coffee` or consider making `../plugin.coffee` a package."
        line: 1
        column: 9
      ]
    test
      code: 'import("../plugin.coffee")'
      errors: [
        message:
          "Relative imports from parent directories are not allowed. Please either pass what you're importing through at runtime (dependency injection), move `index.coffee` to same directory as `../plugin.coffee` or consider making `../plugin.coffee` a package."
        line: 1
        column: 8
      ]
    test
      code: 'import foo from "./../plugin.coffee"'
      errors: [
        message:
          "Relative imports from parent directories are not allowed. Please either pass what you're importing through at runtime (dependency injection), move `index.coffee` to same directory as `./../plugin.coffee` or consider making `./../plugin.coffee` a package."
        line: 1
        column: 17
      ]
    test
      code: 'import foo from "../../api/service"'
      errors: [
        message:
          "Relative imports from parent directories are not allowed. Please either pass what you're importing through at runtime (dependency injection), move `index.coffee` to same directory as `../../api/service` or consider making `../../api/service` a package."
        line: 1
        column: 17
      ]
    test
      code: 'import("../../api/service")'
      errors: [
        message:
          "Relative imports from parent directories are not allowed. Please either pass what you're importing through at runtime (dependency injection), move `index.coffee` to same directory as `../../api/service` or consider making `../../api/service` a package."
        line: 1
        column: 8
      ]
  ]
