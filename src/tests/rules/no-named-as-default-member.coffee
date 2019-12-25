path = require 'path'
{test, SYNTAX_CASES} = require '../eslint-plugin-import-utils'
{RuleTester} = require 'eslint'
rule = require '../../rules/no-named-as-default-member'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-named-as-default-member', rule,
  valid: [
    test code: 'import bar, {foo} from "./bar"'
    test
      code: '''
      import bar from "./bar"
      baz = bar.baz
    '''
    test
      code: '''
      import {foo} from "./bar"
      baz = foo.baz
    '''
    test
      code: '''
      import * as named from "./named-exports"
      a = named.a
    '''
    test
      code: '''
        import foo from "./default-export-default-property"
        a = foo.default
      '''

    ...SYNTAX_CASES
  ]

  invalid: [
    test
      code: '''
        import bar from "./bar"
        foo = bar.foo
      '''
      errors: [
        message:
          'Caution: `bar` also has a named export `foo`. ' +
          "Check if you meant to write `import {foo} from './bar'` instead."
        type: 'MemberExpression'
      ]
    test
      code: '''
        import bar from "./bar"
        bar.foo()
      '''
      errors: [
        message:
          'Caution: `bar` also has a named export `foo`. ' +
          "Check if you meant to write `import {foo} from './bar'` instead."
        type: 'MemberExpression'
      ]
    test
      code: '''
        import bar from "./bar"
        {foo} = bar
      '''
      errors: [
        message:
          'Caution: `bar` also has a named export `foo`. ' +
          "Check if you meant to write `import {foo} from './bar'` instead."
        type: 'Identifier'
      ]
    test
      code: '''
        import bar from "./bar"
        {foo: foo2, baz} = bar
      '''
      errors: [
        message:
          'Caution: `bar` also has a named export `foo`. ' +
          "Check if you meant to write `import {foo} from './bar'` instead."
        type: 'Identifier'
      ]
  ]
