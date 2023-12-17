###*
# @fileoverview Tests for prefer-spread rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/prefer-spread'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

errors = [
  message: "Use the spread operator instead of '.apply()'."
  type: 'CallExpression'
]

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'prefer-spread', rule,
  valid: [
    'foo.apply(obj, args)'
    'obj.foo.apply null, args'
    'obj.foo.apply(otherObj, args)'
    'a.b(x, y).c.foo.apply(a.b(x, z).c, args)'
    'a.b.foo.apply(a.b.c, args)'

    # ignores non variadic.
    'foo.apply(undefined, [1, 2])'
    'foo.apply(null, [1, 2])'
    'obj.foo.apply(obj, [1, 2])'

    # ignores computed property.
    '''
      apply = null
      foo[apply](null, args)
    '''

    # ignores incomplete things.
    'foo.apply()'
    'obj.foo.apply()'
    'obj.foo.apply(obj, ...args)'
  ]
  invalid: [
    {
      code: 'foo.apply(undefined, args)'
      errors
    }
    {
      code: 'foo.apply(null, args)'
      errors
    }
    {
      code: 'obj.foo.apply(obj, args)'
      errors
    }
    {
      code: 'obj.foo.apply obj, args'
      errors
    }
    {
      # Not fixed: a.b.c might activate getters
      code: 'a.b.c.foo.apply(a.b.c, args)'
      output: null
      errors
    }
    {
      # Not fixed: a.b(x, y).c might activate getters
      code: 'a.b(x, y).c.foo.apply(a.b(x, y).c, args)'
      output: null
      errors
    }
    {
      # Not fixed (not an identifier)
      code: '[].concat.apply([ ], args)'
      output: null
      errors
    }
    {
      # Not fixed (not an identifier)
      code: '''
        [].concat.apply([
          ###empty###
        ], args)
      '''
      output: null
      errors
    }
  ]
