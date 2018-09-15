###*
# @fileoverview Enforces consistent naming for boolean props
# @author Ev Haus
###
'use strict'

{has} = require 'lodash'
Components = require '../util/react/Components'
# Components = require 'eslint-plugin-react/lib/util/Components'
propsUtil = require 'eslint-plugin-react/lib/util/props'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      category: 'Stylistic Issues'
      description: 'Enforces consistent naming for boolean props'
      recommended: no
      url: docsUrl 'boolean-prop-naming'

    schema: [
      additionalProperties: no
      properties:
        propTypeNames:
          items:
            type: 'string'
          minItems: 1
          type: 'array'
          uniqueItems: yes
        rule:
          default: '^(is|has)[A-Z]([A-Za-z0-9]?)+'
          minLength: 1
          type: 'string'
        message:
          minLength: 1
          type: 'string'
      type: 'object'
    ]

  create: Components.detect (context, components, utils) ->
    sourceCode = context.getSourceCode()
    config = context.options[0] or {}
    rule = if config.rule then new RegExp config.rule else null
    propTypeNames = config.propTypeNames or ['bool']
    propWrapperFunctions = new Set context.settings.propWrapperFunctions or []

    # Remembers all Flowtype object definitions
    objectTypeAnnotations = new Map()

    ###*
    # Returns the prop key to ensure we handle the following cases:
    # propTypes: {
    #   full: React.PropTypes.bool,
    #   short: PropTypes.bool,
    #   direct: bool,
    #   required: PropTypes.bool.isRequired
    # }
    # @param {Object} node The node we're getting the name of
    ###
    getPropKey = (node) ->
      # Check for `ExperimentalSpreadProperty` (ESLint 3/4) and `SpreadElement` (ESLint 5)
      # so we can skip validation of those fields.
      # Otherwise it will look for `node.value.property` which doesn't exist and breaks ESLint.
      return null if (
        node.type in ['ExperimentalSpreadProperty', 'SpreadElement']
      )
      if node.value.property
        {name} = node.value.property
        if name is 'isRequired'
          return node.value.object.property.name if node.value.object?.property
          return null
        return name
      return node.value.name if node.value.type is 'Identifier'
      null

    ###*
    # Returns the name of the given node (prop)
    # @param {Object} node The node we're getting the name of
    ###
    getPropName = (node) ->
      # Due to this bug https://github.com/babel/babel-eslint/issues/307
      # we can't get the name of the Flow object key name. So we have
      # to hack around it for now.
      return sourceCode.getFirstToken(node).value if (
        node.type is 'ObjectTypeProperty'
      )

      node.key.name

    ###*
    # Checks and mark props with invalid naming
    # @param {Object} node The component node we're testing
    # @param {Array} proptypes A list of Property object (for each proptype defined)
    ###
    validatePropNaming = (node, proptypes) ->
      component = components.get(node) or node
      invalidProps = component.invalidProps or []

      (proptypes or []).forEach (prop) ->
        propKey = getPropKey prop
        flowCheck =
          prop.type is 'ObjectTypeProperty' and
          prop.value.type is 'BooleanTypeAnnotation' and
          rule.test(getPropName prop) is no
        regularCheck =
          propKey and
          propTypeNames.indexOf(propKey) >= 0 and
          rule.test(getPropName prop) is no

        if flowCheck or regularCheck then invalidProps.push prop

      components.set node, {invalidProps}

    ###*
    # Reports invalid prop naming
    # @param {Object} component The component to process
    ###
    reportInvalidNaming = (component) ->
      component.invalidProps.forEach (propNode) ->
        propName = getPropName propNode
        context.report
          node: propNode
          message:
            config.message or
            "Prop name ({{ propName }}) doesn't match rule ({{ pattern }})"
          data: {
            component: propName
            propName
            pattern: config.rule
          }

    checkPropWrapperArguments = (node, args) ->
      return if not node or not Array.isArray args
      args
      .filter (arg) -> arg.type is 'ObjectExpression'
      .forEach (object) -> validatePropNaming node, object.properties

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    ClassProperty: (node) ->
      return if not rule or not propsUtil.isPropTypesDeclaration node
      if (
        node.value and
        node.value.type is 'CallExpression' and
        propWrapperFunctions.has sourceCode.getText node.value.callee
      )
        checkPropWrapperArguments node, node.value.arguments
      if node.value?.properties
        validatePropNaming node, node.value.properties
      if node.typeAnnotation?.typeAnnotation
        validatePropNaming node, node.typeAnnotation.typeAnnotation.properties

    MemberExpression: (node) ->
      return if not rule or not propsUtil.isPropTypesDeclaration node
      component = utils.getRelatedComponent node
      return if not component or not node.parent.right
      {right} = node.parent
      if (
        right.type is 'CallExpression' and
        propWrapperFunctions.has sourceCode.getText right.callee
      )
        checkPropWrapperArguments component.node, right.arguments
        return
      validatePropNaming component.node, node.parent.right.properties

    ObjectExpression: (node) ->
      return unless rule

      # Search for the proptypes declaration
      node.properties.forEach (property) ->
        return unless propsUtil.isPropTypesDeclaration property
        validatePropNaming node, property.value.properties

    TypeAlias: (node) ->
      # Cache all ObjectType annotations, we will check them at the end
      if node.right.type is 'ObjectTypeAnnotation'
        objectTypeAnnotations.set node.id.name, node.right

    'Program:exit': ->
      return unless rule

      list = components.list()
      Object.keys(list).forEach (component) ->
        # If this is a functional component that uses a global type, check it
        if (
          list[component].node.type is 'FunctionDeclaration' and
          list[component].node.params and
          list[component].node.params.length and
          list[component].node.params[0].typeAnnotation
        )
          typeNode = list[component].node.params[0].typeAnnotation
          annotation = typeNode.typeAnnotation

          if annotation.type is 'GenericTypeAnnotation'
            propType = objectTypeAnnotations.get annotation.id.name
          else if annotation.type is 'ObjectTypeAnnotation'
            propType = annotation
          if propType
            validatePropNaming list[component].node, propType.properties

        if not has(list, component) or list[component].invalidProps or [].length
          reportInvalidNaming list[component]

      # Reset cache
      objectTypeAnnotations.clear()
