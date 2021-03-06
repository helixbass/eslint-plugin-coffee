###*
# @fileoverview No unused styles defined in javascript files
# @author Tom Hastjarjanto
###

'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/no-unused-styles'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
tests =
  valid: [
    code: '''
      styles = StyleSheet.create({
        name: {}
      })
      Hello = React.createClass({
        render: ->
          return <Text textStyle={styles.name}>Hello {this.props.name}</Text>
      })
    '''
  ,
    code: '''
      Hello = React.createClass({
        render: ->
          return <Text textStyle={styles.name}>Hello {this.props.name}</Text>
      })
      styles = StyleSheet.create({
        name: {}
      })
    '''
  ,
    code: '''
      styles = StyleSheet.create({
        name: {}
      })
      Hello = React.createClass({
        render: ->
          return <Text style={styles.name}>Hello {this.props.name}</Text>
      })
    '''
  ,
    code: '''
      styles = StyleSheet.create({
        name: {},
        welcome: {}
      })
      Hello = React.createClass({
        render: ->
          return <Text style={styles.name}>Hello {this.props.name}</Text>
      })
      Welcome = React.createClass({
        render: ->
          return <Text style={styles.welcome}>Welcome</Text>
      })
    '''
  ,
    code: '''
      styles = StyleSheet.create({
        text: {}
      })
      Hello = React.createClass({
        propTypes: {
          textStyle: Text.propTypes.style,
        },
        render: ->
          <Text style={[styles.text, textStyle]}>Hello {this.props.name}</Text>
      })
    '''
  ,
    code: '''
      styles = StyleSheet.create({
        text: {}
      })
      styles2 = StyleSheet.create({
        text: {}
      })
      Hello = React.createClass({
        propTypes: {
          textStyle: Text.propTypes.style,
        },
        render: ->
          return (
            <Text style={[styles.text, styles2.text, textStyle]}>
             Hello {this.props.name}
            </Text>
           )
      })
    '''
  ,
    code: '''
      styles = StyleSheet.create({
        text: {}
      })
      Hello = React.createClass({
        getInitialState: ->
          return { condition: true, condition2: true } 
        render: ->
          return (
            <Text
              style={[
                this.state.condition &&
                this.state.condition2 &&
                styles.text]}>
              Hello {this.props.name}
            </Text>
          )
      })
    '''
  ,
    code: '''
      styles = StyleSheet.create({
        text: {},
        text2: {},
      })
      Hello = React.createClass({
        getInitialState: ->
          return { condition: true } 
        render: ->
          return (
            <Text style={[if this.state.condition then styles.text else styles.text2]}>
              Hello {this.props.name}
            </Text>
          )
      })
    '''
  ,
    code: '''
      styles = StyleSheet.create({
          style1: {
              color: 'red',
          },
          style2: {
              color: 'blue',
          }
      })
      export default class MyComponent extends Component
          @propTypes = {
              isDanger: PropTypes.bool
          }
          render: ->
              return <View style={if @props.isDanger then styles.style1 else styles.style2} />
    '''
  ,
    code: '''
      styles = StyleSheet.create({
        text: {}
      })
    '''
  ,
    code: '''
      Hello = React.createClass({
        getInitialState: ->
          return { condition: true } 
        render: ->
          myStyle = if this.state.condition then styles.text else styles.text2
          return (
              <Text style={myStyle}>
                  Hello {this.props.name}
              </Text>
          )
      })
      styles = StyleSheet.create({
        text: {},
        text2: {},
      })
    '''
  ,
    code: '''
      additionalStyles = {}
      styles = StyleSheet.create({
        name: {},
        ...additionalStyles
      })
      Hello = React.createClass({
        render: ->
          return <Text textStyle={styles.name}>Hello {this.props.name}</Text>
      })
    '''
  ]

  invalid: [
    code: '''
      styles = StyleSheet.create({
        text: {}
      })
      Hello = React.createClass({
        render: ->
          return <Text style={styles.b}>Hello {this.props.name}</Text>
      })
    '''
    errors: [message: 'Unused style detected: styles.text']
  ,
    code: '''
      styles = StyleSheet.create({
        foo: {},
        bar: {},
      })
      class Foo extends React.Component
        render: ->
          return <View style={styles.foo}/>
    '''
    errors: [message: 'Unused style detected: styles.bar']
  ,
    code: '''
      styles = StyleSheet.create({
        foo: {},
        bar: {},
      })
      class Foo extends React.PureComponent
        render: ->
          return <View style={styles.foo}/>
    '''
    errors: [message: 'Unused style detected: styles.bar']
  ]

ruleTester.run 'no-unused-styles', rule, tests
