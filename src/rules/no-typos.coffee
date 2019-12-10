###*
# @fileoverview Prevent common casing typos
###
'use strict'

Components = require '../util/react/Components'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

STATIC_CLASS_PROPERTIES = [
  'propTypes'
  'contextTypes'
  'childContextTypes'
  'defaultProps'
]
LIFECYCLE_METHODS = [
  'getDerivedStateFromProps'
  'componentWillMount'
  'UNSAFE_componentWillMount'
  'componentDidMount'
  'componentWillReceiveProps'
  'UNSAFE_componentWillReceiveProps'
  'shouldComponentUpdate'
  'componentWillUpdate'
  'UNSAFE_componentWillUpdate'
  'getSnapshotBeforeUpdate'
  'componentDidUpdate'
  'componentDidCatch'
  'componentWillUnmount'
  'render'
]

PROP_TYPES = Object.keys require 'prop-types'

module.exports =
  meta:
    docs:
      description: 'Prevent common typos'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'no-typos'
    schema: []

  create: Components.detect (context, components, utils) ->
    propTypesPackageName = null
    reactPackageName = null

    checkValidPropTypeQualifier = (node) ->
      unless node.name is 'isRequired'
        context.report {
          node
          message: "Typo in prop type chain qualifier: #{node.name}"
        }

    checkValidPropType = (node) ->
      if (
        node.name and
        not PROP_TYPES.some((propTypeName) -> propTypeName is node.name)
      )
        context.report {
          node
          message: "Typo in declared prop type: #{node.name}"
        }

    isPropTypesPackage = (node) ->
      (node.type is 'Identifier' and node.name is propTypesPackageName) or
      (node.type is 'MemberExpression' and
        node.property.name is 'PropTypes' and
        node.object.name is reactPackageName)

    ### eslint-disable coffee/no-use-before-define ###

    checkValidCallExpression = (node) ->
      {callee} = node
      if callee.type is 'MemberExpression' and callee.property.name is 'shape'
        checkValidPropObject node.arguments[0]
      else if (
        callee.type is 'MemberExpression' and
        callee.property.name is 'oneOfType'
      )
        args = node.arguments[0]
        if args and args.type is 'ArrayExpression'
          args.elements.forEach (el) -> checkValidProp el

    checkValidProp = (node) ->
      return if (not propTypesPackageName and not reactPackageName) or not node

      if node.type is 'MemberExpression'
        if (
          node.object.type is 'MemberExpression' and
          isPropTypesPackage node.object.object
        )
          # PropTypes.myProp.isRequired
          checkValidPropType node.object.property
          checkValidPropTypeQualifier node.property
        else if (
          isPropTypesPackage(node.object) and
          node.property.name isnt 'isRequired'
        )
          # PropTypes.myProp
          checkValidPropType node.property
        else if node.object.type is 'CallExpression'
          checkValidPropTypeQualifier node.property
          checkValidCallExpression node.object
      else if node.type is 'CallExpression'
        checkValidCallExpression node

    ### eslint-enable no-use-before-define ###

    checkValidPropObject = (node) ->
      if node and node.type is 'ObjectExpression'
        node.properties.forEach (prop) -> checkValidProp prop.value

    reportErrorIfClassPropertyCasingTypo = (node, propertyName) ->
      if propertyName in ['propTypes', 'contextTypes', 'childContextTypes']
        checkValidPropObject node
      STATIC_CLASS_PROPERTIES.forEach (CLASS_PROP) ->
        if (
          propertyName and
          CLASS_PROP.toLowerCase() is propertyName.toLowerCase() and
          CLASS_PROP isnt propertyName
        )
          context.report {
            node
            message: 'Typo in static class property declaration'
          }

    reportErrorIfLifecycleMethodCasingTypo = (node) ->
      LIFECYCLE_METHODS.forEach (method) ->
        if (
          method.toLowerCase() is node.key.name.toLowerCase() and
          method isnt node.key.name
        )
          context.report {
            node
            message: 'Typo in component lifecycle method declaration'
          }

    ImportDeclaration: (node) ->
      if node.source and node.source.value is 'prop-types'
        # import PropType from "prop-types"
        propTypesPackageName = node.specifiers[0].local.name
      else if node.source and node.source.value is 'react'
        # import { PropTypes } from "react"
        if node.specifiers.length > 0
          reactPackageName = node.specifiers[0].local.name # guard against accidental anonymous `import "react"`
        if node.specifiers.length >= 1
          propTypesSpecifier = node.specifiers.find (specifier) ->
            specifier.imported and specifier.imported.name is 'PropTypes'
          if propTypesSpecifier
            propTypesPackageName ###:### = propTypesSpecifier.local.name

    ClassProperty: (node) ->
      return if not node.static or not utils.isES6Component node.parent.parent

      tokens = context.getFirstTokens node, 2
      propertyName = tokens[1].value
      reportErrorIfClassPropertyCasingTypo node.value, propertyName

    MemberExpression: (node) ->
      propertyName = node.property.name

      return if (
        not propertyName or
        STATIC_CLASS_PROPERTIES.map((prop) ->
          prop.toLocaleLowerCase()
        ).indexOf(propertyName.toLowerCase()) is -1
      )

      relatedComponent = utils.getRelatedComponent node

      if (
        relatedComponent and
        (utils.isES6Component(relatedComponent.node) or
          utils.isReturningJSX(relatedComponent.node)) and
        (node.parent and
          node.parent.type is 'AssignmentExpression' and
          node.parent.right)
      )
        reportErrorIfClassPropertyCasingTypo node.parent.right, propertyName

    MethodDefinition: (node) ->
      return unless utils.isES6Component node.parent.parent

      reportErrorIfLifecycleMethodCasingTypo node
