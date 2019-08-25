###*
# @fileoverview Android and IOS components should be
# used in platform specific React Native components.
# @author Tom Hastjarjanto
###

'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/split-platform-components'
{RuleTester} = require 'eslint'
path = require 'path'

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
tests =
  valid: [
    code: """
      React = require('react-native')
      {
        ActivityIndicatiorIOS,
      } = React
      Hello = React.createClass({
        render: ->
          return <ActivityIndicatiorIOS />
      })
    """
    filename: 'Hello.ios.js'
  ,
    code: """
      React = require('react-native')
      {
        ProgressBarAndroid,
      } = React
      Hello = React.createClass({
        render: ->
          return <ProgressBarAndroid />
      })
    """
    filename: 'Hello.android.js'
  ,
    code: """
      React = require('react-native')
      {
        View,
      } = React
      Hello = React.createClass({
        render: ->
          <View />
      })
    """
    filename: 'Hello.js'
  ,
    code: """
      import {
        ActivityIndicatiorIOS,
      } from 'react-native'
    """
    filename: 'Hello.ios.js'
  ,
    code: """
      import {
        ProgressBarAndroid,
      } from 'react-native'
    """
    filename: 'Hello.android.js'
  ,
    code: """
      import {
        View,
      } from 'react-native'
    """
    filename: 'Hello.js'
  ,
    code: """
      React = require('react-native')
      {
        ActivityIndicatiorIOS,
      } = React
      Hello = React.createClass({
        render: ->
          return <ActivityIndicatiorIOS />
      })
    """
    options: [iosPathRegex: '\\.ios(\\.test)?\\.js$']
    filename: 'Hello.ios.test.js'
  ,
    code: """
      React = require('react-native')
      {
        ProgressBarAndroid,
      } = React
      Hello = React.createClass({
        render: ->
          return <ProgressBarAndroid />
      })
    """
    options: [androidPathRegex: '\\.android(\\.test)?\\.js$']
    filename: 'Hello.android.test.js'
  ]

  invalid: [
    code: """
      React = require('react-native')
      {
        ProgressBarAndroid,
      } = React
      Hello = React.createClass({
        render: ->
          return <ProgressBarAndroid />
      })
    """
    filename: 'Hello.js'
    errors: [message: 'Android components should be placed in android files']
  ,
    code: """
      React = require('react-native')
      {
        ActivityIndicatiorIOS,
      } = React
      Hello = React.createClass({
        render: ->
          return <ActivityIndicatiorIOS />
      })
    """
    filename: 'Hello.js'
    errors: [message: 'IOS components should be placed in ios files']
  ,
    code: """
      React = require('react-native')
      {
        ActivityIndicatiorIOS,
        ProgressBarAndroid,
      } = React
      Hello = React.createClass({
        render: ->
          return <ActivityIndicatiorIOS />
      })
    """
    filename: 'Hello.js'
    errors: [
      message: "IOS and Android components can't be mixed"
    ,
      message: "IOS and Android components can't be mixed"
    ]
  ,
    code: """
      import {
        ProgressBarAndroid,
      } from 'react-native'
    """
    filename: 'Hello.js'
    errors: [message: 'Android components should be placed in android files']
  ,
    code: """
      import {
        ActivityIndicatiorIOS,
      } from 'react-native'
    """
    filename: 'Hello.js'
    errors: [message: 'IOS components should be placed in ios files']
  ,
    code: """
      import {
        ActivityIndicatiorIOS,
        ProgressBarAndroid,
      } from 'react-native'
    """
    filename: 'Hello.js'
    errors: [
      message: "IOS and Android components can't be mixed"
    ,
      message: "IOS and Android components can't be mixed"
    ]
  ]

ruleTester.run 'split-platform-components', rule, tests
