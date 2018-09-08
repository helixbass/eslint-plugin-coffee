# import {test} from '../utils'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: '../../..'
rule = require '../../rules/no-default-export'

test = (x) -> x

ruleTester.run 'no-default-export', rule,
  valid: [
    test
      code: """
        export foo = 'foo'
        export bar = 'bar'
      """
    test
      code: """
        export foo = 'foo'
        export bar = ->
      """
    test code: "export foo = 'foo'"
    test
      code: """
        foo = 'foo'
        export { foo }
      """
    test code: 'export { foo, bar }'
    # test code: 'export { foo, bar } = item'
    # test code: 'export { foo, bar: baz } = item'
    # test code: 'export { foo: { bar, baz } } = item'
    test
      code: """
        export foo = item
        export { item }
      """
    test code: "export * from './foo'"
    # test code: 'export { foo } = { foo: "bar" }'
    # test code: 'export { foo: { bar } } = { foo: { bar: "baz" } }'
    # test
    #   code: 'export { a, b } from "foo.js"'
    #   parser: 'babel-eslint'

    # no exports at all
    test code: "import * as foo from './foo'"
    test code: "import foo from './foo'"
    test code: "import {default as foo} from './foo'"

    # test
    #   code: 'export type UserId = number'
    #   parser: 'babel-eslint'
    # test
    #   code: 'export foo from "foo.js"'
    #   parser: 'babel-eslint'
    # test
    #   code: "export Memory, { MemoryValue } from './Memory'"
    #   parser: 'babel-eslint'
  ]
  invalid: [
    test
      code: 'export default bar = ->'
      errors: [
        ruleId: 'ExportDefaultDeclaration'
        message: 'Prefer named exports.'
      ]
    test
      code: """
        export foo = 'foo'
        export default bar
      """
      errors: [
        ruleId: 'ExportDefaultDeclaration'
        message: 'Prefer named exports.'
      ]
    test
      code: 'export { foo as default }'
      errors: [
        ruleId: 'ExportNamedDeclaration'
        message:
          'Do not alias `foo` as `default`. Just export `foo` itself ' +
          'instead.'
      ]
      # test
      #   code: 'export default from "foo.js"'
      #   parser: 'babel-eslint'
      #   errors: [
      #     ruleId: 'ExportNamedDeclaration'
      #     message: 'Prefer named exports.'
      #   ]
  ]
