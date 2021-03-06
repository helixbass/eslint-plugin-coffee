###*
# @fileoverview Prevent usage of unnecessary double quotes.
# @author Julian Rosse
###

'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-unnecessary-double-quotes'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ERROR = messageId: 'noDoubleQuotes'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###

ruleTester.run 'no-unnecessary-double-quotes', rule,
  valid: [
    "foo = 'single'"
    'interpolation = "inter#{polation}"'
    'multipleInterpolation = "#{foo}bar#{baz}"'
    '''
      singleQuote = "single'quote"
    '''
    '''
      foo = """
        #{interpolation}foo
      """
    '''
    '''
      foo = """
        'some single quotes for good measure'
      """
    '''
    """
      foo = '''
        singleblock
      '''
    """
    '"use strict"'
    '''
      ->
        "use strict"
        b
    '''
    'd = ///#{foo}///i'
    '''
      d = ///
        #{foo}
      ///i
    '''
    'c = RegExp(".*#{a}0-9")'
    '''
      <div data-testid="wrapper" />
    '''
  ]
  invalid: [
    code: 'foo = "double"'
    errors: [ERROR]
  ,
    code: '''
      foo = """
        doubleblock
      """
    '''
    errors: [ERROR]
  ,
    code: '''
      foo = (("inter") + "polation")
    '''
    errors: [ERROR, ERROR]
  ]
