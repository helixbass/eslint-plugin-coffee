{RuleTester} = require 'eslint'
path = require 'path'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/no-amd'

ruleTester.run 'no-amd', rule,
  valid: [
    'import "x"'
    'import x from "x"'
    'x = require("x")'

    'require("x")'
    # 2-args, not an array
    'require("x", "y")'
    # random other function
    'setTimeout(foo, 100)'
    # non-identifier callee
    '(a or b)(1, 2, 3)'

    # nested scope is fine
    '''
      x = ->
        define ["a"], (a) ->
    '''
    '''
      x = ->
        require ["a"], (a) ->
    '''

    # unmatched arg types/number
    'define(0, 1, 2)'
    'define "a"'
  ]

  invalid: [
    code: 'define [], ->'
    errors: [message: 'Expected imports instead of AMD define().']
  ,
    code: 'define(["a"], (a) -> console.log(a))'
    errors: [message: 'Expected imports instead of AMD define().']
  ,
    code: 'require [], ->'
    errors: [message: 'Expected imports instead of AMD require().']
  ,
    code: 'require ["a"], (a) -> console.log a'
    errors: [message: 'Expected imports instead of AMD require().']
  ]
