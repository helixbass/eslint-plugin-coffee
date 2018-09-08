{RuleTester} = require 'eslint'

EXPORT_MESSAGE = 'Expected "export" or "export default"'
IMPORT_MESSAGE = 'Expected "import" instead of "require()"'

rule = require '../../rules/no-commonjs'

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-commonjs', rule,
  valid: [
    # imports
    'import "x"'
    'import x from "x"'
    'import x from "x"'
    'import { x } from "x"'
    # exports
    'export default "x"'
    'export house = ->'
    '''
      someFunc = ->
        exports = someComputation()
        expect(exports.someProp).toEqual a: 'value'
    '''
    # allowed requires
    '''
      a = ->
        x = require "y"
    ''' # nested requires allowed
    'a = c && require("b")' # conditional requires allowed
    'a = c and require("b")'
    'require.resolve("help")' # methods of require are allowed
    'require.ensure([])' # webpack specific require.ensure is allowed
    'require([], (a, b, c) ->)' # AMD require is allowed
    "bar = require('./bar', true)"
    "bar = proxyquire('./bar')"
    "bar = require('./ba' + 'r')"
    'zero = require(0)'
  ,
    code: 'require("x")', options: [allowRequire: yes]
  ,
    code: 'module.exports = ->'
    options: ['allow-primitive-modules']
  ,
    code: 'module.exports = ->'
    options: [allowPrimitiveModules: yes]
  ,
    code: 'module.exports = "foo"', options: ['allow-primitive-modules']
  ,
    code: 'module.exports = "foo"', options: [allowPrimitiveModules: yes]
  ]

  invalid: [
    # imports
    code: 'x = require("x")', errors: [message: IMPORT_MESSAGE]
  ,
    code: 'require("x")', errors: [message: IMPORT_MESSAGE]
  ,
    # exports
    code: 'exports.face = "palm"', errors: [message: EXPORT_MESSAGE]
  ,
    code: 'module.exports.face = "palm"', errors: [message: EXPORT_MESSAGE]
  ,
    code: 'module.exports = face', errors: [message: EXPORT_MESSAGE]
  ,
    code: 'exports = module.exports = {}', errors: [message: EXPORT_MESSAGE]
  ,
    code: 'x = module.exports = {}', errors: [message: EXPORT_MESSAGE]
  ,
    code: 'module.exports = {}'
    options: ['allow-primitive-modules']
    errors: [message: EXPORT_MESSAGE]
  ,
    code: 'x = module.exports'
    options: ['allow-primitive-modules']
    errors: [message: EXPORT_MESSAGE]
  ]
