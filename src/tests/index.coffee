'use strict'

plugin = require '..'

assert = require 'assert'
fs = require 'fs'
path = require 'path'

ruleFiles = fs
.readdirSync path.resolve __dirname, '../rules/'
.map (f) -> path.basename f, '.js'

describe 'all rule files should be exported by the plugin', ->
  ruleFiles.forEach (ruleName) ->
    it "should export #{ruleName}", ->
      assert.equal(
        plugin.rules[ruleName]
        require path.join '../rules', ruleName
      )
