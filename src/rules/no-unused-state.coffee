###*
# @fileoverview  Attempts to discover all state fields in a React component and
# warn if any of them are never read.
#
# State field definitions are collected from `this.state = {}` assignments in
# the constructor, objects passed to `this.setState()`, and `state = {}` class
# property assignments.
###

'use strict'

Components = require '../util/react/Components'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# Descend through all wrapping TypeCastExpressions and return the expression
# that was cast.
uncast = (node) ->
  while node.type is 'TypeCastExpression' then node = node.expression
  node

# Return the name of an identifier or the string value of a literal. Useful
# anywhere that a literal may be used as a key (e.g., member expressions,
# method definitions, ObjectExpression property keys).
getName = (node) ->
  node = uncast node
  type = node.type

  if type is 'Identifier'
    return node.name
  else if type is 'Literal'
    return String node.value
  else
    return node.quasis[0].value.raw if (
      type is 'TemplateLiteral' and node.expressions.length is 0
    )
  null

isThisExpression = (node) -> uncast(node).type is 'ThisExpression'

getInitialClassInfo = ->
  # Set of nodes where state fields were defined.
  stateFields: new Set()

  # Set of names of state fields that we've seen used.
  usedStateFields: new Set()

  # Names of local variables that may be pointing to this.state. To
  # track this properly, we would need to keep track of all locals,
  # shadowing, assignments, etc. To keep things simple, we only
  # maintain one set of aliases per method and accept that it will
  # produce some false negatives.
  aliases: null

module.exports =
  meta:
    docs:
      description: 'Prevent definition of unused state fields'
      category: 'Best Practices'
      recommended: no
      url: docsUrl 'no-unused-state'
    schema: []

  create: Components.detect (context, components, utils) ->
    # Non-null when we are inside a React component ClassDeclaration and we have
    # not yet encountered any use of this.state which we have chosen not to
    # analyze. If we encounter any such usage (like this.state being spread as
    # JSX attributes), then this is again set to null.
    classInfo = null

    # Returns true if the given node is possibly a reference to `this.state`, `prevState` or `nextState`.
    isStateReference = (node) ->
      node = uncast node

      isDirectStateReference =
        node.type is 'MemberExpression' and
        isThisExpression(node.object) and
        node.property.name is 'state'

      isAliasedStateReference =
        node.type is 'Identifier' and
        classInfo.aliases and
        classInfo.aliases.has node.name

      isPrevStateReference =
        node.type is 'Identifier' and node.name is 'prevState'

      isNextStateReference =
        node.type is 'Identifier' and node.name is 'nextState'

      isDirectStateReference or
        isAliasedStateReference or
        isPrevStateReference or
        isNextStateReference

    # Takes an ObjectExpression node and adds all named Property nodes to the
    # current set of state fields.
    addStateFields = (node) ->
      for prop from node.properties
        key = prop.key

        if (
          prop.type is 'Property' and
          (key.type is 'Literal' or
            (key.type is 'TemplateLiteral' and key.expressions.length is 0) or
            (prop.computed is no and key.type is 'Identifier')) and
          getName(prop.key) isnt null
        )
          classInfo.stateFields.add prop

    # Adds the name of the given node as a used state field if the node is an
    # Identifier or a Literal. Other node types are ignored.
    addUsedStateField = (node) ->
      name = getName node
      if name then classInfo.usedStateFields.add name

    # Records used state fields and new aliases for an ObjectPattern which
    # destructures `this.state`.
    handleStateDestructuring = (node) ->
      for prop from node.properties
        if prop.type is 'Property'
          addUsedStateField prop.key
        else if (
          prop.type in ['ExperimentalRestProperty', 'RestElement'] and
          classInfo.aliases
        )
          classInfo.aliases.add getName prop.argument

    # Used to record used state fields and new aliases for both
    # AssignmentExpressions and VariableDeclarators.
    handleAssignment = (left, right) ->
      switch left.type
        when 'Identifier'
          if isStateReference(right) and classInfo.aliases
            classInfo.aliases.add left.name
        when 'ObjectPattern'
          if isStateReference right
            handleStateDestructuring left
          else if isThisExpression(right) and classInfo.aliases
            for prop from left.properties then if (
              prop.type is 'Property' and getName(prop.key) is 'state'
            )
              name = getName prop.value
              if name
                classInfo.aliases.add name
              else if prop.value.type is 'ObjectPattern'
                handleStateDestructuring prop.value
        # pass

    reportUnusedFields = ->
      # Report all unused state fields.
      for node from classInfo.stateFields
        name = getName node.key
        unless classInfo.usedStateFields.has name
          context.report node, "Unused state field: '#{name}'"

    ClassDeclaration: (node) ->
      if utils.isES6Component node then classInfo = getInitialClassInfo()

    ObjectExpression: (node) ->
      if utils.isES5Component node then classInfo = getInitialClassInfo()

    'ObjectExpression:exit': (node) ->
      return unless classInfo

      if utils.isES5Component node
        reportUnusedFields()
        classInfo = null

    'ClassDeclaration:exit': ->
      return unless classInfo
      reportUnusedFields()
      classInfo = null

    CallExpression: (node) ->
      return unless classInfo
      # If we're looking at a `this.setState({})` invocation, record all the
      # properties as state fields.
      if (
        node.callee.type is 'MemberExpression' and
        isThisExpression(node.callee.object) and
        getName(node.callee.property) is 'setState' and
        node.arguments.length > 0 and
        node.arguments[0].type is 'ObjectExpression'
      )
        addStateFields node.arguments[0]

    ClassProperty: (node) ->
      return unless classInfo
      # If we see state being assigned as a class property using an object
      # expression, record all the fields of that object as state fields.
      if (
        getName(node.key) is 'state' and
        not node.static and
        node.value and
        node.value.type is 'ObjectExpression'
      )
        addStateFields node.value

      if (
        not node.static and
        node.value and
        node.value.type is 'ArrowFunctionExpression'
      )
        # Create a new set for this.state aliases local to this method.
        classInfo.aliases = new Set()

    'ClassProperty:exit': (node) ->
      if (
        classInfo and
        not node.static and
        node.value and
        node.value.type is 'ArrowFunctionExpression'
      )
        # Forget our set of local aliases.
        classInfo.aliases = null

    MethodDefinition: ->
      return unless classInfo
      # Create a new set for this.state aliases local to this method.
      classInfo.aliases = new Set()

    'MethodDefinition:exit': ->
      return unless classInfo
      # Forget our set of local aliases.
      classInfo.aliases = null

    FunctionExpression: (node) ->
      return unless classInfo

      {parent} = node
      return unless utils.isES5Component parent.parent

      if parent.key.name is 'getInitialState'
        {body} = node.body
        lastBodyNode = body[body.length - 1]

        if (
          lastBodyNode.type is 'ReturnStatement' and
          lastBodyNode.argument.type is 'ObjectExpression'
        )
          addStateFields lastBodyNode.argument
        else if lastBodyNode.expression?.type is 'ObjectExpression'
          addStateFields lastBodyNode.expression
      else
        # Create a new set for this.state aliases local to this method.
        classInfo.aliases = new Set()

    AssignmentExpression: (node) ->
      return unless classInfo
      # Check for assignments like `this.state = {}`
      if (
        node.left.type is 'MemberExpression' and
        isThisExpression(node.left.object) and
        getName(node.left.property) is 'state' and
        node.right.type is 'ObjectExpression'
      )
        # Find the nearest function expression containing this assignment.
        fn = node

        while fn.type isnt 'FunctionExpression' and fn.parent
          fn = fn.parent

        # If the nearest containing function is the constructor, then we want
        # to record all the assigned properties as state fields.
        if (
          fn.parent and
          fn.parent.type is 'MethodDefinition' and
          fn.parent.kind is 'constructor'
        )
          addStateFields node.right
      else
        # Check for assignments like `alias = this.state` and record the alias.
        handleAssignment node.left, node.right

    VariableDeclarator: (node) ->
      return if not classInfo or not node.init
      handleAssignment node.id, node.init

    MemberExpression: (node) ->
      return unless classInfo
      if isStateReference node.object
        # If we see this.state[foo] access, give up.
        if node.computed and node.property.type isnt 'Literal'
          classInfo = null
          return
        # Otherwise, record that we saw this property being accessed.
        addUsedStateField node.property
        # If we see a `this.state` access in a CallExpression, give up.
      else if isStateReference(node) and node.parent.type is 'CallExpression'
        classInfo = null

    JSXSpreadAttribute: (node) ->
      if classInfo and isStateReference node.argument then classInfo = null

    'ExperimentalSpreadProperty, SpreadElement': (node) ->
      if classInfo and isStateReference node.argument then classInfo = null
