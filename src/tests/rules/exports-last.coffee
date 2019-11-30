{RuleTester} = require 'eslint'
rule = require 'eslint-plugin-import/lib/rules/exports-last'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

test = (x) -> x
error = (type) ->
  {
    ruleId: 'exports-last'
    message: 'Export statements should appear at the end of the file'
    type
  }

ruleTester.run 'exports-last', rule,
  valid: [
    # Empty file
    test code: '# comment'
    test
      # No exports
      code: '''
        foo = 'bar'
        bar = 'baz'
      '''
    test
      code: '''
        foo = 'bar'
        export {foo}
      '''
    test
      code: '''
        foo = 'bar'
        export default foo
      '''
    # Only exports
    test
      code: '''
        export default foo
        export bar = true
      '''
    test
      code: '''
        foo = 'bar'
        export default foo
        export bar = true
      '''
    # Multiline export
    test
      code: '''
        foo = 'bar'
        export default bar = ->
          very = 'multiline'
        export baz = true
      '''
    # Many exports
    test
      code: '''
        foo = 'bar'
        export default foo
        export so = 'many'
        export exports = ':)'
        export i = 'cant'
        export even = 'count'
        export how = 'many'
      '''
    # Export all
    test
      code: '''
        export * from './foo'
      '''
  ]
  invalid: [
    # Default export before variable declaration
    test
      code: '''
        export default 'bar'
        bar = true
      '''
      errors: [error 'ExportDefaultDeclaration']
    # Named export before variable declaration
    test
      code: '''
        export foo = 'bar'
        bar = true
      '''
      errors: [error 'ExportNamedDeclaration']
    # Export all before variable declaration
    test
      code: '''
        export * from './foo'
        bar = true
      '''
      errors: [error 'ExportAllDeclaration']
    # Many exports arround variable declaration
    test
      code: '''
        export default 'such foo many bar'
        export so = 'many'
        foo = 'bar'
        export exports = ':)'
        export i = 'cant'
        export even = 'count'
        export how = 'many'
      '''
      errors: [
        error 'ExportDefaultDeclaration'
        error 'ExportNamedDeclaration'
      ]
  ]
