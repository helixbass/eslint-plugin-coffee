# import {test} from '../utils'

{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/prefer-default-export'

test = (x) -> x

ruleTester.run 'prefer-default-export', rule,
  valid: [
    test
      code: '''
        export foo = 'foo'
        export bar = 'bar'
      '''
    test
      code: '''
        export default bar = ->
      '''
    test
      code: '''
        export foo = 'foo'
        export bar = ->
      '''
    test
      code: '''
        export foo = 'foo'
        export default bar
      '''
    # test
    #   code: """
    #     export { foo, bar }
    #   """
    # test
    #   code: """
    #     export { foo, bar } = item
    #    """
    # test
    #   code: """
    #     export { foo, bar: baz } = item
    #   """
    # test
    #   code: """
    #     export { foo: { bar, baz } } = item
    #   """
    test
      code: '''
        export foo = item
        export { item }
      '''
    test
      code: '''
        export { foo as default }
      '''
    test
      code: '''
        export * from './foo'
      '''
    # test
    #   code: "export Memory, { MemoryValue } from './Memory'"
    #   parser: 'babel-eslint'

    # no exports at all
    test
      code: '''
        import * as foo from './foo'
      '''

      # test
      #   code: 'export type UserId = number'
      #   parser: 'babel-eslint'

      # issue #653
      # test
      #   code: 'export default from "foo.js"'
      #   parser: 'babel-eslint'
      # test
      #   code: 'export { a, b } from "foo.js"'
      #   parser: 'babel-eslint'

      # ...SYNTAX_CASES,
  ]
  invalid: [
    test
      code: '''
        export bar = ->
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Prefer default export.'
      ]
    test
      code: '''
        export foo = 'foo'
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Prefer default export.'
      ]
    test
      code: '''
        foo = 'foo'
        export { foo }
      '''
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message: 'Prefer default export.'
      ]
      # test
      #   code: """
      #     export { foo } = { foo: "bar" }
      #   """
      #   errors: [
      #     ruleId: 'ExportNamedDeclaration'
      #     message: 'Prefer default export.'
      #   ]
      # test
      #   code: """
      #     export { foo: { bar } } = { foo: { bar: "baz" } }
      #   """
      #   errors: [
      #     ruleId: 'ExportNamedDeclaration'
      #     message: 'Prefer default export.'
      #   ]
  ]
