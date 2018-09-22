###*
# @fileoverview Common propTypes detection functionality.
###
'use strict'

annotations = require 'eslint-plugin-react/lib/util/annotations'
propsUtil = require './props'
variableUtil = require './variable'
versionUtil = require 'eslint-plugin-react/lib/util/version'

###*
# Checks if we are declaring a props as a generic type in a flow-annotated class.
#
# @param {ASTNode} node  the AST node being checked.
# @returns {Boolean} True if the node is a class with generic prop types, false if not.
###
isSuperTypeParameterPropsDeclaration = (node) ->
  if node and node.type in ['ClassDeclaration', 'ClassExpression']
    return yes if (
      node.superTypeParameters and node.superTypeParameters.params.length > 0
    )
  no

###*
# Removes quotes from around an identifier.
# @param {string} the identifier to strip
###
stripQuotes = (string) -> string.replace /^\'|\'$/g, ''

###*
# Retrieve the name of a key node
# @param {ASTNode} node The AST node with the key.
# @return {string} the name of the key
###
getKeyValue = (context, node) ->
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
# Iterates through a properties node, like a customized forEach.
# @param {Object[]} properties Array of properties to iterate.
# @param {Function} fn Function to call on each property, receives property key
    and property value. (key, value) => void
###
iterateProperties = (context, properties, fn) ->
  if properties?.length and typeof fn is 'function'
    i = 0
    j = properties.length
    while i < j
      node = properties[i]
      key = getKeyValue context, node

      value = node.value
      fn key, value
      i++

module.exports = (context, components, utils) ->
  # Used to track the type annotations in scope.
  # Necessary because babel's scopes do not track type annotations.
  stack = null

  classExpressions = []
  defaults = customValidators: []
  configuration = Object.assign {}, defaults, context.options[0] or {}
  customValidators = configuration.customValidators
  sourceCode = context.getSourceCode()
  propWrapperFunctions = new Set context.settings.propWrapperFunctions

  ###*
  # Returns the full scope.
  # @returns {Object} The whole scope.
  ###
  typeScope = -> stack[stack.length - 1]

  ###*
  # Gets a node from the scope.
  # @param {string} key The name of the identifier to access.
  # @returns {ASTNode} The ASTNode associated with the given identifier.
  ###
  getInTypeScope = (key) -> stack[stack.length - 1][key]

  ###*
  # Sets the new value in the scope.
  # @param {string} key The name of the identifier to access
  # @param {ASTNode} value The new value for the identifier.
  # @returns {ASTNode} The ASTNode associated with the given identifier.
  ###
  setInTypeScope = (key, value) ->
    stack[stack.length - 1][key] = value
    value

  ###*
  # Checks if prop should be validated by plugin-react-proptypes
  # @param {String} validator Name of validator to check.
  # @returns {Boolean} True if validator should be checked by custom validator.
  ###
  hasCustomValidator = (validator) ->
    customValidators.indexOf(validator) isnt -1

  ### eslint-disable no-use-before-define ###
  typeDeclarationBuilders =
    GenericTypeAnnotation: (annotation, parentName, seen) ->
      return buildTypeAnnotationDeclarationTypes(
        getInTypeScope annotation.id.name
        parentName
        seen
      ) if getInTypeScope annotation.id.name
      {}

    ObjectTypeAnnotation: (annotation, parentName, seen) ->
      containsObjectTypeSpread = no
      shapeTypeDefinition =
        type: 'shape'
        children: {}
      iterateProperties context, annotation.properties, (
        childKey
        childValue
      ) ->
        fullName = [parentName, childKey].join '.'
        if not childKey and not childValue
          containsObjectTypeSpread = yes
        else
          types = buildTypeAnnotationDeclarationTypes childValue, fullName, seen
          types.fullName = fullName
          types.name = childKey
          types.node = childValue
          shapeTypeDefinition.children[childKey] = types

      # Mark if this shape has spread. We will know to consider all props from this shape as having propTypes,
      # but still have the ability to detect unused children of this shape.
      shapeTypeDefinition.containsSpread = containsObjectTypeSpread

      shapeTypeDefinition

    UnionTypeAnnotation: (annotation, parentName, seen) ->
      unionTypeDefinition =
        type: 'union'
        children: []
      i = 0
      j = annotation.types.length
      while i < j
        type = buildTypeAnnotationDeclarationTypes(
          annotation.types[i]
          parentName
          seen
        )
        if type.type
          if type.children is yes
            unionTypeDefinition.children = yes
            return unionTypeDefinition

        unionTypeDefinition.children.push type
        i++
      # keep only complex type
      # every child is accepted for one type, abort type analysis
      # no complex type found, simply accept everything
      return {} if unionTypeDefinition.children.length is 0
      unionTypeDefinition

    ArrayTypeAnnotation: (annotation, parentName, seen) ->
      fullName = [parentName, '*'].join '.'
      child = buildTypeAnnotationDeclarationTypes(
        annotation.elementType
        fullName
        seen
      )
      child.fullName = fullName
      child.name = '__ANY_KEY__'
      child.node = annotation
      type: 'object'
      children:
        __ANY_KEY__: child
  ### eslint-enable no-use-before-define ###

  ###*
  # Resolve the type annotation for a given node.
  # Flow annotations are sometimes wrapped in outer `TypeAnnotation`
  # and `NullableTypeAnnotation` nodes which obscure the annotation we're
  # interested in.
  # This method also resolves type aliases where possible.
  #
  # @param {ASTNode} node The annotation or a node containing the type annotation.
  # @returns {ASTNode} The resolved type annotation for the node.
  ###
  resolveTypeAnnotation = (node) ->
    annotation = node.typeAnnotation or node

    while annotation?.type in ['TypeAnnotation', 'NullableTypeAnnotation']
      annotation = annotation.typeAnnotation

    return getInTypeScope annotation.id.name if (
      annotation.type is 'GenericTypeAnnotation' and
      getInTypeScope annotation.id.name
    )
    annotation

  ###*
  # Creates the representation of the React props type annotation for the component.
  # The representation is used to verify nested used properties.
  # @param {ASTNode} annotation Type annotation for the props class property.
  # @return {Object} The representation of the declaration, empty object means
  #    the property is declared without the need for further analysis.
  ###
  buildTypeAnnotationDeclarationTypes = (annotation, parentName, seen) ->
    if typeof seen is 'undefined'
      # Keeps track of annotations we've already seen to
      # prevent problems with recursive types.
      seen = new Set()
    # This must be a recursive type annotation, so just accept anything.
    return {} if seen.has annotation
    seen.add annotation

    return typeDeclarationBuilders[annotation.type](
      annotation
      parentName
      seen
    ) if annotation.type of typeDeclarationBuilders
    {}

  ###*
  # Marks all props found inside ObjectTypeAnnotaiton as declared.
  #
  # Modifies the declaredProperties object
  # @param {ASTNode} propTypes
  # @param {Object} declaredPropTypes
  # @returns {Boolean} True if propTypes should be ignored (e.g. when a type can't be resolved, when it is imported)
  ###
  declarePropTypesForObjectTypeAnnotation = (propTypes, declaredPropTypes) ->
    ignorePropsValidation = no

    iterateProperties context, propTypes.properties, (key, value) ->
      unless value
        ignorePropsValidation = yes
        return

      types = buildTypeAnnotationDeclarationTypes value, key
      types.fullName = key
      types.name = key
      types.node = value
      declaredPropTypes[key] = types

    ignorePropsValidation

  ###*
  # Marks all props found inside IntersectionTypeAnnotation as declared.
  # Since InterSectionTypeAnnotations can be nested, this handles recursively.
  #
  # Modifies the declaredPropTypes object
  # @param {ASTNode} propTypes
  # @param {Object} declaredPropTypes
  # @returns {Boolean} True if propTypes should be ignored (e.g. when a type can't be resolved, when it is imported)
  ###
  declarePropTypesForIntersectionTypeAnnotation = (
    propTypes
    declaredPropTypes
  ) ->
    propTypes.types.some (annotation) ->
      return declarePropTypesForObjectTypeAnnotation(
        annotation
        declaredPropTypes
      ) if annotation.type is 'ObjectTypeAnnotation'

      return yes if annotation.type is 'UnionTypeAnnotation'

      # Type can't be resolved
      return yes unless annotation.id

      typeNode = getInTypeScope annotation.id.name

      unless typeNode
        return yes
      else
        return declarePropTypesForIntersectionTypeAnnotation(
          typeNode
          declaredPropTypes
        ) if typeNode.type is 'IntersectionTypeAnnotation'

      declarePropTypesForObjectTypeAnnotation typeNode, declaredPropTypes

  ###*
  # Creates the representation of the React propTypes for the component.
  # The representation is used to verify nested used properties.
  # @param {ASTNode} value Node of the PropTypes for the desired property
  # @return {Object} The representation of the declaration, empty object means
  #    the property is declared without the need for further analysis.
  ###
  buildReactDeclarationTypes = (value, parentName) ->
    return {} if (
      value?.callee and
      value.callee.object and
      hasCustomValidator value.callee.object.name
    )

    if (
      value and
      value.type is 'MemberExpression' and
      value.property and
      value.property.name and
      value.property.name is 'isRequired'
    )
      value = value.object

    # Verify PropTypes that are functions
    if (
      value and
      value.type is 'CallExpression' and
      value.callee and
      value.callee.property and
      value.callee.property.name and
      value.arguments and
      value.arguments.length > 0
    )
      callName = value.callee.property.name
      argument = value.arguments[0]
      switch callName
        when 'shape'
          # Invalid proptype or cannot analyse statically
          return {} unless argument.type is 'ObjectExpression'
          shapeTypeDefinition =
            type: 'shape'
            children: {}
          iterateProperties context, argument.properties, (
            childKey
            childValue
          ) ->
            fullName = [parentName, childKey].join '.'
            types = buildReactDeclarationTypes childValue, fullName
            types.fullName = fullName
            types.name = childKey
            types.node = childValue
            shapeTypeDefinition.children[childKey] = types
          return shapeTypeDefinition
        when 'arrayOf', 'objectOf'
          fullName = [parentName, '*'].join '.'
          child = buildReactDeclarationTypes argument, fullName
          child.fullName = fullName
          child.name = '__ANY_KEY__'
          child.node = argument
          return
            type: 'object'
            children:
              __ANY_KEY__: child


        when 'oneOfType'
          # Invalid proptype or cannot analyse statically
          return {} if not argument.elements or not argument.elements.length
          unionTypeDefinition =
            type: 'union'
            children: []
          i = 0
          j = argument.elements.length
          while i < j
            type = buildReactDeclarationTypes argument.elements[i], parentName
            if type.type
              if type.children is yes
                unionTypeDefinition.children = yes
                return unionTypeDefinition

            unionTypeDefinition.children.push type
            i++
          # keep only complex type
          # every child is accepted for one type, abort type analysis
          # no complex type found, simply accept everything
          return {} if unionTypeDefinition.length is 0
          return unionTypeDefinition
        when 'instanceOf'
          return
            type: 'instance'
            # Accept all children because we can't know what type they are
            children: yes


        else
          return {}
    # Unknown property or accepts everything (any, object, ...)
    {}

  ###*
  # Mark a prop type as declared
  # @param {ASTNode} node The AST node being checked.
  # @param {propTypes} node The AST node containing the proptypes
  ###
  markPropTypesAsDeclared = (node, propTypes) ->
    componentNode = node

    while componentNode and not components.get componentNode
      componentNode = componentNode.parent

    component = components.get componentNode
    declaredPropTypes = component?.declaredPropTypes or {}
    ignorePropsValidation = component?.ignorePropsValidation or no
    switch propTypes?.type
      when 'ObjectTypeAnnotation'
        ignorePropsValidation = declarePropTypesForObjectTypeAnnotation(
          propTypes
          declaredPropTypes
        )
      when 'ObjectExpression'
        iterateProperties context, propTypes.properties, (key, value) ->
          unless value
            ignorePropsValidation ###:### = yes
            return
          types = buildReactDeclarationTypes value, key
          types.fullName = key
          types.name = key
          types.node = value
          declaredPropTypes[key] = types
      when 'MemberExpression'
        curDeclaredPropTypes = declaredPropTypes
        # Walk the list of properties, until we reach the assignment
        # ie: ClassX.propTypes.a.b.c = ...
        while (
          propTypes?.parent and
          propTypes.parent.type isnt 'AssignmentExpression' and
          propTypes.property and
          curDeclaredPropTypes
        )
          propName = propTypes.property.name
          if propName of curDeclaredPropTypes
            curDeclaredPropTypes = curDeclaredPropTypes[propName].children
            propTypes = propTypes.parent
          else
            # This will crash at runtime because we haven't seen this key before
            # stop this and do not declare it
            propTypes = null
        if propTypes?.parent and propTypes.property
          unless (
            propTypes is propTypes.parent.left and propTypes.parent.left.object
          )
            ignorePropsValidation = yes
          parentProp = context
          .getSource(propTypes.parent.left.object)
          .replace /^.*\.propTypes\./, ''
          types = buildReactDeclarationTypes propTypes.parent.right, parentProp

          types.name = propTypes.property.name
          types.fullName = [parentProp, propTypes.property.name].join '.'
          types.node = propTypes.property
          curDeclaredPropTypes[propTypes.property.name] = types
        else
          isUsedInPropTypes = no
          n = propTypes
          while n
            if (
              (n.type is 'AssignmentExpression' and
                propsUtil.isPropTypesDeclaration(n.left)) or
              (n.type in ['ClassProperty', 'Property'] and
                propsUtil.isPropTypesDeclaration n)
            )
              # Found a propType used inside of another propType. This is not considered usage, we'll still validate
              # this component.
              isUsedInPropTypes = yes
            n = n.parent
          unless isUsedInPropTypes then ignorePropsValidation = yes
      when 'Identifier'
        variablesInScope = variableUtil.variablesInScope context
        for variable in variablesInScope
          continue unless variable.name is propTypes.name
          defInScope = variable.defs[variable.defs.length - 1]
          markPropTypesAsDeclared(
            node
            defInScope.node?.init ? defInScope.node?.parent.right
          )
          return
        ignorePropsValidation = yes
      when 'CallExpression'
        if (
          propWrapperFunctions.has(sourceCode.getText propTypes.callee) and
          propTypes.arguments and
          propTypes.arguments[0]
        )
          markPropTypesAsDeclared node, propTypes.arguments[0]
          return
      when 'IntersectionTypeAnnotation'
        ignorePropsValidation = declarePropTypesForIntersectionTypeAnnotation(
          propTypes
          declaredPropTypes
        )
      else
        ignorePropsValidation = yes

    components.set node, {
      declaredPropTypes
      ignorePropsValidation
    }

  ###*
  # @param {ASTNode} node We expect either an ArrowFunctionExpression,
  #   FunctionDeclaration, or FunctionExpression
  ###
  markAnnotatedFunctionArgumentsAsDeclared = (node) ->
    return if (
      not node.params or
      not node.params.length or
      not annotations.isAnnotatedFunctionPropsDeclaration node, context
    )
    markPropTypesAsDeclared node, resolveTypeAnnotation node.params[0]

  ###*
  # Resolve the type annotation for a given class declaration node with superTypeParameters.
  #
  # @param {ASTNode} node The annotation or a node containing the type annotation.
  # @returns {ASTNode} The resolved type annotation for the node.
  ###
  resolveSuperParameterPropsType = (node) ->
    try
      # Flow <=0.52 had 3 required TypedParameters of which the second one is the Props.
      # Flow >=0.53 has 2 optional TypedParameters of which the first one is the Props.
      propsParameterPosition =
        if versionUtil.testFlowVersion context, '0.53.0' then 0 else 1
    catch e
      # In case there is no flow version defined, we can safely assume that when there are 3 Props we are dealing with version <= 0.52
      propsParameterPosition =
        if node.superTypeParameters.params.length <= 2 then 0 else 1

    annotation = node.superTypeParameters.params[propsParameterPosition]

    while annotation?.type in ['TypeAnnotation', 'NullableTypeAnnotation']
      annotation = annotation.typeAnnotation

    return getInTypeScope annotation.id.name if (
      annotation.type is 'GenericTypeAnnotation' and
      getInTypeScope annotation.id.name
    )
    annotation

  ###*
  # Checks if we are declaring a `props` class property with a flow type annotation.
  # @param {ASTNode} node The AST node being checked.
  # @returns {Boolean} True if the node is a type annotated props declaration, false if not.
  ###
  isAnnotatedClassPropsDeclaration = (node) ->
    if node and node.type is 'ClassProperty'
      tokens = context.getFirstTokens node, 2
      return yes if (
        node.typeAnnotation and
        (tokens[0].value is 'props' or
          (tokens[1] and tokens[1].value is 'props'))
      )
    no

  ClassExpression: (node) ->
    # TypeParameterDeclaration need to be added to typeScope in order to handle ClassExpressions.
    # This visitor is executed before TypeParameterDeclaration are scoped, therefore we postpone
    # processing class expressions until when the program exists.
    classExpressions.push node

  ClassDeclaration: (node) ->
    if isSuperTypeParameterPropsDeclaration node
      markPropTypesAsDeclared node, resolveSuperParameterPropsType node

  ClassProperty: (node) ->
    if isAnnotatedClassPropsDeclaration node
      markPropTypesAsDeclared node, resolveTypeAnnotation node
    else if propsUtil.isPropTypesDeclaration node
      markPropTypesAsDeclared node, node.value

  ObjectExpression: (node) ->
    # Search for the proptypes declaration
    node.properties.forEach (property) ->
      return unless propsUtil.isPropTypesDeclaration property
      markPropTypesAsDeclared node, property.value

  FunctionExpression: (node) ->
    unless node.parent.type is 'MethodDefinition'
      markAnnotatedFunctionArgumentsAsDeclared node

  FunctionDeclaration: markAnnotatedFunctionArgumentsAsDeclared

  ArrowFunctionExpression: markAnnotatedFunctionArgumentsAsDeclared

  MemberExpression: (node) ->
    if propsUtil.isPropTypesDeclaration node
      component = utils.getRelatedComponent node
      return unless component
      markPropTypesAsDeclared component.node, node.parent.right or node.parent

  MethodDefinition: (node) ->
    return if (
      not node.static or
      node.kind isnt 'get' or
      not propsUtil.isPropTypesDeclaration node
    )

    i = node.value.body.body.length - 1
    while i >= 0
      if node.value.body.body[i].type is 'ReturnStatement' then break
      i--

    if i >= 0
      markPropTypesAsDeclared node, node.value.body.body[i].argument

  JSXSpreadAttribute: (node) ->
    component = components.get utils.getParentComponent()
    components.set(
      if component then component.node else node
      ignoreUnusedPropTypesValidation: yes
    )

  TypeAlias: (node) -> setInTypeScope node.id.name, node.right

  TypeParameterDeclaration: (node) ->
    identifier = node.params[0]

    if identifier.typeAnnotation
      setInTypeScope identifier.name, identifier.typeAnnotation.typeAnnotation

  Program: -> stack = [{}]

  BlockStatement: -> stack.push Object.create typeScope()

  'BlockStatement:exit': -> stack.pop()

  'Program:exit': ->
    classExpressions.forEach (node) ->
      if isSuperTypeParameterPropsDeclaration node
        markPropTypesAsDeclared node, resolveSuperParameterPropsType node
