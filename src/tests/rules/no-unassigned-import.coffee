{test} = require '../eslint-plugin-import-utils'
path = require 'path'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-unassigned-import'

error =
  ruleId: 'no-unassigned-import'
  message: 'Imported module should be assigned'

ruleTester.run 'no-unassigned-import', rule,
  valid: [
    test code: 'import _ from "lodash"'
    test code: 'import _, {foo} from "lodash"'
    test code: 'import _, {foo as bar} from "lodash"'
    test code: 'import {foo as bar} from "lodash"'
    test code: 'import * as _ from "lodash"'
    test code: 'import _ from "./"'
    test code: '_ = require("lodash")'
    test code: '{foo} = require("lodash")'
    test code: '{foo: bar} = require("lodash")'
    test code: '[a, b] = require("lodash")'
    test code: '_ = require("lodash")'
    test code: '_ = require("./")'
    test code: 'foo(require("lodash"))'
    test code: 'require("lodash").foo'
    test code: 'require("lodash").foo()'
    test code: 'require("lodash")()'
    test
      code: 'import "app.css"'
      options: [allow: ['**/*.css']]
    test
      code: 'import "app.css"'
      options: [allow: ['*.css']]
    test
      code: 'import "./app.css"'
      options: [allow: ['**/*.css']]
    test
      code: 'import "foo/bar"'
      options: [allow: ['foo/**']]
    test
      code: 'import "foo/bar"'
      options: [allow: ['foo/bar']]
    test
      code: 'import "../dir/app.css"'
      options: [allow: ['**/*.css']]
    test
      code: 'import "../dir/app.coffee"'
      options: [allow: ['**/dir/**']]
    test
      code: 'require("./app.css")'
      options: [allow: ['**/*.css']]
    test
      code: 'import "babel-register"'
      options: [allow: ['babel-register']]
    test
      code: 'import "./styles/app.css"'
      options: [allow: ['src/styles/**']]
      filename: path.join process.cwd(), 'src/app.coffee'
    test
      code: 'import "../scripts/register.coffee"'
      options: [allow: ['src/styles/**', '**/scripts/*.coffee']]
      filename: path.join process.cwd(), 'src/app.coffee'
  ]
  invalid: [
    test
      code: 'import "lodash"'
      errors: [error]
    test
      code: 'require("lodash")'
      errors: [error]
    test
      code: 'import "./app.css"'
      options: [allow: ['**/*.coffee']]
      errors: [error]
    test
      code: 'import "./app.css"'
      options: [allow: ['**/dir/**']]
      errors: [error]
    test
      code: 'require("./app.css")'
      options: [allow: ['**/*.coffee']]
      errors: [error]
    test
      code: 'import "./styles/app.css"'
      options: [allow: ['styles/*.css']]
      filename: path.join process.cwd(), 'src/app.coffee'
      errors: [error]
  ]
