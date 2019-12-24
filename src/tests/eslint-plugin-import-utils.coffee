path = require 'path'
{default: eslintPkg} = require 'eslint/package.json'
{default: semver} = require 'semver'
{mergeWith} = require 'lodash'

# warms up the module cache. this import takes a while (>500ms)
# import 'babel-eslint'

exports.testFilePath = testFilePath = (relativePath) ->
  path.join process.cwd(), './src/tests/fixtures/import', relativePath

exports.getTSParsers = getTSParsers = ->
  parsers = []
  if semver.satisfies eslintPkg.version, '>=4.0.0 <6.0.0'
    parsers.push require.resolve 'typescript-eslint-parser'

  if semver.satisfies eslintPkg.version, '>5.0.0'
    parsers.push require.resolve '@typescript-eslint/parser'
  parsers

exports.getNonDefaultParsers = ->
  getTSParsers().concat require.resolve 'babel-eslint'

exports.FILENAME = FILENAME = testFilePath 'foo.coffee'

exports.testVersion = (specifier, t) ->
  semver.satisfies(eslintPkg.version, specifier) and test t()

exports.test = test = (t) ->
  mergeWith
    filename: FILENAME
    settings:
      'import/extensions': ['.coffee', '.js', '.jsx']
      'import/parsers':
        # 'eslint-plugin-coffee/lib/parser': ['.coffee']
        '../../lib/parser': ['.coffee', '.koffee']
      'import/resolver':
        node:
          extensions: ['.coffee', '.js', '.jsx']
  ,
    t
    # parserOptions: Object.assign(
    #   sourceType: 'module'
    #   ecmaVersion: 6
    # ,
    #   t.parserOptions
    # )
    (a, b, key) ->
      return unless key is 'import/resolver'
      return if b.node?
      # allow webpack import/resolver to "replace" node default
      b

exports.testContext = (settings) ->
  getFilename: -> FILENAME
  settings: settings or {}

exports.getFilename = (file) ->
  path.join __dirname, '..', 'files', file or 'foo.js'

###*
# to be added as valid cases just to ensure no nullable fields are going
# to crash at runtime
# @type {Array}
###
exports.SYNTAX_CASES = [
  test code: 'for { foo, bar } from baz then ;'
  test code: 'for [ foo, bar ] from baz then ;'

  test code: '{ x, y } = bar'
  test
    code: '{ x, y, ...z } = bar'  #, parser: require.resolve 'babel-eslint'

  # all the exports
  test
    code: '''
      x = null
      export { x }
    '''
  test
    code: '''
      x = null
      export { x as y }
    '''

  # not sure about these since they reference a file
  # test({ code: 'export { x } from "./y.js"'}),
  # test({ code: 'export * as y from "./y.js"', parser: require.resolve('babel-eslint')}),

  test code: 'export x = null'
  # test code: 'export var x = null'
  # test code: 'export let x = null'

  test code: 'export default x'
  test code: 'export default class x'

  # issue #267: parser opt-in extension list
  test
    code: 'import json from "./data.json"'
    settings: 'import/extensions': ['.coffee']  # breaking: remove for v2

  # JSON
  test
    code: 'import foo from "./foobar.json"'
    settings: 'import/extensions': ['.coffee']  # breaking: remove for v2
  # test
  #   code: 'import foo from "./foobar"'
  #   settings: 'import/extensions': ['.coffee']  # breaking: remove for v2

  # issue #370: deep commonjs import
  test
    code: 'import { foo } from "./issue-370-commonjs-namespace/bar"'
    settings: 'import/ignore': ['foo']

  # issue #348: deep commonjs re-export
  test
    code: 'export * from "./issue-370-commonjs-namespace/bar"'
    settings: 'import/ignore': ['foo']

  test
    code: '''
      import * as a from "./commonjs-namespace/a"
      a.b
    '''

  # ignore invalid extensions
  test code: 'import { foo } from "./ignore.invalid.extension"'
]
