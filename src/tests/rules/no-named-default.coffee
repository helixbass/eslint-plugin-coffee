path = require 'path'
{test, SYNTAX_CASES} = require '../eslint-plugin-import-utils'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-named-default'

ruleTester.run 'no-named-default', rule,
  valid: [
    test code: 'import bar from "./bar"'
    test code: 'import bar, { foo } from "./bar"'

    ...SYNTAX_CASES
  ]

  invalid: [
    ###test({
      code: 'import { default } from "./bar";',
      errors: [{
        message: 'Use default import syntax to import \'default\'.',
        type: 'Identifier',
      }],
      parser: require.resolve('babel-eslint'),
    }),###
    test
      code: 'import { default as bar } from "./bar"'
      errors: [
        message: "Use default import syntax to import 'bar'."
        type: 'Identifier'
      ]
    test
      code: 'import { foo, default as bar } from "./bar"'
      errors: [
        message: "Use default import syntax to import 'bar'."
        type: 'Identifier'
      ]
  ]
