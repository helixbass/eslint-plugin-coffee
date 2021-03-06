###*
# @fileoverview No inline styles defined in javascript files
# @author Aaron Greenwald
###

'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require 'eslint-plugin-react-native/lib/rules/no-inline-styles'
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
                <View style={if this.props.isDanger then styles.style1 else styles.style2} />
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
            render: ->
                trueColor = '#fff'
                falseColor = '#000' 
                return <View 
                   style={[
                     style1, 
                     this.state.isDanger && styles.style1, 
                     {color: if someBoolean then trueColor else falseColor }]} 
                   />
      '''
  ,
    code: '''
        Hello = React.createClass({
          render: ->
            exampleVar = 10
            return <Text style={marginLeft: -exampleVar, height: +examplevar}>
              Hello {this.props.name}
             </Text>
        })
      '''
  ]
  invalid: [
    code: '''
        Hello = React.createClass({
          render: ->
            return <Text style={{backgroundColor: '#FFFFFF', opacity: 0.5}}>
              Hello {this.props.name}
             </Text>
        })
      '''
    errors: [
      message: "Inline style: { backgroundColor: '#FFFFFF', opacity: 0.5 }"
    ]
  ,
    code: '''
        Hello = React.createClass({
          render: ->
            return <Text style={{backgroundColor: '#FFFFFF', opacity: this.state.opacity}}>
              Hello {this.props.name}
             </Text>
        })
      '''
    errors: [message: "Inline style: { backgroundColor: '#FFFFFF' }"]
  ,
    code: '''
        Hello = React.createClass({
          render: ->
            return <Text style={{opacity: this.state.opacity, height: 12}}>
              Hello {this.props.name}
             </Text>
        })
      '''
    errors: [message: 'Inline style: { height: 12 }']
  ,
    code: '''
        Hello = React.createClass({
          render: ->
            return <Text style={{marginLeft: -7, height: +12}}>
              Hello {this.props.name}
             </Text>
        })
      '''
    errors: [message: 'Inline style: { marginLeft: -7, height: 12 }']
  ,
    code: '''
        Hello = React.createClass({
          render: ->
            return <Text style={[styles.text, {backgroundColor: '#FFFFFF'}]}>
              Hello {this.props.name}
             </Text>
        })
      '''
    errors: [message: "Inline style: { backgroundColor: '#FFFFFF' }"]
  ,
    code: '''
        Hello = React.createClass({
          render: ->
            someBoolean = false 
            return <Text style={[styles.text, someBoolean && {backgroundColor: '#FFFFFF'}]}>
              Hello {this.props.name}
             </Text>
        })
      '''
    errors: [message: "Inline style: { backgroundColor: '#FFFFFF' }"]
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
            render: ->
                return (
                  <View 
                    style={[
                      style1, 
                      this.state.isDanger and styles.style1, 
                      {backgroundColor: if someBoolean then '#fff' else '#000'}
                    ]} />
                )
      '''
    errors: [
      message: '''Inline style: { backgroundColor: "if someBoolean then '#fff' else '#000'" }''' #eslint-disable-line
    ]
  ]

ruleTester.run 'no-inline-styles', rule, tests
