{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require '../../rules/no-anonymous-default-export'

test = (x) -> x

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'no-anonymous-default-export', rule,
  valid: [
    # Exports with identifiers are valid
    '''
      foo = 123
      export default foo
    '''
    'export default foo = ->'
    'export default class MyClass'
  ,
    # Allow each forbidden type with appropriate option
    code: 'export default []', options: [allowArray: yes]
  ,
    code: 'export default () => {}', options: [allowAnonymousFunction: yes]
  ,
    code: 'export default class', options: [allowAnonymousClass: yes]
  ,
    code: 'export default ->'
    options: [allowAnonymousFunction: yes]
  ,
    code: 'export default 123', options: [allowLiteral: yes]
  ,
    code: "export default 'foo'", options: [allowLiteral: yes]
  ,
    code: 'export default "#{foo}"', options: [allowLiteral: yes]
  ,
    code: 'export default {}', options: [allowObject: yes]
  ,
    code: 'export default foo(bar)', options: [allowCallExpression: yes]
  ,
    # Allow forbidden types with multiple options
    test
      code: 'export default 123'
      options: [allowLiteral: yes, allowObject: yes]
    test
      code: 'export default {}', options: [allowLiteral: yes, allowObject: yes]

    # Sanity check unrelated export syntaxes
    test code: "export * from 'foo'"
    test
      code: '''
      foo = 123
      export { foo }
    '''
    test
      code: '''
        foo = 123
        export { foo as default }
      '''

    # Allow call expressions by default for backwards compatibility
    test code: 'export default foo(bar)'
  ]

  invalid: [
    test
      code: 'export default []'
      errors: [
        message: 'Assign array to a variable before exporting as module default'
      ]
    test
      code: 'export default () => {}'
      errors: [
        message:
          'Unexpected default export of anonymous function'
      ]
    test
      code: 'export default class'
      errors: [message: 'Unexpected default export of anonymous class']
    test
      code: 'export default ->'
      errors: [message: 'Unexpected default export of anonymous function']
    test
      code: 'export default 123'
      errors: [
        message:
          'Assign literal to a variable before exporting as module default'
      ]
    test
      code: "export default 'foo'"
      errors: [
        message:
          'Assign literal to a variable before exporting as module default'
      ]
    test
      code: 'export default "#{foo}"'
      errors: [
        message:
          'Assign literal to a variable before exporting as module default'
      ]
    test
      code: 'export default {}'
      errors: [
        message:
          'Assign object to a variable before exporting as module default'
      ]
    test
      code: 'export default foo(bar)'
      options: [allowCallExpression: no]
      errors: [
        message:
          'Assign call result to a variable before exporting as module default'
      ]

    # Test failure with non-covering exception
    test
      code: 'export default 123'
      options: [allowObject: yes]
      errors: [
        message:
          'Assign literal to a variable before exporting as module default'
      ]
  ]
