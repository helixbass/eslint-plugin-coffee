###*
# @fileoverview Tests for jsx-no-comment-textnodes
# @author Ben Vinegar
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/jsx-no-comment-textnodes'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-no-comment-textnodes', rule,
  valid: [
    code: """
      class Comp1 extends Component
        render: ->
          return (
            <div>
              {### valid ###}
            </div>
          )
    """
  ,
    # parser: 'babel-eslint'
    code: """
      class Comp1 extends Component
        render: ->
          (
            <>
              {### valid ###}
            </>
          )
    """
  ,
    # parser: 'babel-eslint'
    code: """
      class Comp1 extends Component
        render: ->
          return (<div>{### valid ###}</div>)
    """
  ,
    # parser: 'babel-eslint'
    code: """
      class Comp1 extends Component
        render: ->
          bar = (<div>{### valid ###}</div>)
          return bar
    """
  ,
    # parser: 'babel-eslint'
    code: """
      Hello = createReactClass({
        foo: (<div>{### valid ###}</div>),
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
              {### valid ###}
              {### valid 2 ###}
              {### valid 3 ###}
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
        {### valid ###}
      </Foo>
    """
  ,
    # parser: 'babel-eslint'
    code: """
      <strong>
        &nbsp;https://www.example.com/attachment/download/1
      </strong>
    """
  ,
    # parser: 'babel-eslint'
    # inside element declarations
    code: """
      <Foo ### valid ### placeholder={'foo'}/>
    """
  ,
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #     <### valid ###></>
    #   """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #     <><### valid ###/>
    #   """
    # parser: 'babel-eslint'
    code: """
      <Foo title={'foo' ### valid ###}/>
    """
  ,
    # parser: 'babel-eslint'
    code: '<pre>&#x2F;&#x2F; TODO: Write perfect code</pre>'
  ,
    code: '<pre>&#x2F;&#x2F; TODO: Write perfect code</pre>'
  ,
    # parser: 'babel-eslint'
    code: '<pre>&#x2F;&#42; TODO: Write perfect code &#42;&#x2F;</pre>'
  ,
    code: '<pre>&#x2F;&#42; TODO: Write perfect code &#42;&#x2F;</pre>'
  ,
    # parser: 'babel-eslint'
    code: """
      class Comp1 extends Component
        render: ->
          return (<div>// invalid</div>)
    """
  ,
    code: """
      class Comp1 extends Component
        render: ->
          return (<div>/* invalid */</div>)
    """
  ]

  invalid: [
    code: """
      class Comp1 extends Component
        render: ->
          return (<div># invalid</div>)
    """
    # parser: 'babel-eslint'
    errors: [
      message:
        'Comments inside children section of tag should be placed inside braces'
    ]
  ,
    code: """
      class Comp1 extends Component
        render: ->
          return (<># invalid</>)
    """
    # parser: 'babel-eslint'
    errors: [
      message:
        'Comments inside children section of tag should be placed inside braces'
    ]
  ,
    code: """
      class Comp1 extends Component
        render: ->
          return (<div>### invalid ###</div>)
    """
    # parser: 'babel-eslint'
    errors: [
      message:
        'Comments inside children section of tag should be placed inside braces'
    ]
  ,
    code: """
      class Comp1 extends Component
        render: ->
          return (
            <div>
              # invalid
            </div>
          )
    """
    # parser: 'babel-eslint'
    errors: [
      message:
        'Comments inside children section of tag should be placed inside braces'
    ]
  ,
    code: """
      class Comp1 extends Component
        render: ->
          return (
            <div>
              asdjfl
              ### invalid ###
              foo
            </div>
          )
    """
    # parser: 'babel-eslint'
    errors: [
      message:
        'Comments inside children section of tag should be placed inside braces'
    ]
  ,
    code: """
      class Comp1 extends Component
        render: ->
          return (
            <div>
              {'asdjfl'}
              # invalid
              {'foo'}
            </div>
          )
    """
    # parser: 'babel-eslint'
    errors: [
      message:
        'Comments inside children section of tag should be placed inside braces'
    ]
  ]
