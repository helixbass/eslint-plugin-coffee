###*
# @fileoverview Flag shouldComponentUpdate when extending PureComponent
###
'use strict'

Components = require '../util/react/Components'
astUtil = require '../util/react/ast'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
{isDeclarationAssignment} = require '../util/ast-utils'

errorMessage = (node) ->
  "#{node} does not need shouldComponentUpdate when extending React.PureComponent."

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Flag shouldComponentUpdate when extending PureComponent'
      category: 'Possible Errors'
      recommended: no
      url: docsUrl 'no-redundant-should-component-update'
    schema: []

  create: Components.detect (context, components, utils) ->
    ###*
    # Checks for shouldComponentUpdate property
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} Whether or not the property exists.
    ###
    hasShouldComponentUpdate = (node) ->
      properties = astUtil.getComponentProperties node
      properties.some (property) ->
        name = astUtil.getPropertyName property
        name is 'shouldComponentUpdate'

    ###*
    # Get name of node if available
    # @param {ASTNode} node The AST node being checked.
    # @return {String} The name of the node
    ###
    getNodeName = (node) ->
      if node.id
        return node.id.name
      else if node.parent?.id
        return node.parent.id.name
      else if isDeclarationAssignment node.parent
        return node.parent.left.name ? ''
      ''

    ###*
    # Checks for violation of rule
    # @param {ASTNode} node The AST node being checked.
    ###
    checkForViolation = (node) ->
      if utils.isPureComponent node
        hasScu = hasShouldComponentUpdate node
        if hasScu
          className = getNodeName node
          context.report {
            node
            message: errorMessage className
          }

    ClassDeclaration: checkForViolation
    ClassExpression: checkForViolation
