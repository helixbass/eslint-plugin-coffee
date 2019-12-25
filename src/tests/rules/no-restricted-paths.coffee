path = require 'path'
{RuleTester} = require 'eslint'
rule = require 'eslint-plugin-import/lib/rules/no-restricted-paths'

{test, testFilePath} = require '../eslint-plugin-import-utils'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

getRelativeZonePath = (fixturePath) ->
  "./src/tests/fixtures/import/#{fixturePath}"

ruleTester.run 'no-restricted-paths', rule,
  valid: [
    test
      code: 'import a from "../client/a.coffee"'
      filename: testFilePath './restricted-paths/server/b.coffee'
      options: [
        zones: [
          target: getRelativeZonePath 'restricted-paths/server'
          from: getRelativeZonePath 'restricted-paths/other'
        ]
      ]
    test
      code: 'a = require("../client/a.coffee")'
      filename: testFilePath './restricted-paths/server/b.coffee'
      options: [
        zones: [
          target: getRelativeZonePath 'restricted-paths/server'
          from: getRelativeZonePath 'restricted-paths/other'
        ]
      ]
    test
      code: 'import b from "../server/b.coffee"'
      filename: testFilePath './restricted-paths/client/a.coffee'
      options: [
        zones: [
          target: getRelativeZonePath 'restricted-paths/client'
          from: getRelativeZonePath 'restricted-paths/other'
        ]
      ]

    # irrelevant function calls
    test code: 'notrequire("../server/b.coffee")'
    test
      code: 'notrequire("../server/b.coffee")'
      filename: testFilePath './restricted-paths/client/a.coffee'
      options: [
        zones: [
          target: getRelativeZonePath 'restricted-paths/client'
          from: getRelativeZonePath 'restricted-paths/server'
        ]
      ]

    # no config
    test code: 'require("../server/b.coffee")'
    test code: 'import b from "../server/b.coffee"'

    # builtin (ignore)
    test code: 'require("os")'
  ]

  invalid: [
    test
      code: 'import b from "../server/b.coffee"'
      filename: testFilePath './restricted-paths/client/a.coffee'
      options: [
        zones: [
          target: getRelativeZonePath 'restricted-paths/client'
          from: getRelativeZonePath 'restricted-paths/server'
        ]
      ]
      errors: [
        message:
          'Unexpected path "../server/b.coffee" imported in restricted zone.'
        line: 1
        column: 15
      ]
    test
      code: '''
        import a from "../client/a"
        import c from "./c"
      '''
      filename: testFilePath './restricted-paths/server/b.coffee'
      options: [
        zones: [
          target: getRelativeZonePath 'restricted-paths/server'
          from: getRelativeZonePath 'restricted-paths/client'
        ,
          target: getRelativeZonePath 'restricted-paths/server'
          from: getRelativeZonePath 'restricted-paths/server/c.coffee'
        ]
      ]
      errors: [
        message: 'Unexpected path "../client/a" imported in restricted zone.'
        line: 1
        column: 15
      ,
        message: 'Unexpected path "./c" imported in restricted zone.'
        line: 2
        column: 15
      ]
    test
      code: 'import b from "../server/b.coffee"'
      filename: testFilePath './restricted-paths/client/a.coffee'
      options: [
        zones: [target: './client', from: './server']
        basePath: testFilePath './restricted-paths'
      ]
      errors: [
        message:
          'Unexpected path "../server/b.coffee" imported in restricted zone.'
        line: 1
        column: 15
      ]
    test
      code: 'b = require("../server/b.coffee")'
      filename: testFilePath './restricted-paths/client/a.coffee'
      options: [
        zones: [
          target: getRelativeZonePath 'restricted-paths/client'
          from: getRelativeZonePath 'restricted-paths/server'
        ]
      ]
      errors: [
        message:
          'Unexpected path "../server/b.coffee" imported in restricted zone.'
        line: 1
        column: 13
      ]
  ]
