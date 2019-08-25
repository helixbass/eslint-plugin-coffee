{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-nodejs-modules'

test = (x) -> x
error = (message) ->
  {
    ruleId: 'no-nodejs-modules'
    message
  }

ruleTester.run 'no-nodejs-modules', rule,
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
    test
      code: 'import events from "events"'
      options: [allow: ['events']]
    test
      code: 'import path from "path"'
      options: [allow: ['path']]
    test
      code: 'events = require("events")'
      options: [allow: ['events']]
    test
      code: 'path = require("path")'
      options: [allow: ['path']]
    test
      code: '''
        import path from "path"
        import events from "events"
      '''
      options: [allow: ['path', 'events']]
  ]
  invalid: [
    test
      code: 'import path from "path"'
      errors: [error 'Do not import Node.js builtin module "path"']
    test
      code: 'import fs from "fs"'
      errors: [error 'Do not import Node.js builtin module "fs"']
    test
      code: 'path = require("path")'
      errors: [error 'Do not import Node.js builtin module "path"']
    test
      code: 'fs = require("fs")'
      errors: [error 'Do not import Node.js builtin module "fs"']
    test
      code: 'import fs from "fs"'
      options: [allow: ['path']]
      errors: [error 'Do not import Node.js builtin module "fs"']
  ]
