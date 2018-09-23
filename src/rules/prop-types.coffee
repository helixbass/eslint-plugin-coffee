###*
# @fileoverview Prevent missing props validation in a React component definition
# @author Yannick Croissant
###
'use strict'

# As for exceptions for props.children or props.className (and alike) look at
# https://github.com/yannickcr/eslint-plugin-react/issues/7

Components = require '../util/react/Components'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

PROPS_REGEX = /^(props|nextProps)$/
DIRECT_PROPS_REGEX = /^(props|nextProps)\s*(\.|\[)/

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'Prevent missing props validation in a React component definition'
      category: 'Best Practices'
      recommended: yes
      url: docsUrl 'prop-types'

    schema: [
      type: 'object'
      properties:
        ignore:
          type: 'array'
          items:
            type: 'string'
        customValidators:
          type: 'array'
          items:
            type: 'string'
        skipUndeclared:
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context, components, utils) ->
    sourceCode = context.getSourceCode()
    configuration = context.options[0] or {}
    ignored = configuration.ignore or []
    skipUndeclared = configuration.skipUndeclared or no

    MISSING_MESSAGE = "'{{name}}' is missing in props validation"

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
    # Check if we are in a class constructor
    # @return {boolean} true if we are in a class constructor, false if not
    ###
    inComponentWillReceiveProps = ->
      scope = context.getScope()
      while scope
        return yes if (
          scope.block?.parent and
          scope.block.parent.key and
          scope.block.parent.key.name is 'componentWillReceiveProps'
        )
        scope = scope.upper
      no

    ###*
    # Check if we are in a class constructor
    # @return {boolean} true if we are in a class constructor, false if not
    ###
    inShouldComponentUpdate = ->
      scope = context.getScope()
      while scope
        return yes if (
          scope.block?.parent and
          scope.block.parent.key and
          scope.block.parent.key.name is 'shouldComponentUpdate'
        )
        scope = scope.upper
      no

    ###*
    # Checks if a prop is being assigned a value props.bar = 'bar'
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean}
    ###

    isAssignmentToProp = (node) ->
      node.parent and
      node.parent.type is 'AssignmentExpression' and
      node.parent.left is node

    ###*
    # Checks if we are using a prop
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if we are using a prop, false if not.
    ###
    isPropTypesUsage = (node) ->
      isClassUsage =
        (utils.getParentES6Component() or utils.getParentES5Component()) and
        node.object.type is 'ThisExpression' and
        node.property.name is 'props'
      isStatelessFunctionUsage =
        node.object.name is 'props' and not isAssignmentToProp node
      isNextPropsUsage =
        node.object.name is 'nextProps' and
        (inComponentWillReceiveProps() or inShouldComponentUpdate())
      isClassUsage or isStatelessFunctionUsage or isNextPropsUsage

    ###*
    # Checks if the prop is ignored
    # @param {String} name Name of the prop to check.
    # @returns {Boolean} True if the prop is ignored, false if not.
    ###
    isIgnored = (name) -> ignored.indexOf(name) isnt -1

    ###*
    # Checks if the component must be validated
    # @param {Object} component The component to process
    # @returns {Boolean} True if the component must be validated, false if not.
    ###
    mustBeValidated = (component) ->
      isSkippedByConfig =
        skipUndeclared and typeof component.declaredPropTypes is 'undefined'
      Boolean(
        component?.usedPropTypes and
          not component.ignorePropsValidation and
          not isSkippedByConfig
      )

    ###*
    # Internal: Checks if the prop is declared
    # @param {Object} declaredPropTypes Description of propTypes declared in the current component
    # @param {String[]} keyList Dot separated name of the prop to check.
    # @returns {Boolean} True if the prop is declared, false if not.
    ###
    _isDeclaredInComponent = (declaredPropTypes, keyList) ->
      i = 0
      j = keyList.length # If not, check if this type accepts any key
      for i in [0...j]
        key = keyList[i]
        propType =
          declaredPropTypes and
          (declaredPropTypes[key] or declaredPropTypes.__ANY_KEY__)

        return key is '__COMPUTED_PROP__' unless propType
        return yes if typeof propType is 'object' and not propType.type
        return yes if propType.children is yes or propType.containsSpread
        return key of propType.acceptedProperties if propType.acceptedProperties
        if propType.type is 'union'
          return yes if i + 1 >= j
          unionTypes = propType.children
          unionPropType = {}
          for unionType in unionTypes
            unionPropType[key] = unionType
            isValid = _isDeclaredInComponent unionPropType, keyList.slice i
            return yes if isValid

          return no
        declaredPropTypes = propType.children
      # Check if this key is declared
      # If it's a computed property, we can't make any further analysis, but is valid
      # Consider every children as declared
      # If we fall in this case, we know there is at least one complex type in the union
      # this is the last key, accept everything
      # non trivial, check all of them
      # every possible union were invalid
      yes

    ###*
    # Checks if the prop is declared
    # @param {ASTNode} node The AST node being checked.
    # @param {String[]} names List of names of the prop to check.
    # @returns {Boolean} True if the prop is declared, false if not.
    ###
    isDeclaredInComponent = (node, names) ->
      while node
        component = components.get node

        isDeclared =
          component and
          component.confidence is 2 and
          _isDeclaredInComponent component.declaredPropTypes or {}, names
        return yes if isDeclared
        node = node.parent
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
    # Retrieve the name of a property node
    # @param {ASTNode} node The AST node with the property.
    # @return {string} the name of the property or undefined if not found
    ###
    getPropertyName = (node) ->
      isDirectProp = DIRECT_PROPS_REGEX.test sourceCode.getText node
      isInClassComponent =
        utils.getParentES6Component() or utils.getParentES5Component()
      isNotInConstructor = not inConstructor()
      isNotInComponentWillReceiveProps = not inComponentWillReceiveProps()
      isNotInShouldComponentUpdate = not inShouldComponentUpdate()
      return undefined if (
        isDirectProp and
        isInClassComponent and
        isNotInConstructor and
        isNotInComponentWillReceiveProps and
        isNotInShouldComponentUpdate
      )
      unless isDirectProp then node = node.parent
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
          type = 'destructuring'
          {properties} = node.params[0]
        when 'MethodDefinition'
          destructuring = node.value?.params[0]?.type is 'ObjectPattern'
          if destructuring
            type = 'destructuring'
            {properties} = node.value.params[0]
          else
            return
        when 'VariableDeclarator', 'AssignmentExpression'
          left = node.id ? node.left
          right = node.init ? node.right
          # let {props: {firstname}} = this
          # let {firstname} = props
          for property in left.properties
            thisDestructuring =
              not hasSpreadOperator(property) and
              (PROPS_REGEX.test(property.key.name) or
                PROPS_REGEX.test(property.key.value)) and
              property.value.type is 'ObjectPattern'
            directDestructuring =
              PROPS_REGEX.test(right.name) and
              (utils.getParentStatelessComponent() or
                inConstructor() or
                inComponentWillReceiveProps())
            if thisDestructuring
              {properties} = property.value
            else if directDestructuring
              {properties} = left
            else
              continue
            type = 'destructuring'
        else
          throw new Error(
            "#{node.type} ASTNodes are not handled by markPropTypesAsUsed"
          )

      component = components.get utils.getParentComponent()
      usedPropTypes = (component?.usedPropTypes ? []).slice()

      switch type
        when 'direct'
          # Ignore Object methods
          break if Object.prototype[name]

          isDirectProp = DIRECT_PROPS_REGEX.test sourceCode.getText node

          usedPropTypes.push {
            name
            allNames
            node:
              if (
                not isDirectProp and
                not inConstructor() and
                not inComponentWillReceiveProps()
              )
                node.parent.property
              else
                node.property
          }
        when 'destructuring'
          for property in properties
            continue if hasSpreadOperator(property) or property.computed
            propName = getKeyValue property

            currentNode = node
            allNames = []
            while (
              currentNode.property and
              not PROPS_REGEX.test currentNode.property.name
            )
              allNames.unshift currentNode.property.name
              currentNode = currentNode.object
            allNames.push propName

            if propName
              usedPropTypes.push {
                name: propName
                allNames
                node: property
              }

      components.set node, {usedPropTypes}

    ###*
    # Reports undeclared proptypes for a given component
    # @param {Object} component The component to process
    ###
    reportUndeclaredPropTypes = (component) ->
      for usedPropType in component.usedPropTypes
        {allNames} = usedPropType
        if (
          isIgnored(allNames[0]) or
          isDeclaredInComponent component.node, allNames
        )
          continue
        context.report usedPropType.node, MISSING_MESSAGE,
          name: allNames.join('.').replace /\.__COMPUTED_PROP__/g, '[]'

    ###*
    # @param {ASTNode} node We expect either an ArrowFunctionExpression,
    #   FunctionDeclaration, or FunctionExpression
    ###
    markDestructuredFunctionArgumentsAsUsed = (node) ->
      destructuring = node.params?[0] and node.params[0].type is 'ObjectPattern'
      if destructuring and components.get node then markPropTypesAsUsed node

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    VariableDeclarator: (node) ->
      destructuring = node.init and node.id and node.id.type is 'ObjectPattern'
      # let {props: {firstname}} = this
      thisDestructuring = destructuring and node.init.type is 'ThisExpression'
      # let {firstname} = props
      directDestructuring =
        destructuring and
        PROPS_REGEX.test(node.init.name) and
        (utils.getParentStatelessComponent() or
          inConstructor() or
          inComponentWillReceiveProps())
      return if not thisDestructuring and not directDestructuring
      markPropTypesAsUsed node

    AssignmentExpression: (node) ->
      destructuring = node.left.type is 'ObjectPattern'
      # let {props: {firstname}} = this
      thisDestructuring = destructuring and node.right.type is 'ThisExpression'
      # let {firstname} = props
      directDestructuring =
        destructuring and
        PROPS_REGEX.test(node.right.name) and
        (utils.getParentStatelessComponent() or
          inConstructor() or
          inComponentWillReceiveProps())
      return unless thisDestructuring or directDestructuring
      markPropTypesAsUsed node

    FunctionDeclaration: markDestructuredFunctionArgumentsAsUsed

    ArrowFunctionExpression: markDestructuredFunctionArgumentsAsUsed

    FunctionExpression: (node) ->
      return if node.parent.type is 'MethodDefinition'
      markDestructuredFunctionArgumentsAsUsed node

    MemberExpression: (node) ->
      if isPropTypesUsage node then markPropTypesAsUsed node

    MethodDefinition: (node) ->
      destructuring = node.value?.params[0]?.type is 'ObjectPattern'
      if node.key.name is 'componentWillReceiveProps' and destructuring
        markPropTypesAsUsed node

      if node.key.name is 'shouldComponentUpdate' and destructuring
        markPropTypesAsUsed node

    'Program:exit': ->
      list = components.list()
      # Report undeclared proptypes for all classes
      for own _, component of list
        continue unless mustBeValidated component
        reportUndeclaredPropTypes component
