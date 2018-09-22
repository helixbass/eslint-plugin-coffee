###*
# @fileoverview Enforce default props alphabetical sorting
# @author Vladimir Kattsov
###
'use strict'

variableUtil = require '../util/react/variable'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Enforce default props alphabetical sorting'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-sort-default-props'

    schema: [
      type: 'object'
      properties:
        ignoreCase:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    configuration = context.options[0] or {}
    ignoreCase = configuration.ignoreCase or no
    propWrapperFunctions = new Set context.settings.propWrapperFunctions or []

    ###*
    # Get properties name
    # @param {Object} node - Property.
    # @returns {String} Property name.
    ###
    getPropertyName = (node) ->
      if node.key or ['MethodDefinition', 'Property'].indexOf(node.type) isnt -1
        return node.key.name
      else if node.type is 'MemberExpression'
        return node.property.name
        # Special case for class properties
        # (babel-eslint@5 does not expose property name so we have to rely on tokens)
      else if node.type is 'ClassProperty'
        tokens = context.getFirstTokens node, 2
        return (
          if tokens[1] and tokens[1].type is 'Identifier'
            tokens[1].value
          else
            tokens[0].value
        )
      ''

    ###*
    # Checks if the Identifier node passed in looks like a defaultProps declaration.
    # @param   {ASTNode}  node The node to check. Must be an Identifier node.
    # @returns {Boolean}       `true` if the node is a defaultProps declaration, `false` if not
    ###
    isDefaultPropsDeclaration = (node) ->
      propName = getPropertyName node
      propName in ['defaultProps', 'getDefaultProps']

    getKey = (node) -> sourceCode.getText node.key or node.argument

    ###*
    # Find a variable by name in the current scope.
    # @param  {string} name Name of the variable to look for.
    # @returns {ASTNode|null} Return null if the variable could not be found, ASTNode otherwise.
    ###
    findVariableByName = (name) ->
      variable = variableUtil
      .variablesInScope context
      .find (item) -> item.name is name

      return null unless (defNode = variable?.defs[0]?.node)

      return defNode.right if defNode.type is 'TypeAlias'
      return defNode.parent.right if (
        defNode.parent.type is 'AssignmentExpression'
      )

      defNode.init

    ###*
    # Checks if defaultProps declarations are sorted
    # @param {Array} declarations The array of AST nodes being checked.
    # @returns {void}
    ###
    checkSorted = (declarations) ->
      declarations.reduce(
        (prev, curr, idx, decls) ->
          # return decls[idx + 1] if /SpreadProperty$/.test curr.type TODO: this should be ok once transformation happens
          return decls[idx + 1] if /Spread/.test curr.type

          prevPropName = getKey prev
          currentPropName = getKey curr

          if ignoreCase
            prevPropName = prevPropName.toLowerCase()
            currentPropName = currentPropName.toLowerCase()

          if currentPropName < prevPropName
            context.report
              node: curr
              message:
                'Default prop types declarations should be sorted alphabetically'

            return prev

          curr
        declarations[0]
      )

    checkNode = (node) ->
      switch node?.type
        when 'ObjectExpression'
          checkSorted node.properties
        when 'Identifier'
          propTypesObject = findVariableByName node.name
          if propTypesObject?.properties
            checkSorted propTypesObject.properties
        when 'CallExpression'
          innerNode = node.arguments?[0]
          if propWrapperFunctions.has(node.callee.name) and innerNode
            checkNode innerNode

    # --------------------------------------------------------------------------
    # Public API
    # --------------------------------------------------------------------------

    ClassProperty: (node) ->
      return unless isDefaultPropsDeclaration node

      checkNode node.value

    MemberExpression: (node) ->
      return unless isDefaultPropsDeclaration node

      checkNode node.parent.right
