path = require 'path'
{test} = require '../eslint-plugin-import-utils'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-useless-path-segments'

runResolverTests = (resolver) ->
  ruleTester.run "no-useless-path-segments (#{resolver})", rule,
    valid: [
      # CommonJS modules with default options
      test code: 'require("./../import/malformed.koffee")'

      # ES modules with default options
      test code: 'import "./malformed.koffee"'
      test code: 'import "./test-module"'
      test code: 'import "./bar/"'
      test code: 'import "."'
      test code: 'import ".."'
      test code: 'import fs from "fs"'

      # ES modules + noUselessIndex
      test code: 'import "../index"'  # noUselessIndex is false by default
      test code: 'import "../my-custom-index"', options: [noUselessIndex: yes]
      test code: 'import "./bar.coffee"', options: [noUselessIndex: yes]  # ./bar/index.coffee exists
      test code: 'import "./bar"', options: [noUselessIndex: yes]
      test code: 'import "./bar/"', options: [noUselessIndex: yes]  # ./bar.coffee exists
      test code: 'import "./malformed.koffee"', options: [noUselessIndex: yes]  # ./malformed directory does not exist
      test code: 'import "./malformed"', options: [noUselessIndex: yes]  # ./malformed directory does not exist
      test code: 'import "./importType"', options: [noUselessIndex: yes]  # ./importType.coffee does not exist
      test
        code: 'import(".")'
        # parser: require.resolve 'babel-eslint'
      test
        code: 'import("..")'
        # parser: require.resolve 'babel-eslint'
      test
        code: 'import("fs").then((fs) ->)'
        # parser: require.resolve 'babel-eslint'
    ]

    invalid: [
      # CommonJS modules
      test
        code: 'require("./../import/malformed.koffee")'
        options: [commonjs: yes]
        errors: [
          'Useless path segments for "./../import/malformed.koffee", should be "../import/malformed.koffee"'
        ]
      test
        code: 'require("./../import/malformed")'
        options: [commonjs: yes]
        errors: [
          'Useless path segments for "./../import/malformed", should be "../import/malformed"'
        ]
      test
        code: 'require("../import/malformed.koffee")'
        options: [commonjs: yes]
        errors: [
          'Useless path segments for "../import/malformed.koffee", should be "./malformed.koffee"'
        ]
      test
        code: 'require("../import/malformed")'
        options: [commonjs: yes]
        errors: [
          'Useless path segments for "../import/malformed", should be "./malformed"'
        ]
      test
        code: 'require("./test-module/")'
        options: [commonjs: yes]
        errors: [
          'Useless path segments for "./test-module/", should be "./test-module"'
        ]
      test
        code: 'require("./")'
        options: [commonjs: yes]
        errors: ['Useless path segments for "./", should be "."']
      test
        code: 'require("../")'
        options: [commonjs: yes]
        errors: ['Useless path segments for "../", should be ".."']
      test
        code: 'require("./deep//a")'
        options: [commonjs: yes]
        errors: ['Useless path segments for "./deep//a", should be "./deep/a"']

      # CommonJS modules + noUselessIndex
      test
        code: 'require("./bar/index.coffee")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: [
          'Useless path segments for "./bar/index.coffee", should be "./bar/"'
        ]  # ./bar.coffee exists
      test
        code: 'require("./bar/index")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: ['Useless path segments for "./bar/index", should be "./bar/"']  # ./bar.coffee exists
      test
        code: 'require("./importPath/")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: [
          'Useless path segments for "./importPath/", should be "./importPath"'
        ]  # ./importPath.coffee does not exist
      test
        code: 'require("./importPath/index.coffee")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: [
          'Useless path segments for "./importPath/index.coffee", should be "./importPath"'
        ]  # ./importPath.coffee does not exist
      test
        code: 'require("./importType/index")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: [
          'Useless path segments for "./importType/index", should be "./importType"'
        ]  # ./importPath.coffee does not exist
      test
        code: 'require("./index")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: ['Useless path segments for "./index", should be "."']
      test
        code: 'require("../index")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: ['Useless path segments for "../index", should be ".."']
      test
        code: 'require("../index.coffee")'
        options: [commonjs: yes, noUselessIndex: yes]
        errors: ['Useless path segments for "../index.coffee", should be ".."']

      # ES modules
      test
        code: 'import "./../import/malformed.koffee"'
        errors: [
          'Useless path segments for "./../import/malformed.koffee", should be "../import/malformed.koffee"'
        ]
      test
        code: 'import "./../import/malformed"'
        errors: [
          'Useless path segments for "./../import/malformed", should be "../import/malformed"'
        ]
      test
        code: 'import "../import/malformed.koffee"'
        errors: [
          'Useless path segments for "../import/malformed.koffee", should be "./malformed.koffee"'
        ]
      test
        code: 'import "../import/malformed"'
        errors: [
          'Useless path segments for "../import/malformed", should be "./malformed"'
        ]
      test
        code: 'import "./test-module/"'
        errors: [
          'Useless path segments for "./test-module/", should be "./test-module"'
        ]
      test
        code: 'import "./"'
        errors: ['Useless path segments for "./", should be "."']
      test
        code: 'import "../"'
        errors: ['Useless path segments for "../", should be ".."']
      test
        code: 'import "./deep//a"'
        errors: ['Useless path segments for "./deep//a", should be "./deep/a"']

      # ES modules + noUselessIndex
      test
        code: 'import "./bar/index.coffee"'
        options: [noUselessIndex: yes]
        errors: [
          'Useless path segments for "./bar/index.coffee", should be "./bar/"'
        ]  # ./bar.coffee exists
      test
        code: 'import "./bar/index"'
        options: [noUselessIndex: yes]
        errors: ['Useless path segments for "./bar/index", should be "./bar/"']  # ./bar.coffee exists
      test
        code: 'import "./importPath/"'
        options: [noUselessIndex: yes]
        errors: [
          'Useless path segments for "./importPath/", should be "./importPath"'
        ]  # ./importPath.coffee does not exist
      test
        code: 'import "./importPath/index.coffee"'
        options: [noUselessIndex: yes]
        errors: [
          'Useless path segments for "./importPath/index.coffee", should be "./importPath"'
        ]  # ./importPath.coffee does not exist
      test
        code: 'import "./importPath/index"'
        options: [noUselessIndex: yes]
        errors: [
          'Useless path segments for "./importPath/index", should be "./importPath"'
        ]  # ./importPath.coffee does not exist
      test
        code: 'import "./index"'
        options: [noUselessIndex: yes]
        errors: ['Useless path segments for "./index", should be "."']
      test
        code: 'import "../index"'
        options: [noUselessIndex: yes]
        errors: ['Useless path segments for "../index", should be ".."']
      test
        code: 'import "../index.coffee"'
        options: [noUselessIndex: yes]
        errors: ['Useless path segments for "../index.coffee", should be ".."']
      test
        code: 'import("./")'
        errors: ['Useless path segments for "./", should be "."']
        # parser: require.resolve 'babel-eslint'
      test
        code: 'import("../")'
        errors: ['Useless path segments for "../", should be ".."']
        # parser: require.resolve 'babel-eslint'
      test
        code: 'import("./deep//a")'
        errors: ['Useless path segments for "./deep//a", should be "./deep/a"']
        # parser: require.resolve 'babel-eslint'
    ]

['node', 'webpack'].forEach runResolverTests
