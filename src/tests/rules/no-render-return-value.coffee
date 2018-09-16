###*
# @fileoverview Prevent usage of setState
# @author Mark Dalgleish
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-render-return-value'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-render-return-value', rule,
  valid: [
    code: 'ReactDOM.render(<div />, document.body)'
  ,
    code: """
      node = null
      ReactDOM.render(<div ref={(ref) => node = ref}/>, document.body)
    """
  ,
    code:
      'ReactDOM.render(<div ref={(ref) => this.node = ref}/>, document.body)'
    settings:
      react:
        version: '0.14.0'
  ,
    code: 'React.render(<div ref={(ref) => this.node = ref}/>, document.body)'
    settings:
      react:
        version: '0.14.0'
  ,
    code: 'React.render(<div ref={(ref) => this.node = ref}/>, document.body)'
    settings:
      react:
        version: '0.13.0'
  ]

  invalid: [
    code: 'Hello = ReactDOM.render(<div />, document.body)'
    errors: [message: 'Do not depend on the return value from ReactDOM.render']
  ,
    code: """
      o = {
        inst: ReactDOM.render(<div />, document.body)
      }
    """
    errors: [message: 'Do not depend on the return value from ReactDOM.render']
  ,
    code: """
      render = ->
        return ReactDOM.render(<div />, document.body)
    """
    errors: [message: 'Do not depend on the return value from ReactDOM.render']
  ,

  ,
    code: """
        render = ->
          ReactDOM.render(<div />, document.body)
      """
    errors: [message: 'Do not depend on the return value from ReactDOM.render']
  ,
    code: 'render = (a, b) => ReactDOM.render(a, b)'
    errors: [message: 'Do not depend on the return value from ReactDOM.render']
  ,
    code: 'inst = React.render(<div />, document.body)'
    settings:
      react:
        version: '0.14.0'
    errors: [message: 'Do not depend on the return value from React.render']
  ,
    code: 'inst = ReactDOM.render(<div />, document.body)'
    settings:
      react:
        version: '0.14.0'
    errors: [message: 'Do not depend on the return value from ReactDOM.render']
  ,
    code: 'inst = React.render(<div />, document.body)'
    settings:
      react:
        version: '0.13.0'
    errors: [message: 'Do not depend on the return value from React.render']
  ]
