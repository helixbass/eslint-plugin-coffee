###*
# @fileoverview Validate JSX indentation
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/jsx-indent'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'jsx-indent', rule,
  valid: [
    code: ['<App></App>'].join '\n'
  ,
    code: ['<></>'].join '\n'
  ,
    # parser: 'babel-eslint'
    code: ['<App>', '</App>'].join '\n'
  ,
    code: ['<>', '</>'].join '\n'
  ,
    # parser: 'babel-eslint'
    code: ['<App>', '  <Foo />', '</App>'].join '\n'
    options: [2]
  ,
    code: ['<App>', '  <></>', '</App>'].join '\n'
    # parser: 'babel-eslint'
    options: [2]
  ,
    code: ['<>', '  <Foo />', '</>'].join '\n'
    # parser: 'babel-eslint'
    options: [2]
  ,
    code: ['<App>', '<Foo />', '</App>'].join '\n'
    options: [0]
  ,
    code: ['  <App>', '<Foo />', '  </App>'].join '\n'
    options: [-2]
  ,
    code: ['<App>', '\t<Foo />', '</App>'].join '\n'
    options: ['tab']
  ,
    code: ['App = ->', '  return <App>', '    <Foo />', '  </App>'].join '\n'
    options: [2]
  ,
    code: ['App = ->', '  return <App>', '    <></>', '  </App>'].join '\n'
    # parser: 'babel-eslint'
    options: [2]
  ,
    code: ['App = ->', '  return (<App>', '    <Foo />', '  </App>)'].join '\n'
    options: [2]
  ,
    code: ['App = ->', '  return (<App>', '    <></>', '  </App>)'].join '\n'
    # parser: 'babel-eslint'
    options: [2]
  ,
    code: [
      'App = ->'
      '  return ('
      '    <App>'
      '      <Foo />'
      '    </App>'
      '  )'
    ].join '\n'
    options: [2]
  ,
    code: [
      'App = ->'
      '  return ('
      '    <App>'
      '      <></>'
      '    </App>'
      '  )'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [2]
  ,
    code: [
      'it('
      '  ('
      '    <div>'
      '      <span />'
      '    </div>'
      '  )'
      ')'
    ].join '\n'
    options: [2]
  ,
    code: [
      'it('
      '  ('
      '    <div>'
      '      <></>'
      '    </div>'
      '  )'
      ')'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [2]
  ,
    code: [
      'it('
      '  (<div>'
      '    <span />'
      '    <span />'
      '    <span />'
      '  </div>)'
      ')'
    ].join '\n'
    options: [2]
  ,
    code: ['(', '  <div>', '    <span />', '  </div>', ')'].join '\n'
    options: [2]
  ,
    code: ['head.title &&', '  <h1>', '    {head.title}', '  </h1>'].join '\n'
    options: [2]
  ,
    # code: ['  head.title &&', '  <>', '    {head.title}', '  </>'].join '\n'
    code: ['head.title &&', '  <>', '    {head.title}', '  </>'].join '\n'
    # parser: 'babel-eslint'
    options: [2]
  ,
    code: [
      '  head.title &&'
      '    <h1>'
      '      {head.title}'
      '    </h1>'
    ].join '\n'
    options: [2]
  ,
    code: [
      '  head.title && ('
      '    <h1>'
      '      {head.title}'
      '    </h1>)'
    ].join '\n'
    options: [2]
  ,
    code: [
      '  head.title && ('
      '    <h1>'
      '      {head.title}'
      '    </h1>'
      '  )'
    ].join '\n'
    options: [2]
  ,
    # parser: 'babel-eslint'
    # Literals indentation is not touched
    code: [
      '<div>'
      'bar <div>'
      '   bar'
      '   bar {foo}'
      'bar </div>'
      '</div>'
    ].join '\n'
  ,
    code: ['<>', 'bar <>', '   bar', '   bar {foo}', 'bar </>', '</>'].join '\n'
  ,
    # parser: 'babel-eslint'
    code: '''
      class Test extends React.Component
        render: ->
          return (
            <div>
              <div />
              <div />
            </div>
          )
    '''
    options: [2]
  ,
    code: '''
      class Test extends React.Component
        render: ->
          return (
            <>
              <></>
              <></>
            </>
          )
    '''
    # parser: 'babel-eslint'
    options: [2]
  ]

  invalid: [
    code: ['<App>', '  <Foo />', '</App>'].join '\n'
    output: ['<App>', '    <Foo />', '</App>'].join '\n'
    errors: [message: 'Expected indentation of 4 space characters but found 2.']
  ,
    # ,
    #   code: ['<App>', '  <></>', '</App>'].join '\n'
    #   # parser: 'babel-eslint'
    #   output: ['<App>', '    <></>', '</App>'].join '\n'
    #   errors: [
    #     message: 'Expected indentation of 4 space characters but found 2.'
    #   ]
    code: ['<>', '  <Foo />', '</>'].join '\n'
    # parser: 'babel-eslint'
    output: ['<>', '    <Foo />', '</>'].join '\n'
    errors: [message: 'Expected indentation of 4 space characters but found 2.']
  ,
    code: ['<App>', '    <Foo />', '</App>'].join '\n'
    output: ['<App>', '  <Foo />', '</App>'].join '\n'
    options: [2]
    errors: [message: 'Expected indentation of 2 space characters but found 4.']
  ,
    code: ['<App>', '    <Foo />', '</App>'].join '\n'
    output: ['<App>', '\t<Foo />', '</App>'].join '\n'
    options: ['tab']
    errors: [message: 'Expected indentation of 1 tab character but found 0.']
  ,
    code: ['App = ->', '  return <App>', '    <Foo />', '         </App>'].join(
      '\n'
    )
    output: ['App = ->', '  return <App>', '    <Foo />', '  </App>'].join '\n'
    options: [2]
    errors: [message: 'Expected indentation of 2 space characters but found 9.']
  ,
    code: ['App = ->', '  return (<App>', '    <Foo />', '    </App>)'].join(
      '\n'
    )
    output: ['App = ->', '  return (<App>', '    <Foo />', '  </App>)'].join(
      '\n'
    )
    options: [2]
    errors: [message: 'Expected indentation of 2 space characters but found 4.']
  ,
    code: ['<App>', '   {test}', '</App>'].join '\n'
    output: ['<App>', '    {test}', '</App>'].join '\n'
    errors: [message: 'Expected indentation of 4 space characters but found 3.']
  ,
    code: [
      '<App>'
      '    {options.map (option, index) => ('
      '        <option key={index} value={option.key}>'
      '           {option.name}'
      '        </option>'
      '    )}'
      '</App>'
    ].join '\n'
    output: [
      '<App>'
      '    {options.map (option, index) => ('
      '        <option key={index} value={option.key}>'
      '            {option.name}'
      '        </option>'
      '    )}'
      '</App>'
    ].join '\n'
    errors: [
      message: 'Expected indentation of 12 space characters but found 11.'
    ]
  ,
    code: ['<App>', '{test}', '</App>'].join '\n'
    output: ['<App>', '\t{test}', '</App>'].join '\n'
    options: ['tab']
    errors: [message: 'Expected indentation of 1 tab character but found 0.']
  ,
    code: [
      '<App>'
      '\t{options.map (option, index) => ('
      '\t\t<option key={index} value={option.key}>'
      '\t\t{option.name}'
      '\t\t</option>'
      '\t)}'
      '</App>'
    ].join '\n'
    output: [
      '<App>'
      '\t{options.map (option, index) => ('
      '\t\t<option key={index} value={option.key}>'
      '\t\t\t{option.name}'
      '\t\t</option>'
      '\t)}'
      '</App>'
    ].join '\n'
    options: ['tab']
    errors: [message: 'Expected indentation of 3 tab characters but found 2.']
  ,
    code: ['<App>\n', '<Foo />\n', '</App>'].join '\n'
    output: ['<App>\n', '\t<Foo />\n', '</App>'].join '\n'
    options: ['tab']
    errors: [message: 'Expected indentation of 1 tab character but found 0.']
  ,
    code: ['<App>\n', ' <Foo />\n', '</App>'].join '\n'
    output: ['<App>\n', '\t<Foo />\n', '</App>'].join '\n'
    options: ['tab']
    errors: [message: 'Expected indentation of 1 tab character but found 0.']
  ,
    code: ['<App>\n', '\t<Foo />\n', '</App>'].join '\n'
    output: ['<App>\n', '  <Foo />\n', '</App>'].join '\n'
    options: [2]
    errors: [message: 'Expected indentation of 2 space characters but found 0.']
  ,
    code: [
      '<p>'
      '    <div>'
      '        <SelfClosingTag />Text'
      '  </div>'
      '</p>'
    ].join '\n'
    errors: [message: 'Expected indentation of 4 space characters but found 2.']
  ]
