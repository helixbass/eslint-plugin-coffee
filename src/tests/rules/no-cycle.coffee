path = require 'path'
{test: _test, testFilePath} = require '../eslint-plugin-import-utils'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-cycle'

error = (message) -> {ruleId: 'no-cycle', message}

test = (def) ->
  _test Object.assign def, filename: testFilePath './cycles/depth-zero.coffee'

# describe.only("no-cycle", () => {
ruleTester.run 'no-cycle', rule,
  valid: [
    # this rule doesn't care if the cycle length is 0
    test code: 'import foo from "./foo.coffee"'

    test code: 'import _ from "lodash"'
    test code: 'import foo from "@scope/foo"'
    test code: '_ = require("lodash")'
    test code: 'find = require("lodash.find")'
    test code: 'foo = require("./foo")'
    test code: 'foo = require("../foo")'
    test code: 'foo = require("foo")'
    test code: 'foo = require("./")'
    test code: 'foo = require("@scope/foo")'
    test code: 'bar = require("./bar/index")'
    test code: 'bar = require("./bar")'
    test
      code: 'bar = require("./bar")'
      filename: '<text>'
    test
      code: 'import { foo } from "./depth-two"'
      options: [maxDepth: 1]
    test
      code: 'import { foo, bar } from "./depth-two"'
      options: [maxDepth: 1]
    test
      code: 'import("./depth-two").then(({ foo }) ->)'
      options: [maxDepth: 1]
      # parser: require.resolve 'babel-eslint'
      # test
      #   code: 'import type { FooType } from "./depth-one"'
      #   parser: require.resolve 'babel-eslint'
      # test
      #   code: 'import type { FooType, BarType } from "./depth-one"'
      #   parser: require.resolve 'babel-eslint'
      # test
      #   code: 'import { bar } from "./flow-types"'
      #   parser: require.resolve 'babel-eslint'
  ]
  invalid: [
    test
      code: 'import { foo } from "./depth-one"'
      errors: [error 'Dependency cycle detected.']
    test
      code: 'import { foo } from "./depth-one"'
      options: [maxDepth: 1]
      errors: [error 'Dependency cycle detected.']
    test
      code: '{ foo } = require("./depth-one")'
      errors: [error 'Dependency cycle detected.']
      options: [commonjs: yes]
    test
      code: 'require(["./depth-one"], (d1) => {})'
      errors: [error 'Dependency cycle detected.']
      options: [amd: yes]
    test
      code: 'define(["./depth-one"], (d1) => {})'
      errors: [error 'Dependency cycle detected.']
      options: [amd: yes]
    test
      code: 'import { foo } from "./depth-two"'
      errors: [error 'Dependency cycle via ./depth-one:1']
    test
      code: 'import { foo } from "./depth-two"'
      options: [maxDepth: 2]
      errors: [error 'Dependency cycle via ./depth-one:1']
    test
      code: '{ foo } = require("./depth-two")'
      errors: [error 'Dependency cycle via ./depth-one:1']
      options: [commonjs: yes]
    test
      code: 'import { two } from "./depth-three-star"'
      errors: [error 'Dependency cycle via ./depth-two:1=>./depth-one:1']
    test
      code: 'import one, { two, three } from "./depth-three-star"'
      errors: [error 'Dependency cycle via ./depth-two:1=>./depth-one:1']
    test
      code: 'import { bar } from "./depth-three-indirect"'
      errors: [error 'Dependency cycle via ./depth-two:1=>./depth-one:1']
      # test
      #   code: 'import { bar } from "./depth-three-indirect"'
      #   errors: [error 'Dependency cycle via ./depth-two:1=>./depth-one:1']
      #   parser: require.resolve 'babel-eslint'
    test
      code: 'import("./depth-three-star")'
      errors: [error 'Dependency cycle via ./depth-two:1=>./depth-one:1']
      # parser: require.resolve 'babel-eslint'
    test
      code: 'import("./depth-three-indirect")'
      errors: [error 'Dependency cycle via ./depth-two:1=>./depth-one:1']
      # parser: require.resolve 'babel-eslint'
      # test
      #   code: 'import { bar } from "./flow-types-depth-one"'
      #   parser: require.resolve 'babel-eslint'
      #   errors: [
      #     error 'Dependency cycle via ./flow-types-depth-two:4=>./depth-one:1'
      #   ]
  ]
# })
