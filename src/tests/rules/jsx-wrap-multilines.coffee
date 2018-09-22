###*
# @fileoverview Prevent missing parentheses around multilines JSX
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/jsx-wrap-multilines'
{RuleTester} = require 'eslint'

# ------------------------------------------------------------------------------
# Constants/Code Snippets
# ------------------------------------------------------------------------------

MISSING_PARENS = 'Missing parentheses around multilines JSX'
PARENS_NEW_LINES = 'Parentheses around JSX should be on separate lines'

RETURN_SINGLE_LINE = """
  Hello = createReactClass({
    render: ->
      return <p>Hello {this.props.name}</p>
  })
"""

RETURN_PAREN = """
  Hello = createReactClass({
    render: ->
      return (<div>
        <p>Hello {this.props.name}</p>
      </div>)
  })
"""

RETURN_PAREN_FRAGMENT = """
  Hello = createReactClass({
    render: ->
      return (<>
        <p>Hello {this.props.name}</p>
      </>)
  })
"""

RETURN_NO_PAREN = """
  Hello = createReactClass({
    render: ->
      return <div>
        <p>Hello {this.props.name}</p>
      </div>
  })
"""

RETURN_NO_PAREN_FRAGMENT = """
  Hello = createReactClass({
    render: ->
      return <>
        <p>Hello {this.props.name}</p>
      </>
  })
"""

RETURN_PAREN_NEW_LINE = """
  Hello = createReactClass({
    render: ->
      return (
        <div>
          <p>Hello {this.props.name}</p>
        </div>
      )
  })
"""

RETURN_PAREN_NEW_LINE_FRAGMENT = """
  Hello = createReactClass({
    render: ->
      return (
        <>
          <p>Hello {this.props.name}</p>
        </>
      )
  })
"""

RETURN_SINGLE_LINE_FRAGMENT = """
  Hello = createReactClass({
    render: ->
      return <>Hello {this.props.name}</>
  })
"""

ASSIGNMENT_SINGLE_LINE = 'hello hello = <p>Hello</p>'

ASSIGNMENT_PAREN = """
  hello
  hello = (<div>
    <p>Hello</p>
  </div>)
"""

ASSIGNMENT_PAREN_FRAGMENT = """
  hello
  hello = (<>
    <p>Hello</p>
  </>)
"""

ASSIGNMENT_NO_PAREN = """
  hello
  hello = <div>
    <p>Hello</p>
  </div>
"""

ASSIGNMENT_NO_PAREN_FRAGMENT = """
  hello
  hello = <>
    <p>Hello</p>
  </>
"""

ASSIGNMENT_PAREN_NEW_LINE = """
  hello
  hello = (
    <div>
      <p>Hello</p>
    </div>
  )
"""

ARROW_SINGLE_LINE = 'hello = () => <p>Hello</p>'

ARROW_PAREN = """
  hello = () => (<div>
    <p>Hello</p>
  </div>)
"""

ARROW_PAREN_FRAGMENT = """
  hello = () => (<>
    <p>Hello</p>
  </>)
"""

ARROW_NO_PAREN = """
  hello = () => <div>
    <p>Hello</p>
  </div>
"""

ARROW_NO_PAREN_FRAGMENT = """
  hello = () => <>
    <p>Hello</p>
  </>
"""

ARROW_PAREN_NEW_LINE = """
  hello = () => (
    <div>
      <p>Hello</p>
    </div>
  )
"""

LOGICAL_SINGLE_LINE = 'foo and <p>Hello</p>'

LOGICAL_PAREN = """
  <div>
    {foo and
      (<div>
        <p>Hello World</p>
      </div>)
    }
  </div>
"""

LOGICAL_PAREN_FRAGMENT = """
  <div>
    {foo and
      (<>
        <p>Hello World</p>
      </>)
    }
  </div>
"""

LOGICAL_NO_PAREN = """
  <div>
    {foo and
      <div>
        <p>Hello World</p>
      </div>
    }
  </div>
"""

LOGICAL_NO_PAREN_FRAGMENT = """
  <div>
    {foo and
      <>
        <p>Hello World</p>
      </>
    }
  </div>
"""

LOGICAL_PAREN_NEW_LINE = """
  <div>
    {foo && (
      <div>
        <p>Hello World</p>
      </div>
    )}
  </div>
"""

ATTR_SINGLE_LINE = '<div prop={<p>Hello</p>}></div>'

ATTR_PAREN = """
  <div prop={
    (<div>
      <p>Hello</p>
    </div>)
  }>
    <p>Hello</p>
  </div>
"""

ATTR_PAREN_FRAGMENT = """
  <div prop={
    (<>
      <p>Hello</p>
    </>)
  }>
    <p>Hello</p>
  </div>
"""

ATTR_NO_PAREN = """
  <div prop={
    <div>
      <p>Hello</p>
    </div>
  }>
    <p>Hello</p>
  </div>
"""

ATTR_NO_PAREN_FRAGMENT = """
  <div prop={
    <>
      <p>Hello</p>
    </>
  }>
    <p>Hello</p>
  </div>
"""

ATTR_PAREN_NEW_LINE = """
  <div prop={(
    <div>
      <p>Hello</p>
    </div>
  )}>
    <p>Hello</p>
  </div>
"""

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-wrap-multilines', rule,
  valid: [
    code: RETURN_SINGLE_LINE
  ,
    code: RETURN_SINGLE_LINE_FRAGMENT
  ,
    # parser: 'babel-eslint'
    code: RETURN_PAREN
  ,
    code: RETURN_PAREN
  ,
    # parser: 'babel-eslint'
    code: RETURN_SINGLE_LINE
    options: [return: yes]
  ,
    code: RETURN_SINGLE_LINE_FRAGMENT
    # parser: 'babel-eslint'
    options: [return: yes]
  ,
    code: RETURN_PAREN
    options: [return: yes]
  ,
    code: RETURN_NO_PAREN
    options: [return: 'ignore']
  ,
    code: RETURN_NO_PAREN
    options: [return: no]
  ,
    code: ASSIGNMENT_SINGLE_LINE
  ,
    # options: [declaration: 'ignore']
    code: ASSIGNMENT_SINGLE_LINE
  ,
    # options: [declaration: no]
    code: ASSIGNMENT_PAREN
  ,
    code: ASSIGNMENT_PAREN_FRAGMENT
  ,
    # parser: 'babel-eslint'
    code: ASSIGNMENT_PAREN
    options: [assignment: yes]
  ,
    code: ASSIGNMENT_NO_PAREN
    options: [assignment: 'ignore']
  ,
    code: ASSIGNMENT_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    options: [assignment: 'ignore']
  ,
    code: ASSIGNMENT_NO_PAREN
    options: [assignment: no]
  ,
    code: ARROW_PAREN
  ,
    code: ARROW_PAREN_FRAGMENT
  ,
    # parser: 'babel-eslint'
    code: ARROW_SINGLE_LINE
  ,
    code: ARROW_PAREN
    options: [arrow: yes]
  ,
    code: ARROW_PAREN
    # parser: 'babel-eslint'
    options: [arrow: yes]
  ,
    code: ARROW_SINGLE_LINE
    options: [arrow: yes]
  ,
    code: ARROW_NO_PAREN
    options: [arrow: 'ignore']
  ,
    code: ARROW_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    options: [arrow: 'ignore']
  ,
    code: ARROW_NO_PAREN
    options: [arrow: no]
  ,
    '''
      ->
        doSomething()
        <div>
          x
        </div>
    '''
  ,
    code: LOGICAL_SINGLE_LINE
  ,
    code: LOGICAL_NO_PAREN
  ,
    code: LOGICAL_PAREN
    options: [logical: yes]
  ,
    code: LOGICAL_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    options: [logical: yes]
  ,
    code: ATTR_SINGLE_LINE
  ,
    code: ATTR_NO_PAREN
  ,
    code: ATTR_PAREN
    options: [prop: yes]
  ,
    code: ATTR_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    options: [prop: yes]
  ,
    code: RETURN_PAREN_NEW_LINE
    options: [return: 'parens-new-line']
  ,
    code: RETURN_PAREN_NEW_LINE_FRAGMENT
    # parser: 'babel-eslint'
    options: [return: 'parens-new-line']
  ,
    code: ASSIGNMENT_PAREN_NEW_LINE
    options: [assignment: 'parens-new-line']
  ,
    code: ARROW_PAREN_NEW_LINE
    options: [arrow: 'parens-new-line']
  ,
    code: LOGICAL_PAREN_NEW_LINE
    options: [logical: 'parens-new-line']
  ,
    code: ATTR_PAREN_NEW_LINE
    options: [prop: 'parens-new-line']
  ]

  invalid: [
    code: RETURN_NO_PAREN
    # output: RETURN_PAREN
    errors: [message: MISSING_PARENS]
  ,
    code: RETURN_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: RETURN_PAREN_FRAGMENT
    errors: [message: MISSING_PARENS]
  ,
    code: RETURN_NO_PAREN
    # output: RETURN_PAREN
    options: [return: yes]
    errors: [message: MISSING_PARENS]
  ,
    code: RETURN_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: RETURN_PAREN_FRAGMENT
    options: [return: yes]
    errors: [message: MISSING_PARENS]
  ,
    code: ASSIGNMENT_NO_PAREN
    # output: ASSIGNMENT_PAREN
    errors: [message: MISSING_PARENS]
  ,
    code: ASSIGNMENT_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: ASSIGNMENT_PAREN_FRAGMENT
    errors: [message: MISSING_PARENS]
  ,
    code: ASSIGNMENT_NO_PAREN
    # output: ASSIGNMENT_PAREN
    options: [assignment: yes]
    errors: [message: MISSING_PARENS]
  ,
    code: ARROW_NO_PAREN
    # output: ARROW_PAREN
    errors: [message: MISSING_PARENS]
  ,
    code: ARROW_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: ARROW_PAREN_FRAGMENT
    errors: [message: MISSING_PARENS]
  ,
    code: ARROW_NO_PAREN
    # output: ARROW_PAREN
    options: [arrow: yes]
    errors: [message: MISSING_PARENS]
  ,
    code: LOGICAL_NO_PAREN
    # output: LOGICAL_PAREN
    options: [logical: 'parens']
    errors: [message: MISSING_PARENS]
  ,
    code: LOGICAL_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: LOGICAL_PAREN_FRAGMENT
    options: [logical: 'parens']
    errors: [message: MISSING_PARENS]
  ,
    code: LOGICAL_NO_PAREN
    # output: LOGICAL_PAREN
    options: [logical: yes]
    errors: [message: MISSING_PARENS]
  ,
    code: ATTR_NO_PAREN
    # output: ATTR_PAREN
    options: [prop: 'parens']
    errors: [message: MISSING_PARENS]
  ,
    code: ATTR_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: ATTR_PAREN_FRAGMENT
    options: [prop: 'parens']
    errors: [message: MISSING_PARENS]
  ,
    code: ATTR_NO_PAREN
    # output: ATTR_PAREN
    options: [prop: yes]
    errors: [message: MISSING_PARENS]
  ,
    code: RETURN_NO_PAREN
    # output: addNewLineSymbols RETURN_PAREN
    options: [return: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: RETURN_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: addNewLineSymbols RETURN_PAREN_FRAGMENT
    options: [return: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: RETURN_PAREN
    # output: addNewLineSymbols RETURN_PAREN
    options: [return: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: RETURN_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: addNewLineSymbols RETURN_PAREN_FRAGMENT
    options: [return: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: ASSIGNMENT_NO_PAREN
    # output: addNewLineSymbols ASSIGNMENT_PAREN
    options: [assignment: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: ASSIGNMENT_PAREN
    # output: addNewLineSymbols ASSIGNMENT_PAREN
    options: [assignment: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: ARROW_PAREN
    # output: addNewLineSymbols ARROW_PAREN
    options: [arrow: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: ARROW_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: addNewLineSymbols ARROW_PAREN_FRAGMENT
    options: [arrow: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: ARROW_NO_PAREN
    # output: addNewLineSymbols ARROW_PAREN
    options: [arrow: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: ARROW_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: addNewLineSymbols ARROW_PAREN_FRAGMENT
    options: [arrow: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: LOGICAL_PAREN
    # output: addNewLineSymbols LOGICAL_PAREN
    options: [logical: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: LOGICAL_NO_PAREN
    # output: LOGICAL_PAREN_NEW_LINE_AUTOFIX
    options: [logical: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: LOGICAL_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: LOGICAL_PAREN_NEW_LINE_AUTOFIX_FRAGMENT
    options: [logical: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: ATTR_PAREN
    # output: addNewLineSymbols ATTR_PAREN
    options: [prop: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: ATTR_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: addNewLineSymbols ATTR_PAREN_FRAGMENT
    options: [prop: 'parens-new-line']
    errors: [message: PARENS_NEW_LINES]
  ,
    code: ATTR_NO_PAREN
    # output: ATTR_PAREN_NEW_LINE_AUTOFIX
    options: [prop: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ,
    code: ATTR_NO_PAREN_FRAGMENT
    # parser: 'babel-eslint'
    # output: ATTR_PAREN_NEW_LINE_AUTOFIX_FRAGMENT
    options: [prop: 'parens-new-line']
    errors: [message: MISSING_PARENS]
  ]
