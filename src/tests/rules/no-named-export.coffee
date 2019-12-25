path = require 'path'
{RuleTester} = require 'eslint'
{test} = require '../eslint-plugin-import-utils'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require '../../rules/no-named-export'

ruleTester.run 'no-named-export', rule,
  valid: [
    test code: 'export default bar = ->'
    test
      code: '''
      foo = null
      export { foo as default }
    '''
    # test
    #   code: 'export default from "foo.js"'
    #   parser: require.resolve 'babel-eslint'

    # no exports at all
    test code: "import * as foo from './foo'"
    test code: "import foo from './foo'"
    test code: "import {default as foo} from './foo'"
  ]
  invalid: [
    test
      code: '''
        export foo = 'foo'
        export bar = 'bar'
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ,
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
    test
      code: '''
        export foo = 'foo'
        export default bar
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
    test
      code: '''
        export foo = 'foo'
        export bar = ->
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ,
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
    test
      code: "export foo = 'foo'"
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
    test
      code: '''
        foo = 'foo'
        export { foo }
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
    test
      code: '''
        foo = null
        bar = null
        export { foo, bar }
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
    # TODO: these can be uncommented once Coffeescript supports this syntax
    # test
    #   code: 'export { foo, bar } = item'
    #   errors: [
    #     ruleId: 'ExportNamedDeclaration'
    #     message: 'Named exports are not allowed.'
    #   ]
    # test
    #   code: 'export { foo, bar: baz } = item'
    #   errors: [
    #     ruleId: 'ExportNamedDeclaration'
    #     message: 'Named exports are not allowed.'
    #   ]
    # test
    #   code: 'export { foo: { bar, baz } } = item'
    #   errors: [
    #     ruleId: 'ExportNamedDeclaration'
    #     message: 'Named exports are not allowed.'
    #   ]
    test
      code: '''
        item = null
        export foo = item
        export { item }
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ,
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
    test
      code: "export * from './foo'"
      errors: [
        ruleId: 'ExportAllDeclaration'
        message: 'Named exports are not allowed.'
      ]
    # test
    #   code: 'export { foo } = { foo: "bar" }'
    #   errors: [
    #     ruleId: 'ExportNamedDeclaration'
    #     message: 'Named exports are not allowed.'
    #   ]
    # test
    #   code: 'export { foo: { bar } } = { foo: { bar: "baz" } }'
    #   errors: [
    #     ruleId: 'ExportNamedDeclaration'
    #     message: 'Named exports are not allowed.'
    #   ]
    test
      code: 'export { a, b } from "foo.js"'
      # parser: require.resolve 'babel-eslint'
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Named exports are not allowed.'
      ]
      # test
      #   code: 'export type UserId = number;'
      #   parser: require.resolve 'babel-eslint'
      #   errors: [
      #     ruleId: 'ExportNamedDeclaration'
      #     message: 'Named exports are not allowed.'
      #   ]
      # test
      #   code: 'export foo from "foo.js"'
      #   parser: require.resolve 'babel-eslint'
      #   errors: [
      #     ruleId: 'ExportNamedDeclaration'
      #     message: 'Named exports are not allowed.'
      #   ]
      # test
      #   code: "export Memory, { MemoryValue } from './Memory'"
      #   parser: require.resolve 'babel-eslint'
      #   errors: [
      #     ruleId: 'ExportNamedDeclaration'
      #     message: 'Named exports are not allowed.'
      #   ]
  ]
