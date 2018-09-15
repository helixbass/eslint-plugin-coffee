###*
# @fileoverview Prevent missing displayName in a React component definition
# @author Yannick Croissant
###
'use strict'

has = require 'has'
Components = require '../util/react/Components'
astUtil = require '../util/react/ast'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
{isDeclarationAssignment} = require '../util/ast-utils'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Prevent missing displayName in a React component definition'
      category: 'Best Practices'
      recommended: yes
      url: docsUrl 'display-name'

    schema: [
      type: 'object'
      properties:
        ignoreTranspilerName:
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context, components, utils) ->
    config = context.options[0] or {}
    ignoreTranspilerName = config.ignoreTranspilerName or no

    MISSING_MESSAGE = 'Component definition is missing display name'

    ###*
    # Checks if we are declaring a display name
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if we are declaring a display name, false if not.
    ###
    isDisplayNameDeclaration = (node) ->
      switch node.type
        when 'ClassProperty'
          return node.key and node.key.name is 'displayName'
        when 'Identifier'
          return node.name is 'displayName'
        when 'Literal'
          return node.value is 'displayName'
        else
          return no

    ###*
    # Mark a prop type as declared
    # @param {ASTNode} node The AST node being checked.
    ###
    markDisplayNameAsDeclared = (node) ->
      components.set node, hasDisplayName: yes

    ###*
    # Reports missing display name for a given component
    # @param {Object} component The component to process
    ###
    reportMissingDisplayName = (component) ->
      context.report
        node: component.node
        message: MISSING_MESSAGE
        data:
          component: component.name

    ###*
    # Checks if the component have a name set by the transpiler
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if component has a name, false if not.
    ###
    hasTranspilerName = (node) ->
      namedObjectAssignment =
        node.type is 'ObjectExpression' and
        node.parent and
        node.parent.parent and
        node.parent.parent.type is 'AssignmentExpression' and
        (not node.parent.parent.left.object or
          node.parent.parent.left.object.name isnt 'module' or
          node.parent.parent.left.property.name isnt 'exports')
      namedObjectDeclaration =
        node.type is 'ObjectExpression' and
        node.parent and
        node.parent.parent and
        node.parent.parent.type is 'VariableDeclarator'
      namedClass =
        node.type in ['ClassDeclaration', 'ClassExpression'] and
        node.id and
        node.id.name

      namedFunctionDeclaration =
        node.type in ['FunctionDeclaration', 'FunctionExpression'] and
        node.id and
        node.id.name

      namedFunctionExpression =
        astUtil.isFunctionLikeExpression(node) and
        node.parent and
        (node.parent?.type is 'VariableDeclarator' or
          node.parent.method is yes or
          (node.parent.type is 'Property' and
            node is node.parent.value and
            node.parent.parent.type is 'ObjectExpression') or
          (isDeclarationAssignment(node.parent) and node.parent.left.name)) and
        (not node.parent.parent or not utils.isES5Component node.parent.parent)

      return yes if (
        namedObjectAssignment or
        namedObjectDeclaration or
        namedClass or
        namedFunctionDeclaration or
        namedFunctionExpression
      )
      no

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    ClassProperty: (node) ->
      return unless isDisplayNameDeclaration node
      markDisplayNameAsDeclared node

    MemberExpression: (node) ->
      # console.log {node}
      return unless isDisplayNameDeclaration node.property
      component = utils.getRelatedComponent node
      return unless component
      markDisplayNameAsDeclared component.node

    FunctionExpression: (node) ->
      return if ignoreTranspilerName or not hasTranspilerName node
      markDisplayNameAsDeclared node

    FunctionDeclaration: (node) ->
      return if ignoreTranspilerName or not hasTranspilerName node
      markDisplayNameAsDeclared node

    ArrowFunctionExpression: (node) ->
      return if ignoreTranspilerName or not hasTranspilerName node
      markDisplayNameAsDeclared node

    MethodDefinition: (node) ->
      return unless isDisplayNameDeclaration node.key
      markDisplayNameAsDeclared node

    ClassExpression: (node) ->
      return if ignoreTranspilerName or not hasTranspilerName node
      markDisplayNameAsDeclared node

    ClassDeclaration: (node) ->
      return if ignoreTranspilerName or not hasTranspilerName node
      markDisplayNameAsDeclared node

    ObjectExpression: (node) ->
      if ignoreTranspilerName or not hasTranspilerName node
        # Search for the displayName declaration
        node.properties.forEach (property) ->
          return if (
            not property.key or not isDisplayNameDeclaration property.key
          )
          markDisplayNameAsDeclared node
        return
      markDisplayNameAsDeclared node

    'Program:exit': ->
      list = components.list()
      # Report missing display name for all components
      for component of list
        if not has(list, component) or list[component].hasDisplayName
          continue
        reportMissingDisplayName list[component]
