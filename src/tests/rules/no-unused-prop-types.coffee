###*
# @fileoverview Warn about unused PropType definitions in React components
# @author Evgueni Naverniouk
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-unused-prop-types'
{RuleTester} = require 'eslint'

settings =
  react:
    pragma: 'Foo'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'no-unused-prop-types', rule,
  valid: [
    code: '''
      Hello = createReactClass
        propTypes:
          name: PropTypes.string.isRequired
        render: ->
          <div>Hello {@props.name}</div>
    '''
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          name: PropTypes.object.isRequired
        },
        render: ->
          return <div>Hello {this.props.name.firstname}</div>
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          return <div>Hello World</div>
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          props = this.props
          return <div>Hello World</div>
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        render: ->
          propName = "foo"
          return <div>Hello World {this.props[propName]}</div>
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        propTypes: externalPropTypes,
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        propTypes: externalPropTypes.mySharedPropTypes,
        render: ->
          return <div>Hello {this.props.name}</div>
      })
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello World</div>
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.firstname} {this.props.lastname}</div>
      Hello.propTypes = {
        firstname: PropTypes.string
      }
      Hello.propTypes.lastname = PropTypes.string
    '''
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          name: PropTypes.object.isRequired
        },
        render: ->
          user = {
            name: this.props.name
          }
          return <div>Hello {user.name}</div>
      })
    '''
  ,
    code: '''
      class Hello
        render: ->
          return 'Hello' + this.props.name
    '''
  ,
    # ,
    #   code: '''
    #     class Hello extends React.Component {
    #       static get propTypes() {
    #         return {
    #           name: PropTypes.string
    #         }
    #       }
    #     '  render() {
    #     '    return <div>Hello {this.props.name}</div>
    #     '  }
    #     '}
    #   '''
    # Props validation is ignored when spread is used
    code: '''
      class Hello extends React.Component
        render: ->
          { firstname, ...props } = this.props
          { category, icon } = props
          return <div>Hello {firstname}</div>
      Hello.propTypes = {
        firstname: PropTypes.string,
        category: PropTypes.string,
        icon: PropTypes.bool
      }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class Hello extends React.Component
        render: ->
          {firstname, lastname} = this.state
          something = this.props
          return <div>Hello {firstname}</div>
    '''
  ,
    code: '''
      class Hello extends React.Component
        @propTypes = {
          name: PropTypes.string
        }
        render: ->
          return <div>Hello {this.props.name}</div>
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class Hello extends React.Component
        render: ->
          return <div>Hello {this.props.firstname}</div>
      Hello.propTypes = {
        'firstname': PropTypes.string
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          if (Object.prototype.hasOwnProperty.call(this.props, 'firstname'))
            return <div>Hello {this.props.firstname}</div>
      Hello.propTypes = {
        'firstname': PropTypes.string
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props.a.b
          return <div>Hello</div>
      Hello.propTypes = {}
      Hello.propTypes.a = PropTypes.shape({
        b: PropTypes.string
      })
    '''
    options: [skipShapeProps: no]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props.a.b.c
          return <div>Hello</div>
      Hello.propTypes = {
        a: PropTypes.shape({
          b: PropTypes.shape({
          })
        })
      }
      Hello.propTypes.a.b.c = PropTypes.number
    '''
    options: [skipShapeProps: no]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props.a.b.c
          this.props.a.__.d.length
          this.props.a.anything.e[2]
          return <div>Hello</div>
      Hello.propTypes = {
        a: PropTypes.objectOf(
          PropTypes.shape({
            c: PropTypes.number,
            d: PropTypes.string,
            e: PropTypes.array
          })
        )
      }
    '''
    options: [skipShapeProps: no]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          i = 3
          this.props.a[2].c
          this.props.a[i].d.length
          this.props.a[i + 2].e[2]
          this.props.a.length
          return <div>Hello</div>
      Hello.propTypes = {
        a: PropTypes.arrayOf(
          PropTypes.shape({
            c: PropTypes.number,
            d: PropTypes.string,
            e: PropTypes.array
          })
        )
      }
    '''
    options: [skipShapeProps: no]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props.a.length
          return <div>Hello</div>
      Hello.propTypes = {
        a: PropTypes.oneOfType([
          PropTypes.array,
          PropTypes.string
        ])
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props.a.c
          this.props.a[2] is true
          this.props.a.e[2]
          this.props.a.length
          return <div>Hello</div>
      Hello.propTypes = {
        a: PropTypes.oneOfType([
          PropTypes.shape({
            c: PropTypes.number,
            e: PropTypes.array
          }).isRequired,
          PropTypes.arrayOf(
            PropTypes.bool
          )
        ])
      }
    '''
    options: [skipShapeProps: no]
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props.a.render
          this.props.a.c
          return <div>Hello</div>
      Hello.propTypes = {
        a: PropTypes.instanceOf(Hello)
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props.arr
          this.props.arr[3]
          this.props.arr.length
          this.props.arr.push(3)
          this.props.bo
          this.props.bo.toString()
          this.props.fu
          this.props.fu.bind(this)
          this.props.numb
          this.props.numb.toFixed()
          this.props.stri
          this.props.stri.length()
          return <div>Hello</div>
      Hello.propTypes = {
        arr: PropTypes.array,
        bo: PropTypes.bool.isRequired,
        fu: PropTypes.func,
        numb: PropTypes.number,
        stri: PropTypes.string
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          { 
            propX,
            "aria-controls": ariaControls, 
            ...props } = this.props
          return <div>Hello</div>
      Hello.propTypes = {
        "propX": PropTypes.string,
        "aria-controls": PropTypes.string
      }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class Hello extends React.Component
        render: ->
          this.props["some.value"]
          return <div>Hello</div>
      Hello.propTypes = {
        "some.value": PropTypes.string
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props["arr"][1]
          return <div>Hello</div>
      Hello.propTypes = {
        "arr": PropTypes.array
      }
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          this.props["arr"][1]["some.value"]
          return <div>Hello</div>
      Hello.propTypes = {
        "arr": PropTypes.arrayOf(
          PropTypes.shape({"some.value": PropTypes.string})
        )
      }
    '''
    options: [skipShapeProps: no]
  ,
    code: '''
      TestComp1 = createReactClass({
        propTypes: {
          size: PropTypes.string
        },
        render: ->
          foo = {
            baz: 'bar'
          }
          icons = foo[this.props.size].salut
          return <div>{icons}</div>
      })
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          {firstname, lastname} = this.props.name
          return <div>{firstname} {lastname}</div>
      Hello.propTypes = {
        name: PropTypes.shape({
          firstname: PropTypes.string,
          lastname: PropTypes.string
        })
      }
    '''
    options: [skipShapeProps: no]
  ,
    # parser: 'babel-eslint'
    code: '''
      class Hello extends React.Component
        render: ->
          {firstname} = this
          return <div>{firstname}</div>
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      Hello = createReactClass({
        propTypes: {
          router: PropTypes.func
        },
        render: ->
          nextPath = this.props.router.getCurrentQuery().nextPath
          return <div>{nextPath}</div>
      })
    '''
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          firstname: CustomValidator.string
        },
        render: ->
          return <div>{this.props.firstname}</div>
      })
    '''
    options: [customValidators: ['CustomValidator']]
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          outer: CustomValidator.shape({
            inner: CustomValidator.map
          })
        },
        render: ->
          return <div>{this.props.outer.inner}</div>
      })
    '''
    options: [customValidators: ['CustomValidator'], skipShapeProps: no]
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          outer: PropTypes.shape({
            inner: CustomValidator.string
          })
        },
        render: ->
          return <div>{this.props.outer.inner}</div>
      })
    '''
    options: [customValidators: ['CustomValidator'], skipShapeProps: no]
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          outer: CustomValidator.shape({
            inner: PropTypes.string
          })
        },
        render: ->
          return <div>{this.props.outer.inner}</div>
      })
    '''
    options: [customValidators: ['CustomValidator'], skipShapeProps: no]
  ,
    code: '''
      Hello = createReactClass({
        propTypes: {
          name: PropTypes.string
        },
        render: ->
          return <div>{this.props.name.get("test")}</div>
      })
    '''
    options: [customValidators: ['CustomValidator']]
  ,
    code: '''
      SomeComponent = createReactClass({
        propTypes: SomeOtherComponent.propTypes
      })
    '''
  ,
    # parser: 'babel-eslint
    code: '''
      Hello = createReactClass({
        render: ->
          { a, ...b } = obj
          c = { ...d }
          return <div />
      })
    '''
  ,
    # ,
    #   code: [
    #     'class Hello extends React.Component {'
    #     '  static get propTypes() {}'
    #     '  render() ->'
    #     '    return <div>Hello World</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    # ,
    #   code: [
    #     'class Hello extends React.Component {'
    #     '  static get propTypes() {}'
    #     '  render() ->'
    #     "    users = this.props.users.find(user => user.name is 'John')"
    #     '    return <div>Hello you {users.length}</div>'
    #     '  }'
    #     '}'
    #     'Hello.propTypes = {'
    #     '  users: PropTypes.arrayOf(PropTypes.object)'
    #     '}'
    #   ].join '\n'
    code: '''
      class Hello extends React.Component
        render: ->
          {} = this.props
          return <div>Hello</div>
    '''
  ,
    code: '''
      class Hello extends React.Component
        render: ->
          foo = 'fullname'
          { [foo]: firstname } = this.props
          return <div>Hello {firstname}</div>
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class Hello extends React.Component
        constructor: (props, context) ->
          super(props, context)
          this.state = { status: props.source.uri }
        @propTypes = {
          source: PropTypes.object
        }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class Hello extends React.Component
        constructor: (props, context) ->
          super(props, context)
          this.state = { status: this.props.source.uri }
        @propTypes = {
          source: PropTypes.object
        }
    '''
  ,
    # parser: 'babel-eslint'
    # Should not be detected as a component
    code: '''
      HelloJohn.prototype.render = ->
        return React.createElement(Hello, {
          name: this.props.firstname
        })
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      HelloComponent = ->
        class Hello extends React.Component
          render: ->
            return <div>Hello {this.props.name}</div>
        Hello.propTypes = { name: PropTypes.string }
        return Hello
      module.exports = HelloComponent()
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      HelloComponent = ->
        Hello = createReactClass({
          propTypes: { name: PropTypes.string },
          render: ->
            return <div>Hello {this.props.name}</div>
        })
        return Hello
      module.exports = HelloComponent()
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      class DynamicHello extends Component
        render: ->
          {firstname} = this.props
          class Hello extends Component
            render: ->
              {name} = this.props
              return <div>Hello {name}</div>
          Hello.propTypes = {
            name: PropTypes.string
          }
          return <Hello />
      DynamicHello.propTypes = {
        firstname: PropTypes.string,
      }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      Hello = (props) =>
        team = props.names.map (name) =>
            return <li>{name}, {props.company}</li>
        return <ul>{team}</ul>
      Hello.propTypes = {
        names: PropTypes.array,
        company: PropTypes.string
      }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      export default {
        renderHello: ->
          {name} = this.props
          return <div>{name}</div>
      }
    '''
  ,
    # parser: 'babel-eslint'
    # Reassigned props are ignored
    code: '''
      export class Hello extends Component
        render: ->
          props = this.props
          return <div>Hello {props.name.firstname} {props['name'].lastname}</div>
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      export default FooBar = (props) ->
        bar = props.bar
        return (<div bar={bar}><div {...props}/></div>)
      if (process.env.NODE_ENV isnt 'production')
        FooBar.propTypes = {
          bar: PropTypes.string
        }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      Hello = createReactClass({
        render: ->
          {...other} = this.props
          return (
            <div {...other} />
          )
      })
    '''
  ,
    code: '''
      notAComponent = ({ something }) ->
        return something + 1
    '''
  ,
    code: '''
      notAComponent = ({ something }) ->
        something + 1
    '''
  ,
    # Validation is ignored on reassigned props object
    code: '''
      statelessComponent = (props) =>
        newProps = props
        return <span>{newProps.someProp}</span>
    '''
  ,
    # parser: 'babel-eslint'
    # Ignore component validation if propTypes are composed using spread
    code: '''
      class Hello extends React.Component
          render: ->
              return  <div>Hello {this.props.firstName} {this.props.lastName}</div>
      otherPropTypes = {
          lastName: PropTypes.string
      }
      Hello.propTypes = {
          ...otherPropTypes,
          firstName: PropTypes.string
      }
    '''
  ,
    # Ignore destructured function arguments
    code: '''
      class Hello extends React.Component
        render: ->
          return ["string"].map ({length}) => <div>{length}</div>
    '''
  ,
    code: '''
      Card.propTypes = {
        title: PropTypes.string.isRequired,
        children: PropTypes.element.isRequired,
        footer: PropTypes.node
      }
      Card = ({ title, children, footer }) ->
        return (
          <div/>
        )
    '''
  ,
    code: '''
      JobList = (props) ->
        props
        .jobs
        .forEach(() => {})
        return <div></div>
      JobList.propTypes = {
        jobs: PropTypes.array
      }
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      Greetings = ->
        return <div>{({name}) => <Hello name={name} />}</div>
    '''
  ,
    # parser: 'babel-eslint'
    code: '''
      Greetings = ->
        <div>{({name}) -> return <Hello name={name} />}</div>
    '''
  ,
    # parser: 'babel-eslint'
    # Should stop at the class when searching for a parent component
    code: '''
      export default (ComposedComponent) => class Something extends SomeOtherComponent
        someMethod = ({width}) => {}
    '''
  ,
    # parser: 'babel-eslint
    # Destructured shape props are skipped by default
    code: '''
      class Hello extends Component
        @propTypes = {
          params: PropTypes.shape({
            id: PropTypes.string
          })
        }
        render: ->
          {params} = this.props
          id = (params || {}).id
          return <span>{id}</span>
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in componentWillReceiveProps shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        componentWillReceiveProps: (nextProps) ->
          {something} = nextProps
          doSomething(something)
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in componentWillReceiveProps shouldn't throw errors
    code: '''
      class Hello extends Component
        componentWillReceiveProps: (nextProps) ->
          {something} = nextProps
          doSomething(something)
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured props in componentWillReceiveProps shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillReceiveProps: (nextProps) ->
          {something} = nextProps
          doSomething(something)
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in componentWillReceiveProps shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillReceiveProps: (nextProps) ->
          {something} = nextProps
          doSomething(something)
      })
    '''
  ,
    # Destructured function props in componentWillReceiveProps shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        componentWillReceiveProps: ({something}) ->
          doSomething(something)
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in componentWillReceiveProps shouldn't throw errors
    code: '''
      class Hello extends Component
        componentWillReceiveProps: ({something}) ->
          doSomething(something)
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured function props in componentWillReceiveProps shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillReceiveProps: ({something}) ->
          doSomething(something)
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in componentWillReceiveProps shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillReceiveProps: ({something}) ->
          doSomething(something)
      })
    '''
  ,
    # Destructured props in the constructor shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        constructor: (props) ->
          super(props)
          {something} = props
          doSomething(something)
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in the constructor shouldn't throw errors
    code: '''
      class Hello extends Component
        constructor: (props) ->
          super(props)
          {something} = props
          doSomething(something)
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured function props in the constructor shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        constructor: ({something}) ->
          super({something})
          doSomething(something)
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in the constructor shouldn't throw errors
    code: '''
      class Hello extends Component
        constructor: ({something}) ->
          super({something})
          doSomething(something)
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured props in the `shouldComponentUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        shouldComponentUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in the `shouldComponentUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        shouldComponentUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured props in `shouldComponentUpdate` shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        shouldComponentUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in `shouldComponentUpdate` shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        shouldComponentUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
      })
    '''
  ,
    # Destructured function props in the `shouldComponentUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        shouldComponentUpdate: ({something}, nextState) ->
          return something
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in the `shouldComponentUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        shouldComponentUpdate: ({something}, nextState) ->
          return something
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured function props in `shouldComponentUpdate` shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        shouldComponentUpdate: ({something}, nextState) ->
          return something
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in `shouldComponentUpdate` shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        shouldComponentUpdate: ({something}, nextState) ->
          return something
      })
    '''
  ,
    # Destructured props in the `componentWillUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        componentWillUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in the `componentWillUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        componentWillUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured props in `componentWillUpdate` shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in `componentWillUpdate` shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillUpdate: (nextProps, nextState) ->
          {something} = nextProps
          return something
      })
    '''
  ,
    # Destructured function props in the `componentWillUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        componentWillUpdate: ({something}, nextState) ->
          return something
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in the `componentWillUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        componentWillUpdate: ({something}, nextState) ->
          return something
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured function props in the `componentWillUpdate` method shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillUpdate: ({something}, nextState) ->
          return something
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in the `componentWillUpdate` method shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentWillUpdate: ({something}, nextState) ->
          return something
      })
    '''
  ,
    # Destructured props in the `componentDidUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        componentDidUpdate: (prevProps, prevState) ->
          {something} = prevProps
          return something
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in the `componentDidUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        componentDidUpdate: (prevProps, prevState) ->
          {something} = prevProps
          return something
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured props in `componentDidUpdate` shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentDidUpdate: (prevProps, prevState) ->
          {something} = prevProps
          return something
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured props in `componentDidUpdate` shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentDidUpdate: (prevProps, prevState) ->
          {something} = prevProps
          return something
      })
    '''
  ,
    # Destructured function props in the `componentDidUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        componentDidUpdate: ({something}, prevState) ->
          return something
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in the `componentDidUpdate` method shouldn't throw errors
    code: '''
      class Hello extends Component
        componentDidUpdate: ({something}, prevState) ->
          return something
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured function props in the `componentDidUpdate` method shouldn't throw errors when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentDidUpdate: ({something}, prevState) ->
          return something
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured function props in the `componentDidUpdate` method shouldn't throw errors when used createReactClass, with default parser
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentDidUpdate: ({something}, prevState) ->
          return something
      })
    '''
  ,
    # Destructured state props in `componentDidUpdate` [Issue #825]
    code: '''
      class Hello extends Component
        @propTypes = {
          something: PropTypes.bool
        }
        componentDidUpdate: ({something}, {state1, state2}) ->
          return something
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured state props in `componentDidUpdate` [Issue #825]
    code: '''
      class Hello extends Component
        componentDidUpdate: ({something}, {state1, state2}) ->
          return something
      Hello.propTypes = {
        something: PropTypes.bool,
      }
    '''
  ,
    # Destructured state props in `componentDidUpdate` [Issue #825] when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentDidUpdate: ({something}, {state1, state2}) ->
          return something
      })
    '''
  ,
    # parser: 'babel-eslint'
    # Destructured state props in `componentDidUpdate` without custom parser [Issue #825]
    code: '''
      Hello = React.Component({
        propTypes: {
          something: PropTypes.bool
        },
        componentDidUpdate: ({something}, {state1, state2}) ->
          return something
      })
    '''
  ,
    # Destructured state props in `componentDidUpdate` without custom parser [Issue #825] when used createReactClass
    code: '''
      Hello = createReactClass({
        propTypes: {
          something: PropTypes.bool,
        },
        componentDidUpdate: ({something}, {state1, state2}) ->
          return something
      })
    '''
  ,
    # Destructured props in a stateless function
    code: '''
      Hello = (props) =>
        {...rest} = props
        return <div />
    '''
  ,
    # `no-unused-prop-types` in jsx expressions - [Issue #885]
    code: '''
      PagingBlock = (props) ->
        return (
          <span>
            <a onClick={() => props.previousPage()}/>
            <a onClick={() => props.nextPage()}/>
          </span>
       )

      PagingBlock.propTypes = {
        nextPage: PropTypes.func.isRequired,
        previousPage: PropTypes.func.isRequired,
      }
    '''
  ,
    # `no-unused-prop-types` rest param props in jsx expressions - [Issue #885]
    code: '''
      PagingBlock = (props) ->
        return (
          <SomeChild {...props} />
       )

      PagingBlock.propTypes = {
        nextPage: PropTypes.func.isRequired,
        previousPage: PropTypes.func.isRequired,
      }
    '''
  ,
    code: '''
      class Hello extends Component
        componentWillReceiveProps: (nextProps) ->
          if (nextProps.foo)
            doSomething(this.props.bar)

      Hello.propTypes = {
        foo: PropTypes.bool,
        bar: PropTypes.bool
      }
    '''
  ,
    # The next two test cases are related to: https://github.com/yannickcr/eslint-plugin-react/issues/1183
    code: '''
      export default SomeComponent = (props) ->
          callback = () =>
              props.a(props.b)
      
          anotherCallback = () => {}
      
          return (
              <SomeOtherComponent
                  name={props.c}
                  callback={callback}
              />
          )
      
      SomeComponent.propTypes = {
          a: React.PropTypes.func.isRequired,
          b: React.PropTypes.string.isRequired,
          c: React.PropTypes.string.isRequired,
      }
    '''
  ,
    code: [
      'export default SomeComponent = (props) ->'
      '    callback = () =>'
      '        props.a(props.b)'
      ''
      '    return ('
      '        <SomeOtherComponent'
      '            name={props.c}'
      '            callback={callback}'
      '        />'
      '    )'
      ''
      'SomeComponent.propTypes = {'
      '    a: React.PropTypes.func.isRequired,'
      '    b: React.PropTypes.string.isRequired,'
      '    c: React.PropTypes.string.isRequired,'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  shouldComponentUpdate: (props) ->'
      '    if (props.foo)'
      '      return true'
      ''
      '  render() ->'
      '    return (<div>{this.props.bar}</div>)'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends Component'
      '  shouldComponentUpdate: (props) ->'
      '    if (props.foo)'
      '      return true'
      ''
      '  render() ->'
      '    return (<div>{this.props.bar}</div>)'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  componentWillUpdate: (props) ->'
      '    if (props.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends Component'
      '  componentWillUpdate: (props) ->'
      '    if (props.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  componentWillReceiveProps: (nextProps) ->'
      '    {foo} = nextProps'
      '    if (foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Props used inside of an async class property
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '  }'
      '  classProperty: () =>'
      '    await @props.foo()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Multiple props used inside of an async class property
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  classProperty = () =>'
      '    await this.props.foo()'
      '    await this.props.bar()'
      '    await this.props.baz()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends Component'
      '  componentWillReceiveProps: (props) ->'
      '    if (props.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  shouldComponentUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Destructured props inside of async class property
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '  }'
      '  classProperty: =>'
      '    { foo } = this.props'
      '    await foo()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Multiple destructured props inside of async class property
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  classProperty: =>'
      '    { foo, bar, baz } = this.props'
      '    await foo()'
      '    await bar()'
      '    await baz()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends Component'
      '  shouldComponentUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  componentWillUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Props used inside of an async class method
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '  }'
      '  method: ->'
      '    await this.props.foo()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Multiple props used inside of an async class method
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  method: ->'
      '    await this.props.foo()'
      '    await this.props.bar()'
      '    await this.props.baz()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Destrucuted props inside of async class method
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '  }'
      '  method: ->'
      '    { foo } = this.props'
      '    await foo()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends Component'
      '  componentWillUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  componentDidUpdate: (prevProps) ->'
      '    if (prevProps.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Multiple destructured props inside of async class method
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  method: ->'
      '    { foo, bar, baz } = this.props'
      '    await foo()'
      '    await bar()'
      '    await baz()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # factory functions that return async functions
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  factory: ->'
      '    return () =>'
      '      await this.props.foo()'
      '      await this.props.bar()'
      '      await this.props.baz()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # factory functions that return async functions
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  factory: ->'
      '    return ->'
      '      await this.props.foo()'
      '      await this.props.bar()'
      '      await this.props.baz()'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    code: [
      'class Hello extends Component'
      '  componentDidUpdate: (prevProps) ->'
      '    if (prevProps.foo)'
      '      return true'
      ''
      '  render: ->'
      '    return (<div>{this.props.bar}</div>)'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
  ,
    # Multiple props used inside of an async method
    code: [
      'class Example extends Component'
      '  method: ->'
      '    await this.props.foo()'
      '    await this.props.bar()'
      'Example.propTypes = {'
      '  foo: PropTypes.func,'
      '  bar: PropTypes.func,'
      '}'
    ].join '\n'
  ,
    # Multiple props used inside of an async function
    code: [
      'class Example extends Component'
      '  render: ->'
      '    onSubmit = ->'
      '      await this.props.foo()'
      '      await this.props.bar()'
      '    return <Form onSubmit={onSubmit} />'
      'Example.propTypes = {'
      '  foo: PropTypes.func,'
      '  bar: PropTypes.func,'
      '}'
    ].join '\n'
  ,
    # Multiple props used inside of an async arrow function
    code: [
      'class Example extends Component'
      '  render: ->'
      '    onSubmit = =>'
      '      await this.props.foo()'
      '      await this.props.bar()'
      '    return <Form onSubmit={onSubmit} />'
      'Example.propTypes = {'
      '  foo: PropTypes.func,'
      '  bar: PropTypes.func,'
      '}'
    ].join '\n'
  ,
    # Destructured assignment with Shape propTypes issue #816
    code: [
      'export default class NavigationButton extends React.Component'
      '  @propTypes = {'
      '    route: PropTypes.shape({'
      '      getBarTintColor: PropTypes.func.isRequired,'
      '    }).isRequired,'
      '  }'

      ' renderTitle: ->'
      '   { route } = this.props'
      '   return <Title tintColor={route.getBarTintColor()}>TITLE</Title>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # Destructured assignment without Shape propTypes issue #816
    code: [
      'Component = ({ children: aNode }) => ('
      ' <div>{aNode}</div>'
      ')'

      'Component.defaultProps = {'
      ' children: null,'
      '}'

      'Component.propTypes = {'
      ' children: React.PropTypes.node,'
      '}'
    ].join '\n'
  ,
    # issue 1309
    code: [
      'Thing = (props) => ('
      '    <div>'
      '      {(() =>'
      '            if(props.enabled && props.test)'
      '                return ('
      '                    <span>Enabled!</span>'
      '                )'
      '            return ('
      '                <span>Disabled..</span>'
      '            )'
      '        )()}'
      '    </div>'
      ')'

      'Thing.propTypes = {'
      '    enabled: React.PropTypes.bool,'
      '    test: React.PropTypes.bool'
      '}'
    ].join '\n'
  ,
    code: [
      'Thing = (props) => ('
      '    <div>'
      '      {do =>'
      '            if(props.enabled && props.test)'
      '                return ('
      '                    <span>Enabled!</span>'
      '                )'
      '            return ('
      '                <span>Disabled..</span>'
      '            )'
      '        }'
      '    </div>'
      ')'

      'Thing.propTypes = {'
      '    enabled: React.PropTypes.bool,'
      '    test: React.PropTypes.bool'
      '}'
    ].join '\n'
  ,
    # issue 1107
    code: [
      'Test = (props) => <div>'
      '  {someArray.map (l) => <div'
      '    key={l}>'
      '      {props.property + props.property2}'
      '    </div>}'
      '</div>'

      'Test.propTypes = {'
      '  property: React.propTypes.string.isRequired,'
      '  property2: React.propTypes.string.isRequired'
      '}'
    ].join '\n'
  ,
    # issue 811
    code: [
      'Button = React.createClass({'
      '  displayName: "Button",'

      '  propTypes: {'
      '    name: React.PropTypes.string.isRequired,'
      '    isEnabled: React.PropTypes.bool.isRequired'
      '  },'

      '  render: ->'
      '    item = this.props'
      '    disabled = !this.props.isEnabled'
      '    return ('
      '        <div>'
      '            <button type="button" disabled={disabled}>{item.name}</button>'
      '        </div>'
      '    )'
      '})'
    ].join '\n'
  ,
    # issue 811
    code: [
      'class Foo extends React.Component'
      '  @propTypes = {'
      '    foo: PropTypes.func.isRequired,'
      '  }'

      '  constructor: (props) ->'
      '    super(props)'

      '    { foo } = props'
      '    this.message = foo("blablabla")'

      '  render: ->'
      '    return <div>{this.message}</div>'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # issue #1097
    code: [
      'class HelloGraphQL extends Component'
      '  render: ->'
      '      return <div>Hello</div>'

      'HellowQueries = graphql(queryDetails, {'
      '  options: (ownProps) => ({'
      '    variables: ownProps.aProp'
      '  }),'
      '})(HelloGraphQL)'

      'HellowQueries.propTypes = {'
      '  aProp: PropTypes.string.isRequired'
      '}'

      'export default connect(mapStateToProps, mapDispatchToProps)(HellowQueries)'
    ].join '\n'
  ,
    # parser: 'babel-eslint'
    # issue #1335
    # code: [
    #   'type Props = {'
    #   ' foo: {'
    #   '  bar: boolean'
    #   ' }'
    #   '}'

    #   'class DigitalServices extends React.Component'
    #   ' props: Props'
    #   ' render: ->'
    #   '   { foo } = this.props'
    #   '   return <div>{foo.bar}</div>'
    #   ' }'
    #   '}'
    # ].join '\n'
    # ,
    # parser: 'babel-eslint'
    code: [
      'foo = {}'
      'class Hello extends React.Component'
      '  render: ->'
      '    {firstname, lastname} = this.props.name'
      '    return <div>{firstname} {lastname}</div>'
      'Hello.propTypes = {'
      '  name: PropTypes.shape(foo)'
      '}'
    ].join '\n'
  ,
    # ,
    #   # parser: 'babel-eslint'
    #   # issue #933
    #   code: [
    #     'type Props = {'
    #     ' onMouseOver: Function,'
    #     ' onClick: Function,'
    #     '}'

    #     'MyComponent = (props: Props) => ('
    #     '<div>'
    #     '  <button onMouseOver={() => props.onMouseOver()} />'
    #     '  <button onClick={() => props.onClick()} />'
    #     '</div>'
    #     ')'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    # issue #1506
    code: [
      'class MyComponent extends React.Component'
      '  onFoo:  ->'
      '    this.setState((prevState, props) =>'
      '      props.doSomething()'
      '    )'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
      'tempVar2'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [skipShapeProps: no]
  ,
    # issue #1506
    code: [
      'class MyComponent extends React.Component'
      '  onFoo: ->'
      '    this.setState((prevState, { doSomething }) =>'
      '      doSomething()'
      '    )'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [skipShapeProps: no]
  ,
    # issue #1506
    code: [
      'class MyComponent extends React.Component'
      '  onFoo: ->'
      '    this.setState((prevState, obj) =>'
      '      obj.doSomething()'
      '    )'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
      'tempVar2'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [skipShapeProps: no]
  ,
    # issue #1506
    code: [
      'class MyComponent extends React.Component'
      '  onFoo: ->'
      '    this.setState(() =>'
      '      this.props.doSomething()'
      '    )'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
      'tempVar'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [skipShapeProps: no]
  ,
    # issue #1542
    code: [
      'class MyComponent extends React.Component'
      '  onFoo: ->'
      '    this.setState((prevState) =>'
      '      this.props.doSomething()'
      '    )'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
  ,
    # issue #1542
    code: [
      'class MyComponent extends React.Component'
      '  onFoo: ->'
      '    this.setState(({ something }) =>'
      '      this.props.doSomething()'
      '    )'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
  ,
    # issue #106
    code: """
        import React from 'react'
        import SharedPropTypes from './SharedPropTypes'

        export default class A extends React.Component
          render: ->
            return (
              <span
                a={this.props.a}
                b={this.props.b}
                c={this.props.c}>
                {this.props.children}
              </span>
            )

        A.propTypes = {
          a: React.PropTypes.string,
          ...SharedPropTypes # eslint-disable-line object-shorthand
        }
      """
  ,
    # ,
    #   # parser: 'babel-eslint'
    #   # issue #933
    #   code: """
    #       type Props = {
    #         +foo: number
    #       }
    #       class MyComponent extends React.Component
    #         render: ->
    #           return <div>{this.props.foo}</div>
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Props = {
    #         \'completed?\': boolean,
    #       }
    #       Hello = (props: Props): React.Element => {
    #         return <div>{props[\'completed?\']}</div>
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Person = {
    #         firstname: string
    #       }
    #       class MyComponent extends React.Component<void, Props, void> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Person = {
    #         firstname: string
    #       }
    #       class MyComponent extends React.Component<void, Props, void> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.52'
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Person = {
    #         firstname: string
    #       }
    #       class MyComponent extends React.Component<Props> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Person = {
    #         firstname: string
    #       }
    #       class MyComponent extends React.Component<Props> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    # parser: 'babel-eslint'
    # Issue #1068
    code: """
      class MyComponent extends Component
        @propTypes = {
          validate: PropTypes.bool,
          options: PropTypes.array,
          value: ({options, value, validate}) =>
            if (!validate) then return
            if (options.indexOf(value) < 0)
              throw new Errow('oops')
        }

        render: ->
          return <ul>
            {this.props.options.map((option) =>
              <li className={this.props.value == option && "active"}>{option}</li>
            )}
          </ul>
      """
  ,
    # parser: 'babel-eslint'
    # Issue #1068
    code: """
      class MyComponent extends Component
        @propTypes = {
          validate: PropTypes.bool,
          options: PropTypes.array,
          value: ({options, value, validate}) ->
            if (!validate) then return
            if (options.indexOf(value) < 0)
              throw new Errow('oops')
        }

        render: ->
          return <ul>
            {this.props.options.map((option) =>
              <li className={this.props.value == option && "active"}>{option}</li>
            )}
          </ul>
      """
  ,
    # parser: 'babel-eslint'
    # Issue #1068
    code: """
      class MyComponent extends Component
        @propTypes = {
          validate: PropTypes.bool,
          options: PropTypes.array,
          value: ({options, value, validate}) ->
            if (!validate) then return
            if (options.indexOf(value) < 0)
              throw new Errow('oops')
        }

        render: ->
          return <ul>
            {this.props.options.map((option) =>
              <li className={this.props.value == option && "active"}>{option}</li>
            )}
          </ul>
      """
  ,
    # parser: 'babel-eslint'
    code: """
        class MyComponent extends React.Component
          render: ->
            return <div>{ this.props.other }</div>
        MyComponent.propTypes = { other: () => {} }
      """
  ,
    # Sanity test coverage for new UNSAFE_componentWillReceiveProps lifecycles
    code: [
      """
        class Hello extends Component
          @propTypes = {
            something: PropTypes.bool
          }
          UNSAFE_componentWillReceiveProps: (nextProps) ->
            {something} = nextProps
            doSomething(something)
      """
    ].join '\n'
    settings: react: version: '16.3.0'
  ,
    # parser: 'babel-eslint'
    # Destructured props in the `UNSAFE_componentWillUpdate` method shouldn't throw errors
    code: [
      """
        class Hello extends Component
          @propTypes = {
            something: PropTypes.bool
          }
          UNSAFE_componentWillUpdate: (nextProps, nextState) ->
            {something} = nextProps
            return something
      """
    ].join '\n'
    settings: react: version: '16.3.0'
  ,
    # parser: 'babel-eslint'
    # Simple test of new @getDerivedStateFromProps lifecycle
    code: [
      """
        class MyComponent extends React.Component
          @propTypes = {
            defaultValue: 'bar'
          }
          state = {
            currentValue: null
          }
          @getDerivedStateFromProps: (nextProps, prevState) ->
            if (prevState.currentValue is null)
              return {
                currentValue: nextProps.defaultValue,
              }
            return null
          render: ->
            return <div>{ this.state.currentValue }</div>
      """
    ].join '\n'
    settings: react: version: '16.3.0'
  ,
    # parser: 'babel-eslint'
    # Simple test of new @getSnapshotBeforeUpdate lifecycle
    code: [
      """
        class MyComponent extends React.Component
          @propTypes = {
            defaultValue: PropTypes.string
          }
          getSnapshotBeforeUpdate: (prevProps, prevState) ->
            if (prevProps.defaultValue is null)
              return 'snapshot'
            return null
          render: ->
            return <div />
      """
    ].join '\n'
    settings: react: version: '16.3.0'
  ,
    # ,
    #   # parser: 'babel-eslint'
    #   # Impossible intersection type
    #   code: """
    #       import React from 'react'
    #       type Props = string & {
    #         fullname: string
    #       }
    #       class Test extends React.PureComponent<Props> {
    #         render: ->
    #           return <div>Hello {this.props.fullname}</div>
    #         }
    #       }
    #     """
    # ,
    #   # parser: 'babel-eslint'
    #   code: [
    #     "import type {BasePerson} from './types'"
    #     'type Props = {'
    #     '  person: {'
    #     '   ...$Exact<BasePerson>,'
    #     '   lastname: string'
    #     '  }'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    # parser: 'babel-eslint'
    code: [
      "import BasePerson from './types'"
      'class Hello extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.person.firstname}</div>'
      'Hello.propTypes = {'
      '  person: ProTypes.shape({'
      '    ...BasePerson,'
      '    lastname: PropTypes.string'
      '  })'
      '}'
    ].join '\n'
  ]

  invalid: [
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    unused: PropTypes.string'
      '  },'
      '  render: ->'
      '    return React.createElement("div", {}, this.props.value)'
      '})'
    ].join '\n'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    name: PropTypes.string'
      '  },'
      '  render: ->'
      '    return <div>Hello {this.props.value}</div>'
      '})'
    ].join '\n'
    errors: [
      message: "'name' PropType is defined but prop is never used"
      line: 3
      column: 11
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {'
      '    name: PropTypes.string'
      '  }'
      '  render: ->'
      '    return <div>Hello {this.props.value}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'name' PropType is defined but prop is never used"
      line: 3
      column: 11
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.firstname} {this.props.lastname}</div>'
      'Hello.propTypes = {'
      '  unused: PropTypes.string'
      '}'
    ].join '\n'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
      'Hello.propTypes = {'
      '  unused: PropTypes.string'
      '}'
      'class HelloBis extends React.Component'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
    ].join '\n'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    unused: PropTypes.string.isRequired,'
      '    anotherunused: PropTypes.string.isRequired'
      '  },'
      '  render: ->'
      '    return <div>Hello {this.props.name} and {this.props.propWithoutTypeDefinition}</div>'
      '})'
      'Hello2 = createReactClass({'
      '  render: ->'
      '    return <div>Hello {this.props.name}</div>'
      '})'
    ].join '\n'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
    ,
      message: "'anotherunused' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    { firstname, lastname } = this.props'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  unused: PropTypes.string'
      '}'
    ].join '\n'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.z'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.shape({'
      '    b: PropTypes.string'
      '  })'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [message: "'a.b' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b.z'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.shape({'
      '    b: PropTypes.shape({'
      '      c: PropTypes.string'
      '    })'
      '  })'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [message: "'a.b.c' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.b.c'
      '    this.props.a.__.d.length'
      '    this.props.a.anything.e[2]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.objectOf('
      '    PropTypes.shape({'
      '      unused: PropTypes.string'
      '    })'
      '  )'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [
      message: "'a.*.unused' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    i = 3'
      '    this.props.a[2].c'
      '    this.props.a[i].d.length'
      '    this.props.a[i + 2].e[2]'
      '    this.props.a.length'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.arrayOf('
      '    PropTypes.shape({'
      '      unused: PropTypes.string'
      '    })'
      '  )'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [
      message: "'a.*.unused' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props.a.length'
      '    this.props.a.b'
      '    this.props.a.e.length'
      '    this.props.a.e.anyProp'
      '    this.props.a.c.toString()'
      '    this.props.a.c.someThingElse()'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.oneOfType(['
      '    PropTypes.shape({'
      '      unused: PropTypes.number,'
      '      anotherunused: PropTypes.array'
      '    })'
      '  ])'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [
      message: "'a.unused' PropType is defined but prop is never used"
    ,
      message: "'a.anotherunused' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["some.value"]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "some.unused": PropTypes.string'
      '}'
    ].join '\n'
    errors: [
      message: "'some.unused' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    this.props["arr"][1]["some.value"]'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  "arr": PropTypes.arrayOf('
      '    PropTypes.shape({'
      '      "some.unused": PropTypes.string'
      '    })'
      '  )'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [
      message: "'arr.*.some.unused' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {'
      '    unused: PropTypes.string'
      '  }'
      '  render: ->'
      '    text'
      "    text = 'Hello '"
      '    {props: {firstname}} = this'
      '    return <div>{text} {firstname}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    if (true)'
      '      return <span>{this.props.firstname}</span>'
      '    else'
      '      return <span>{this.props.lastname}</span>'
      'Hello.propTypes = {'
      '  unused: PropTypes.string'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Hello = (props) ->'
      '  return <div>Hello {props.name}</div>'
      'Hello.prototype.propTypes = {unused: PropTypes.string}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Hello = (props) =>'
      '  {name} = props'
      '  return <div>Hello {name}</div>'
      'Hello.prototype.propTypes = {unused: PropTypes.string}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Hello = ({ name }) ->'
      '  return <div>Hello {name}</div>'
      'Hello.prototype.propTypes = {unused: PropTypes.string}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Hello = ({ name }) ->'
      '  return <div>Hello {name}</div>'
      'Hello.prototype.propTypes = {unused: PropTypes.string}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Hello = ({ name }) =>'
      '  return <div>Hello {name}</div>'
      'Hello.prototype.propTypes = {unused: PropTypes.string}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {unused: PropTypes.string}'
      '  render: ->'
      "    props = {firstname: 'John'}"
      '    return <div>Hello {props.firstname} {this.props.lastname}</div>'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {unused: PropTypes.string}'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: props.source }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'class Hello extends React.Component'
      '  @propTypes = {unused: PropTypes.string}'
      '  constructor: (props, context) ->'
      '    super(props, context)'
      '    this.state = { status: props.source.uri }'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'HelloComponent = ->'
      '  Hello = createReactClass({'
      '    propTypes: {unused: PropTypes.string},'
      '    render: ->'
      '      return <div>Hello {this.props.name}</div>'
      '  })'
      '  return Hello'
      'module.exports = HelloComponent()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Hello = (props) =>'
      '  team = props.names.map((name) =>'
      '      return <li>{name}, {props.company}</li>'
      '    )'
      '  return <ul>{team}</ul>'
      'Hello.prototype.propTypes = {unused: PropTypes.string}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'Annotation = (props) => ('
      '  <div>'
      '    {props.text}'
      '  </div>'
      ')'
      'Annotation.prototype.propTypes = {unused: PropTypes.string}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'for key of foo'
      '  Hello = createReactClass({'
      '    propTypes: {unused: PropTypes.string},'
      '    render: ->'
      '      return <div>Hello {this.props.name}</div>'
      '  })'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'propTypes = {'
      '  unused: PropTypes.string'
      '}'
      'class Test extends React.Component'
      '  render: ->'
      '    return ('
      '      <div>{this.props.firstname} {this.props.lastname}</div>'
      '    )'
      'Test.propTypes = propTypes'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    {
      code: [
        'class Test extends Foo.Component'
        '  render: ->'
        '    return ('
        '      <div>{this.props.firstname} {this.props.lastname}</div>'
        '    )'
        'Test.propTypes = {'
        '  unused: PropTypes.string'
        '}'
      ].join '\n'
      # parser: 'babel-eslint'
      settings
      errors: [message: "'unused' PropType is defined but prop is never used"]
    }
  ,
    code: [
      '###* @jsx Foo ###'
      'class Test extends Foo.Component'
      '  render: ->'
      '    return ('
      '      <div>{this.props.firstname} {this.props.lastname}</div>'
      '    )'
      'Test.propTypes = {'
      '  unused: PropTypes.string'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    unused: PropTypes.string'
    #     '  }'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name}</div>'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'unused' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {'
    #     '    unused: Object'
    #     '  }'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'unused' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     'type Props = {unused: Object}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'unused' PropType is defined but prop is never used"]
    # ,
    #   code: """
    #     type PropsA = { a: string }
    #     type PropsB = { b: string }
    #     type Props = PropsA & PropsB

    #     class MyComponent extends React.Component
    #       props: Props

    #       render: ->
    #         return <div>{this.props.a}</div>
    #       }
    #     }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'b' PropType is defined but prop is never used"]
    # ,
    #   code: """
    #       type PropsA = { foo: string }
    #       type PropsB = { bar: string }
    #       type PropsC = { zap: string }
    #       type Props = PropsA & PropsB

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'zap' PropType is defined but prop is never used"]
    # ,
    #   code: """
    #       type PropsB = { foo: string }
    #       type PropsC = { bar: string }
    #       type Props = PropsB & {
    #         zap: string
    #       }

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar}</div>
    #         }
    #       }
    #     """
    #   errors: [message: "'zap' PropType is defined but prop is never used"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type PropsB = { foo: string }
    #       type PropsC = { bar: string }
    #       type Props = {
    #         zap: string
    #       } & PropsB

    #       class Bar extends React.Component
    #         props: Props & PropsC

    #         render: ->
    #           return <div>{this.props.foo} - {this.props.bar}</div>
    #         }
    #       }
    #     """
    #   errors: [message: "'zap' PropType is defined but prop is never used"]
    # parser: 'babel-eslint'
    # code: [
    #   'class Hello extends React.Component'
    #   '  props: {'
    #   '    name: {'
    #   '      unused: string'
    #   '    }'
    #   '  }'
    #   '  render : ->'
    #   '    return <div>Hello {this.props.name.lastname}</div>'
    # ].join '\n'
    # # parser: 'babel-eslint'
    # options: [skipShapeProps: no]
    # errors: [
    #   message: "'name.unused' PropType is defined but prop is never used"
    # ]
    # ,
    # ,
    #   code: [
    #     'type Props = {name: {unused: string}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    #   errors: [
    #     message: "'name.unused' PropType is defined but prop is never used"
    #   ]
    # ,
    #   code: [
    #     'class Hello extends React.Component'
    #     '  props: {person: {name: {unused: string}}}'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.name.lastname}</div>'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    #   errors: [
    #     message: "'person.name.unused' PropType is defined but prop is never used"
    #   ]
    # ,
    #   code: [
    #     'type Props = {person: {name: {unused: string}}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.name.lastname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    #   errors: [
    #     message: "'person.name.unused' PropType is defined but prop is never used"
    #   ]
    # ,
    #   code: [
    #     'type Person = {name: {unused: string}}'
    #     'class Hello extends React.Component'
    #     '  props: {people: Person[]}'
    #     '  render : ->'
    #     '    names = []'
    #     '    for (i = 0 i < this.props.people.length i++) ->'
    #     '      names.push(this.props.people[i].name.lastname)'
    #     '    }'
    #     '    return <div>Hello {names.join('
    #     ')}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    #   errors: [
    #     message:
    #       "'people.*.name.unused' PropType is defined but prop is never used"
    #   ]
    # ,
    #   code: [
    #     'type Person = {name: {unused: string}}'
    #     'type Props = {people: Person[]}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    names = []'
    #     '    for (i = 0 i < this.props.people.length i++) ->'
    #     '      names.push(this.props.people[i].name.lastname)'
    #     '    }'
    #     '    return <div>Hello {names.join('
    #     ')}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    #   errors: [
    #     message:
    #       "'people.*.name.unused' PropType is defined but prop is never used"
    #   ]
    # ,
    #   code: [
    #     'type Props = {result?: {ok: string | boolean}|{ok: number | Array}}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.result.notok}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    #   errors: [
    #     message: "'result.ok' PropType is defined but prop is never used"
    #   ,
    #     message: "'result.ok' PropType is defined but prop is never used"
    #   ]
    # ,
    #   code: [
    #     'function Greetings({names}) ->'
    #     '  names = names.map(({firstname, lastname}) => <div>{firstname} {lastname}</div>)'
    #     '  return <Hello>{names}</Hello>'
    #     '}'
    #     'Greetings.propTypes = {unused: Object}'
    #   ].join '\n'
    #   errors: [message: "'unused' PropType is defined but prop is never used"]
    code: [
      'MyComponent = (props) => ('
      '  <div onClick={() => props.toggle()}></div>'
      ')'
      'MyComponent.propTypes = {unused: Object}'
    ].join '\n'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    code: [
      'MyComponent = (props) => if props.test then <div /> else <span />'
      'MyComponent.propTypes = {unused: Object}'
    ].join '\n'
    errors: [message: "'unused' PropType is defined but prop is never used"]
  ,
    # ,
    #   code: [
    #     'type Props = {'
    #     '  unused: ?string,'
    #     '}'
    #     'function Hello({firstname, lastname}: Props): React$Element'
    #     '  return <div>Hello {firstname} {lastname}</div>'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'unused' PropType is defined but prop is never used"]
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  constructor: (props) ->'
      '    super(props)'
      '    {something} = props'
      '    doSomething(something)'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  constructor: ({something}) ->'
      '    super({something})'
      '    doSomething(something)'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  componentWillReceiveProps: (nextProps, nextState) ->'
      '    {something} = nextProps'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  componentWillReceiveProps: ({something}, nextState) ->'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  shouldComponentUpdate: (nextProps, nextState) ->'
      '    {something} = nextProps'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  shouldComponentUpdate: ({something}, nextState) ->'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  componentWillUpdate: (nextProps, nextState) ->'
      '    {something} = nextProps'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  componentWillUpdate: ({something}, nextState) ->'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  componentDidUpdate: (prevProps, prevState) ->'
      '    {something} = prevProps'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    unused: PropTypes.bool'
      '  }'
      '  componentDidUpdate: ({something}, prevState) ->'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'unused' PropType is defined but prop is never used"
      line: 3
      column: 13
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    something: PropTypes.bool'
      '  }'
      '  componentDidUpdate: (prevProps, {state1, state2}) ->'
      '    return something'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'something' PropType is defined but prop is never used"
      line: 3
      column: 16
    ]
  ,
    code: [
      'Hello = createReactClass({'
      '  propTypes: {'
      '    something: PropTypes.bool'
      '  },'
      '  componentDidUpdate: (prevProps, {state1, state2}) ->'
      '    return something'
      '})'
    ].join '\n'
    errors: [
      message: "'something' PropType is defined but prop is never used"
      line: 3
      column: 16
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  componentWillUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 4
      column: 10
    ]
  ,
    # Multiple props used inside of an async class property
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  classProperty: =>'
      '    await this.props.foo()'
      '    await this.props.bar()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'baz' PropType is defined but prop is never used"
      line: 5
      column: 10
    ]
  ,
    code: [
      'class Hello extends Component'
      '  componentWillUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 7
      column: 8
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  shouldComponentUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 4
      column: 10
    ]
  ,
    # Multiple destructured props inside of async class property
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  classProperty: =>'
      '    { bar, baz } = this.props'
      '    await bar()'
      '    await baz()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'foo' PropType is defined but prop is never used"]
  ,
    # Multiple props used inside of an async class method
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  method: ->'
      '    await this.props.foo()'
      '    await this.props.baz()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 4
      column: 10
    ]
  ,
    code: [
      'class Hello extends Component'
      '  shouldComponentUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 7
      column: 8
    ]
  ,
    code: [
      'class Hello extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.string,'
      '    bar: PropTypes.string,'
      '  }'
      ''
      '  componentDidUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 4
      column: 10
    ]
  ,
    # Multiple destructured props inside of async class method
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  method: ->'
      '    { foo, bar } = this.props'
      '    await foo()'
      '    await bar()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'baz' PropType is defined but prop is never used"
      line: 5
      column: 10
    ]
  ,
    # factory functions that return async functions
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  factory: ->'
      '    =>'
      '      await this.props.foo()'
      '      await this.props.bar()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'baz' PropType is defined but prop is never used"
      line: 5
      column: 10
    ]
  ,
    code: [
      'class Hello extends Component'
      '  componentDidUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      'Hello.propTypes = {'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '}'
    ].join '\n'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 7
      column: 8
    ]
  ,
    code: [
      'class Hello extends Component'
      '  componentDidUpdate: (nextProps) ->'
      '    if (nextProps.foo)'
      '      return true'
      'Hello.propTypes = forbidExtraProps({'
      '  foo: PropTypes.string,'
      '  bar: PropTypes.string,'
      '})'
    ].join '\n'
    errors: [
      message: "'bar' PropType is defined but prop is never used"
      line: 7
      column: 8
    ]
    settings:
      propWrapperFunctions: ['forbidExtraProps']
  ,
    # ,
    #   code: [
    #     'class Hello extends Component'
    #     '  propTypes = forbidExtraProps({'
    #     '    foo: PropTypes.string,'
    #     '    bar: PropTypes.string'
    #     '  })'
    #     '  componentDidUpdate: (nextProps) ->'
    #     '    if (nextProps.foo)'
    #     '      return true'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [
    #     message: "'bar' PropType is defined but prop is never used"
    #     line: 4
    #     column: 10
    #   ]
    #   settings:
    #     propWrapperFunctions: ['forbidExtraProps']
    # factory functions that return async functions
    code: [
      'export class Example extends Component'
      '  @propTypes = {'
      '    foo: PropTypes.func,'
      '    bar: PropTypes.func,'
      '    baz: PropTypes.func,'
      '  }'
      '  factory: ->'
      '    return ->'
      '      await this.props.bar()'
      '      await this.props.baz()'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'foo' PropType is defined but prop is never used"
      line: 3
      column: 10
    ]
  ,
    # Multiple props used inside of an async function
    code: [
      'class Example extends Component'
      '  render: ->'
      '    onSubmit = ->'
      '      await this.props.foo()'
      '      await this.props.bar()'
      '    return <Form onSubmit={onSubmit} />'
      'Example.propTypes = {'
      '  foo: PropTypes.func,'
      '  bar: PropTypes.func,'
      '  baz: PropTypes.func,'
      '}'
    ].join '\n'
    errors: [
      message: "'baz' PropType is defined but prop is never used"
      line: 10
      column: 8
    ]
  ,
    # Multiple props used inside of an async arrow function
    code: [
      'class Example extends Component'
      '  render: ->'
      '    onSubmit = =>'
      '      await this.props.bar()'
      '      await this.props.baz()'
      '    return <Form onSubmit={onSubmit} />'
      'Example.propTypes = {'
      '  foo: PropTypes.func,'
      '  bar: PropTypes.func,'
      '  baz: PropTypes.func,'
      '}'
    ].join '\n'
    errors: [
      message: "'foo' PropType is defined but prop is never used"
      line: 8
      column: 8
    ]
  ,
    # None of the props are used issue #1162
    code: [
      'import React from "react" '
      'Hello = React.createReactClass({'
      ' propTypes: {'
      '   name: React.PropTypes.string'
      ' },'
      ' render: ->'
      '   return <div>Hello Bob</div>'
      '})'
    ].join '\n'
    errors: [message: "'name' PropType is defined but prop is never used"]
  ,
    code: [
      'class Comp1 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp1.propTypes = {'
      '  prop1: PropTypes.number'
      '}'
      'class Comp2 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp2.propTypes = {'
      '  prop2: PropTypes.arrayOf(Comp1.propTypes.prop1)'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'prop1' PropType is defined but prop is never used"
    ,
      message: "'prop2' PropType is defined but prop is never used"
    ,
      message: "'prop2.*' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Comp1 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp1.propTypes = {'
      '  prop1: PropTypes.number'
      '}'
      'class Comp2 extends Component'
      '  @propTypes = {'
      '    prop2: PropTypes.arrayOf(Comp1.propTypes.prop1)'
      '  }'
      '  render: ->'
      '    return <span />'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'prop1' PropType is defined but prop is never used"
    ,
      message: "'prop2' PropType is defined but prop is never used"
    ,
      message: "'prop2.*' PropType is defined but prop is never used"
    ]
  ,
    code: [
      'class Comp1 extends Component'
      '  render: ->'
      '    return <span />'
      'Comp1.propTypes = {'
      '  prop1: PropTypes.number'
      '}'
      'Comp2 = createReactClass({'
      '  propTypes: {'
      '    prop2: PropTypes.arrayOf(Comp1.propTypes.prop1)'
      '  },'
      '  render: ->'
      '    return <span />'
      '})'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [
      message: "'prop1' PropType is defined but prop is never used"
    ,
      message: "'prop2' PropType is defined but prop is never used"
    ,
      message: "'prop2.*' PropType is defined but prop is never used"
    ]
  ,
    # Destructured assignment with Shape propTypes with skipShapeProps off issue #816
    code: [
      'export default class NavigationButton extends React.Component'
      '  @propTypes = {'
      '    route: PropTypes.shape({'
      '      getBarTintColor: PropTypes.func.isRequired,'
      '    }).isRequired,'
      '  }'

      '  renderTitle: ->'
      '    { route } = this.props'
      '    return <Title tintColor={route.getBarTintColor()}>TITLE</Title>'
    ].join '\n'
    # parser: 'babel-eslint'
    options: [skipShapeProps: no]
    errors: [
      message:
        "'route.getBarTintColor' PropType is defined but prop is never used"
    ]
  ,
    code: [
      # issue #1097
      'class HelloGraphQL extends Component'
      '  render: ->'
      '      return <div>Hello</div>'
      'HelloGraphQL.propTypes = {'
      '  aProp: PropTypes.string.isRequired'
      '}'

      'HellowQueries = graphql(queryDetails, {'
      '  options: (ownProps) => ({'
      '    variables: ownProps.aProp'
      '  }),'
      '})(HelloGraphQL)'

      'export default connect(mapStateToProps, mapDispatchToProps)(HellowQueries)'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'aProp' PropType is defined but prop is never used"]
  ,
    # ,
    #   code: """
    #       type Props = {
    #         firstname: string,
    #         lastname: string,
    #       }
    #       class MyComponent extends React.Component<void, Props, void> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: """
    #       type Props = {
    #         firstname: string,
    #         lastname: string,
    #       }
    #       class MyComponent extends React.Component<void, Props, void> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.52'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: """
    #       type Props = {
    #         firstname: string,
    #         lastname: string,
    #       }
    #       class MyComponent extends React.Component<Props> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: """
    #       type Person = string
    #       class Hello extends React.Component<{ person: Person }> {
    #         render : ->
    #           return <div />
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    #   errors: [message: "'person' PropType is defined but prop is never used"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       type Person = string
    #       class Hello extends React.Component<void, { person: Person }, void> {
    #         render : ->
    #           return <div />
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.52'
    #   errors: [message: "'person' PropType is defined but prop is never used"]
    # ,
    #   # parser: 'babel-eslint'
    #   code: """
    #       function higherOrderComponent<P: { foo: string }>: ->
    #         return class extends React.Component<P> {
    #           render: ->
    #             return <div />
    #           }
    #         }
    #       }
    #     """
    #   errors: [message: "'foo' PropType is defined but prop is never used"]
    # parser: 'babel-eslint'
    # issue #1506
    code: [
      'class MyComponent extends React.Component'
      '  onFoo: ->'
      '    this.setState(({ doSomething }, props) =>'
      '      return { doSomething: doSomething + 1 }'
      '    )'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
    ].join '\n'
    errors: [
      message: "'doSomething' PropType is defined but prop is never used"
    ]
  ,
    # issue #1685
    code: [
      'class MyComponent extends React.Component'
      '  onFoo: ->'
      '    this.setState((prevState) => ({'
      '      doSomething: prevState.doSomething + 1,'
      '    }))'
      '  render: ->'
      '    return ('
      '       <div onClick={this.onFoo}>Test</div>'
      '    )'
      'MyComponent.propTypes = {'
      '  doSomething: PropTypes.func'
      '}'
    ].join '\n'
    errors: [
      message: "'doSomething' PropType is defined but prop is never used"
    ]
  ,
    # ,
    #   code: """
    #       type Props = {
    #         firstname: string,
    #         lastname: string,
    #       }
    #       class MyComponent extends React.Component<Props> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    #   settings: react: flowVersion: '0.53'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    code: [
      """
        class Hello extends Component
          @propTypes = {
            something: PropTypes.bool
          }
          UNSAFE_componentWillReceiveProps: (nextProps) ->
            {something} = nextProps
            doSomething(something)
      """
    ].join '\n'
    settings: react: version: '16.2.0'
    # parser: 'babel-eslint'
    errors: [message: "'something' PropType is defined but prop is never used"]
  ,
    code: [
      """
        class Hello extends Component
          @propTypes = {
            something: PropTypes.bool
          }
          UNSAFE_componentWillUpdate: (nextProps, nextState) ->
            {something} = nextProps
            return something
      """
    ].join '\n'
    settings: react: version: '16.2.0'
    # parser: 'babel-eslint'
    errors: [message: "'something' PropType is defined but prop is never used"]
  ,
    code: [
      """
        class MyComponent extends React.Component
          @propTypes = {
            defaultValue: 'bar'
          }
          state = {
            currentValue: null
          }
          @getDerivedStateFromProps: (nextProps, prevState) ->
            if (prevState.currentValue is null)
              return {
                currentValue: nextProps.defaultValue,
              }
            return null
          render: ->
            return <div>{ this.state.currentValue }</div>
      """
    ].join '\n'
    settings: react: version: '16.2.0'
    # parser: 'babel-eslint'
    errors: [
      message: "'defaultValue' PropType is defined but prop is never used"
    ]
  ,
    code: [
      """
        class MyComponent extends React.Component
          @propTypes = {
            defaultValue: PropTypes.string
          }
          getSnapshotBeforeUpdate: (prevProps, prevState) ->
            if (prevProps.defaultValue is null)
              return 'snapshot'
            return null
          render: ->
            return <div />
      """
    ].join '\n'
    settings: react: version: '16.2.0'
    # parser: 'babel-eslint'
    errors: [
      message: "'defaultValue' PropType is defined but prop is never used"
    ]
  ,
    # ,
    #   # Mixed union and intersection types
    #   code: """
    #       import React from 'react'
    #       type OtherProps = {
    #         firstname: string,
    #         lastname: string,
    #       } | {
    #         fullname: string
    #       }
    #       type Props = OtherProps & {
    #         age: number
    #       }
    #       class Test extends React.PureComponent<Props> {
    #         render: ->
    #           return <div>Hello {this.props.firstname}</div>
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'age' PropType is defined but prop is never used"]
    code: [
      'class Hello extends React.Component'
      '  render: ->'
      '    return <div>Hello</div>'
      'Hello.propTypes = {'
      '  a: PropTypes.shape({'
      '    b: PropTypes.shape({'
      '    })'
      '  })'
      '}'
      'Hello.propTypes.a.b.c = PropTypes.number'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [
      message: "'a' PropType is defined but prop is never used"
    ,
      message: "'a.b' PropType is defined but prop is never used"
    ,
      message: "'a.b.c' PropType is defined but prop is never used"
    ]
  ,
    # ,
    #   code: """
    #       type Props = { foo: string }
    #       function higherOrderComponent<Props>: ->
    #         return class extends React.Component<Props> {
    #           render: ->
    #             return <div />
    #           }
    #         }
    #       }
    #     """
    #   # parser: 'babel-eslint'
    #   errors: [message: "'foo' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     'type Person = {'
    #     '  ...data,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     'type Person = {|'
    #     '  ...data,'
    #     '  lastname: string'
    #     '|}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     'type Person = {'
    #     '  ...$Exact<data>,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     "import type {Data} from './Data'"
    #     'type Person = {'
    #     '  ...Data,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.bar}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     "import type {Data} from 'some-libdef-like-flow-typed-provides'"
    #     'type Person = {'
    #     '  ...Data,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.bar}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     'type Person = {'
    #     '  ...data,'
    #     '  lastname: string'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    # ,
    #   code: [
    #     'type Person = {|'
    #     '  ...data,'
    #     '  lastname: string'
    #     '|}'
    #     'class Hello extends React.Component'
    #     '  props: Person'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   errors: [message: "'lastname' PropType is defined but prop is never used"]
    code: [
      'class Hello extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.firstname}</div>'
      'Hello.propTypes = {'
      '  ...BasePerson,'
      '  lastname: PropTypes.string'
      '}'
    ].join '\n'
    # parser: 'babel-eslint'
    errors: [message: "'lastname' PropType is defined but prop is never used"]
  ,
    # ,
    #   code: [
    #     "import type {BasePerson} from './types'"
    #     'type Props = {'
    #     '  person: {'
    #     '   ...$Exact<BasePerson>,'
    #     '   lastname: string'
    #     '  }'
    #     '}'
    #     'class Hello extends React.Component'
    #     '  props: Props'
    #     '  render : ->'
    #     '    return <div>Hello {this.props.person.firstname}</div>'
    #     '  }'
    #     '}'
    #   ].join '\n'
    #   # parser: 'babel-eslint'
    #   options: [skipShapeProps: no]
    #   errors: [
    #     message: "'person.lastname' PropType is defined but prop is never used"
    #   ]
    code: [
      "import BasePerson from './types'"
      'class Hello extends React.Component'
      '  render : ->'
      '    return <div>Hello {this.props.person.firstname}</div>'
      'Hello.propTypes = {'
      '  person: PropTypes.shape({'
      '    ...BasePerson,'
      '    lastname: PropTypes.string'
      '  })'
      '}'
    ].join '\n'
    options: [skipShapeProps: no]
    errors: [
      message: "'person.lastname' PropType is defined but prop is never used"
    ]

    ### , {
      # Enable this when the following issue is fixed
      # https:#github.com/yannickcr/eslint-plugin-react/issues/296
      code: [
        'function Foo(props) ->',
        '  { bar: { nope } } = props',
        '  return <div test={nope} />',
        '}',
        'Foo.propTypes = {',
        '  foo: PropTypes.number,',
        '  bar: PropTypes.shape({',
        '    faz: PropTypes.number,',
        '    qaz: PropTypes.object,',
        '  }),',
        '}'
      ].join('\n'),
      # parser: 'babel-eslint',
      errors: [{
        message: '\'foo\' PropType is defined but prop is never used'
      }]
    }###
  ]
