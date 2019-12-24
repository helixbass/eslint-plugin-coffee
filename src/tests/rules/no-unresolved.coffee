path = require 'path'

{test, SYNTAX_CASES} = require '../eslint-plugin-import-utils'

{CASE_SENSITIVE_FS} = require 'eslint-module-utils/resolve'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-unresolved'

runResolverTests = (resolver) ->
  # redefine 'test' to set a resolver
  # thus 'rest'. needed something 4-chars-long for formatting simplicity
  rest = (specs) ->
    specs.settings = Object.assign {}, specs.settings,
      'import/resolver':
        [resolver]:
          extensions: ['.coffee', '.js', '.jsx']

    test specs

  ruleTester.run "no-unresolved (#{resolver})", rule,
    valid: [
      test code: 'import "./malformed.koffee"'

      rest code: 'import foo from "./bar"'
      rest code: "import bar from './bar.coffee'"
      rest code: "import {someThing} from './test-module'"
      rest code: "import fs from 'fs'"
      rest
        code: "import('fs')"
        # parser: require.resolve 'babel-eslint'

        # TODO: couldn't discern how this would work/why it was added in
        # https://github.com/benmosher/eslint-plugin-import/commit/5cdfb1
        # rest code: 'import * as foo from "a"'

      rest code: 'export { foo } from "./bar"'
      rest code: 'export * from "./bar"'
      rest
        code: '''
        foo = null
        export { foo }
      '''

        # # stage 1 proposal for export symmetry,
        # rest
        #   code: 'export * as bar from "./bar"'
        #   parser: require.resolve 'babel-eslint'
        # rest
        #   code: 'export bar from "./bar"'
        #   parser: require.resolve 'babel-eslint'
      rest code: 'import foo from "./jsx/MyUnCoolComponent.coffee"'

      # commonjs setting
      rest
        code: 'foo = require("./bar")'
        options: [commonjs: yes]
      rest
        code: 'require("./bar")'
        options: [commonjs: yes]
      rest
        code: 'require("./does-not-exist")'
        options: [commonjs: no]
      rest code: 'require("./does-not-exist")'

      # amd setting
      rest
        code: 'require(["./bar"], (bar) ->)'
        options: [amd: yes]
      rest
        code: 'define(["./bar"], (bar) ->)'
        options: [amd: yes]
      rest
        code: 'require(["./does-not-exist"], (bar) ->)'
        options: [amd: no]
      # magic modules: http://git.io/vByan
      rest
        code: 'define(["require", "exports", "module"], (r, e, m) ->)'
        options: [amd: yes]

      # don't validate without callback param
      rest
        code: 'require(["./does-not-exist"])'
        options: [amd: yes]
      rest code: 'define(["./does-not-exist"], (bar) ->)'

      # stress tests
      rest
        code: 'require("./does-not-exist", "another arg")'
        options: [commonjs: yes, amd: yes]
      rest
        code: 'proxyquire("./does-not-exist")'
        options: [commonjs: yes, amd: yes]
      rest
        code: '(->)("./does-not-exist")'
        options: [commonjs: yes, amd: yes]
      rest
        code: 'define([0, foo], (bar) ->)'
        options: [amd: yes]
      rest
        code: 'require(0)'
        options: [commonjs: yes]
      rest
        code: 'require(foo)'
        options: [commonjs: yes]
    ]

    invalid: [
      rest
        code: 'import reallyfake from "./reallyfake/module"'
        settings: 'import/ignore': ['^\\./fake/']
        errors: [
          message:
            "Unable to resolve path to module './reallyfake/module'."
        ]

      rest
        code: "import bar from './baz'"
        errors: [
          message: "Unable to resolve path to module './baz'."
          type: 'Literal'
        ]
        # rest
        #   code: "import bar from './baz';"
        #   errors: [
        #     message: "Unable to resolve path to module './baz'."
        #     type: 'Literal'
        #   ]
      rest
        code: "import bar from './empty-folder'"
        errors: [
          message: "Unable to resolve path to module './empty-folder'."
          type: 'Literal'
        ]

      # sanity check that this module is _not_ found without proper settings
      rest
        code: "import { DEEP } from 'in-alternate-root'"
        errors: [
          message:
            "Unable to resolve path to module 'in-alternate-root'."
          type: 'Literal'
        ]
      rest
        code: "import('in-alternate-root').then(({DEEP}) ->)"
        errors: [
          message:
            "Unable to resolve path to module 'in-alternate-root'."
          type: 'Literal'
        ]
        # parser: require.resolve 'babel-eslint'

      rest
        code: 'export { foo } from "./does-not-exist"'
        errors: ["Unable to resolve path to module './does-not-exist'."]
      rest
        code: 'export * from "./does-not-exist"'
        errors: ["Unable to resolve path to module './does-not-exist'."]

        # # export symmetry proposal
        # rest
        #   code: 'export * as bar from "./does-not-exist"'
        #   parser: require.resolve 'babel-eslint'
        #   errors: ["Unable to resolve path to module './does-not-exist'."]
        # rest
        #   code: 'export bar from "./does-not-exist"'
        #   parser: require.resolve 'babel-eslint'
        #   errors: ["Unable to resolve path to module './does-not-exist'."]

      # commonjs setting
      rest
        code: 'bar = require("./baz")'
        options: [commonjs: yes]
        errors: [
          message: "Unable to resolve path to module './baz'."
          type: 'Literal'
        ]
      rest
        code: 'require("./baz")'
        options: [commonjs: yes]
        errors: [
          message: "Unable to resolve path to module './baz'."
          type: 'Literal'
        ]

      # amd
      rest
        code: 'require(["./baz"], (bar) ->)'
        options: [amd: yes]
        errors: [
          message: "Unable to resolve path to module './baz'."
          type: 'Literal'
        ]
      rest
        code: 'define(["./baz"], (bar) ->)'
        options: [amd: yes]
        errors: [
          message: "Unable to resolve path to module './baz'."
          type: 'Literal'
        ]
      rest
        code:
          'define(["./baz", "./bar", "./does-not-exist"], (bar) ->)'
        options: [amd: yes]
        errors: [
          message: "Unable to resolve path to module './baz'."
          type: 'Literal'
        ,
          message: "Unable to resolve path to module './does-not-exist'."
          type: 'Literal'
        ]
    ]

  ruleTester.run "issue #333 (#{resolver})", rule,
    valid: [
      rest code: 'import foo from "./bar.json"'
      rest code: 'import foo from "./bar"'
      rest
        code: 'import foo from "./bar.json"'
        settings: 'import/extensions': ['.coffee']
      rest
        code: 'import foo from "./bar"'
        settings: 'import/extensions': ['.coffee']
    ]
    invalid: [
      rest
        code: 'import bar from "./foo.json"'
        errors: ["Unable to resolve path to module './foo.json'."]
    ]

  unless CASE_SENSITIVE_FS
    ruleTester.run 'case sensitivity', rule,
      valid: [
        rest
          # test with explicit flag
          code: 'import foo from "./jsx/MyUncoolComponent.coffee"'
          options: [caseSensitive: no]
      ]

      invalid: [
        rest
          # test default
          code: 'import foo from "./jsx/MyUncoolComponent.coffee"'
          errors: [
            'Casing of ./jsx/MyUncoolComponent.coffee does not match the underlying filesystem.'
          ]
        rest
          # test with explicit flag
          code: 'import foo from "./jsx/MyUncoolComponent.coffee"'
          options: [caseSensitive: yes]
          errors: [
            'Casing of ./jsx/MyUncoolComponent.coffee does not match the underlying filesystem.'
          ]
      ]

['node', 'webpack'].forEach runResolverTests

# TODO: this wasn't working (maybe import/resolve requires its own .coffee extensions supplied or something?
# doesn't seem necessary to support old import/resolve interface though?
# ruleTester.run 'no-unresolved (import/resolve legacy)', rule,
#   valid: [
#     test
#       code: "import { DEEP } from 'in-alternate-root'"
#       settings:
#         'import/resolve':
#           paths: [
#             path.join(
#               process.cwd()
#               'src'
#               'tests'
#               'fixtures'
#               'import'
#               'alternate-root'
#             )
#           ]

#           test
#             code:
#               """
#                 import { DEEP } from 'in-alternate-root'
#                 import { bar } from 'src-bar'
#               """
#             settings:
#               'import/resolve':
#                 paths: [
#                   path.join 'src', 'tests', 'fixtures', 'import', 'src-root'
#                   path.join 'src', 'tests', 'fixtures', 'import', 'alternate-root'
#                 ]

#           test
#             code: 'import * as foo from "jsx-module/foo"'
#             settings: 'import/resolve': extensions: ['.jsx']
#   ]

#   invalid: [
#     test
#       code: 'import * as foo from "jsx-module/foo"'
#       errors: ["Unable to resolve path to module 'jsx-module/foo'."]
#   ]

ruleTester.run 'no-unresolved (webpack-specific)', rule,
  valid: [
    test
      # default webpack config in files/webpack.config.js knows about jsx
      code: 'import * as foo from "jsx-module/foo"'
      settings:
        'import/resolver': 'webpack'
    test
      # should ignore loaders
      code: 'import * as foo from "some-loader?with=args!jsx-module/foo"'
      settings:
        'import/resolver': 'webpack'
  ]
  invalid: [
    test
      # default webpack config in files/webpack.config.js knows about jsx
      code: 'import * as foo from "jsx-module/foo"'
      settings:
        'import/resolver':
          webpack:
            config: 'webpack.empty.config.js'
      errors: ["Unable to resolve path to module 'jsx-module/foo'."]
  ]

ruleTester.run 'no-unresolved ignore list', rule,
  valid: [
    test
      code: 'import "./malformed.koffee"'
      options: [ignore: ['.png$', '.gif$']]
    test
      code: 'import "./test.giffy"'
      options: [ignore: ['.png$', '.gif$']]

    test
      code: 'import "./test.gif"'
      options: [ignore: ['.png$', '.gif$']]

    test
      code: 'import "./test.png"'
      options: [ignore: ['.png$', '.gif$']]
  ]

  invalid: [
    test
      code: 'import "./test.gif"'
      options: [ignore: ['.png$']]
      errors: ["Unable to resolve path to module './test.gif'."]

    test
      code: 'import "./test.png"'
      options: [ignore: ['.gif$']]
      errors: ["Unable to resolve path to module './test.png'."]
  ]

ruleTester.run 'no-unresolved unknown resolver', rule,
  valid: []

  invalid: [
    # logs resolver load error
    test
      code: 'import "./malformed.koffee"'
      settings: 'import/resolver': 'foo'
      errors: [
        'Resolve error: unable to load resolver "foo".'
        "Unable to resolve path to module './malformed.koffee'."
      ]

    # only logs resolver message once
    test
      code: '''
        import "./malformed.koffee"
        import "./fake.coffee"
      '''
      settings: 'import/resolver': 'foo'
      errors: [
        'Resolve error: unable to load resolver "foo".'
        "Unable to resolve path to module './malformed.koffee'."
        "Unable to resolve path to module './fake.coffee'."
      ]
  ]

ruleTester.run 'no-unresolved electron', rule,
  valid: [
    test
      code: 'import "electron"'
      settings: 'import/core-modules': ['electron']
  ]
  invalid: [
    test
      code: 'import "electron"'
      errors: ["Unable to resolve path to module 'electron'."]
  ]

ruleTester.run 'no-unresolved syntax verification', rule,
  valid: SYNTAX_CASES
  invalid: []
