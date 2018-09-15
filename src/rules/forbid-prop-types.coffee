###*
# @fileoverview Forbid certain propTypes
###
'use strict'

variableUtil = require '../util/react/variable'
propsUtil = require '../util/react/props'
astUtil = require '../util/react/ast'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

DEFAULTS = ['any', 'array', 'object']

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Forbid certain propTypes'
      category: 'Best Practices'
      recommended: no
      url: docsUrl 'forbid-prop-types'

    schema: [
      type: 'object'
      properties:
        forbid:
          type: 'array'
          items:
            type: 'string'
        checkContextTypes:
          type: 'boolean'
        checkChildContextTypes:
          type: 'boolean'
      additionalProperties: yes
    ]

  create: (context) ->
    propWrapperFunctions = new Set context.settings.propWrapperFunctions or []
    configuration = context.options[0] or {}
    checkContextTypes = configuration.checkContextTypes or no
    checkChildContextTypes = configuration.checkChildContextTypes or no

    isForbidden = (type) ->
      forbid = configuration.forbid or DEFAULTS
      forbid.indexOf(type) >= 0

    shouldCheckContextTypes = (node) ->
      return yes if (
        checkContextTypes and propsUtil.isContextTypesDeclaration node
      )
      no

    shouldCheckChildContextTypes = (node) ->
      return yes if (
        checkChildContextTypes and propsUtil.isChildContextTypesDeclaration node
      )
      no

    ###*
    # Checks if propTypes declarations are forbidden
    # @param {Array} declarations The array of AST nodes being checked.
    # @returns {void}
    ###
    checkProperties = (declarations) ->
      declarations.forEach (declaration) ->
        return unless declaration.type is 'Property'
        {value} = declaration
        if (
          value.type is 'MemberExpression' and
          value.property and
          value.property.name and
          value.property.name is 'isRequired'
        )
          value = value.object
        if (
          value.type is 'CallExpression' and
          value.callee.type is 'MemberExpression'
        )
          value = value.callee
        if value.property
          target = value.property.name
        else if value.type is 'Identifier'
          target = value.name
        if isForbidden target
          context.report
            node: declaration
            message: "Prop type `#{target}` is forbidden"

    checkNode = (node) ->
      switch node?.type
        when 'ObjectExpression'
          checkProperties node.properties
        when 'Identifier'
          propTypesObject = variableUtil.findVariableByName context, node.name
          if propTypesObject?.properties
            checkProperties propTypesObject.properties
        when 'CallExpression'
          innerNode = node.arguments?[0]
          if propWrapperFunctions.has(node.callee.name) and innerNode
            checkNode innerNode

    ClassProperty: (node) ->
      return if (
        not propsUtil.isPropTypesDeclaration(node) and
        not shouldCheckContextTypes(node) and
        not shouldCheckChildContextTypes node
      )
      checkNode node.value

    MemberExpression: (node) ->
      return if (
        not propsUtil.isPropTypesDeclaration(node) and
        not shouldCheckContextTypes(node) and
        not shouldCheckChildContextTypes node
      )

      checkNode node.parent.right

    MethodDefinition: (node) ->
      return if (
        not propsUtil.isPropTypesDeclaration(node) and
        not shouldCheckContextTypes(node) and
        not shouldCheckChildContextTypes node
      )

      returnStatement = astUtil.findReturnStatement node

      if returnStatement?.argument then checkNode returnStatement.argument

    ObjectExpression: (node) ->
      node.properties.forEach (property) ->
        return unless property.key

        return if (
          not propsUtil.isPropTypesDeclaration(property) and
          not shouldCheckContextTypes(property) and
          not shouldCheckChildContextTypes property
        )
        if property.value.type is 'ObjectExpression'
          checkProperties property.value.properties
