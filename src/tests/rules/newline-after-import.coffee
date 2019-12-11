{RuleTester} = require 'eslint'
path = require 'path'

IMPORT_ERROR_MESSAGE =
  'Expected 1 empty line after import statement not followed by another import.'
IMPORT_ERROR_MESSAGE_MULTIPLE = (count) ->
  "Expected #{count} empty lines after import statement not followed by another import."
REQUIRE_ERROR_MESSAGE =
  'Expected 1 empty line after require statement not followed by another require.'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require 'eslint-plugin-import/lib/rules/newline-after-import'
ruleTester.run 'newline-after-import', rule,
  valid: [
    '''
      path = require('path')
      foo = require('foo')
    '''
    "require('foo')"
    '''
      switch 'foo'
        when 'bar'
          require('baz')
    '''
  ,
    code: '''
      x = () => require('baz')
      y = () => require('bar')
    '''
  ,
    code: "x = () => require('baz') && require('bar')"
  ,
    "x = -> require('baz')"
    "a(require('b'), require('c'), require('d'))"
    '''
      foo = ->
        switch renderData.modalViewKey
          when 'value'
            bar = require('bar')
            return bar(renderData, options)
          else
            return renderData.mainModalContent.clone()
    '''
  ,
    code: '''
      #issue 441
      bar = ->
        switch foo
          when '1'
            return require('../path/to/file1.jst.hbs')(renderData, options)
          when '2'
            return require('../path/to/file2.jst.hbs')(renderData, options)
          when '3'
            return require('../path/to/file3.jst.hbs')(renderData, options)
          when '4'
            return require('../path/to/file4.jst.hbs')(renderData, options)
          when '5'
            return require('../path/to/file5.jst.hbs')(renderData, options)
          when '6'
            return require('../path/to/file6.jst.hbs')(renderData, options)
          when '7'
            return require('../path/to/file7.jst.hbs')(renderData, options)
          when '8'
            return require('../path/to/file8.jst.hbs')(renderData, options)
          when '9'
            return require('../path/to/file9.jst.hbs')(renderData, options)
          when '10'
            return require('../path/to/file10.jst.hbs')(renderData, options)
          when '11'
            return require('../path/to/file11.jst.hbs')(renderData, options)
          when '12'
            return something()
          else
            return somethingElse()
    '''
  ,
    code: '''
      import path from 'path'
      import foo from 'foo'
    '''
  ,
    code: '''
      import path from 'path'
      import foo from 'foo'
    '''
  ,
    code: '''
      import path from 'path'
      import foo from 'foo'

      bar = 42
    '''
  ,
    code: '''
      import foo from 'foo'
      
      bar = 'bar'
    '''
  ,
    code: '''
      import foo from 'foo'
      
      
      bar = 'bar'
    '''
    options: [count: 2]
  ,
    code: '''
      import foo from 'foo'
      
      
      
      
      bar = 'bar'
    '''
    options: [count: 4]
  ,
    code: '''
      foo = require('foo-module')
      
      foo = 'bar'
    '''
  ,
    code: '''
      foo = require('foo-module')
      
      
      foo = 'bar'
    '''
    options: [count: 2]
  ,
    code: '''
      foo = require('foo-module')
      
      
      
      
      foo = 'bar'
    '''
    options: [count: 4]
  ,
    code: '''
      require('foo-module')
      
      foo = 'bar'
    '''
  ,
    code: '''
      import foo from 'foo'
      import { bar } from './bar-lib'
    '''
  ,
    code: '''
      import foo from 'foo'
      
      a = 123
      
      import { bar } from './bar-lib'
    '''
  ,
    code: '''
      foo = require('foo-module')
      
      a = 123
      
      bar = require('bar-lib')
    '''
  ,
    code: '''
      foo = ->
        foo = require('foo')
        foo()
    '''
  ,
    code: '''
      if true
        foo = require('foo')
        foo()
    '''
  ,
    code: '''
      a = ->
        assign = Object.assign or require('object-assign')
        foo = require('foo')
        bar = 42
    '''
    # ,
    #   code: """
    #     #issue 592
    #     @SomeDecorator(require('./some-file'))
    #     export default class App {}
    #   """
    #   parserOptions: sourceType: 'module'
    #   parser: 'babel-eslint'
    # ,
    #   code: "foo = require('foo')\n\n@SomeDecorator(foo)\nclass Foo {}"
    #   parserOptions: sourceType: 'module'
    #   parser: 'babel-eslint'
  ]

  invalid: [
    code: '''
      import foo from 'foo'
      export default ->
    '''
    output: '''
      import foo from 'foo'
      
      export default ->
    '''
    errors: [
      line: 1
      column: 1
      message: IMPORT_ERROR_MESSAGE
    ]
  ,
    code: '''
      import foo from 'foo'
      
      export default ->
    '''
    output: '''
      import foo from 'foo'
      
      
      export default ->
    '''
    options: [count: 2]
    errors: [
      line: 1
      column: 1
      # eslint-disable-next-line new-cap
      message: IMPORT_ERROR_MESSAGE_MULTIPLE 2
    ]
  ,
    code: '''
      foo = require('foo-module')
      something = 123
    '''
    output: '''
      foo = require('foo-module')
      
      something = 123
    '''
    errors: [
      line: 1
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
  ,
    code: '''
      import foo from 'foo'
      export default ->
    '''
    output: '''
      import foo from 'foo'
      
      export default ->
    '''
    options: [count: 1]
    errors: [
      line: 1
      column: 1
      message: IMPORT_ERROR_MESSAGE
    ]
  ,
    code: '''
      foo = require('foo-module')
      something = 123
    '''
    output: '''
      foo = require('foo-module')
      
      something = 123
    '''
    errors: [
      line: 1
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
  ,
    code: '''
      import foo from 'foo'
      a = 123
      
      import { bar } from './bar-lib'
      b=456
    '''
    output: '''
      import foo from 'foo'
      
      a = 123
      
      import { bar } from './bar-lib'
      
      b=456
    '''
    errors: [
      line: 1
      column: 1
      message: IMPORT_ERROR_MESSAGE
    ,
      line: 4
      column: 1
      message: IMPORT_ERROR_MESSAGE
    ]
  ,
    code: '''
      foo = require('foo-module')
      a = 123
      
      bar = require('bar-lib')
      b=456
    '''
    output: '''
      foo = require('foo-module')
      
      a = 123
      
      bar = require('bar-lib')
      
      b=456
    '''
    errors: [
      line: 1
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ,
      line: 4
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
  ,
    code: '''
      foo = require('foo-module')
      a = 123
      
      require('bar-lib')
      b=456
    '''
    output: '''
      foo = require('foo-module')
      
      a = 123
      
      require('bar-lib')
      
      b=456
    '''
    errors: [
      line: 1
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ,
      line: 4
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
    parserOptions: sourceType: 'module'
  ,
    code: '''
      path = require('path')
      foo = require('foo')
      bar = 42
    '''
    output: '''
      path = require('path')
      foo = require('foo')
      
      bar = 42
    '''
    errors: [
      line: 2
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
  ,
    code: '''
      assign = Object.assign or require('object-assign')
      foo = require('foo')
      bar = 42
    '''
    output: '''
      assign = Object.assign or require('object-assign')
      foo = require('foo')
      
      bar = 42
    '''
    errors: [
      line: 2
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
  ,
    code: '''
      require('a')
      foo(require('b'), require('c'), require('d'))
      require('d')
      foo = 'bar'
    '''
    output: '''
      require('a')
      foo(require('b'), require('c'), require('d'))
      require('d')
      
      foo = 'bar'
    '''
    errors: [
      line: 3
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
  ,
    code: '''
      require('a')
      foo(
        require('b'),
        require('c'),
        require('d')
      )
      foo = 'bar'
    '''
    output: '''
      require('a')
      foo(
        require('b'),
        require('c'),
        require('d')
      )
      
      foo = 'bar'
    '''
    errors: [
      line: 6
      column: 1
      message: REQUIRE_ERROR_MESSAGE
    ]
  ,
    code: '''
      import path from 'path'
      import foo from 'foo'
      bar = 42
    '''
    output: '''
      import path from 'path'
      import foo from 'foo'
      
      bar = 42
    '''
    errors: [
      line: 2
      column: 1
      message: IMPORT_ERROR_MESSAGE
    ]
    # ,
    #   code: """
    #     import foo from 'foo'
    #     @SomeDecorator(foo)\nclass Foo {}"
    #   output: "import foo from 'foo'\n\n@SomeDecorator(foo)\nclass Foo {}"
    #   errors: [
    #     line: 1
    #     column: 1
    #     message: IMPORT_ERROR_MESSAGE
    #   ]
    #   parserOptions: sourceType: 'module'
    #   parser: 'babel-eslint'
    # ,
    #   code: "foo = require('foo')\n@SomeDecorator(foo)\nclass Foo {}"
    #   output: "foo = require('foo')\n\n@SomeDecorator(foo)\nclass Foo {}"
    #   errors: [
    #     line: 1
    #     column: 1
    #     message: REQUIRE_ERROR_MESSAGE
    #   ]
    #   parserOptions: sourceType: 'module'
    #   parser: 'babel-eslint'
  ]
