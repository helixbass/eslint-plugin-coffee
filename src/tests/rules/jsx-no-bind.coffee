###*
# @fileoverview Prevents usage of Function.prototype.bind and arrow functions
#               in React component definition.
# @author Daniel Lo Nigro <dan.cx>
###
'use strict'

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

rule = require '../../rules/jsx-no-bind'
{RuleTester} = require 'eslint'
path = require 'path'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
ruleTester.run 'jsx-no-bind', rule,
  valid: [
    # Not covered by the rule
    code: '<div onClick={this._handleClick}></div>'
  ,
    code: '<div onClick={@_handleClick}></div>'
  ,
    code: '<div meaningOfLife={42}></div>'
  ,
    code: '<div onClick={getHandler()}></div>'
  ,
    # bind() and arrow functions in refs explicitly ignored
    code: '<div ref={(c) => this._input = c}></div>'
    options: [ignoreRefs: yes]
  ,
    code: '<div ref={this._refCallback.bind(this)}></div>'
    options: [ignoreRefs: yes]
  ,
    code: '<div ref={(c) -> this._input = c}></div>'
    options: [ignoreRefs: yes]
  ,
    # bind() explicitly allowed
    code: '<div onClick={this._handleClick.bind(this)}></div>'
    options: [allowBind: yes]
  ,
    # Arrow functions explicitly allowed
    code: '<div onClick={-> alert("1337")}></div>'
    options: [allowFunctions: yes]
  ,
    # Redux connect
    code: '''
      class Hello extends Component
        render: ->
          <div>Hello</div>
      export default connect()(Hello)
    '''
    options: [allowBind: yes]
  ,
    # Backbone view with a bind
    code: '''
      DocumentRow = Backbone.View.extend({
        tagName: "li",
        render: ->
          this.onTap.bind(this)
      })
    '''
  ,
    code: '''
        foo = {
          render: ->
            this.onTap.bind(this)
            return true
        }
      '''
  ,
    code: '''
        foo = {
          render: ->
            this.onTap.bind(this)
            return true
        }
      '''
  ,
    code: [
      'class Hello extends Component'
      '  render: ->'
      '    click = this.onTap.bind(this)'
      '    return <div onClick={onClick}>Hello</div>'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  render: ->'
      '    foo.onClick = this.onTap.bind(this)'
      '    return <div onClick={onClick}>Hello</div>'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  render: ->'
      '    return (<div>{'
      '      this.props.list.map(this.wrap.bind(this, "span"))'
      '    }</div>)'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  render: ->'
      '    click = () => true'
      '    return <div onClick={onClick}>Hello</div>'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  render: ->'
      '    (<div>{'
      '      this.props.list.map (item) => <item hello="true"/>'
      '    }</div>)'
    ].join '\n'
  ,
    # ,
    #   code: [
    #     'class Hello extends Component'
    #     '  render: ->'
    #     '    click = this.bar::baz'
    #     '    return <div onClick={onClick}>Hello</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello extends Component'
    #     '  render: ->'
    #     '    return (<div>{'
    #     '      this.props.list.map(this.bar::baz)'
    #     '    }</div>)'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '    return (<div>{'
      '      this.props.list.map(this.wrap.bind(this, "span"))'
      '    }</div>)'
      '})'
    ].join '\n'
  ,
    # ,
    #   code: [
    #     'Hello = React.createClass({'
    #     '  render: -> '
    #     '    click = this.bar::baz'
    #     '    return <div onClick={onClick}>Hello</div>'
    #     '  }'
    #     '})'
    #   ].join '\n'
    #   parser: 'babel-eslint'
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '    click = () => true'
      '    return <div onClick={onClick}>Hello</div>'
      '})'
    ].join '\n'
  ,
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: =>'
      '    onClick = this.doSomething.bind(this, "no")'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # issue #1543: don't crash on uninitialized variables
    code: [
      'class Hello extends Component'
      '  render: ->'
      '    click = null'
      '    return <div onClick={onClick}>Hello</div>'
    ].join '\n'
  ,
    # ignore DOM components
    code: '<div onClick={this._handleClick.bind(this)}></div>'
    options: [ignoreDOMComponents: yes]
  ,
    code: '<div onClick={() => alert("1337")}></div>'
    options: [ignoreDOMComponents: yes]
  ,
    code: '<div onClick={-> alert("1337")}></div>'
    options: [ignoreDOMComponents: yes]
  ,
    # ,
    #   code: '<div foo={::this.onChange} />'
    #   options: [ignoreDOMComponents: yes]
    #   parser: 'babel-eslint'
    code: '<a href={if user? then path}>My Posts</a>'
  ]

  invalid: [
    # .bind()
    code: '<div onClick={this._handleClick.bind(this)}></div>'
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '<div onClick={someGlobalFunction.bind(this)}></div>'
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '<div onClick={window.lol.bind(this)}></div>'
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '<div ref={this._refCallback.bind(this)}></div>'
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '''
        Hello = createReactClass({
          render: ->
            click = @someMethod.bind @
            <div onClick={click}>Hello {@state.name}</div>
        })
      '''
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '''
      class Hello23 extends React.Component
        render: ->
          click = this.someMethod.bind(this)
          return <div onClick={click}>Hello {this.state.name}</div>
    '''
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: ->'
      '    click = this.doSomething.bind(this, "no")'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: () =>'
      '    click = this.doSomething.bind(this, "no")'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
    errors: [message: 'JSX props should not use .bind()']
  ,
    # parser: 'babel-eslint'
    code: '''
        foo = {
          render: ({onClick}) => (
            <div onClick={onClick.bind(this)}>Hello</div>
          )
        }
      '''
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '   return <div onClick={this.doSomething.bind(this, "hey")} />'
      '})'
    ].join '\n'
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '    doThing = this.doSomething.bind(this, "hey")'
      '    return <div onClick={doThing} />'
      '})'
    ].join '\n'
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: =>'
      '    click = () => true'
      '    renderStuff = () =>'
      '      click1 = this.doSomething.bind(this, "hey")'
      '      return <div onClick={click1} />'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
    errors: [
      message: 'JSX props should not use .bind()'
    ,
      message: 'JSX props should not use arrow functions'
    ]
  ,
    # parser: 'babel-eslint'
    code: '''
        foo = {
          render: ({onClick}) => (
            <div onClick={if (returningBoolean()) then onClick.bind(this) else onClick.bind(this)}>Hello</div>
          )
        }
      '''
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '''
        foo = {
          render: ({onClick}) => (
            <div onClick={if (returningBoolean()) then onClick.bind(this) else handleClick()}>Hello</div>
          )
        }
      '''
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '''
        foo = {
          render: ({onClick}) => (
            <div onClick={if (returningBoolean()) then handleClick() else this.onClick.bind(this)}>Hello</div>
          )
        }
      '''
    errors: [message: 'JSX props should not use .bind()']
  ,
    code: '''
        foo = {
          render: ({onClick}) => (
            <div onClick={if returningBoolean.bind(this) then handleClick() else onClick()}>Hello</div>
          )
        }
      '''
    errors: [message: 'JSX props should not use .bind()']
  ,
    # Arrow functions
    code: '<div onClick={() => alert("1337")}></div>'
    errors: [message: 'JSX props should not use arrow functions']
  ,
    code: '<div onClick={-> 42}></div>'
    errors: [message: 'JSX props should not use functions']
  ,
    code: '<div onClick={(param) => first()}></div>'
    errors: [message: 'JSX props should not use arrow functions']
  ,
    code: '<div ref={(c) => this._input = c}></div>'
    errors: [message: 'JSX props should not use arrow functions']
  ,
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: =>'
      '    click = () => true'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
    errors: [message: 'JSX props should not use arrow functions']
  ,
    # parser: 'babel-eslint'
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '   return <div onClick={() => true} />'
      '})'
    ].join '\n'
    errors: [message: 'JSX props should not use arrow functions']
  ,
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '   return <div onClick={=> await true} />'
      '})'
    ].join '\n'
    errors: [message: 'JSX props should not use arrow functions']
  ,
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '    doThing = () => true'
      '    return <div onClick={doThing} />'
      '})'
    ].join '\n'
    errors: [message: 'JSX props should not use arrow functions']
  ,
    # ,
    #   code: [
    #     'class Hello23 extends React.Component'
    #     '  renderDiv = () => {'
    #     '    click = ::this.onChange'
    #     '    renderStuff = () => {'
    #     '      click = () => true'
    #     '      return <div onClick={click} />'
    #     '    }'
    #     '    return <div onClick={click}>Hello</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: 'JSX props should not use functions'
    #   ,
    #     message: 'JSX props should not use ::'
    #   ]
    #   parser: 'babel-eslint'
    # Functions
    code: '<div onClick={-> alert("1337")}></div>'
    errors: [message: 'JSX props should not use functions']
  ,
    code: '<div onClick={-> yield alert("1337")}></div>'
    errors: [message: 'JSX props should not use functions']
  ,
    code: '<div onClick={-> await alert("1337")}></div>'
    errors: [message: 'JSX props should not use functions']
  ,
    code: '<div ref={(c) -> this._input = c}></div>'
    errors: [message: 'JSX props should not use functions']
  ,
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: () =>'
      '    click = -> return true'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
    errors: [message: 'JSX props should not use functions']
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: =>'
      '    click = -> yield true'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
    errors: [message: 'JSX props should not use functions']
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello23 extends React.Component'
      '  renderDiv: =>'
      '    await 1'
      '    click = -> return true'
      '    return <div onClick={click}>Hello</div>'
    ].join '\n'
    errors: [message: 'JSX props should not use functions']
  ,
    # parser: 'babel-eslint'
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '   return <div onClick={-> return true} />'
      '})'
    ].join '\n'
    errors: [message: 'JSX props should not use functions']
  ,
    code: [
      'Hello = React.createClass({'
      '  render: -> '
      '    doThing = -> true'
      '    return <div onClick={doThing} />'
      '})'
    ].join '\n'
    errors: [message: 'JSX props should not use functions']
  ,
    # ,
    #   code: [
    #     'class Hello23 extends React.Component'
    #     '  renderDiv = () => {'
    #     '    click = ::this.onChange'
    #     '    renderStuff = () => {'
    #     '      click = function () { return true }'
    #     '      return <div onClick={click} />'
    #     '    }'
    #     '    return <div onClick={click}>Hello</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [
    #     message: 'JSX props should not use functions'
    #   ,
    #     message: 'JSX props should not use ::'
    #   ]
    #   parser: 'babel-eslint'
    # ,
    #   # Bind expression
    #   code: '<div foo={::this.onChange} />'
    #   errors: [message: 'JSX props should not use ::']
    #   parser: 'babel-eslint'
    # ,
    #   code: '<div foo={foo.bar::baz} />'
    #   errors: [message: 'JSX props should not use ::']
    #   parser: 'babel-eslint'
    # ,
    #   code: '<div foo={foo::bar} />'
    #   errors: [message: 'JSX props should not use ::']
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello23 extends React.Component'
    #     '  renderDiv: ->'
    #     '    click = ::this.onChange'
    #     '    return <div onClick={click}>Hello</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [message: 'JSX props should not use ::']
    #   parser: 'babel-eslint'
    # ,
    #   code: [
    #     'class Hello23 extends React.Component'
    #     '  renderDiv: ->'
    #     '    click = this.bar::baz'
    #     '    return <div onClick={click}>Hello</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   errors: [message: 'JSX props should not use ::']
    #   parser: 'babel-eslint'
    # ,
    # code: [
    #   'class Hello23 extends React.Component'
    #   '  renderDiv = async () => {'
    #   '    click = this.bar::baz'
    #   '    return <div onClick={click}>Hello</div>'
    #   '  }'
    #   '}'
    # ].join '\n'
    # errors: [message: 'JSX props should not use ::']
    # parser: 'babel-eslint'
    # ,
    # code: [
    #   'class Hello23 extends React.Component'
    #   '  renderDiv = () => {'
    #   '    click = true'
    #   '    renderStuff = () => {'
    #   '      click = this.bar::baz'
    #   '      return <div onClick={click} />'
    #   '    }'
    #   '    return <div onClick={click}>Hello</div>'
    #   '  }'
    #   '}'
    # ].join '\n'
    # errors: [message: 'JSX props should not use ::']
    # parser: 'babel-eslint'
    # ignore DOM components
    code: '<Foo onClick={this._handleClick.bind(this)} />'
    options: [ignoreDOMComponents: yes]
    errors: [message: 'JSX props should not use .bind()']
  ]
