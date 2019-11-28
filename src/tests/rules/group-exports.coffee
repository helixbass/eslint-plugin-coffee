# import {test} from '../utils'
{RuleTester} = require 'eslint'
rule = require 'eslint-plugin-import/lib/rules/group-exports'
path = require 'path'

### eslint-disable max-len ###
errors =
  named:
    'Multiple named export declarations; consolidate all named exports into a single export declaration'
  commonjs:
    'Multiple CommonJS exports; consolidate all exports into a single assignment to `module.exports`'
test = (x) -> x
### eslint-enable max-len ###
ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'group-exports', rule,
  valid: [
    test code: 'export test = true'
    test
      code: '''
        export default {}
        export test = true
      '''
    test
      code: '''
        first = true
        second = true
        export {
          first,
          second
        }
      '''
    test
      code: '''
        export default {}
        ### test ###
        export test = true
      '''
    test
      code: '''
        export default {}
        # test
        export test = true
      '''
    test
      code: '''
        export test = true
        ### test ###
        export default {}
      '''
    test
      code: '''
        export test = true
        # test
        export default {}
      '''
    test code: 'module.exports = {} '
    test
      code: '''
        module.exports = { test: true, another: false }
      '''
    test code: 'exports.test = true'

    test
      code: '''
        module.exports = {}
        test = module.exports
      '''
    test
      code: '''
        exports.test = true
        test = exports.test
      '''
    test
      code: '''
        module.exports = {}
        module.exports.too.deep = true
      '''
    test
      code: '''
        module.exports.deep.first = true
        module.exports.deep.second = true
      '''
    test
      code: '''
        module.exports = {}
        exports.too.deep = true
      '''
    test
      code: '''
        export default {}
        test = true
        export { test }
      '''
    test
      code: '''
        test = true
        export { test }
        another = true
        export default {}
      '''
    test
      code: '''
        module.something.else = true
        module.something.different = true
      '''
    test
      code: '''
        module.exports.test = true
        module.something.different = true
      '''
    test
      code: '''
        exports.test = true
        module.something.different = true
      '''
    test
      code: '''
        unrelated = 'assignment'
        module.exports.test = true
      '''
  ]
  invalid: [
    test
      code: '''
        export test = true
        export another = true
      '''
      errors: [errors.named, errors.named]
    test
      code: '''
        module.exports = {}
        module.exports.test = true
        module.exports.another = true
      '''
      errors: [errors.commonjs, errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports = {}
        module.exports.test = true
      '''
      errors: [errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports = { test: true }
        module.exports.another = true
      '''
      errors: [errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports.test = true
        module.exports.another = true
      '''
      errors: [errors.commonjs, errors.commonjs]
    test
      code: '''
        exports.test = true
        module.exports.another = true
      '''
      errors: [errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports = () => {}
        module.exports.attached = true
      '''
      errors: [errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports = test = ->
        module.exports.attached = true
      '''
      errors: [errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports = () => {}
        exports.test = true
        exports.another = true
      '''
      errors: [errors.commonjs, errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports = "non-object"
        module.exports.attached = true
      '''
      errors: [errors.commonjs, errors.commonjs]
    test
      code: '''
        module.exports = "non-object"
        module.exports.attached = true
        module.exports.another = true
      '''
      errors: [errors.commonjs, errors.commonjs, errors.commonjs]
  ]
