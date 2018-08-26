{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: '../../..'
rule = require 'eslint-plugin-import/lib/rules/prefer-default-export'

ruleTester.run 'prefer-default-export', rule,
  valid: [
    """
      export foo = 'foo'
      export bar = 'bar'
    """
    'export default bar = ->'
    """
      export foo = 'foo'
      export bar = ->
    """
    """
      export foo = 'foo'
      export default bar
    """
    'export { foo, bar }'
    # 'export { foo, bar } = item'
    # 'export { foo, bar: baz } = item'
    # 'export { foo: { bar, baz } } = item'
    """
        export foo = item
        export { item }
    """
    'export { foo as default }'
    "export * from './foo'"
    # "export Memory, { MemoryValue } from './Memory'"

    # no exports at all
    "import * as foo from './foo'"

    # issue #653
    # 'export default from "foo.js"'
    'export { a, b } from "foo.js"'

    # ...SYNTAX_CASES,
  ]
  invalid: [
    code: 'export bar = ->'
    errors: [
      ruleId: 'ExportNamedDeclaration'
      message: 'Prefer default export.'
    ]
  ,
    code: "export foo = 'foo'"
    errors: [
      ruleId: 'ExportNamedDeclaration'
      message: 'Prefer default export.'
    ]
  ,
    code: """
      foo = 'foo'
      export { foo }
    """
    errors: [
      ruleId: 'ExportNamedDeclaration'
      message: 'Prefer default export.'
    ]
    # ,
    #   code: 'export { foo } = { foo: "bar" }'
    #   errors: [
    #     ruleId: 'ExportNamedDeclaration'
    #     message: 'Prefer default export.'
    #   ]
    # ,
    #   code: 'export { foo: { bar } } = { foo: { bar: "baz" } }'
    #   errors: [
    #     ruleId: 'ExportNamedDeclaration'
    #     message: 'Prefer default export.'
    #   ]
  ]
