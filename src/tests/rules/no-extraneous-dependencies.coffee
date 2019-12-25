{test} = require '../eslint-plugin-import-utils'
path = require 'path'
fs = require 'fs'

{RuleTester} = require 'eslint'
ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-extraneous-dependencies'

getPackageDir = (dir) ->
  path.join __dirname, "../../../src/tests/fixtures/import/#{dir}"

packageDirWithSyntaxError = getPackageDir 'with-syntax-error'
packageFileWithSyntaxErrorMessage =
  (->
    try
      JSON.parse(
        fs.readFileSync path.join packageDirWithSyntaxError, 'package.json'
      )
    catch error then return error.message
  )()
# packageDirWithFlowTyped = path.join __dirname, '../../files/with-flow-typed'
packageDirMonoRepoRoot = getPackageDir 'monorepo'
packageDirMonoRepoWithNested = getPackageDir 'monorepo/packages/nested-package'
packageDirWithEmpty = getPackageDir 'empty'
packageDirBundleDeps = getPackageDir 'bundled-dependencies/as-array-bundle-deps'
packageDirBundledDepsAsObject = getPackageDir 'bundled-dependencies/as-object'
packageDirBundledDepsRaceCondition = getPackageDir(
  'bundled-dependencies/race-condition'
)

ruleTester.run 'no-extraneous-dependencies', rule,
  valid: [
    test code: 'import "lodash.cond"'
    test code: 'import "pkg-up"'
    test code: 'import foo, { bar } from "lodash.cond"'
    test code: 'import foo, { bar } from "pkg-up"'
    test code: 'import "eslint"'
    test code: 'import "eslint/lib/api"'
    test code: 'require("lodash.cond")'
    test code: 'require("pkg-up")'
    test code: 'foo = require("lodash.cond")'
    test code: 'foo = require("pkg-up")'
    test code: 'import "fs"'
    test code: 'import "./foo"'
    test code: 'import "lodash.isarray"'
    test code: 'import "@org/package"'

    test
      code: 'import "electron"', settings: 'import/core-modules': ['electron']
    test code: 'import "eslint"'
    test
      code: 'import "eslint"'
      options: [peerDependencies: yes]

    # 'project' type
    test
      code: 'import "importType"'
      settings:
        'import/resolver':
          node:
            paths: [getPackageDir '.']
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.spec.coffee']]
      filename: 'foo.spec.coffee'
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.spec.coffee']]
      filename: path.join process.cwd(), 'foo.spec.coffee'
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.test.coffee', '*.spec.coffee']]
      filename: path.join process.cwd(), 'foo.spec.coffee'
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.test.coffee', '*.spec.coffee']]
      filename: path.join process.cwd(), 'foo.spec.coffee'
    test code: 'require(6)'
    test
      code: 'import "doctrine"'
      options: [packageDir: path.join __dirname, '../../../']
    # test
    #   code: 'import type MyType from "myflowtyped";'
    #   options: [packageDir: packageDirWithFlowTyped]
    #   parser: require.resolve 'babel-eslint'
    test
      code: 'import react from "react"'
      options: [packageDir: packageDirMonoRepoWithNested]
    test
      code: 'import leftpad from "left-pad"'
      options: [
        packageDir: [packageDirMonoRepoWithNested, packageDirMonoRepoRoot]
      ]
    test
      code: 'import leftpad from "left-pad"'
      options: [packageDir: packageDirMonoRepoRoot]
    test
      code: 'import react from "react"'
      options: [
        packageDir: [packageDirMonoRepoRoot, packageDirMonoRepoWithNested]
      ]
    test
      code: 'import leftpad from "left-pad"'
      options: [
        packageDir: [packageDirMonoRepoRoot, packageDirMonoRepoWithNested]
      ]
    test
      code: 'import leftpad from "left-pad"'
      options: [
        packageDir: [packageDirMonoRepoWithNested, packageDirMonoRepoRoot]
      ]
    test
      code: 'import rightpad from "right-pad"'
      options: [
        packageDir: [packageDirMonoRepoRoot, packageDirMonoRepoWithNested]
      ]
    test code: 'import foo from "@generated/foo"'
    test
      code: 'import foo from "@generated/foo"'
      options: [packageDir: packageDirBundleDeps]
    test
      code: 'import foo from "@generated/foo"'
      options: [packageDir: packageDirBundledDepsAsObject]
    test
      code: 'import foo from "@generated/foo"'
      options: [packageDir: packageDirBundledDepsRaceCondition]
    test code: 'export { foo } from "lodash.cond"'
    test code: 'export * from "lodash.cond"'
    test code: 'export getToken = ->'
  ]
  invalid: [
    test
      code: 'import "not-a-dependency"'
      filename: path.join packageDirMonoRepoRoot, 'foo.coffee'
      options: [packageDir: packageDirMonoRepoRoot]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
    test
      code: 'import "not-a-dependency"'
      filename: path.join packageDirMonoRepoWithNested, 'foo.coffee'
      options: [packageDir: packageDirMonoRepoRoot]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
    test
      code: 'import "not-a-dependency"'
      options: [packageDir: packageDirMonoRepoRoot]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
    test
      code: 'import "not-a-dependency"'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
    test
      code: 'donthaveit = require("@org/not-a-dependency")'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'@org/not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S @org/not-a-dependency' to add it"
      ]
    test
      code: 'donthaveit = require("@org/not-a-dependency/foo")'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'@org/not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S @org/not-a-dependency' to add it"
      ]
    test
      code: 'import "eslint"'
      options: [devDependencies: no, peerDependencies: no]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'eslint' should be listed in the project's dependencies, not devDependencies."
      ]
    test
      code: 'import "lodash.isarray"'
      options: [optionalDependencies: no]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'lodash.isarray' should be listed in the project's dependencies, not optionalDependencies."
      ]
    test
      code: 'foo = require("not-a-dependency")'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
    test
      code: 'glob = require("glob")'
      options: [devDependencies: no]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'glob' should be listed in the project's dependencies, not devDependencies."
      ]
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.test.coffee']]
      filename: 'foo.tes.coffee'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'chai' should be listed in the project's dependencies, not devDependencies."
      ]
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.test.coffee']]
      filename: path.join process.cwd(), 'foo.tes.coffee'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'chai' should be listed in the project's dependencies, not devDependencies."
      ]
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.test.coffee', '*.spec.coffee']]
      filename: 'foo.tes.coffee'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'chai' should be listed in the project's dependencies, not devDependencies."
      ]
    test
      code: 'import chai from "chai"'
      options: [devDependencies: ['*.test.coffee', '*.spec.coffee']]
      filename: path.join process.cwd(), 'foo.tes.coffee'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'chai' should be listed in the project's dependencies, not devDependencies."
      ]
    test
      code: 'eslint = require("lodash.isarray")'
      options: [optionalDependencies: no]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'lodash.isarray' should be listed in the project's dependencies, not optionalDependencies."
      ]
    test
      code: 'import "not-a-dependency"'
      options: [packageDir: path.join __dirname, '../../../']
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
    test
      code: 'import "bar"'
      options: [packageDir: path.join __dirname, './doesn-exist/']
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message: 'The package.json file could not be found.'
      ]
    test
      code: 'import foo from "foo"'
      options: [packageDir: packageDirWithSyntaxError]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message: "The package.json file could not be parsed: #{packageFileWithSyntaxErrorMessage}"
      ]
    test
      code: 'import leftpad from "left-pad"'
      filename: path.join packageDirMonoRepoWithNested, 'foo.coffee'
      options: [packageDir: packageDirMonoRepoWithNested]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'left-pad' should be listed in the project's dependencies. Run 'npm i -S left-pad' to add it"
      ]
    test
      code: 'import react from "react"'
      filename: path.join packageDirMonoRepoRoot, 'foo.coffee'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'react' should be listed in the project's dependencies. Run 'npm i -S react' to add it"
      ]
    test
      code: 'import react from "react"'
      filename: path.join packageDirMonoRepoWithNested, 'foo.coffee'
      options: [packageDir: packageDirMonoRepoRoot]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'react' should be listed in the project's dependencies. Run 'npm i -S react' to add it"
      ]
    test
      code: 'import "react"'
      filename: path.join packageDirWithEmpty, 'index.coffee'
      options: [packageDir: packageDirWithEmpty]
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'react' should be listed in the project's dependencies. Run 'npm i -S react' to add it"
      ]
    test
      code: 'import bar from "@generated/bar"'
      errors: [
        "'@generated/bar' should be listed in the project's dependencies. Run 'npm i -S @generated/bar' to add it"
      ]
    test
      code: 'import foo from "@generated/foo"'
      options: [bundledDependencies: no]
      errors: [
        "'@generated/foo' should be listed in the project's dependencies. Run 'npm i -S @generated/foo' to add it"
      ]
    test
      code: 'import bar from "@generated/bar"'
      options: [packageDir: packageDirBundledDepsRaceCondition]
      errors: [
        "'@generated/bar' should be listed in the project's dependencies. Run 'npm i -S @generated/bar' to add it"
      ]
    test
      code: 'export { foo } from "not-a-dependency"'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
    test
      code: 'export * from "not-a-dependency"'
      errors: [
        ruleId: 'no-extraneous-dependencies'
        message:
          "'not-a-dependency' should be listed in the project's dependencies. Run 'npm i -S not-a-dependency' to add it"
      ]
  ]
