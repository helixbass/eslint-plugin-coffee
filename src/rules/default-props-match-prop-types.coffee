###*
# @fileOverview Enforce all defaultProps are defined in propTypes
# @author Vitor Balocco
# @author Roy Sutton
###
'use strict'

Components = require '../util/react/Components'
variableUtil = require '../util/react/variable'
annotations = require 'eslint-plugin-react/lib/util/annotations'
astUtil = require '../util/react/ast'
propsUtil = require 'eslint-plugin-react/lib/util/props'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'Enforce all defaultProps are defined and not "required" in propTypes.'
      category: 'Best Practices'
      url: docsUrl 'default-props-match-prop-types'

    schema: [
      type: 'object'
      properties:
        allowRequiredDefaults:
          default: no
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context, components, utils) ->
    configuration = context.options[0] or {}
    allowRequiredDefaults = configuration.allowRequiredDefaults or no
    propWrapperFunctions = new Set context.settings.propWrapperFunctions or []
    # Used to track the type annotations in scope.
    # Necessary because babel's scopes do not track type annotations.
    stack = null

    ###*
    # Try to resolve the node passed in to a variable in the current scope. If the node passed in is not
    # an Identifier, then the node is simply returned.
    # @param   {ASTNode} node The node to resolve.
    # @returns {ASTNode|null} Return null if the value could not be resolved, ASTNode otherwise.
    ###
    resolveNodeValue = (node) ->
      return variableUtil.findVariableByName context, node.name if (
        node.type is 'Identifier'
      )
      return resolveNodeValue node.arguments[0] if (
        node.type is 'CallExpression' and
        propWrapperFunctions.has(node.callee.name) and
        node.arguments and
        node.arguments[0]
      )
      node

    ###*
    # Helper for accessing the current scope in the stack.
    # @param {string} key The name of the identifier to access. If omitted, returns the full scope.
    # @param {ASTNode} value If provided sets the new value for the identifier.
    # @returns {Object|ASTNode} Either the whole scope or the ASTNode associated with the given identifier.
    ###
    typeScope = (key, value) ->
      if arguments.length is 0
        return stack[stack.length - 1]
      else
        return stack[stack.length - 1][key] if arguments.length is 1
      stack[stack.length - 1][key] = value
      value

    ###*
    # Tries to find the definition of a GenericTypeAnnotation in the current scope.
    # @param  {ASTNode}      node The node GenericTypeAnnotation node to resolve.
    # @return {ASTNode|null}      Return null if definition cannot be found, ASTNode otherwise.
    ###
    resolveGenericTypeAnnotation = (node) ->
      return null if (
        node.type isnt 'GenericTypeAnnotation' or node.id.type isnt 'Identifier'
      )

      variableUtil.findVariableByName(context, node.id.name) or
        typeScope node.id.name

    resolveUnionTypeAnnotation = (node) ->
      # Go through all the union and resolve any generic types.
      node.types.map (annotation) ->
        return resolveGenericTypeAnnotation annotation if (
          annotation.type is 'GenericTypeAnnotation'
        )

        annotation

    ###*
    # Extracts a PropType from an ObjectExpression node.
    # @param   {ASTNode} objectExpression ObjectExpression node.
    # @returns {Object[]}        Array of PropType object representations, to be consumed by `addPropTypesToComponent`.
    ###
    getPropTypesFromObjectExpression = (objectExpression) ->
      props = objectExpression.properties.filter (property) ->
        property.type isnt 'ExperimentalSpreadProperty' and
        property.type isnt 'SpreadElement'

      props.map (property) ->
        name: property.key.name
        isRequired: propsUtil.isRequiredPropType property.value
        node: property

    ###*
    # Handles Props defined in IntersectionTypeAnnotation nodes
    # e.g. type Props = PropsA & PropsB
    # @param   {ASTNode} intersectionTypeAnnotation ObjectExpression node.
    # @returns {Object[]}
    ###
    getPropertiesFromIntersectionTypeAnnotationNode = (annotation) ->
      annotation.types.reduce(
        (properties, type) ->
          annotation ###:### = resolveGenericTypeAnnotation type

          if annotation?.id
            annotation ###:### = variableUtil.findVariableByName(
              context
              annotation.id.name
            )

          return properties if not annotation or not annotation.properties

          properties.concat annotation.properties
        []
      )

    ###*
    # Extracts a PropType from a TypeAnnotation node.
    # @param   {ASTNode} node TypeAnnotation node.
    # @returns {Object[]}     Array of PropType object representations, to be consumed by `addPropTypesToComponent`.
    ###
    getPropTypesFromTypeAnnotation = (node) ->
      properties = []

      switch node.typeAnnotation.type
        when 'GenericTypeAnnotation'
          annotation = resolveGenericTypeAnnotation node.typeAnnotation

          if annotation and annotation.type is 'IntersectionTypeAnnotation'
            properties = getPropertiesFromIntersectionTypeAnnotationNode(
              annotation
            )
          else
            if annotation?.id
              annotation = variableUtil.findVariableByName(
                context
                annotation.id.name
              )

            properties = if annotation then annotation.properties or [] else []

        when 'UnionTypeAnnotation'
          union = resolveUnionTypeAnnotation node.typeAnnotation
          properties = union.reduce(
            (acc, curr) ->
              return acc unless curr

              acc.concat curr.properties
            []
          )

        when 'ObjectTypeAnnotation'
          {properties} = node.typeAnnotation

        else
          properties = []

      props = properties.filter (property) ->
        property.type is 'ObjectTypeProperty'

      props.map (property) ->
        # the `key` property is not present in ObjectTypeProperty nodes, so we need to get the key name manually.
        tokens = context.getFirstTokens property, 1
        name = tokens[0].value

        {
          name
          isRequired: not property.optional
          node: property
        }

    ###*
    # Extracts a DefaultProp from an ObjectExpression node.
    # @param   {ASTNode} objectExpression ObjectExpression node.
    # @returns {Object|string}            Object representation of a defaultProp, to be consumed by
    #                                     `addDefaultPropsToComponent`, or string "unresolved", if the defaultProps
    #                                     from this ObjectExpression can't be resolved.
    ###
    getDefaultPropsFromObjectExpression = (objectExpression) ->
      hasSpread = objectExpression.properties.find (property) ->
        property.type in ['ExperimentalSpreadProperty', 'SpreadElement']

      return 'unresolved' if hasSpread

      objectExpression.properties.map (defaultProp) ->
        name: defaultProp.key.name
        node: defaultProp

    ###*
    # Marks a component's DefaultProps declaration as "unresolved". A component's DefaultProps is
    # marked as "unresolved" if we cannot safely infer the values of its defaultProps declarations
    # without risking false negatives.
    # @param   {Object} component The component to mark.
    # @returns {void}
    ###
    markDefaultPropsAsUnresolved = (component) ->
      components.set component.node, defaultProps: 'unresolved'

    ###*
    # Adds propTypes to the component passed in.
    # @param   {ASTNode}  component The component to add the propTypes to.
    # @param   {Object[]} propTypes propTypes to add to the component.
    # @returns {void}
    ###
    addPropTypesToComponent = (component, propTypes) ->
      props = component.propTypes or []

      components.set component.node, propTypes: props.concat propTypes

    ###*
    # Adds defaultProps to the component passed in.
    # @param   {ASTNode}         component    The component to add the defaultProps to.
    # @param   {String[]|String} defaultProps defaultProps to add to the component or the string "unresolved"
    #                                         if this component has defaultProps that can't be resolved.
    # @returns {void}
    ###
    addDefaultPropsToComponent = (component, defaultProps) ->
      # Early return if this component's defaultProps is already marked as "unresolved".
      return if component.defaultProps is 'unresolved'

      if defaultProps is 'unresolved'
        markDefaultPropsAsUnresolved component
        return

      defaults = component.defaultProps or []

      components.set component.node, defaultProps: defaults.concat defaultProps

    ###*
    # Tries to find a props type annotation in a stateless component.
    # @param  {ASTNode} node The AST node to look for a props type annotation.
    # @return {void}
    ###
    handleStatelessComponent = (node) ->
      return if (
        not node.params or
        not node.params.length or
        not annotations.isAnnotatedFunctionPropsDeclaration node, context
      )

      # find component this props annotation belongs to
      component = components.get utils.getParentStatelessComponent()
      return unless component

      addPropTypesToComponent(
        component
        getPropTypesFromTypeAnnotation node.params[0].typeAnnotation, context
      )

    handlePropTypeAnnotationClassProperty = (node) ->
      # find component this props annotation belongs to
      component = components.get utils.getParentES6Component()
      return unless component
      addPropTypesToComponent(
        component
        getPropTypesFromTypeAnnotation node.typeAnnotation, context
      )

    isPropTypeAnnotation = (node) ->
      astUtil.getPropertyName(node) is 'props' and !!node.typeAnnotation

    propFromName = (propTypes, name) ->
      propTypes.find (prop) -> prop.name is name

    ###*
    # Reports all defaultProps passed in that don't have an appropriate propTypes counterpart.
    # @param  {Object[]} propTypes    Array of propTypes to check.
    # @param  {Object}   defaultProps Object of defaultProps to check. Keys are the props names.
    # @return {void}
    ###
    reportInvalidDefaultProps = (propTypes, defaultProps) ->
      # If this defaultProps is "unresolved" or the propTypes is undefined, then we should ignore
      # this component and not report any errors for it, to avoid false-positives with e.g.
      # external defaultProps/propTypes declarations or spread operators.
      return if defaultProps is 'unresolved' or not propTypes

      defaultProps.forEach (defaultProp) ->
        prop = propFromName propTypes, defaultProp.name

        return if prop and (allowRequiredDefaults or not prop.isRequired)

        if prop
          context.report(
            defaultProp.node
            'defaultProp "{{name}}" defined for isRequired propType.'
            name: defaultProp.name
          )
        else
          context.report(
            defaultProp.node
            'defaultProp "{{name}}" has no corresponding propTypes declaration.'
            name: defaultProp.name
          )

    # --------------------------------------------------------------------------
    # Public API
    # --------------------------------------------------------------------------

    MemberExpression: (node) ->
      isPropType = propsUtil.isPropTypesDeclaration node
      isDefaultProp = propsUtil.isDefaultPropsDeclaration node

      return if not isPropType and not isDefaultProp

      # find component this propTypes/defaultProps belongs to
      component = utils.getRelatedComponent node
      return unless component

      # e.g.:
      # MyComponent.propTypes = {
      #   foo: React.PropTypes.string.isRequired,
      #   bar: React.PropTypes.string
      # };
      #
      # or:
      #
      # MyComponent.propTypes = myPropTypes;
      if node.parent.type is 'AssignmentExpression'
        expression = resolveNodeValue node.parent.right
        if not expression or expression.type isnt 'ObjectExpression'
          # If a value can't be found, we mark the defaultProps declaration as "unresolved", because
          # we should ignore this component and not report any errors for it, to avoid false-positives
          # with e.g. external defaultProps declarations.
          if isDefaultProp then markDefaultPropsAsUnresolved component

          return

        if isPropType
          addPropTypesToComponent(
            component
            getPropTypesFromObjectExpression expression
          )
        else
          addDefaultPropsToComponent(
            component
            getDefaultPropsFromObjectExpression expression
          )

        return

      # e.g.:
      # MyComponent.propTypes.baz = React.PropTypes.string;
      if (
        node.parent.type is 'MemberExpression' and
        node.parent.parent and
        node.parent.parent.type is 'AssignmentExpression'
      )
        if isPropType
          addPropTypesToComponent component, [
            name: node.parent.property.name
            isRequired: propsUtil.isRequiredPropType node.parent.parent.right
            node: node.parent.parent
          ]
        else
          addDefaultPropsToComponent component, [
            name: node.parent.property.name
            node: node.parent.parent
          ]

    # e.g.:
    # class Hello extends React.Component {
    #   static get propTypes() {
    #     return {
    #       name: React.PropTypes.string
    #     };
    #   }
    #   static get defaultProps() {
    #     return {
    #       name: 'Dean'
    #     };
    #   }
    #   render() {
    #     return <div>Hello {this.props.name}</div>;
    #   }
    # }
    MethodDefinition: (node) ->
      return if not node.static or node.kind isnt 'get'

      isPropType = propsUtil.isPropTypesDeclaration node
      isDefaultProp = propsUtil.isDefaultPropsDeclaration node

      return if not isPropType and not isDefaultProp

      # find component this propTypes/defaultProps belongs to
      component = components.get utils.getParentES6Component()
      return unless component

      {expression: returnValue} = utils.findReturnStatement node
      return unless returnValue

      expression = resolveNodeValue returnValue
      return unless expression?.type is 'ObjectExpression'

      if isPropType
        addPropTypesToComponent(
          component
          getPropTypesFromObjectExpression expression
        )
      else
        addDefaultPropsToComponent(
          component
          getDefaultPropsFromObjectExpression expression
        )

    # e.g.:
    # class Greeting extends React.Component {
    #   render() {
    #     return (
    #       <h1>Hello, {this.props.foo} {this.props.bar}</h1>
    #     );
    #   }
    #   static propTypes = {
    #     foo: React.PropTypes.string,
    #     bar: React.PropTypes.string.isRequired
    #   };
    # }
    ClassProperty: (node) ->
      if isPropTypeAnnotation node
        handlePropTypeAnnotationClassProperty node
        return

      return unless node.static

      return unless node.value

      propName = astUtil.getPropertyName node
      isPropType = propName is 'propTypes'
      isDefaultProp = propName in ['defaultProps', 'getDefaultProps']

      return if not isPropType and not isDefaultProp

      # find component this propTypes/defaultProps belongs to
      component = components.get utils.getParentES6Component()
      return unless component

      expression = resolveNodeValue node.value
      return if not expression or expression.type isnt 'ObjectExpression'

      if isPropType
        addPropTypesToComponent(
          component
          getPropTypesFromObjectExpression expression
        )
      else
        addDefaultPropsToComponent(
          component
          getDefaultPropsFromObjectExpression expression
        )

    # e.g.:
    # React.createClass({
    #   render: function() {
    #     return <div>{this.props.foo}</div>;
    #   },
    #   propTypes: {
    #     foo: React.PropTypes.string.isRequired,
    #   },
    #   getDefaultProps: function() {
    #     return {
    #       foo: 'default'
    #     };
    #   }
    # });
    ObjectExpression: (node) ->
      # find component this propTypes/defaultProps belongs to
      component = utils.isES5Component(node) and components.get node
      return unless component

      # Search for the proptypes declaration
      node.properties.forEach (property) ->
        return if property.type in [
          'ExperimentalSpreadProperty'
          'SpreadElement'
        ]

        isPropType = propsUtil.isPropTypesDeclaration property
        isDefaultProp = propsUtil.isDefaultPropsDeclaration property

        return if not isPropType and not isDefaultProp

        if isPropType and property.value.type is 'ObjectExpression'
          addPropTypesToComponent(
            component
            getPropTypesFromObjectExpression property.value
          )
          return

        if isDefaultProp and property.value.type is 'FunctionExpression'
          {expression: returnValue} = utils.findReturnStatement property
          return unless returnValue?.type is 'ObjectExpression'

          addDefaultPropsToComponent(
            component
            getDefaultPropsFromObjectExpression returnValue
          )

    TypeAlias: (node) -> typeScope node.id.name, node.right

    Program: -> stack = [{}]

    BlockStatement: -> stack.push Object.create typeScope()

    'BlockStatement:exit': -> stack.pop()

    # Check for type annotations in stateless components
    FunctionDeclaration: handleStatelessComponent
    ArrowFunctionExpression: handleStatelessComponent
    FunctionExpression: handleStatelessComponent

    'Program:exit': ->
      stack ###:### = null
      list = components.list()

      for own _, component of list
        # If no defaultProps could be found, we don't report anything.
        return unless component.defaultProps

        reportInvalidDefaultProps(
          component.propTypes
          component.defaultProps or {}
        )
