# import {test} from '../utils'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: '../../..'
rule = require 'eslint-plugin-import/lib/rules/max-dependencies'

test = (x) -> x

ruleTester.run 'max-dependencies', rule,
  valid: [
    test code: 'import "./foo.js"'

    test
      code: '''
        import "./foo.js"
        import "./bar.js"
      '''
      options: [max: 2]

    test
      code: '''
        import "./foo.js"
        import "./bar.js"
        a = require("./foo.js")
        b = require("./bar.js")
      '''
      options: [max: 2]

    test code: 'import {x, y, z} from "./foo"'
  ]
  invalid: [
    test
      code: """
        import { x } from './foo'
        import { y } from './foo'
        import {z} from './bar'
      """
      options: [max: 1]
      errors: ['Maximum number of dependencies (1) exceeded.']

    test
      code: """
        import { x } from './foo'
        import { y } from './bar'
        import { z } from './baz'
      """
      options: [max: 2]
      errors: ['Maximum number of dependencies (2) exceeded.']

    test
      code: """
        import { x } from './foo'
        require("./bar")
        import { z } from './baz'
      """
      options: [max: 2]
      errors: ['Maximum number of dependencies (2) exceeded.']

    test
      code: '''
        import { x } from './foo'
        import { z } from './foo'
        require("./bar")
        path = require("path")
      '''
      options: [max: 2]
      errors: ['Maximum number of dependencies (2) exceeded.']

      # test
      #   code: """
      #     import type { x } from './foo'
      #     import type { y } from './bar'
      #   """
      #   parser: 'babel-eslint'
      #   options: [max: 1]
      #   errors: ['Maximum number of dependencies (1) exceeded.']
  ]
