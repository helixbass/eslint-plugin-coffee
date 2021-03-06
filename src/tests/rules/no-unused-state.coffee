###*
# @fileoverview Tests for no-unused-state
###

'use strict'

rule = require '../../rules/no-unused-state'
{RuleTester} = require 'eslint'
path = require 'path'

eslintTester = new RuleTester parser: path.join __dirname, '../../..'

getErrorMessages = (unusedFields) ->
  unusedFields.map (field) ->
    message: "Unused state field: '#{field}'"

eslintTester.run 'no-unused-state', rule,
  valid: [
    '''
      StatelessFnUnaffectedTest = (props) ->
        return <SomeComponent foo={props.foo} />
    '''
    '''
      NoStateTest = createReactClass({
        render: ->
          <SomeComponent />
      })
    '''
    ''' 
      NoStateMethodTest = createReactClass({
        render: ->
          return <SomeComponent />
      })
    '''
    '''
      GetInitialStateTest = createReactClass({
        getInitialState: ->
          return { foo: 0 }
        render: ->
          return <SomeComponent foo={this.state.foo} />
      })
    '''
    '''
      ComputedKeyFromVariableTest = createReactClass({
        getInitialState: ->
          return { [foo]: 0 }
        render: ->
          return <SomeComponent />
      })
    '''
    '''
      ComputedKeyFromBooleanLiteralTest = createReactClass({
        getInitialState: ->
          return { [true]: 0 }
        render: ->
          return <SomeComponent foo={this.state[true]} />
      })
    '''
    '''
      ComputedKeyFromNumberLiteralTest = createReactClass({
        getInitialState: ->
          return { [123]: 0 }
        render: ->
          return <SomeComponent foo={this.state[123]} />
      })
    '''
    '''
      ComputedKeyFromExpressionTest = createReactClass({
        getInitialState: ->
          return { [foo + bar]: 0 }
        render: ->
          return <SomeComponent />
      })
    '''
    '''
      ComputedKeyFromBinaryExpressionTest = createReactClass({
        getInitialState: ->
          return { ['foo' + 'bar' * 8]: 0 }
        render: ->
          return <SomeComponent />
      })
    '''
    '''
      ComputedKeyFromStringLiteralTest = createReactClass({
        getInitialState: ->
          return { ['foo']: 0 }
        render: ->
          return <SomeComponent foo={this.state.foo} />
      })
    '''
    # eslint-disable-next-line coffee/no-template-curly-in-string
    '''
      ComputedKeyFromTemplateLiteralTest = createReactClass({
        getInitialState: ->
          return { ["foo#{bar}"]: 0 }
        render: ->
          return <SomeComponent />
      })
    '''
    '''
      ComputedKeyFromTemplateLiteralTest = createReactClass({
        getInitialState: ->
          return { ["foo"]: 0 }
        render: ->
          return <SomeComponent foo={this.state['foo']} />
      })
    '''
    '''
      GetInitialStateMethodTest = createReactClass({
        getInitialState: ->
          return { foo: 0 }
        render: ->
          return <SomeComponent foo={this.state.foo} />
      })
    '''
    '''
      SetStateTest = createReactClass({
        onFooChange: (newFoo) ->
          this.setState({ foo: newFoo })
        render: ->
          return <SomeComponent foo={this.state.foo} />
      })
    '''
    '''
      MultipleSetState = createReactClass({
        getInitialState: ->
          return { foo: 0 }
        update: ->
          this.setState({foo: 1})
        render: ->
          return <SomeComponent onClick={this.update} foo={this.state.foo} />
      })
    '''
    '''
      class NoStateTest extends React.Component
        render: ->
          return <SomeComponent />
    '''
    '''
      class CtorStateTest extends React.Component
        constructor: ->
          super()
          this.state = { foo: 0 }
        render: ->
          return <SomeComponent foo={this.state.foo} />
    '''
    '''
      class ComputedKeyFromVariableTest extends React.Component
        constructor: ->
          super()
          this.state = { [foo]: 0 }
        render: ->
          return <SomeComponent />
    '''
    '''
      class ComputedKeyFromBooleanLiteralTest extends React.Component
        constructor: ->
          super()
          this.state = { [false]: 0 }
        render: ->
          return <SomeComponent foo={this.state['false']} />
    '''
    '''
      class ComputedKeyFromNumberLiteralTest extends React.Component
        constructor: ->
          super()
          this.state = { [345]: 0 }
        render: ->
          return <SomeComponent foo={this.state[345]} />
    '''
    '''
      class ComputedKeyFromExpressionTest extends React.Component
        constructor: ->
          super()
          this.state = { [foo + bar]: 0 }
        render: ->
          return <SomeComponent />
    '''
    '''
      class ComputedKeyFromBinaryExpressionTest extends React.Component
        constructor: ->
          super()
          this.state = { [1 + 2 * 8]: 0 }
        render: ->
          return <SomeComponent />
    '''
    '''
      class ComputedKeyFromStringLiteralTest extends React.Component
        constructor: ->
          super()
          this.state = { ['foo']: 0 }
        render: ->
          return <SomeComponent foo={this.state.foo} />
    '''
    # eslint-disable-next-line coffee/no-template-curly-in-string
    '''
      class ComputedKeyFromTemplateLiteralTest extends React.Component
        constructor: ->
          super()
          this.state = { ["foo#{bar}"]: 0 }
        render: ->
          return <SomeComponent />
    '''
    '''
      class ComputedKeyFromTemplateLiteralTest extends React.Component
        constructor: ->
          super()
          this.state = { ["foo"]: 0 }
        render: ->
          return <SomeComponent foo={this.state.foo} />
    '''
    '''
      class SetStateTest extends React.Component
        onFooChange: (newFoo) ->
          this.setState({ foo: newFoo })
        render: ->
          return <SomeComponent foo={this.state.foo} />
    '''
    # ,
    #   code: """
    #     class ClassPropertyStateTest extends React.Component
    #       state = { foo: 0 }
    #       render: ->
    #         return <SomeComponent foo={this.state.foo} />
    #   """
    #   # parser: 'babel-eslint'
    '''
      class VariableDeclarationTest extends React.Component
          constructor: ->
            super()
            @state = { foo: 0 }
          render: ->
            foo = @state.foo
            return <SomeComponent foo={foo} />
    '''
    '''
      class DestructuringTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            {foo: myFoo} = this.state
            return <SomeComponent foo={myFoo} />
    '''
    '''
      class ShorthandDestructuringTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            {foo} = this.state
            return <SomeComponent foo={foo} />
    '''
    '''
      class AliasDeclarationTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            state = this.state
            return <SomeComponent foo={state.foo} />
    '''
    '''
      class AliasAssignmentTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            state
            state = this.state
            return <SomeComponent foo={state.foo} />
    '''
    '''
      class DestructuringAliasTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            {state: myState} = this
            return <SomeComponent foo={myState.foo} />
    '''
    '''
      class ShorthandDestructuringAliasTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            {state} = this
            return <SomeComponent foo={state.foo} />
    '''
    '''
      class RestPropertyTest extends React.Component
          constructor: ->
            super()
            this.state = {
              foo: 0,
              bar: 1,
            }
          render: ->
            {foo, ...others} = this.state
            return <SomeComponent foo={foo} bar={others.bar} />
    '''
    # ,
    #   code: """
    #     class DeepDestructuringTest extends React.Component
    #       state = { foo: 0, bar: 0 }
    #       render: ->
    #         {state: {foo, ...others}} = this
    #         return <SomeComponent foo={foo} bar={others.bar} />
    #   """
    #   # parser: 'babel-eslint'
    # A cleverer analysis might recognize that the following should be errors,
    # but they're out of scope for this lint rule.
    '''
      class MethodArgFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          consumeFoo: (foo) ->
          render: ->
            this.consumeFoo(this.state.foo)
            return <SomeComponent />
    '''
    '''
      class AssignedToObjectFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            obj = { foo: this.state.foo, bar: 0 }
            return <SomeComponent bar={obj.bar} />
    '''
    '''
      class ComputedAccessFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0, bar: 1 }
          render: ->
            bar = 'bar'
            return <SomeComponent bar={this.state[bar]} />
    '''
    '''
      class JsxSpreadFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            return <SomeComponent {...this.state} />
    '''
    '''
      class AliasedJsxSpreadFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            state = this.state
            return <SomeComponent {...state} />
    '''
    '''
      class ObjectSpreadFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            attrs = { ...this.state, foo: 1 }
            return <SomeComponent foo={attrs.foo} />
    '''
    '''
      class ShadowingFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }
          render: ->
            state = this.state
            foo = null
            do ->
              state = { foo: 5 }
              foo = state.foo
            return <SomeComponent foo={foo} />
    '''
    '''
      class NonRenderClassMethodFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0, bar: 0 }
          doSomething: ->
            { foo } = this.state
            return this.state.foo
          doSomethingElse: ->
            { state: { bar }} = this
            return bar
          render: ->
            return <SomeComponent />
    '''
  ,
    # ,
    #   code: """
    #     class TypeCastExpressionSpreadFalseNegativeTest extends React.Component
    #       constructor: ->
    #         this.state = { foo: 0 }
    #       render: ->
    #         return <SomeComponent {...(this.state: any)} />
    #   """
    # parser: 'babel-eslint'
    code: '''
      class ArrowFunctionClassMethodDestructuringFalseNegativeTest extends React.Component
          constructor: ->
            super()
            this.state = { foo: 0 }

          doSomething: =>
            { state: { foo } } = this

            return foo

          render: ->
            return <SomeComponent />
    '''
  ,
    # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class ArrowFunctionClassMethodWithClassPropertyTransformFalseNegativeTest extends React.Component
    #         state = { foo: 0 }

    #         doSomething: =>
    #           { state:{ foo } } = this

    #           return foo

    #         render: ->
    #           return <SomeComponent />
    #   """
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class ArrowFunctionClassMethodDeepDestructuringFalseNegativeTest extends React.Component
    #         state = { foo: { bar: 0 } }

    #         doSomething: =>
    #           { state: { foo: { bar }}} = this

    #           return bar

    #         render: ->
    #           return <SomeComponent />
    #   """
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class ArrowFunctionClassMethodDestructuringAssignmentFalseNegativeTest extends React.Component
    #         state = { foo: 0 }

    #         doSomething: =>
    #           { state: { foo: bar }} = this

    #           return bar

    #         render: ->
    #           return <SomeComponent />
    #   """
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class ThisStateAsAnObject extends React.Component
    #         state = {
    #           active: true
    #         }

    #         render: ->
    #           return <div className={classNames('overflowEdgeIndicator', className, this.state)} />
    #         }
    #       }"""
    #   # parser: 'babel-eslint'
    code: '''
      class ESLintExample extends Component
          constructor: (props) ->
            super(props)
            this.state = {
              id: 123,
            }
          @getDerivedStateFromProps: (nextProps, prevState) ->
            if (prevState.id is nextProps.id)
              return {
                selected: true,
              }
            return null
          render: ->
            return (
              <h1>{if this.state.selected then 'Selected' else 'Not selected'}</h1>
            )
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class ESLintExample extends Component
          constructor: (props) ->
            super(props)
            this.state = {
              id: 123,
            }
          shouldComponentUpdate: (nextProps, nextState) ->
            return nextState.id is nextProps.id
          render: ->
            return (
              <h1>{if this.state.selected then 'Selected' else 'Not selected'}</h1>
            )
    '''
    # parser: 'babel-eslint'
  ]

  invalid: [
    code: '''
      UnusedGetInitialStateTest = createReactClass
            getInitialState: ->
              { foo: 0 }
            render: ->
              <SomeComponent />
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      UnusedComputedStringLiteralKeyStateTest = createReactClass({
            getInitialState: ->
              return { ['foo']: 0 }
            render: ->
              return <SomeComponent />
      })
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      UnusedComputedTemplateLiteralKeyStateTest = createReactClass({
            getInitialState: ->
              return { ["foo"]: 0 }
            render: ->
              return <SomeComponent />
      })
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      UnusedComputedNumberLiteralKeyStateTest = createReactClass({
            getInitialState: ->
              return { [123]: 0 }
            render: ->
              return <SomeComponent />
      })
    '''
    errors: getErrorMessages ['123']
  ,
    code: '''
      UnusedComputedBooleanLiteralKeyStateTest = createReactClass({
            getInitialState: ->
              return { [true]: 0 }
            render: ->
              return <SomeComponent />
      })
    '''
    errors: getErrorMessages ['true']
  ,
    code: '''
      UnusedGetInitialStateMethodTest = createReactClass({
            getInitialState: ->
              return { foo: 0 }
            render: ->
              return <SomeComponent />
      })
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      UnusedSetStateTest = createReactClass({
            onFooChange: (newFoo) ->
              this.setState({ foo: newFoo })
            render: ->
              return <SomeComponent />
      })
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      class UnusedCtorStateTest extends React.Component
        constructor: ->
          super()
          this.state = { foo: 0 }
        render: ->
          return <SomeComponent />
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      class UnusedSetStateTest extends React.Component
            onFooChange: (newFoo) ->
              this.setState({ foo: newFoo })
            render: ->
              return <SomeComponent />
    '''
    errors: getErrorMessages ['foo']
  ,
    # ,
    #   code: """
    #     class UnusedClassPropertyStateTest extends React.Component
    #           state = { foo: 0 }
    #           render: ->
    #             return <SomeComponent />
    #   """
    #   errors: getErrorMessages ['foo']
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class UnusedComputedStringLiteralKeyStateTest extends React.Component
    #           state = { ['foo']: 0 }
    #           render: ->
    #             return <SomeComponent />
    #   """
    #   errors: getErrorMessages ['foo']
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class UnusedComputedTemplateLiteralKeyStateTest extends React.Component
    #           state = { ["foo"]: 0 }
    #           render: ->
    #             return <SomeComponent />
    #   """
    #   errors: getErrorMessages ['foo']
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class UnusedComputedTemplateLiteralKeyStateTest extends React.Component
    #           state = { ["foo \\n bar"]: 0 }
    #           render: ->
    #             return <SomeComponent />
    #   """
    #   errors: getErrorMessages ['foo \\n bar']
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class UnusedComputedBooleanLiteralKeyStateTest extends React.Component
    #           state = { [true]: 0 }
    #           render: ->
    #             return <SomeComponent />
    #   """
    #   errors: getErrorMessages ['true']
    #   # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class UnusedComputedNumberLiteralKeyStateTest extends React.Component
    #           state = { [123]: 0 }
    #           render: ->
    #             return <SomeComponent />
    #   """
    #   errors: getErrorMessages ['123']
    #   # parser: 'babel-eslint'
    # ,
    #   code: """class UnusedComputedFloatLiteralKeyStateTest extends React.Component
    #         state = { [123.12]: 0 }
    #         render: ->
    #           return <SomeComponent />
    #         }
    #       }"""
    #   errors: getErrorMessages ['123.12']
    #   # parser: 'babel-eslint'
    code: '''
      class UnusedStateWhenPropsAreSpreadTest extends React.Component
            constructor: ->
              super()
              this.state = { foo: 0 }
            render: ->
              return <SomeComponent {...this.props} />
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      class AliasOutOfScopeTest extends React.Component
            constructor: ->
              super()
              this.state = { foo: 0 }
            render: ->
              state = this.state
              return <SomeComponent />
            someMethod: ->
              outOfScope = state.foo
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      class MultipleErrorsTest extends React.Component
            constructor: ->
              super()
              this.state = {
                foo: 0,
                bar: 1,
                baz: 2,
                qux: 3,
              }
            render: ->
              {state} = this
              return <SomeComponent baz={state.baz} qux={state.qux} />
    '''
    errors: getErrorMessages ['foo', 'bar']
  ,
    code: '''
      class MultipleErrorsForSameKeyTest extends React.Component
            constructor: ->
              super()
              this.state = { foo: 0 }
            onFooChange: (newFoo) ->
              this.setState({ foo: newFoo })
            render: ->
              return <SomeComponent />
    '''
    errors: getErrorMessages ['foo', 'foo']
  ,
    code: '''
      class UnusedRestPropertyFieldTest extends React.Component
            constructor: ->
              super()
              this.state = {
                foo: 0,
                bar: 1,
              }
            render: ->
              {bar, ...others} = this.state
              return <SomeComponent bar={bar} />
    '''
    errors: getErrorMessages ['foo']
  ,
    code: '''
      class UnusedStateArrowFunctionMethodTest extends React.Component
            constructor: ->
              super()
              this.state = { foo: 0 }
            doSomething: =>
              return null
            render: ->
              return <SomeComponent />
    '''
    errors: getErrorMessages ['foo']
  ,
    # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class TypeCastExpressionTest extends React.Component
    #           constructor: ->
    #             this.state = {
    #               foo: 0,
    #               bar: 1,
    #               baz: 2,
    #               qux: 3,
    #             }
    #           render: ->
    #             foo = ((this: any).state: any).foo
    #             {bar, ...others} = (this.state: any)
    #             baz = null
    #             baz = (others: any)['baz']
    #             return <SomeComponent foo={foo} bar={bar} baz={baz} />
    #           }
    #         }"""
    #   errors: getErrorMessages ['qux']
    #   # parser: 'babel-eslint'
    code: '''
      class UnusedDeepDestructuringTest extends React.Component
            constructor: ->
              super()
              @state = { foo: 0, bar: 0 }
            render: ->
              {state: {foo}} = this
              return <SomeComponent foo={foo} />
    '''
    errors: getErrorMessages ['bar']
    # parser: 'babel-eslint'
    # ,
    #   code: """
    #     class UnusedDeepDestructuringTest extends React.Component
    #           state = { foo: 0, bar: 0 }
    #           render: ->
    #             {state: {foo}} = this
    #             return <SomeComponent foo={foo} />
    #           }
    #         }"""
    #   errors: getErrorMessages ['bar']
    #   # parser: 'babel-eslint'
  ]
