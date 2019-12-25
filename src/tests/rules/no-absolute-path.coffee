path = require 'path'
{test} = require '../eslint-plugin-import-utils'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-absolute-path'

error =
  ruleId: 'no-absolute-path'
  message: 'Do not import modules using an absolute path'

ruleTester.run 'no-absolute-path', rule,
  valid: [
    test code: 'import _ from "lodash"'
    test code: 'import find from "lodash.find"'
    test code: 'import foo from "./foo"'
    test code: 'import foo from "../foo"'
    test code: 'import foo from "foo"'
    test code: 'import foo from "./"'
    test code: 'import foo from "@scope/foo"'
    test code: '_ = require("lodash")'
    test code: 'find = require("lodash.find")'
    test code: 'foo = require("./foo")'
    test code: 'foo = require("../foo")'
    test code: 'foo = require("foo")'
    test code: 'foo = require("./")'
    test code: 'foo = require("@scope/foo")'

    test code: 'import events from "events"'
    test code: 'import path from "path"'
    test code: 'events = require("events")'
    test code: 'path = require("path")'
    test
      code: '''
        import path from "path"
        import events from "events"
      '''

    # still works if only `amd: true` is provided
    test
      code: 'import path from "path"'
      options: [amd: yes]

    # amd not enabled by default
    test code: 'require(["/some/path"], (f) -> ### ... ###)'
    test code: 'define(["/some/path"], (f) -> ### ... ###)'
    test
      code: 'require(["./some/path"], (f) -> ### ... ###)'
      options: [amd: yes]
    test
      code: 'define(["./some/path"], (f) -> ### ... ###)'
      options: [amd: yes]
  ]
  invalid: [
    test
      code: 'import f from "/foo"'
      errors: [error]
    test
      code: 'import f from "/foo/path"'
      errors: [error]
    test
      code: 'import f from "/some/path"'
      errors: [error]
    test
      code: 'import f from "/some/path"'
      options: [amd: yes]
      errors: [error]
    test
      code: 'f = require("/foo")'
      errors: [error]
    test
      code: 'f = require("/foo/path")'
      errors: [error]
    test
      code: 'f = require("/some/path")'
      errors: [error]
    test
      code: 'f = require("/some/path")'
      options: [amd: yes]
      errors: [error]
    # validate amd
    test
      code: 'require(["/some/path"], (f) -> ### ... ###)'
      options: [amd: yes]
      errors: [error]
    test
      code: 'define(["/some/path"], (f) -> ### ... ###)'
      options: [amd: yes]
      errors: [error]
  ]
