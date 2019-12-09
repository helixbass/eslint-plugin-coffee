###*
# @fileoverview Prevent definitions of unused prop types
# @author Evgueni Naverniouk
###
'use strict'

# As for exceptions for props.children or props.className (and alike) look at
# https://github.com/yannickcr/eslint-plugin-react/issues/7

Components = require '../util/react/Components'
astUtil = require '../util/react/ast'
versionUtil = require 'eslint-plugin-react/lib/util/version'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

DIRECT_PROPS_REGEX = /^props\s*(\.|\[)/
DIRECT_NEXT_PROPS_REGEX = /^nextProps\s*(\.|\[)/
DIRECT_PREV_PROPS_REGEX = /^prevProps\s*(\.|\[)/
LIFE_CYCLE_METHODS = [
  'componentWillReceiveProps'
  'shouldComponentUpdate'
  'componentWillUpdate'
  'componentDidUpdate'
]
ASYNC_SAFE_LIFE_CYCLE_METHODS = [
  'getDerivedStateFromProps'
  'getSnapshotBeforeUpdate'
  'UNSAFE_componentWillReceiveProps'
  'UNSAFE_componentWillUpdate'
]

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Prevent definitions of unused prop types'
      category: 'Best Practices'
      recommended: no
      url: docsUrl 'no-unused-prop-types'

    schema: [
      type: 'object'
      properties:
        customValidators:
          type: 'array'
          items:
            type: 'string'
        skipShapeProps:
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context, components, utils) ->
    sourceCode = context.getSourceCode()
    checkAsyncSafeLifeCycles = versionUtil.testReactVersion context, '16.3.0'
    defaults = skipShapeProps: yes, customValidators: []
    configuration = {...defaults, ...(context.options[0] or {})}
    UNUSED_MESSAGE = "'{{name}}' PropType is defined but prop is never used" #

    ###*
    # Check if we are in a lifecycle method
    # @return {boolean} true if we are in a class constructor, false if not
    ###
    inLifeCycleMethod = ->
      scope = context.getScope()
      while scope
        if scope.block?.parent?.key
          {name} = scope.block.parent.key

          return yes if LIFE_CYCLE_METHODS.indexOf(name) >= 0
          return yes if (
            checkAsyncSafeLifeCycles and
            ASYNC_SAFE_LIFE_CYCLE_METHODS.indexOf(name) >= 0
          )
        scope = scope.upper
      no

    ###*
    # Check if the current node is in a setState updater method
    # @return {boolean} true if we are in a setState updater, false if not
    ###
    inSetStateUpdater = ->
      scope = context.getScope()
      while scope
        return yes if (
          scope.block?.parent?.type is 'CallExpression' and
          scope.block.parent.callee.property?.name is 'setState' and
          # Make sure we are in the updater not the callback
          scope.block.parent.arguments[0].start is scope.block.start
        )
        scope = scope.upper
      no

    isPropArgumentInSetStateUpdater = (node) ->
      scope = context.getScope()
      while scope
        return (
          scope.block.parent.arguments[0].params[1].name is node.object.name
        ) if (
          scope.block?.parent and
          scope.block.parent.type is 'CallExpression' and
          scope.block.parent.callee.property and
          scope.block.parent.callee.property.name is 'setState' and
          # Make sure we are in the updater not the callback
          scope.block.parent.arguments[0].start is scope.block.start and
          scope.block.parent.arguments[0].params and
          scope.block.parent.arguments[0].params.length > 1
        )
        scope = scope.upper
      no

    ###*
    # Checks if we are using a prop
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if we are using a prop, false if not.
    ###
    isPropTypesUsage = (node) ->
      isClassUsage =
        (utils.getParentES6Component() or utils.getParentES5Component()) and
        ((node.object.type is 'ThisExpression' and
          node.property.name is 'props') or
          isPropArgumentInSetStateUpdater node)
      isStatelessFunctionUsage = node.object.name is 'props'
      isClassUsage or isStatelessFunctionUsage or inLifeCycleMethod()

    ###*
    # Checks if the component must be validated
    # @param {Object} component The component to process
    # @returns {Boolean} True if the component must be validated, false if not.
    ###
    mustBeValidated = (component) ->
      Boolean component and not component.ignoreUnusedPropTypesValidation

    ###*
    # Returns true if the given node is a React Component lifecycle method
    # @param {ASTNode} node The AST node being checked.
    # @return {Boolean} True if the node is a lifecycle method
    ###
    isNodeALifeCycleMethod = (node) ->
      nodeKeyName = node.key?.name

      return yes if node.kind is 'constructor'
      return yes if LIFE_CYCLE_METHODS.indexOf(nodeKeyName) >= 0
      return yes if (
        checkAsyncSafeLifeCycles and
        ASYNC_SAFE_LIFE_CYCLE_METHODS.indexOf(nodeKeyName) >= 0
      )

      no

    ###*
    # Returns true if the given node is inside a React Component lifecycle
    # method.
    # @param {ASTNode} node The AST node being checked.
    # @return {Boolean} True if the node is inside a lifecycle method
    ###
    isInLifeCycleMethod = (node) ->
      return yes if (
        node.type in ['MethodDefinition', 'Property'] and
        isNodeALifeCycleMethod node
      )

      return isInLifeCycleMethod node.parent if node.parent

      no

    ###*
    # Checks if a prop init name matches common naming patterns
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if the prop name matches
    ###
    isPropAttributeName = (node) ->
      (node.init ? node.right).name in ['props', 'nextProps', 'prevProps']

    ###*
    # Checks if a prop is used
    # @param {ASTNode} node The AST node being checked.
    # @param {Object} prop Declared prop object
    # @returns {Boolean} True if the prop is used, false if not.
    ###
    isPropUsed = (node, prop) ->
      usedPropTypes = node.usedPropTypes or []
      i = 0
      l = usedPropTypes.length
      while i < l
        usedProp = usedPropTypes[i]
        return yes if (
          prop.type is 'shape' or
          prop.name is '__ANY_KEY__' or
          usedProp.name is prop.name
        )
        i++

      no

    ###*
    # Checks if the prop has spread operator.
    # @param {ASTNode} node The AST node being marked.
    # @returns {Boolean} True if the prop has spread operator, false if not.
    ###
    hasSpreadOperator = (node) ->
      tokens = sourceCode.getTokens node
      tokens.length and tokens[0].value is '...'

    ###*
    # Removes quotes from around an identifier.
    # @param {string} the identifier to strip
    ###
    stripQuotes = (string) -> string.replace /^'|'$/g, ''

    ###*
    # Retrieve the name of a key node
    # @param {ASTNode} node The AST node with the key.
    # @return {string} the name of the key
    ###
    getKeyValue = (node) ->
      if node.type is 'ObjectTypeProperty'
        tokens = context.getFirstTokens node, 2
        return (
          if tokens[0].value in ['+', '-']
            tokens[1].value
          else
            stripQuotes tokens[0].value
        )
      key = node.key or node.argument
      if key.type is 'Identifier' then key.name else key.value

    ###*
    # Check if we are in a class constructor
    # @return {boolean} true if we are in a class constructor, false if not
    ###
    inConstructor = ->
      scope = context.getScope()
      while scope
        return yes if (
          scope.block?.parent and scope.block.parent.kind is 'constructor'
        )
        scope = scope.upper
      no

    ###*
    # Retrieve the name of a property node
    # @param {ASTNode} node The AST node with the property.
    # @return {string} the name of the property or undefined if not found
    ###
    getPropertyName = (node) ->
      isDirectProp = DIRECT_PROPS_REGEX.test sourceCode.getText node
      isDirectNextProp = DIRECT_NEXT_PROPS_REGEX.test sourceCode.getText node
      isDirectPrevProp = DIRECT_PREV_PROPS_REGEX.test sourceCode.getText node
      isDirectSetStateProp = isPropArgumentInSetStateUpdater node
      isInClassComponent =
        utils.getParentES6Component() or utils.getParentES5Component()
      isNotInConstructor = not inConstructor node
      isNotInLifeCycleMethod = not inLifeCycleMethod()
      isNotInSetStateUpdater = not inSetStateUpdater()
      return undefined if (
        (isDirectProp or
          isDirectNextProp or
          isDirectPrevProp or
          isDirectSetStateProp) and
        isInClassComponent and
        isNotInConstructor and
        isNotInLifeCycleMethod and
        isNotInSetStateUpdater
      )
      if (
        not isDirectProp and
        not isDirectNextProp and
        not isDirectPrevProp and
        not isDirectSetStateProp
      )
        node = node.parent
      {property} = node
      if property
        switch property.type
          when 'Identifier'
            return '__COMPUTED_PROP__' if node.computed
            return property.name
          when 'MemberExpression'
            return undefined
          when 'Literal'
            # Accept computed properties that are literal strings
            return property.value if typeof property.value is 'string'
            return '__COMPUTED_PROP__' if node.computed
          else
            return '__COMPUTED_PROP__' if node.computed
      undefined

    ###*
    # Mark a prop type as used
    # @param {ASTNode} node The AST node being marked.
    ###
    markPropTypesAsUsed = (node, parentNames) ->
      parentNames or= []
      switch node.type
        when 'MemberExpression'
          name = getPropertyName node
          if name
            allNames = parentNames.concat name
            if node.parent.type is 'MemberExpression'
              markPropTypesAsUsed node.parent, allNames
            # Do not mark computed props as used.
            type = unless name is '__COMPUTED_PROP__' then 'direct' else null
          else
            left = node.parent.id ? node.parent.left
            if left?.properties?.length and getKeyValue left.properties[0]
              type = 'destructuring'
              {properties} = left
        when 'ArrowFunctionExpression', 'FunctionDeclaration', 'FunctionExpression'
          break unless node.params.length
          type = 'destructuring'
          {properties} = node.params[0]
          {properties} = node.params[1] ? {} if inSetStateUpdater()
        when 'VariableDeclarator', 'AssignmentExpression'
          left = node.id ? node.left
          # let {props: {firstname}} = this
          # let {firstname} = props
          for property in left.properties
            thisDestructuring =
              property.key and
              ((property.key.name is 'props' or
                property.key.value is 'props') and
                property.value.type is 'ObjectPattern')
            genericDestructuring =
              isPropAttributeName(node) and
              (utils.getParentStatelessComponent() or isInLifeCycleMethod node)

            if thisDestructuring
              {properties} = property.value
            else if genericDestructuring
              {properties} = left
            else
              continue
            type = 'destructuring'
        else
          throw new Error(
            "#{node.type} ASTNodes are not handled by markPropTypesAsUsed"
          )

      component = components.get utils.getParentComponent()
      usedPropTypes = component?.usedPropTypes or []
      ignoreUnusedPropTypesValidation =
        component?.ignoreUnusedPropTypesValidation or no

      switch type
        when 'direct'
          # Ignore Object methods
          break if Object::[name]

          usedPropTypes.push {
            name
            allNames
          }
        when 'destructuring'
          for property in properties or []
            if hasSpreadOperator(property) or property.computed
              ignoreUnusedPropTypesValidation = yes
            propName = getKeyValue property

            currentNode = node
            allNames = []
            while (
              currentNode.property and currentNode.property.name isnt 'props'
            )
              allNames.unshift currentNode.property.name
              currentNode = currentNode.object
            allNames.push propName

            if propName
              usedPropTypes.push {
                allNames
                name: propName
              }

      components.set component?.node ? node, {
        usedPropTypes
        ignoreUnusedPropTypesValidation
      }

    ###*
    # Used to recursively loop through each declared prop type
    # @param {Object} component The component to process
    # @param {Array} props List of props to validate
    ###
    reportUnusedPropType = (component, props) ->
      # Skip props that check instances
      return if props is yes

      Object.keys(props or {}).forEach (key) ->
        prop = props[key]
        # Skip props that check instances
        return if prop is yes

        return if prop.type is 'shape' and configuration.skipShapeProps

        if prop.node and not isPropUsed component, prop
          context.report prop.node, UNUSED_MESSAGE, name: prop.fullName

        if prop.children then reportUnusedPropType component, prop.children

    ###*
    # Reports unused proptypes for a given component
    # @param {Object} component The component to process
    ###
    reportUnusedPropTypes = (component) ->
      reportUnusedPropType component, component.declaredPropTypes

    ###*
    # @param {ASTNode} node We expect either an ArrowFunctionExpression,
    #   FunctionDeclaration, or FunctionExpression
    ###
    markDestructuredFunctionArgumentsAsUsed = (node) ->
      destructuring = node.params?[0]?.type is 'ObjectPattern'
      if destructuring and components.get node then markPropTypesAsUsed node

    handleSetStateUpdater = (node) ->
      return unless node.params?.length >= 2 and inSetStateUpdater()
      markPropTypesAsUsed node

    ###*
    # Handle both stateless functions and setState updater functions.
    # @param {ASTNode} node We expect either an ArrowFunctionExpression,
    #   FunctionDeclaration, or FunctionExpression
    ###
    handleFunctionLikeExpressions = (node) ->
      handleSetStateUpdater node
      markDestructuredFunctionArgumentsAsUsed node

    handleCustomValidators = (component) ->
      propTypes = component.declaredPropTypes
      return unless propTypes

      Object.keys(propTypes).forEach (key) ->
        {node} = propTypes[key]

        if astUtil.isFunctionLikeExpression node then markPropTypesAsUsed node

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    VariableDeclarator: (node) ->
      destructuring = node.init and node.id and node.id.type is 'ObjectPattern'
      # let {props: {firstname}} = this
      thisDestructuring = destructuring and node.init.type is 'ThisExpression'
      # let {firstname} = props
      statelessDestructuring =
        destructuring and
        isPropAttributeName(node) and
        (utils.getParentStatelessComponent() or isInLifeCycleMethod node)

      return if not thisDestructuring and not statelessDestructuring
      markPropTypesAsUsed node

    AssignmentExpression: (node) ->
      destructuring = node.left.type is 'ObjectPattern'
      # let {props: {firstname}} = this
      thisDestructuring = destructuring and node.right.type is 'ThisExpression'
      # let {firstname} = props
      statelessDestructuring =
        destructuring and
        isPropAttributeName(node) and
        (utils.getParentStatelessComponent() or isInLifeCycleMethod node)

      return unless thisDestructuring or statelessDestructuring
      markPropTypesAsUsed node

    FunctionDeclaration: handleFunctionLikeExpressions

    ArrowFunctionExpression: handleFunctionLikeExpressions

    FunctionExpression: handleFunctionLikeExpressions

    MemberExpression: (node) ->
      markPropTypesAsUsed node if isPropTypesUsage node

    ObjectPattern: (node) ->
      # If the object pattern is a destructured props object in a lifecycle
      # method -- mark it for used props.
      if isNodeALifeCycleMethod node.parent.parent
        node.properties.forEach (property, i) ->
          if i is 0 then markPropTypesAsUsed node.parent

    'Program:exit': ->
      list = components.list()
      # Report undeclared proptypes for all classes
      for own _, component of list when mustBeValidated component
        handleCustomValidators component
        reportUnusedPropTypes component
