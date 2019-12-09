###*
# @fileoverview Utility class and functions for React components detection
# @author Yannick Croissant
###
'use strict'

util = require 'util'
doctrine = require 'doctrine'
variableUtil = require './variable'
pragmaUtil = require 'eslint-plugin-react/lib/util/pragma'
astUtil = require './ast'
propTypes = require './propTypes'

getId = (node) -> node?.range.join ':'

usedPropTypesAreEquivalent = (propA, propB) ->
  if propA.name is propB.name
    if not propA.allNames and not propB.allNames
      return yes
    return yes if (
      Array.isArray(propA.allNames) and
      Array.isArray(propB.allNames) and
      propA.allNames.join('') is propB.allNames.join ''
    )
    return no
  no

mergeUsedPropTypes = (propsList, newPropsList) ->
  propsToAdd = []
  newPropsList.forEach (newProp) ->
    newPropisAlreadyInTheList = propsList.some (prop) ->
      usedPropTypesAreEquivalent prop, newProp
    unless newPropisAlreadyInTheList then propsToAdd.push newProp
  propsList.concat propsToAdd

###*
# Components
###
class Components
  constructor: ->
    @_list = {}

  ###*
  # Add a node to the components list, or update it if it's already in the list
  #
  # @param {ASTNode} node The AST node being added.
  # @param {Number} confidence Confidence in the component detection (0=banned, 1=maybe, 2=yes)
  # @returns {Object} Added component object
  ###
  add: (node, confidence) ->
    id = getId node
    if @_list[id]
      if confidence is 0 or @_list[id].confidence is 0
        @_list[id].confidence = 0
      else
        @_list[id].confidence = Math.max @_list[id].confidence, confidence
      return @_list[id]
    @_list[id] = {node, confidence}
    @_list[id]

  ###*
  # Find a component in the list using its node
  #
  # @param {ASTNode} node The AST node being searched.
  # @returns {Object} Component object, undefined if the component is not found or has confidence value of 0.
  ###
  get: (node) ->
    id = getId node
    return @_list[id] if @_list[id]?.confidence >= 1
    null

  ###*
  # Update a component in the list
  #
  # @param {ASTNode} node The AST node being updated.
  # @param {Object} props Additional properties to add to the component.
  ###
  set: (node, props) ->
    node = node.parent while node and not @_list[getId node]
    return unless node
    id = getId node
    if @_list[id]
      # usedPropTypes is an array. _extend replaces existing array with a new one which caused issue #1309.
      # preserving original array so it can be merged later on.
      copyUsedPropTypes = @_list[id].usedPropTypes?.slice()
    @_list[id] = util._extend @_list[id], props
    if @_list[id] and props.usedPropTypes
      @_list[id].usedPropTypes = mergeUsedPropTypes(
        copyUsedPropTypes or []
        props.usedPropTypes
      )

  ###*
  # Return the components list
  # Components for which we are not confident are not returned
  #
  # @returns {Object} Components list
  ###
  list: ->
    list = {}
    usedPropTypes = {}

    # Find props used in components for which we are not confident
    for own _, comp of @_list
      continue if comp.confidence >= 2
      component = null
      node = null
      {node} = comp
      while not component and node.parent
        node = node.parent
        # Stop moving up if we reach a decorator
        break if node.type is 'Decorator'
        component = @get node
      if component
        newUsedProps = (comp.usedPropTypes or []).filter (propType) ->
          not propType.node or propType.node.kind isnt 'init'

        componentId = getId component.node
        usedPropTypes[componentId] = (usedPropTypes[componentId] or []).concat(
          newUsedProps
        )

    # Assign used props in not confident components to the parent component
    for own j, comp of @_list when comp.confidence >= 2
      id = getId comp.node
      list[j] = comp
      if usedPropTypes[id]
        list[j].usedPropTypes = (list[j].usedPropTypes or []).concat(
          usedPropTypes[id]
        )
    list

  ###*
  # Return the length of the components list
  # Components for which we are not confident are not counted
  #
  # @returns {Number} Components list length
  ###
  length: ->
    length = 0
    for own i of @_list when @_list[i].confidence >= 2
      length++
    length

componentRule = (rule, context) ->
  createClass = pragmaUtil.getCreateClassFromContext context
  pragma = pragmaUtil.getFromContext context
  sourceCode = context.getSourceCode()
  components = new Components()

  # Utilities for component detection
  utils =
    ###*
    # Check if the node is a React ES5 component
    #
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if the node is a React ES5 component, false if not
    ###
    isES5Component: (node) ->
      return no unless node.parent
      ///^(#{pragma}\.)?#{createClass}$///.test(
        sourceCode.getText node.parent.callee
      )

    ###*
    # Check if the node is a React ES6 component
    #
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if the node is a React ES6 component, false if not
    ###
    isES6Component: (node) ->
      return yes if utils.isExplicitComponent node

      return no unless node.superClass
      ///^(#{pragma}\.)?(Pure)?Component$///.test(
        sourceCode.getText node.superClass
      )

    ###*
    # Check if the node is explicitly declared as a descendant of a React Component
    #
    # @param {ASTNode} node The AST node being checked (can be a ReturnStatement or an ArrowFunctionExpression).
    # @returns {Boolean} True if the node is explicitly declared as a descendant of a React Component, false if not
    ###
    isExplicitComponent: (node) ->
      # Sometimes the passed node may not have been parsed yet by eslint, and this function call crashes.
      # Can be removed when eslint sets "parent" property for all nodes on initial AST traversal: https://github.com/eslint/eslint-scope/issues/27
      # eslint-disable-next-line no-warning-comments
      # FIXME: Remove try/catch when https://github.com/eslint/eslint-scope/issues/27 is implemented.
      try
        comment = sourceCode.getJSDocComment node
      catch e
        comment = null

      return no if comment is null

      commentAst = doctrine.parse comment.value,
        unwrap: yes
        tags: ['extends', 'augments']

      relevantTags = commentAst.tags.filter (tag) ->
        tag.name in ['React.Component', 'React.PureComponent']

      relevantTags.length > 0

    ###*
    # Checks to see if our component extends React.PureComponent
    #
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if node extends React.PureComponent, false if not
    ###
    isPureComponent: (node) ->
      return ///^(#{pragma}\.)?PureComponent$///.test(
        sourceCode.getText node.superClass
      ) if node.superClass
      no

    ###*
    # Check if createElement is destructured from React import
    #
    # @returns {Boolean} True if createElement is destructured from React
    ###
    hasDestructuredReactCreateElement: ->
      variables = variableUtil.variablesInScope context
      variable = variableUtil.getVariable variables, 'createElement'
      if variable
        map = variable.scope.set
        return yes if map.has 'React'
      no

    ###*
    # Checks to see if node is called within React.createElement
    #
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if React.createElement called
    ###
    isReactCreateElement: (node) ->
      calledOnReact =
        node?.callee?.object?.name is 'React' and
        node.callee.property?.name is 'createElement'

      calledDirectly = node?.callee?.name is 'createElement'

      return (
        calledDirectly or calledOnReact
      ) if @hasDestructuredReactCreateElement()
      calledOnReact

    getReturnPropertyAndNode: (ASTnode) ->
      node = ASTnode
      return {node, property: 'expression'} if (
        node.type is 'ExpressionStatement' and node.expression.returns
      )
      switch node.type
        when 'ReturnStatement'
          property = 'argument'
        when 'ArrowFunctionExpression'
          property = 'body'
          if node[property] and node[property].type is 'BlockStatement'
            {node, property} = utils.findReturnStatement node
        else
          {node, property} = utils.findReturnStatement node
      {node, property}

    ###*
    # Check if the node is returning JSX
    #
    # @param {ASTNode} ASTnode The AST node being checked
    # @param {Boolean} strict If true, in a ternary condition the node must return JSX in both cases
    # @returns {Boolean} True if the node is returning JSX, false if not
    ###
    isReturningJSX: (ASTnode, strict) ->
      nodeAndProperty = utils.getReturnPropertyAndNode ASTnode
      {node, property} = nodeAndProperty

      return no unless node

      returnsConditionalJSXConsequent =
        node[property] and
        node[property].type is 'ConditionalExpression' and
        node[property].consequent.type is 'JSXElement'
      returnsConditionalJSXAlternate =
        node[property] and
        node[property].type is 'ConditionalExpression' and
        node[property].alternate?.type is 'JSXElement'
      returnsConditionalJSX =
        if strict
          returnsConditionalJSXConsequent and returnsConditionalJSXAlternate
        else
          returnsConditionalJSXConsequent or returnsConditionalJSXAlternate

      returnsJSX = node[property] and node[property].type is 'JSXElement'
      returnsReactCreateElement = @isReactCreateElement node[property]

      Boolean returnsConditionalJSX or returnsJSX or returnsReactCreateElement

    ###*
    # Check if the node is returning null
    #
    # @param {ASTNode} ASTnode The AST node being checked
    # @returns {Boolean} True if the node is returning null, false if not
    ###
    isReturningNull: (ASTnode) ->
      nodeAndProperty = utils.getReturnPropertyAndNode ASTnode
      {property, node} = nodeAndProperty

      return no unless node

      node[property] and node[property].value is null

    ###*
    # Check if the node is returning JSX or null
    #
    # @param {ASTNode} ASTnode The AST node being checked
    # @param {Boolean} strict If true, in a ternary condition the node must return JSX in both cases
    # @returns {Boolean} True if the node is returning JSX or null, false if not
    ###
    isReturningJSXOrNull: (ASTNode, strict) ->
      utils.isReturningJSX(ASTNode, strict) or utils.isReturningNull ASTNode

    ###*
    # Find a return statment in the current node
    #
    # @param {ASTNode} ASTnode The AST node being checked
    ###
    findReturnStatement: astUtil.findReturnStatement

    ###*
    # Get the parent component node from the current scope
    #
    # @returns {ASTNode} component node, null if we are not in a component
    ###
    getParentComponent: ->
      utils.getParentES6Component() or
      utils.getParentES5Component() or
      utils.getParentStatelessComponent()

    ###*
    # Get the parent ES5 component node from the current scope
    #
    # @returns {ASTNode} component node, null if we are not in a component
    ###
    getParentES5Component: ->
      # eslint-disable-next-line coffee/destructuring-assignment
      scope = context.getScope()
      while scope
        node = scope.block?.parent?.parent
        return node if node and utils.isES5Component node
        scope = scope.upper
      null

    ###*
    # Get the parent ES6 component node from the current scope
    #
    # @returns {ASTNode} component node, null if we are not in a component
    ###
    getParentES6Component: ->
      scope = context.getScope()
      while scope and scope.type isnt 'class'
        scope = scope.upper
      node = scope?.block
      return null if not node or not utils.isES6Component node
      node

    ###*
    # Get the parent stateless component node from the current scope
    #
    # @returns {ASTNode} component node, null if we are not in a component
    ###
    getParentStatelessComponent: ->
      # eslint-disable-next-line coffee/destructuring-assignment
      scope = context.getScope()
      while scope
        node = scope.block
        isClass = node.type is 'ClassExpression'
        isFunction = /Function/.test node.type # Functions
        isMethod = node.parent?.type is 'MethodDefinition' # Classes methods
        isArgument =
          node.parent?.type is 'CallExpression' or
          (node.parent?.type is 'UnaryExpression' and
            node.parent.operator is 'do') # Arguments (callback, etc.)
        # Attribute Expressions inside JSX Elements (<button onClick={() => props.handleClick()}></button>)
        isJSXExpressionContainer = node.parent?.type is 'JSXExpressionContainer'
        # Stop moving up if we reach a class or an argument (like a callback)
        return null if isClass or isArgument
        # Return the node if it is a function that is not a class method and is not inside a JSX Element
        return node if (
          isFunction and
          not isMethod and
          not isJSXExpressionContainer and
          utils.isReturningJSXOrNull node
        )
        scope = scope.upper
      null

    ###*
    # Get the related component from a node
    #
    # @param {ASTNode} node The AST node being checked (must be a MemberExpression).
    # @returns {ASTNode} component node, null if we cannot find the component
    ###
    getRelatedComponent: (node) ->
      # Get the component path
      componentPath = []
      while node
        if node.property and node.property.type is 'Identifier'
          componentPath.push node.property.name
        if node.object and node.object.type is 'Identifier'
          componentPath.push node.object.name
        node = node.object
      componentPath.reverse()
      componentName = componentPath.slice(0, componentPath.length - 1).join '.'

      # Find the variable in the current scope
      variableName = componentPath.shift()
      return null unless variableName
      variables = variableUtil.variablesInScope context
      for variable in variables
        if variable.name is variableName
          variableInScope = variable
          break
      return null unless variableInScope

      # Try to find the component using variable references
      for ref in variableInScope.references
        refId = ref.identifier
        if refId.parent and refId.parent.type is 'MemberExpression'
          refId = refId.parent
        continue unless sourceCode.getText(refId) is componentName
        if refId.type is 'MemberExpression'
          componentNode = refId.parent.right
        else if refId.parent and refId.parent.type is 'VariableDeclarator'
          componentNode = refId.parent.init
        else if (
          refId.declaration and refId.parent.type is 'AssignmentExpression'
        )
          componentNode = refId.parent.right
        break

      # Return the component
      return components.add componentNode, 1 if componentNode

      # Try to find the component using variable declarations
      for def in variableInScope.defs
        if def.type in ['ClassName', 'FunctionName', 'Variable']
          defInScope = def
          break
      return null unless defInScope?.node
      componentNode =
        defInScope.node.init or
        (defInScope.node.declaration and
          defInScope.node.parent.type is 'AssignmentExpression' and
          defInScope.node.parent.right) or
        defInScope.node

      # Traverse the node properties to the component declaration
      for componentPathSegment in componentPath
        continue unless componentNode.properties
        for prop in componentNode.properties
          if prop.key?.name is componentPathSegment
            componentNode = prop
            break
        return null if not componentNode or not componentNode.value
        componentNode = componentNode.value

      # Return the component
      components.add componentNode, 1

  # Component detection instructions
  detectionInstructions =
    ClassExpression: (node) ->
      return unless utils.isES6Component node
      components.add node, 2

    ClassDeclaration: (node) ->
      return unless utils.isES6Component node
      components.add node, 2

    ClassProperty: (node) ->
      node = utils.getParentComponent()
      return unless node
      components.add node, 2

    ObjectExpression: (node) ->
      return unless utils.isES5Component node
      components.add node, 2

    FunctionExpression: (node) ->
      if node.async
        components.add node, 0
        return
      component = utils.getParentComponent()
      if (
        not component or
        (component.parent and component.parent.type is 'JSXExpressionContainer')
      )
        # Ban the node if we cannot find a parent component
        components.add node, 0
        return
      components.add component, 1

    FunctionDeclaration: (node) ->
      if node.async
        components.add node, 0
        return
      node = utils.getParentComponent()
      return unless node
      components.add node, 1

    ArrowFunctionExpression: (node) ->
      if node.async
        components.add node, 0
        return
      component = utils.getParentComponent()
      if (
        not component or
        (component.parent and component.parent.type is 'JSXExpressionContainer')
      )
        # Ban the node if we cannot find a parent component
        components.add node, 0
        return
      if component.expression and utils.isReturningJSX component
        components.add component, 2
      else
        components.add component, 1

    ThisExpression: (node) ->
      component = utils.getParentComponent()
      return if (
        not component or
        not /Function/.test(component.type) or
        not node.parent.property
      )
      # Ban functions accessing a property on a ThisExpression
      components.add node, 0

    ReturnStatement: (node) ->
      return unless utils.isReturningJSX node
      node = utils.getParentComponent()
      unless node
        scope = context.getScope()
        components.add scope.block, 1
        return
      components.add node, 2

    ExpressionStatement: (node) ->
      return unless utils.isReturningJSX node
      node = utils.getParentComponent()
      unless node
        scope = context.getScope()
        components.add scope.block, 1
        return
      components.add node, 2

  # Update the provided rule instructions to add the component detection
  ruleInstructions = rule context, components, utils
  updatedRuleInstructions = util._extend {}, ruleInstructions
  propTypesInstructions = propTypes context, components, utils
  allKeys = new Set(
    Object.keys(detectionInstructions).concat Object.keys propTypesInstructions
  )
  allKeys.forEach (instruction) ->
    updatedRuleInstructions[instruction] = (node) ->
      if instruction of detectionInstructions
        detectionInstructions[instruction] node
      if instruction of propTypesInstructions
        propTypesInstructions[instruction] node
      if ruleInstructions[instruction]
        ruleInstructions[instruction] node
      else
        undefined

  # Return the updated rule instructions
  updatedRuleInstructions

module.exports = Object.assign Components,
  detect: (rule) -> componentRule.bind @, rule
