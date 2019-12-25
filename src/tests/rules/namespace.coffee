path = require 'path'
{test, SYNTAX_CASES} = require '../eslint-plugin-import-utils'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require '../../rules/namespace'

error = (name, namespace) ->
  message: "'#{name}' not found in imported namespace '#{namespace}'."

valid = [
  test code: 'import "./malformed.koffee"'

  test code: "import * as foo from './empty-folder'"
  test
    code: '''
      import * as names from "./named-exports"
      console.log((names.b).c)
    '''

  test
    code: '''
      import * as names from "./named-exports"
      console.log(names.a)
    '''
  test
    code: '''
      import * as names from "./re-export-names"
      console.log(names.foo)
    '''
  test
    code: "import * as elements from './jsx'"
    # parserOptions:
    #   sourceType: 'module'
    #   ecmaFeatures: jsx: yes
    #   ecmaVersion: 2015
  test code: "import * as foo from './common'"

  # destructuring namespaces
  test
    code: '''
      import * as names from "./named-exports"
      { a } = names
    '''
  test
    code: '''
      import * as names from "./named-exports"
      { d: c } = names
    '''
  test
    code: '''
      import * as names from "./named-exports"
      { c } = foo
      { length } = "names"
      alt = names
    '''
  # deep destructuring only cares about top level
  test
    code: '''
      import * as names from "./named-exports"
      { ExportedClass: { length } } = names
    '''

  # detect scope redefinition
  test
    code: '''
      import * as names from "./named-exports"
      b = (names) ->
        { c } = names
    '''
  ,
    # test
    #   code: '''
    #     import * as names from "./named-exports"
    #     b = ->
    #       names = null
    #       { c } = names
    #   '''
    # test
    #   code:
    #     'import * as names from "./named-exports";' +
    #     'const x = function names() { const { c } = names }'

    # #///////
    # # es7 //
    # #///////
    # test
    #   code: 'export * as names from "./named-exports"'
    #   parser: require.resolve 'babel-eslint'
    # test
    #   code: 'export defport, * as names from "./named-exports"'
    #   parser: require.resolve 'babel-eslint'
    # # non-existent is handled by no-unresolved
    # test
    #   code: 'export * as names from "./does-not-exist"'
    #   parser: require.resolve 'babel-eslint'

    # test
    #   code:
    #     'import * as Endpoints from "./issue-195/Endpoints"; console.log(Endpoints.Users)'
    #   parser: require.resolve 'babel-eslint'

    # respect hoisting
    test
      code: '''
        x = ->
          console.log((names.b).c)
        import * as names from "./named-exports"
      '''
    # names.default is valid export
    test code: "import * as names from './default-export'"
    test
      code: '''
        import * as names from './default-export'
        console.log(names.default)
      '''
      # test
      #   code: 'export * as names from "./default-export"'
      #   parser: require.resolve 'babel-eslint'
      # test
      #   code: 'export defport, * as names from "./default-export"'
      #   parser: require.resolve 'babel-eslint'
    # #456: optionally ignore computed references
    test
      code: '''
        import * as names from './named-exports'
        console.log(names['a'])
      '''
      options: [allowComputed: yes]
    # #656: should handle object-rest properties
    test
      code: '''
        import * as names from './named-exports'
        {a, b, ...rest} = names
      '''
    ,
      # parserOptions:
      #   ecmaVersion: 2018
      # test
      #   code:
      #     "import * as names from './named-exports'; const {a, b, ...rest} = names;"
      #   parser: require.resolve 'babel-eslint'

      # # #1144: should handle re-export CommonJS as namespace
      test
        code: '''
          import * as ns from './re-export-common'
          {foo} = ns
        '''
      # JSX
      test
        code: '''
          import * as Names from "./named-exports"
          Foo = <Names.a/>
        '''
        # parserOptions:
        #   ecmaFeatures:
        #     jsx: yes
      ...SYNTAX_CASES
]

invalid = [
  test
    code: '''
        import * as names from './named-exports'
        console.log(names.c)
      '''
    errors: [error 'c', 'names']

  test
    code: '''
        import * as names from './named-exports'
        console.log(names['a'])
      '''
    errors: [
      "Unable to validate computed reference to imported namespace 'names'."
    ]

  # assignment warning (from no-reassign)
  test
    code: '''
      import * as foo from './bar'
      foo.foo = 'y'
    '''
    errors: [message: "Assignment to member of namespace 'foo'."]
  test
    code: '''
      import * as foo from './bar'
      foo.x = 'y'
    '''
    errors: [
      "Assignment to member of namespace 'foo'."
      "'x' not found in imported namespace 'foo'."
    ]

  # invalid destructuring
  test
    code: '''
      import * as names from "./named-exports"
      { c } = names
    '''
    errors: [
      type: 'Property', message: "'c' not found in imported namespace 'names'."
    ]
  test
    code: '''
        import * as names from "./named-exports"
        b = ->
          { c } = names
      '''
    errors: [
      type: 'Property'
      message: "'c' not found in imported namespace 'names'."
    ]
  test
    code: '''
      import * as names from "./named-exports"
      { c: d } = names
    '''
    errors: [
      type: 'Property', message: "'c' not found in imported namespace 'names'."
    ]
  test
    code: '''
      import * as names from "./named-exports"
      { c: { d } } = names
    '''
    errors: [
      type: 'Property', message: "'c' not found in imported namespace 'names'."
    ]

    # #///////
    # # es7 //
    # #///////

    # test
    #   code:
    #     'import * as Endpoints from "./issue-195/Endpoints"; console.log(Endpoints.Foo)'
    #   parser: require.resolve 'babel-eslint'
    #   errors: ["'Foo' not found in imported namespace 'Endpoints'."]

  # parse errors
  test
    code: "import * as namespace from './malformed.koffee'"
    errors: [
      message:
        "Parse errors in imported module './malformed.koffee': unexpected implicit function call (1:8)"
      type: 'Literal'
    ]

  test
    code: '''
      import b from './deep/default'
      console.log(b.e)
    '''
    errors: ["'e' not found in imported namespace 'b'."]

  # respect hoisting
  test
    code: '''
      console.log(names.c)
      import * as names from './named-exports'
    '''
    errors: [error 'c', 'names']
  test
    code: '''
      x = ->
        console.log(names.c)
      import * as names from './named-exports'
    '''
    errors: [error 'c', 'names']

  # #328: * exports do not include default
  test
    code: '''
      import * as ree from "./re-export"
      console.log(ree.default)
    '''
    errors: ["'default' not found in imported namespace 'ree'."]

  # JSX
  test
    code: '''
      import * as Names from "./named-exports"
      Foo = <Names.e/>
    '''
    errors: [error 'e', 'Names']
    # parserOptions:
    #   ecmaFeatures:
    #     jsx: yes
]

#/////////////////////
# deep dereferences //
#////////////////////
# close over params
valid.push(
  test
    code: '''
      import * as a from "./deep/a"
      console.log(a.b.c.d.e)
    '''
  test
    code: '''
      import { b } from "./deep/a"
      console.log(b.c.d.e)
    '''
  test
    code: '''
      import * as a from "./deep/a"
      console.log(a.b.c.d.e.f)
    '''
  test
    code: '''
      import * as a from "./deep/a"
      {b:{c:{d:{e}}}} = a
    '''
  test
    code: '''
      import { b } from "./deep/a"
      {c:{d:{e}}} = b
    '''
  # deep namespaces should include explicitly exported defaults
  test
    code: '''
      import * as a from "./deep/a"
      console.log(a.b.default)
    '''
)

invalid.push(
  test
    code: '''
      import * as a from "./deep/a"
      console.log(a.b.e)
    '''
    errors: ["'e' not found in deeply imported namespace 'a.b'."]
  test
    code: '''
      import { b } from "./deep/a"
      console.log(b.e)
    '''
    errors: ["'e' not found in imported namespace 'b'."]
  test
    code: '''
      import * as a from "./deep/a"
      console.log(a.b.c.e)
    '''
    errors: ["'e' not found in deeply imported namespace 'a.b.c'."]
  test
    code: '''
      import { b } from "./deep/a"
      console.log(b.c.e)
    '''
    errors: ["'e' not found in deeply imported namespace 'b.c'."]
  test
    code: '''
      import * as a from "./deep/a"
      {b:{ e }} = a
    '''
    errors: ["'e' not found in deeply imported namespace 'a.b'."]
  test
    code: '''
      import * as a from "./deep/a"
      {b:{c:{ e }}} = a
    '''
    errors: ["'e' not found in deeply imported namespace 'a.b.c'."]
)

ruleTester.run 'namespace', rule, {valid, invalid}
