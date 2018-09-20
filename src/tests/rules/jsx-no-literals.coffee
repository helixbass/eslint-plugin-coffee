###*
# @fileoverview Prevent using unwrapped literals in a React component definition
# @author Caleb morris
# @author David Buchan-Swanson
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react/lib/rules/jsx-no-literals'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'jsx-no-literals', rule,
  valid: [
    code: """
        class Comp1 extends Component
          render: ->
            return (
              <div>
                {'asdjfl'}
              </div>
            )
      """
  ,
    # parser: 'babel-eslint'
    code: """
        class Comp1 extends Component
          render: ->
            return (
              <>
                {'asdjfl'}
              </>
            )
      """
  ,
    # parser: 'babel-eslint'
    code: """
        class Comp1 extends Component
          render: ->
            (<div>{'test'}</div>)
      """
  ,
    # parser: 'babel-eslint'
    code: """
        class Comp1 extends Component
          render: ->
            bar = (<div>{'hello'}</div>)
            return bar
      """
  ,
    # parser: 'babel-eslint'
    code: """
        Hello = createReactClass({
          foo: (<div>{'hello'}</div>),
          render: ->
            return this.foo
        })
      """
  ,
    # parser: 'babel-eslint'
    code: """
        class Comp1 extends Component
          render: ->
            return (
              <div>
                {'asdjfl'}
                {'test'}
                {'foo'}
              </div>
            )
      """
  ,
    # parser: 'babel-eslint'
    code: """
        class Comp1 extends Component
          render: ->
            return (
              <div>
              </div>
            )
      """
  ,
    # parser: 'babel-eslint'
    code: """
        foo = require('foo')
      """
  ,
    # parser: 'babel-eslint'
    code: """
        <Foo bar='test'>
          {'blarg'}
        </Foo>
      """
  ,
    # parser: 'babel-eslint'
    code: """
        <Foo bar="test">
          {intl.formatText(message)}
        </Foo>
      """
    # parser: 'babel-eslint'
    options: [noStrings: yes]
  ,
    code: """
        <Foo bar="test">
          {translate('my.translate.key')}
        </Foo>
      """
    # parser: 'babel-eslint'
    options: [noStrings: yes]
  ,
    code: """
        <Foo bar="test">
          {intl.formatText(message)}
        </Foo>
      """
    options: [noStrings: yes]
  ,
    code: """
        <Foo bar="test">
          {translate('my.translate.key')}
        </Foo>
      """
    options: [noStrings: yes]
  ,
    code: '<Foo bar={true} />'
    options: [noStrings: yes]
  ,
    code: '<Foo bar={false} />'
    options: [noStrings: yes]
  ,
    code: '<Foo bar={100} />'
    options: [noStrings: yes]
  ,
    code: '<Foo bar={null} />'
    options: [noStrings: yes]
  ,
    code: '<Foo bar={{}} />'
    options: [noStrings: yes]
  ,
    code: """
        class Comp1 extends Component
          asdf: ->
          render: ->
            return <Foo bar={this.asdf} />
      """
    options: [noStrings: yes]
  ,
    code: """
        class Comp1 extends Component
          render: ->
            foo = "bar"
            return <div />
      """
    options: [noStrings: yes]
  ]

  invalid: [
    code: """
        class Comp1 extends Component
          render: ->
            return (<div>test</div>)
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        class Comp1 extends Component
          render: ->
            return (<>test</>)
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        class Comp1 extends Component
          render: ->
            foo = (<div>test</div>)
            return foo
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        class Comp1 extends Component
          render: ->
            varObjectTest = { testKey : (<div>test</div>) }
            return varObjectTest.testKey
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        Hello = createReactClass({
          foo: (<div>hello</div>),
          render: ->
            return this.foo
        })
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        class Comp1 extends Component
          render: ->
            return (
              <div>
                asdjfl
              </div>
            )
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        class Comp1 extends Component
          render: ->
            return (
              <div>
                asdjfl
                test
                foo
              </div>
            )
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        class Comp1 extends Component
          render: ->
            return (
              <div>
                {'asdjfl'}
                test
                {'foo'}
              </div>
            )
      """
    # parser: 'babel-eslint'
    errors: [message: 'Missing JSX expression container around literal string']
  ,
    code: """
        <Foo bar="test">
          {'Test'}
        </Foo>
      """
    # parser: 'babel-eslint'
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: """
        <Foo bar="test">
          {'Test'}
        </Foo>
      """
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: """
        <Foo bar="test">
          {'Test' + name}
        </Foo>
      """
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: """
        <Foo bar="test">
          Test
        </Foo>
      """
    # parser: 'babel-eslint'
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: """
        <Foo bar="test">
          Test
        </Foo>
      """
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: """
        <Foo>
          {"Test"}
        </Foo>
      """
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: '<Foo bar={"Test"} />'
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: '<Foo bar={"#{baz}"} />'
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: '<Foo bar={"Test #{baz}"} />'
    options: [noStrings: yes]
    errors: [message: 'Strings not allowed in JSX files']
  ,
    code: '<Foo bar={"foo" + \'bar\'} />'
    options: [noStrings: yes]
    errors: [
      message: 'Strings not allowed in JSX files'
    ,
      message: 'Strings not allowed in JSX files'
    ]
  ,
    code: '<Foo bar={"foo" + "bar"} />'
    options: [noStrings: yes]
    errors: [
      message: 'Strings not allowed in JSX files'
    ,
      message: 'Strings not allowed in JSX files'
    ]
  ,
    code: '<Foo bar={\'foo\' + "bar"} />'
    options: [noStrings: yes]
    errors: [
      message: 'Strings not allowed in JSX files'
    ,
      message: 'Strings not allowed in JSX files'
    ]
  ]
