path = require 'path'
{RuleTester} = require 'eslint'
rule = require 'eslint-plugin-import/lib/rules/extensions'
{test, testFilePath} = require '../eslint-plugin-import-utils'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'extensions', rule,
  valid: [
    test code: 'import a from "a"'
    test code: 'import dot from "./file.with.dot"'
    test
      code: 'import a from "a/index.js"'
      options: ['always']
    test
      code: 'import dot from "./file.with.dot.coffee"'
      options: ['always']
    test
      code: [
        'import a from "a"'
        'import packageConfig from "./package.json"'
      ].join '\n'
      options: [json: 'always', js: 'never', coffee: 'never']
    # test
    #   code: [
    #     'import lib from "./bar"'
    #     'import component from "./bar.coffee"'
    #     'import data from "./bar.json"'
    #   ].join '\n'
    #   options: ['never']
    #   # settings: 'import/resolve': extensions: ['.js', '.jsx', '.json']

    test
      code: [
        'import bar from "./bar"'
        'import barjson from "./bar.json"'
        'import barhbs from "./bar.hbs"'
      ].join '\n'
      options: ['always', {js: 'never', jsx: 'never', coffee: 'never'}]
      # settings: 'import/resolve': extensions: ['.js', '.jsx', '.json', '.hbs']

    test
      code: [
        'import bar from "./bar.coffee"'
        'import pack from "./package"'
      ].join '\n'
      options: ['never', {js: 'always', coffee: 'always', json: 'never'}]
      # settings: 'import/resolve': extensions: ['.js', '.json']

    # unresolved (#271/#295)
    test code: 'import path from "path"'
    test code: 'import path from "path"', options: ['never']
    test code: 'import path from "path"', options: ['always']
    test code: 'import thing from "./fake-file.coffee"', options: ['always']
    test
      code: 'import thing from "non-package"'
      options: ['never']

    test
      code: '''
        import foo from './foo.coffee'
        import bar from './bar.json'
        import Component from './Component.coffee'
        import express from 'express'
      '''
      options: ['ignorePackages']

    test
      code: '''
        import foo from './foo.coffee'
        import bar from './bar.json'
        import Component from './Component.coffee'
        import express from 'express'
      '''
      options: ['always', {ignorePackages: yes}]

    test
      code: '''
        import foo from './foo'
        import bar from './bar'
        import Component from './Component'
        import express from 'express'
      '''
      options: ['never', {ignorePackages: yes}]

    test
      code: 'import exceljs from "exceljs"'
      options: ['always', {js: 'never', jsx: 'never', coffee: 'never'}]
      filename: testFilePath './internal-modules/plugins/plugin.coffee'
      settings:
        'import/resolver':
          node: extensions: ['.js', '.jsx', '.json', '.coffee']
          webpack: config: 'webpack.empty.config.js'

    # export (#964)
    test
      code: '''
        export { foo } from "./foo.coffee"
        bar = null
        export { bar }
      '''
      options: ['always']
    test
      code: '''
        export { foo } from "./foo"
        bar = null
        export { bar }
      '''
      options: ['never']
  ]

  invalid: [
    test
      code: 'import a from "a/index.js"'
      errors: [
        message:
          'Unexpected use of file extension "js" for "a/index.js"'
        line: 1
        column: 15
      ]
    test
      code: 'import a from "a"'
      options: ['always']
      errors: [
        message: 'Missing file extension "js" for "a"'
        line: 1
        column: 15
      ]
    test
      code: 'import dot from "./file.with.dot"'
      options: ['always']
      errors: [
        message: 'Missing file extension "coffee" for "./file.with.dot"'
        line: 1
        column: 17
      ]
    test
      code: [
        'import a from "a/index.js"'
        'import packageConfig from "./package"'
      ].join '\n'
      options: [json: 'always', js: 'never']
      # settings: 'import/resolve': extensions: ['.js', '.json']
      errors: [
        message: 'Unexpected use of file extension "js" for "a/index.js"'
        line: 1
        column: 15
      ,
        message: 'Missing file extension "json" for "./package"'
        line: 2
        column: 27
      ]
    test
      code: [
        'import lib from "./bar.coffee"'
        'import component from "./bar.jsx"'
        'import data from "./bar.json"'
      ].join '\n'
      options: ['never']
      # settings: 'import/resolve': extensions: ['.js', '.jsx', '.json']
      errors: [
        message: 'Unexpected use of file extension "coffee" for "./bar.coffee"'
        line: 1
        column: 17
      ]
    test
      code: [
        'import lib from "./bar.coffee"'
        'import component from "./bar.jsx"'
        'import data from "./bar.json"'
      ].join '\n'
      options: [json: 'always', coffee: 'never', jsx: 'never']
      # settings: 'import/resolve': extensions: ['.js', '.jsx', '.json']
      errors: [
        message: 'Unexpected use of file extension "coffee" for "./bar.coffee"'
        line: 1
        column: 17
      ]
    # extension resolve order (#583/#965)
    test
      code: [
        'import component from "./bar.coffee"'
        'import data from "./bar.json"'
      ].join '\n'
      options: [json: 'always', js: 'never', coffe: 'never']
      # settings: 'import/resolve': extensions: ['.jsx', '.json', '.js']
      errors: [
        message: 'Unexpected use of file extension "coffee" for "./bar.coffee"'
        line: 1
        column: 23
      ]
      # test
      #   code: 'import "./bar.coffee"'
      #   errors: [
      #     message: 'Unexpected use of file extension "coffee" for "./bar.coffee"'
      #     line: 1
      #     column: 8
      #   ]
      #   options: ['never', {js: 'always', jsx: 'always'}]
      #   settings: 'import/resolve': extensions: ['.coffee', '.js']

    test
      code: [
        'import barjs from "./bar.coffee"'
        'import barjson from "./bar.json"'
        'import barnone from "./bar"'
      ].join '\n'
      options: ['always', {json: 'always', coffee: 'never', jsx: 'never'}]
      # settings: 'import/resolve': extensions: ['.js', '.jsx', '.json']
      errors: [
        message: 'Unexpected use of file extension "coffee" for "./bar.coffee"'
        line: 1
        column: 19
      ]

    test
      code: [
        'import barjs from "./bar.coffee"'
        'import barjson from "./bar.json"'
        'import barnone from "./bar"'
      ].join '\n'
      options: ['never', {json: 'always', coffee: 'never', jsx: 'never'}]
      settings: 'import/resolve': extensions: ['.coffee', '.jsx', '.json']
      errors: [
        message: 'Unexpected use of file extension "coffee" for "./bar.coffee"'
        line: 1
        column: 19
      ]

    # unresolved (#271/#295)
    test
      code: 'import thing from "./fake-file.coffee"'
      options: ['never']
      errors: [
        message:
          'Unexpected use of file extension "coffee" for "./fake-file.coffee"'
        line: 1
        column: 19
      ]
    test
      code: 'import thing from "non-package"'
      options: ['always']
      errors: [
        message: 'Missing file extension for "non-package"'
        line: 1
        column: 19
      ]

    test
      # TODO: this just changed in https://github.com/benmosher/eslint-plugin-import/commit/e51773956a63a67eb510d34eb27d1d353b08bfd3#diff-31df74d3e97a4fa68663ab62d8351913
      # could use this version once a corresponding version of eslint-plugin-import is included/required?
      # code: '''
      #   import foo from './foo.coffee'
      #   import bar from './bar.json'
      #   import Component from './Component'
      #   import baz from 'foo/baz'
      #   import baw from '@scoped/baw/import'
      #   import express from 'express'
      # '''
      code: '''
        import foo from './foo.coffee'
        import bar from './bar.json'
        import Component from './Component'
        import express from 'express'
      '''
      options: ['always', {ignorePackages: yes}]
      errors: [
        message: 'Missing file extension for "./Component"'
        line: 3
        column: 23
      ]

    test
      # code: '''
      #   import foo from './foo.js'
      #   import bar from './bar.json'
      #   import Component from './Component'
      #   import baz from 'foo/baz'
      #   import baw from '@scoped/baw/import'
      #   import express from 'express'
      # '''
      code: '''
        import foo from './foo.coffee'
        import bar from './bar.json'
        import Component from './Component'
        import express from 'express'
      '''
      options: ['ignorePackages']
      errors: [
        message: 'Missing file extension for "./Component"'
        line: 3
        column: 23
      ]

    test
      code: '''
        import foo from './foo.coffee'
        import bar from './bar.json'
        import Component from './Component.coffee'
        import express from 'express'
      '''
      errors: [
        message: 'Unexpected use of file extension "coffee" for "./foo.coffee"'
        line: 1
        column: 17
      ,
        message:
          'Unexpected use of file extension "coffee" for "./Component.coffee"'
        line: 3
        column: 23
      ]
      options: ['never', {ignorePackages: yes}]

    # export (#964)
    test
      code: '''
        export { foo } from "./foo"
        bar = null
        export { bar }
      '''
      options: ['always']
      errors: [
        message: 'Missing file extension for "./foo"'
        line: 1
        column: 21
      ]
    test
      code: '''
        export { foo } from "./foo.coffee"
        bar = null
        export { bar }
      '''
      options: ['never']
      errors: [
        message: 'Unexpected use of file extension "coffee" for "./foo.coffee"'
        line: 1
        column: 21
      ]
  ]
