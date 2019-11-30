###*
# @fileoverview Tests for prefer-template rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/prefer-template'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

errors = [
  message: 'Unexpected string concatenation.'
  type: 'BinaryExpression'
]

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'prefer-template', rule,
  valid: [
    "'use strict'"
    "foo = 'foo' + '\\0'"
    "foo = 'bar'"
    "foo = 'bar' + 'baz'"
    "foo = foo + +'100'"
    'foo = "bar"'
    'foo = "hello, #{name}!"'

    # https://github.com/eslint/eslint/issues/3507
    'foo = "foo" + "bar" + "hoge"'
    'foo = "foo" +\n    "bar" +\n    "hoge"'
  ]
  invalid: [
    {
      code: "foo = 'hello, ' + name + '!'"
      output: 'foo = "hello, #{  name  }!"'
      errors
    }
    {
      code: "foo = bar + 'baz'"
      output: 'foo = "#{bar  }baz"'
      errors
    }
    {
      code: 'foo = bar + "baz"'
      output: 'foo = "#{bar  }baz"'
      errors
    }
    {
      code: "foo = +100 + 'yen'"
      output: 'foo = "#{+100  }yen"'
      errors
    }
    {
      code: "foo = 'bar' + baz"
      output: 'foo = "bar#{  baz}"'
      errors
    }
    {
      code: "foo = '￥' + (n * 1000) + '-'"
      output: 'foo = "￥#{  n * 1000  }-"'
      errors
    }
  ,
    code: '''
      foo = 'aaa' + aaa
      bar = 'bbb' + bbb
    '''
    output: '''
      foo = "aaa#{  aaa}"
      bar = "bbb#{  bbb}"
    '''
    errors: [errors[0], errors[0]]
  ,
    {
      code: "string = (number + 1) + 'px'"
      output: 'string = "#{number + 1  }px"'
      errors
    }
    {
      code: "foo = 'bar' + baz + 'qux'"
      output: 'foo = "bar#{  baz  }qux"'
      errors
    }
    {
      code: 'foo = \'0 backslashes: #{bar}\' + baz'
      output: 'foo = "0 backslashes: \\#{bar}#{  baz}"'
      errors
    }
    {
      code: 'foo = \'1 backslash: \\#{bar}\' + baz'
      output: 'foo = "1 backslash: \\#{bar}#{  baz}"'
      errors
    }
    {
      code: 'foo = \'2 backslashes: \\\\#{bar}\' + baz'
      output: 'foo = "2 backslashes: \\\\\\#{bar}#{  baz}"'
      errors
    }
    {
      code: 'foo = \'3 backslashes: \\\\\\#{bar}\' + baz'
      output: 'foo = "3 backslashes: \\\\\\#{bar}#{  baz}"'
      errors
    }
    {
      code: "foo = bar + 'this is a backtick: \"' + baz"
      output: 'foo = "#{bar  }this is a backtick: \\"#{  baz}"'
      errors
    }
    {
      code: '''
        foo = bar + 'this is a backtick preceded by a backslash: \\"' + baz
      '''
      output: '''
        foo = "#{bar  }this is a backtick preceded by a backslash: \\"#{  baz}"
      '''
      errors
    }
    {
      code: '''
        foo = bar + 'this is a backtick preceded by two backslashes: \\\\"' + baz
      '''
      output: '''
        foo = "#{bar  }this is a backtick preceded by two backslashes: \\\\\\"#{  baz}"
      '''
      errors
    }
    {
      code: 'foo = bar + "#{baz}foo"'
      output: 'foo = "#{bar  }#{baz}foo"'
      errors
    }
    {
      code: '''
        foo = 'favorites: ' + (favorites.map (f) ->
          f.name
        ) + ''
      '''
      output: '''
        foo = "favorites: #{  favorites.map (f) ->
          f.name  }"
      '''
      errors
    }
    {
      code: "foo = bar + baz + 'qux'"
      output: 'foo = "#{bar + baz  }qux"'
      errors
    }
    {
      code: '''
        foo = 'favorites: ' +
          favorites.map((f) =>
            return f.name
          ) +
        ''
      '''
      output: '''
        foo = "favorites: #{ 
          favorites.map((f) =>
            return f.name
          ) 
        }"
      '''
      errors
    }
    {
      code:
        "foo = ### a ### 'bar' ### b ### + ### c ### baz ### d ### + 'qux' ### e ### "
      output:
        'foo = ### a ### "bar#{ ### b ###  ### c ### baz ### d ###  }qux" ### e ### '
      errors
    }
    {
      code: "foo = bar + ('baz') + 'qux' + (boop)"
      output: 'foo = "#{bar  }baz" + "qux#{  boop}"'
      errors
    }
    {
      code:
        "foo + 'unescapes an escaped single quote in a single-quoted string: \\''"
      output:
        '"#{foo  }unescapes an escaped single quote in a single-quoted string: \'"'
      errors
    }
    {
      code:
        'foo + "unescapes an escaped double quote in a double-quoted string: \\""'
      output:
        '"#{foo  }unescapes an escaped double quote in a double-quoted string: \\""'
      errors
    }
    {
      code:
        "foo + 'does not unescape an escaped double quote in a single-quoted string: \\\"'"
      output:
        '"#{foo  }does not unescape an escaped double quote in a single-quoted string: \\""'
      errors
    }
    {
      code:
        'foo + "does not unescape an escaped single quote in a double-quoted string: \\\'"'
      output:
        '"#{foo  }does not unescape an escaped single quote in a double-quoted string: \\\'"'
      errors
    }
    {
      code: "foo + 'handles unicode escapes correctly: \\x27'" # "\x27" === "'"
      output: '"#{foo  }handles unicode escapes correctly: \\x27"'
      errors
    }
    {
      code: "foo + '\\\\033'"
      output: '"#{foo  }\\\\033"'
      errors
    }
    {
      code: "foo + '\\0'"
      output: '"#{foo  }\\0"'
      errors
    }
  ]
