{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/first'

test = (x) -> x

ruleTester.run 'first', rule,
  valid: [
    test
      code: """
        import { x } from './foo'
        import { y } from './bar'
        export { x, y }
      """
    test
      code: """
      import { x } from 'foo'
      import { y } from './bar'
    """
    test
      code: """
      import { x } from './foo'
      import { y } from 'bar'
    """
    test
      code: """
        'use directive'
        import { x } from 'foo'
      """
  ]
  invalid: [
    test
      code: """
        import { x } from './foo'
        export { x }
        import { y } from './bar'
      """
      errors: 1
      output: """
        import { x } from './foo'
        import { y } from './bar'
        export { x }
      """
    test
      code: """
        import { x } from './foo'
        export { x }
        import { y } from './bar'
        import { z } from './baz'
      """
      errors: 2
      output: """
        import { x } from './foo'
        import { y } from './bar'
        import { z } from './baz'
        export { x }
      """
    test
      code: """
        import { x } from './foo'
        import { y } from 'bar'
      """
      options: ['absolute-first']
      errors: 1
    test
      code: """
        import { x } from 'foo'
        'use directive'
        import { y } from 'bar'
      """
      errors: 1
      output: """
        import { x } from 'foo'
        import { y } from 'bar'
        'use directive'
      """
    test
      code: """
        a = 1
        import { y } from './bar'
        if true
          x()
        import { x } from './foo'
        import { z } from './baz'
      """
      errors: 3
      output: """
        import { y } from './bar'
        a = 1
        if true
          x()
        import { x } from './foo'
        import { z } from './baz'
      """
    test
      code: """
        if (true) then console.log(1)
        import a from 'b'
      """
      errors: 1
      output: """
        import a from 'b'
        if (true) then console.log(1)
      """
  ]
