path = require 'path'
{test, testFilePath} = require '../eslint-plugin-import-utils'
# import jsxConfig from '../../../config/react'
# import typescriptConfig from '../../../config/typescript'

{RuleTester} = require 'eslint'
fs = require 'fs'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
# typescriptRuleTester = new RuleTester typescriptConfig
# jsxRuleTester = new RuleTester jsxConfig
rule = require '../../rules/no-unused-modules'

error = (message) -> {ruleId: 'no-unused-modules', message}

missingExportsOptions = [missingExports: yes]

unusedExportsOptions = [
  unusedExports: yes
  src: [testFilePath './no-unused-modules/**/*.coffee']
  ignoreExports: [testFilePath './no-unused-modules/*ignored*.coffee']
]

# unusedExportsTypescriptOptions = [
#   unusedExports: yes
#   src: [testFilePath './no-unused-modules/typescript']
#   ignoreExports: undefined
# ]

unusedExportsJsxOptions = [
  unusedExports: yes
  src: [testFilePath './no-unused-modules/jsx']
  ignoreExports: undefined
]

# tests for missing exports
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test code: 'export default noOptions = ->'
    test
      options: missingExportsOptions
      code: 'export default () => 1'
    test
      options: missingExportsOptions
      code: 'export a = 1'
    test
      options: missingExportsOptions
      code: '''
        a = 1
        export { a }
      '''
    test
      options: missingExportsOptions
      code: '''
        a = ->
          return true
        export { a }
      '''
    test
      options: missingExportsOptions
      code: '''
        a = 1
        b = 2
        export { a, b }
      '''
    test
      options: missingExportsOptions
      code: '''
        a = 1
        export default a
      '''
    test
      options: missingExportsOptions
      code: 'export class Foo'
  ]
  invalid: [
    test
      options: missingExportsOptions
      code: 'a = 1'
      errors: [error 'No exports found']
    test
      options: missingExportsOptions
      code: '### a = 1 ###'
      errors: [error 'No exports found']
  ]

# tests for  exports
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: '''
        import { o2 } from "./file-o"
        export default () => 12
      '''
      filename: testFilePath './no-unused-modules/file-a.coffee'
    test
      options: unusedExportsOptions
      code: 'export b = 2'
      filename: testFilePath './no-unused-modules/file-b.coffee'
    test
      options: unusedExportsOptions
      code: '''
        c1 = 3
        c2 = ->
          return 3
        export { c1, c2 }
      '''
      filename: testFilePath './no-unused-modules/file-c.coffee'
    test
      options: unusedExportsOptions
      code: 'export d = -> return 4'
      filename: testFilePath './no-unused-modules/file-d.coffee'
    test
      options: unusedExportsOptions
      code: '''
        export class q
          q0: ->
      '''
      filename: testFilePath './no-unused-modules/file-q.coffee'
    test
      options: unusedExportsOptions
      code: '''
        e0 = 5
        export { e0 as e }
      '''
      filename: testFilePath './no-unused-modules/file-e.coffee'
    test
      options: unusedExportsOptions
      code: '''
        l0 = 5
        l = 10
        export { l0 as l1, l }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-l.coffee'
    test
      options: unusedExportsOptions
      code: '''
        o0 = 0
        o1 = 1
        export { o0, o1 as o2 }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-o.coffee'
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: '''
        import eslint from 'eslint'
        import fileA from './file-a'
        import { b } from './file-b'
        import { c1, c2 } from './file-c'
        import { d } from './file-d'
        import { e } from './file-e'
        import { e2 } from './file-e'
        import { h2 } from './file-h'
        import * as l from './file-l'
        export * from './file-n'
        export { default, o0, o3 } from './file-o'
        export { p } from './file-p'
      '''
      filename: testFilePath './no-unused-modules/file-0.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
        error "exported declaration 'o0' not used within other modules"
        error "exported declaration 'o3' not used within other modules"
        error "exported declaration 'p' not used within other modules"
      ]
    test
      options: unusedExportsOptions
      code: '''
        n0 = 'n0'
        n1 = 42
        export { n0, n1 }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-n.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
      ]
  ]

# test for unused exports
ruleTester.run 'no-unused-modules', rule,
  valid: []
  invalid: [
    test
      options: unusedExportsOptions
      code: 'export default () => 13'
      filename: testFilePath './no-unused-modules/file-f.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
      ]
    test
      options: unusedExportsOptions
      code: 'export g = 2'
      filename: testFilePath './no-unused-modules/file-g.coffee'
      errors: [error "exported declaration 'g' not used within other modules"]
    test
      options: unusedExportsOptions
      code: '''
        h1 = 3
        h2 = ->
          return 3
        h3 = true
        export { h1, h2, h3 }
      '''
      filename: testFilePath './no-unused-modules/file-h.coffee'
      errors: [error "exported declaration 'h1' not used within other modules"]
    test
      options: unusedExportsOptions
      code: '''
        i1 = 3
        i2 = ->
          return 3
        export { i1, i2 }
      '''
      filename: testFilePath './no-unused-modules/file-i.coffee'
      errors: [
        error "exported declaration 'i1' not used within other modules"
        error "exported declaration 'i2' not used within other modules"
      ]
    test
      options: unusedExportsOptions
      code: 'export j = -> return 4'
      filename: testFilePath './no-unused-modules/file-j.coffee'
      errors: [error "exported declaration 'j' not used within other modules"]
    test
      options: unusedExportsOptions
      code: '''
        export class q
          q0: ->
      '''
      filename: testFilePath './no-unused-modules/file-q.coffee'
      errors: [error "exported declaration 'q' not used within other modules"]
    test
      options: unusedExportsOptions
      code: '''
        k0 = 5
        export { k0 as k }
      '''
      filename: testFilePath './no-unused-modules/file-k.coffee'
      errors: [error "exported declaration 'k' not used within other modules"]
  ]

# // test for export from
ruleTester.run 'no-unused-modules', rule,
  valid: []
  invalid: [
    test
      options: unusedExportsOptions
      code: "export { k } from '#{testFilePath(
        './no-unused-modules/file-k.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-j.coffee'
      errors: [error "exported declaration 'k' not used within other modules"]
  ]

ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: '''
        k0 = 5
        export { k0 as k }
      '''
      filename: testFilePath './no-unused-modules/file-k.coffee'
  ]
  invalid: []

# test for ignored files
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: 'export default () => 14'
      filename: testFilePath './no-unused-modules/file-ignored-a.coffee'
    test
      options: unusedExportsOptions
      code: 'export b = 2'
      filename: testFilePath './no-unused-modules/file-ignored-b.coffee'
    test
      options: unusedExportsOptions
      code: '''
        c1 = 3
        c2 = -> return 3
        export { c1, c2 }
      '''
      filename: testFilePath './no-unused-modules/file-ignored-c.coffee'
    test
      options: unusedExportsOptions
      code: 'export d = -> return 4'
      filename: testFilePath './no-unused-modules/file-ignored-d.coffee'
    test
      options: unusedExportsOptions
      code: '''
        f = 5
        export { f as e }
      '''
      filename: testFilePath './no-unused-modules/file-ignored-e.coffee'
    test
      options: unusedExportsOptions
      code: '''
        l0 = 5
        l = 10
        export { l0 as l1, l }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-ignored-l.coffee'
  ]
  invalid: []

# add named import for file with default export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "import { f } from '#{testFilePath(
        './no-unused-modules/file-f.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: 'export default () => 15'
      filename: testFilePath './no-unused-modules/file-f.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
      ]
  ]

# add default import for file with default export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "import f from '#{testFilePath(
        './no-unused-modules/file-f.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
    test
      options: unusedExportsOptions
      code: 'export default () => 16'
      filename: testFilePath './no-unused-modules/file-f.coffee'
  ]
  invalid: []

# add default import for file with named export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "import g from '#{testFilePath(
        './no-unused-modules/file-g.coffee'
      )}';import {h} from '#{testFilePath(
        './no-unused-modules/file-gg.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: 'export g = 2'
      filename: testFilePath './no-unused-modules/file-g.coffee'
      errors: [error "exported declaration 'g' not used within other modules"]
  ]

# add named import for file with named export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: """
        import { g } from '#{testFilePath './no-unused-modules/file-g.coffee'}'
        import eslint from 'eslint'
      """
      filename: testFilePath './no-unused-modules/file-0.coffee'
    test
      options: unusedExportsOptions
      code: 'export g = 2'
      filename: testFilePath './no-unused-modules/file-g.coffee'
  ]
  invalid: []

# add different named import for file with named export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "import { c } from '#{testFilePath(
        './no-unused-modules/file-b.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: 'export b = 2'
      filename: testFilePath './no-unused-modules/file-b.coffee'
      errors: [error "exported declaration 'b' not used within other modules"]
  ]

# add renamed named import for file with named export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: """
        import { g as g1 } from '#{testFilePath(
        './no-unused-modules/file-g.coffee'
      )}'
        import eslint from 'eslint'
      """
      filename: testFilePath './no-unused-modules/file-0.coffee'
    test
      options: unusedExportsOptions
      code: 'export g = 2'
      filename: testFilePath './no-unused-modules/file-g.coffee'
  ]
  invalid: []

# add different renamed named import for file with named export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "import { g1 as g } from '#{testFilePath(
        './no-unused-modules/file-g.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: 'export g = 2'
      filename: testFilePath './no-unused-modules/file-g.coffee'
      errors: [error "exported declaration 'g' not used within other modules"]
  ]

# remove default import for file with default export
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "import { a1, a2 } from '#{testFilePath(
        './no-unused-modules/file-a.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: 'export default () => 17'
      filename: testFilePath './no-unused-modules/file-a.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
      ]
  ]

# add namespace import for file with unused exports
ruleTester.run 'no-unused-modules', rule,
  valid: []
  invalid: [
    test
      options: unusedExportsOptions
      code: '''
        m0 = 5
        m = 10
        export { m0 as m1, m }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-m.coffee'
      errors: [
        error "exported declaration 'm1' not used within other modules"
        error "exported declaration 'm' not used within other modules"
        error "exported declaration 'default' not used within other modules"
      ]
  ]
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: """
        import * as m from '#{testFilePath './no-unused-modules/file-m.coffee'}'
        import unknown from 'unknown-module'
      """
      filename: testFilePath './no-unused-modules/file-0.coffee'
    test
      options: unusedExportsOptions
      code: '''
        m0 = 5
        m = 10
        export { m0 as m1, m }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-m.coffee'
  ]
  invalid: []

# remove all exports
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "### import * as m from '#{testFilePath(
        './no-unused-modules/file-m.coffee'
      )}' ###"
      filename: testFilePath './no-unused-modules/file-0.coffee'
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: '''
        m0 = 5
        m = 10
        export { m0 as m1, m }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-m.coffee'
      errors: [
        error "exported declaration 'm1' not used within other modules"
        error "exported declaration 'm' not used within other modules"
        error "exported declaration 'default' not used within other modules"
      ]
  ]

ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: "export * from '#{testFilePath(
        './no-unused-modules/file-m.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
  ]
  invalid: []
ruleTester.run 'no-unused-modules', rule,
  valid: []
  invalid: [
    test
      options: unusedExportsOptions
      code: '''
        m0 = 5
        m = 10
        export { m0 as m1, m }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-m.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
      ]
  ]

ruleTester.run 'no-unused-modules', rule,
  valid: []
  invalid: [
    test
      options: unusedExportsOptions
      code: "export { m1, m} from '#{testFilePath(
        './no-unused-modules/file-m.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
      errors: [
        error "exported declaration 'm1' not used within other modules"
        error "exported declaration 'm' not used within other modules"
      ]
    test
      options: unusedExportsOptions
      code: '''
        m0 = 5
        m = 10
        export { m0 as m1, m }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-m.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
      ]
  ]

ruleTester.run 'no-unused-modules', rule,
  valid: [
    # test({ options: unusedExportsOptions,
    #        code: `export { default, m1 } from '${testFilePath('./no-unused-modules/file-m.coffee')}';`,
    #        filename: testFilePath('./no-unused-modules/file-0.coffee')}),
  ]
  invalid: [
    test
      options: unusedExportsOptions
      code: "export { default, m1 } from '#{testFilePath(
        './no-unused-modules/file-m.coffee'
      )}'"
      filename: testFilePath './no-unused-modules/file-0.coffee'
      errors: [
        error "exported declaration 'default' not used within other modules"
        error "exported declaration 'm1' not used within other modules"
      ]
    test
      options: unusedExportsOptions
      code: '''
        m0 = 5
        m = 10
        export { m0 as m1, m }
        export default () => {}
      '''
      filename: testFilePath './no-unused-modules/file-m.coffee'
      errors: [error "exported declaration 'm' not used within other modules"]
  ]

describe 'test behaviour for new file', ->
  before ->
    fs.writeFileSync(
      testFilePath './no-unused-modules/file-added-0.coffee'
      ''
      encoding: 'utf8'
    )

  # add import in newly created file
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: "import * as m from '#{testFilePath(
          './no-unused-modules/file-m.coffee'
        )}'"
        filename: testFilePath './no-unused-modules/file-added-0.coffee'
      test
        options: unusedExportsOptions
        code: '''
          m0 = 5
          m = 10
          export { m0 as m1, m }
          export default () => {}
        '''
        filename: testFilePath './no-unused-modules/file-m.coffee'
    ]
    invalid: []

  # add export for newly created file
  ruleTester.run 'no-unused-modules', rule,
    valid: []
    invalid: [
      test
        options: unusedExportsOptions
        code: 'export default () => 2'
        filename: testFilePath './no-unused-modules/file-added-0.coffee'
        errors: [
          error "exported declaration 'default' not used within other modules"
        ]
    ]

  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: "import def from '#{testFilePath(
          './no-unused-modules/file-added-0.coffee'
        )}'"
        filename: testFilePath './no-unused-modules/file-0.coffee'
      test
        options: unusedExportsOptions
        code: 'export default () => {}'
        filename: testFilePath './no-unused-modules/file-added-0.coffee'
    ]
    invalid: []

  # export * only considers named imports. default imports still need to be reported
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: "export * from '#{testFilePath(
          './no-unused-modules/file-added-0.coffee'
        )}'"
        filename: testFilePath './no-unused-modules/file-0.coffee'
      # Test export * from 'external-compiled-library'
      test
        options: unusedExportsOptions
        code: "export * from 'external-compiled-library'"
        filename: testFilePath './no-unused-modules/file-r.coffee'
    ]
    invalid: [
      test
        options: unusedExportsOptions
        code: '''
          z = 'z'
          export default () => {}
        '''
        filename: testFilePath './no-unused-modules/file-added-0.coffee'
        errors: [
          error "exported declaration 'default' not used within other modules"
        ]
    ]
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: 'export a = 2'
        filename: testFilePath './no-unused-modules/file-added-0.coffee'
    ]
    invalid: []

  # remove export *. all exports need to be reported
  ruleTester.run 'no-unused-modules', rule,
    valid: []
    invalid: [
      test
        options: unusedExportsOptions
        code: "export { a } from '#{testFilePath(
          './no-unused-modules/file-added-0.coffee'
        )}'"
        filename: testFilePath './no-unused-modules/file-0.coffee'
        errors: [
          error "exported declaration 'a' not used within other modules"
        ]
      test
        options: unusedExportsOptions
        code: '''
          export z = 'z'
          export default () => {}
        '''
        filename: testFilePath './no-unused-modules/file-added-0.coffee'
        errors: [
          error "exported declaration 'z' not used within other modules"
          error "exported declaration 'default' not used within other modules"
        ]
    ]

  describe 'test behaviour for new file', ->
    before ->
      fs.writeFileSync(
        testFilePath './no-unused-modules/file-added-1.coffee'
        ''
        encoding: 'utf8'
      )
    ruleTester.run 'no-unused-modules', rule,
      valid: [
        test
          options: unusedExportsOptions
          code: "export * from '#{testFilePath(
            './no-unused-modules/file-added-1.coffee'
          )}'"
          filename: testFilePath './no-unused-modules/file-0.coffee'
      ]
      invalid: [
        test
          options: unusedExportsOptions
          code: '''
            export z = 'z'
            export default () => {}
          '''
          filename: testFilePath './no-unused-modules/file-added-1.coffee'
          errors: [
            error "exported declaration 'default' not used within other modules"
          ]
      ]
    after ->
      if fs.existsSync testFilePath './no-unused-modules/file-added-1.coffee'
        fs.unlinkSync testFilePath './no-unused-modules/file-added-1.coffee'

  after ->
    if fs.existsSync testFilePath './no-unused-modules/file-added-0.coffee'
      fs.unlinkSync testFilePath './no-unused-modules/file-added-0.coffee'

describe 'test behaviour for new file', ->
  before ->
    fs.writeFileSync(
      testFilePath './no-unused-modules/file-added-2.coffee'
      ''
      encoding: 'utf8'
    )
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: "import added from '#{testFilePath(
          './no-unused-modules/file-added-2.coffee'
        )}'"
        filename: testFilePath './no-unused-modules/file-added-1.coffee'
      test
        options: unusedExportsOptions
        code: 'export default () => {}'
        filename: testFilePath './no-unused-modules/file-added-2.coffee'
    ]
    invalid: []
  after ->
    if fs.existsSync testFilePath './no-unused-modules/file-added-2.coffee'
      fs.unlinkSync testFilePath './no-unused-modules/file-added-2.coffee'

describe 'test behaviour for new file', ->
  before ->
    fs.writeFileSync(
      testFilePath './no-unused-modules/file-added-3.coffee'
      ''
      encoding: 'utf8'
    )
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: "import { added } from '#{testFilePath(
          './no-unused-modules/file-added-3.coffee'
        )}'"
        filename: testFilePath './no-unused-modules/file-added-1.coffee'
      test
        options: unusedExportsOptions
        code: 'export added = () => {}'
        filename: testFilePath './no-unused-modules/file-added-3.coffee'
    ]
    invalid: []
  after ->
    if fs.existsSync testFilePath './no-unused-modules/file-added-3.coffee'
      fs.unlinkSync testFilePath './no-unused-modules/file-added-3.coffee'

describe 'test behaviour for new file', ->
  before ->
    fs.writeFileSync(
      testFilePath './no-unused-modules/file-added-4.coffee.coffee'
      ''
      encoding: 'utf8'
    )
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: "import * as added from '#{testFilePath(
          './no-unused-modules/file-added-4.coffee.coffee'
        )}'"
        filename: testFilePath './no-unused-modules/file-added-1.coffee'
      test
        options: unusedExportsOptions
        code: '''
          export added = () => {}
          export default () => {}
        '''
        filename: testFilePath './no-unused-modules/file-added-4.coffee.coffee'
    ]
    invalid: []
  after ->
    if fs.existsSync(
      testFilePath './no-unused-modules/file-added-4.coffee.coffee'
    )
      fs.unlinkSync(
        testFilePath './no-unused-modules/file-added-4.coffee.coffee'
      )

describe 'do not report missing export for ignored file', ->
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: [
          src: [testFilePath './no-unused-modules/**/*.coffee']
          ignoreExports: [testFilePath './no-unused-modules/*ignored*.coffee']
          missingExports: yes
        ]
        code: 'export test = true'
        filename: testFilePath './no-unused-modules/file-ignored-a.coffee'
    ]
    invalid: []

# lint file not available in `src`
ruleTester.run 'no-unused-modules', rule,
  valid: [
    test
      options: unusedExportsOptions
      code: '''
        export jsxFoo = 'foo'
        export jsxBar = 'bar'
      '''
      filename: testFilePath '../jsx/named.jsx'
  ]
  invalid: []

# TODO: should this be updated to work for Coffeescript (ie .coffee -> .js naming in package.json)?
# describe 'do not report unused export for files mentioned in package.json', ->
#   ruleTester.run 'no-unused-modules', rule,
#     valid: [
#       test
#         options: unusedExportsOptions
#         code: 'export bin = "bin"'
#         filename: testFilePath './no-unused-modules/bin.coffee'
#       test
#         options: unusedExportsOptions
#         code: 'export binObject = "binObject"'
#         filename: testFilePath './no-unused-modules/binObject/index.coffee'
#       test
#         options: unusedExportsOptions
#         code: 'export browser = "browser"'
#         filename: testFilePath './no-unused-modules/browser.coffee'
#       test
#         options: unusedExportsOptions
#         code: 'export browserObject = "browserObject"'
#         filename: testFilePath './no-unused-modules/browserObject/index.coffee'
#       test
#         options: unusedExportsOptions
#         code: 'export main = "main"'
#         filename: testFilePath './no-unused-modules/main/index.coffee'
#     ]
#     invalid: [
#       test
#         options: unusedExportsOptions
#         code: 'export privatePkg = "privatePkg"'
#         filename: testFilePath './no-unused-modules/privatePkg/index.coffee'
#         errors: [
#           error(
#             "exported declaration 'privatePkg' not used within other modules"
#           )
#         ]
#     ]

# describe 'correctly report flow types', ->
#   ruleTester.run 'no-unused-modules', rule,
#     valid: [
#       test
#         options: unusedExportsOptions
#         code: 'import { type FooType } from "./flow-2";'
#         parser: require.resolve 'babel-eslint'
#         filename: testFilePath './no-unused-modules/flow-0.js'
#       test
#         options: unusedExportsOptions
#         code: '''// @flow strict
#                export type FooType = string;'''
#         parser: require.resolve 'babel-eslint'
#         filename: testFilePath './no-unused-modules/flow-2.js'
#     ]
#     invalid: [
#       test
#         options: unusedExportsOptions
#         code: '''// @flow strict
#                export type Bar = string;'''
#         parser: require.resolve 'babel-eslint'
#         filename: testFilePath './no-unused-modules/flow-1.js'
#         errors: [
#           error "exported declaration 'Bar' not used within other modules"
#         ]
#     ]

describe 'Avoid errors if re-export all from umd compiled library', ->
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsOptions
        code: "export * from '#{testFilePath './no-unused-modules/bin.coffee'}'"
        filename: testFilePath './no-unused-modules/main/index.coffee'
    ]
    invalid: []

# describe 'correctly work with Typescript only files', ->
#   typescriptRuleTester.run 'no-unused-modules', rule,
#     valid: [
#       test
#         options: unusedExportsTypescriptOptions
#         code: 'import a from "file-ts-a";'
#         parser: require.resolve 'babel-eslint'
#         filename: testFilePath './no-unused-modules/typescript/file-ts-a.ts'
#     ]
#     invalid: [
#       test
#         options: unusedExportsTypescriptOptions
#         code: 'export const b = 2;'
#         parser: require.resolve 'babel-eslint'
#         filename: testFilePath './no-unused-modules/typescript/file-ts-b.ts'
#         errors: [error "exported declaration 'b' not used within other modules"]
#     ]

describe 'correctly work with JSX only files', ->
  ruleTester.run 'no-unused-modules', rule,
    valid: [
      test
        options: unusedExportsJsxOptions
        code: 'import a from "file-jsx-a"'
        # parser: require.resolve 'babel-eslint'
        filename: testFilePath './no-unused-modules/jsx/file-jsx-a.coffee'
    ]
    invalid: [
      test
        options: unusedExportsJsxOptions
        code: 'export b = 2'
        # parser: require.resolve 'babel-eslint'
        filename: testFilePath './no-unused-modules/jsx/file-jsx-b.coffee'
        errors: [error "exported declaration 'b' not used within other modules"]
    ]
