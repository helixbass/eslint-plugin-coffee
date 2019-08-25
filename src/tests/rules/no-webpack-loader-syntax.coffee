{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-webpack-loader-syntax'

message = 'Do not use import syntax to configure webpack loaders.'

ruleTester.run 'no-webpack-loader-syntax', rule,
  valid: [
    'import _ from "lodash"'
    'import find from "lodash.find"'
    'import foo from "./foo.css"'
    'import data from "@scope/my-package/data.json"'
    '_ = require("lodash")'
    'find = require("lodash.find")'
    'foo = require("./foo")'
    'foo = require("../foo")'
    'foo = require("foo")'
    'foo = require("./")'
    'foo = require("@scope/foo")'
  ]
  invalid: [
    code: 'import _ from "babel!lodash"'
    errors: [message: "Unexpected '!' in 'babel!lodash'. #{message}"]
  ,
    code: 'import find from "-babel-loader!lodash.find"'
    errors: [
      message: "Unexpected '!' in '-babel-loader!lodash.find'. #{message}"
    ]
  ,
    code: 'import foo from "style!css!./foo.css"'
    errors: [message: "Unexpected '!' in 'style!css!./foo.css'. #{message}"]
  ,
    code: 'import data from "json!@scope/my-package/data.json"'
    errors: [
      message: "Unexpected '!' in 'json!@scope/my-package/data.json'. #{message}"
    ]
  ,
    code: '_ = require("babel!lodash")'
    errors: [message: "Unexpected '!' in 'babel!lodash'. #{message}"]
  ,
    code: 'find = require("-babel-loader!lodash.find")'
    errors: [
      message: "Unexpected '!' in '-babel-loader!lodash.find'. #{message}"
    ]
  ,
    code: 'foo = require("style!css!./foo.css")'
    errors: [message: "Unexpected '!' in 'style!css!./foo.css'. #{message}"]
  ,
    code: 'data = require("json!@scope/my-package/data.json")'
    errors: [
      message: "Unexpected '!' in 'json!@scope/my-package/data.json'. #{message}"
    ]
  ]
