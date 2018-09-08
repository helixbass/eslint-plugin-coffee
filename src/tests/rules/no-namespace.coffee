{RuleTester} = require 'eslint'

ERROR_MESSAGE = 'Unexpected namespace import.'

ruleTester = new RuleTester parser: '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-namespace'

ruleTester.run 'no-namespace', rule,
  valid: [
    code: "import { a, b } from 'foo'"
  ,
    code: "import { a, b } from './foo'"
  ,
    code: "import bar from 'bar'"
  ,
    code: "import bar from './bar'"
  ]

  invalid: [
    code: "import * as foo from 'foo'"
    errors: [
      line: 1
      column: 8
      message: ERROR_MESSAGE
    ]
  ,
    code: "import defaultExport, * as foo from 'foo'"
    errors: [
      line: 1
      column: 23
      message: ERROR_MESSAGE
    ]
  ,
    code: "import * as foo from './foo'"
    errors: [
      line: 1
      column: 8
      message: ERROR_MESSAGE
    ]
  ]
