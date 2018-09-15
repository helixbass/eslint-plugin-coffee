###*
# @fileoverview Utility functions for props
###
'use strict'

astUtil = require './ast'

isPropertyOnClassBody = (node) ->
  node?.type is 'Property' and
  node.parent.type is 'ObjectExpression' and
  node.parent.parent.type is 'ExpressionStatement' and
  node.parent.parent.parent.type is 'ClassBody'

###*
# Checks if the Identifier node passed in looks like a propTypes declaration.
# @param {ASTNode} node The node to check. Must be an Identifier node.
# @returns {Boolean} `true` if the node is a propTypes declaration, `false` if not
###
isPropTypesDeclaration = (node) ->
  if node and node.type is 'ClassProperty'
    # Flow support
    return yes if node.typeAnnotation and node.key.name is 'props'
  return no if isPropertyOnClassBody node
  astUtil.getPropertyName(node) is 'propTypes'

###*
# Checks if the node passed in looks like a contextTypes declaration.
# @param {ASTNode} node The node to check.
# @returns {Boolean} `true` if the node is a contextTypes declaration, `false` if not
###
isContextTypesDeclaration = (node) ->
  if node and node.type is 'ClassProperty'
    # Flow support
    return yes if node.typeAnnotation and node.key.name is 'context'
  return no if isPropertyOnClassBody node
  astUtil.getPropertyName(node) is 'contextTypes'

###*
# Checks if the node passed in looks like a childContextTypes declaration.
# @param {ASTNode} node The node to check.
# @returns {Boolean} `true` if the node is a childContextTypes declaration, `false` if not
###
isChildContextTypesDeclaration = (node) ->
  return no if isPropertyOnClassBody node
  astUtil.getPropertyName(node) is 'childContextTypes'

###*
# Checks if the Identifier node passed in looks like a defaultProps declaration.
# @param {ASTNode} node The node to check. Must be an Identifier node.
# @returns {Boolean} `true` if the node is a defaultProps declaration, `false` if not
###
isDefaultPropsDeclaration = (node) ->
  return no if isPropertyOnClassBody node
  propName = astUtil.getPropertyName node
  propName in ['defaultProps', 'getDefaultProps']

###*
# Checks if the PropTypes MemberExpression node passed in declares a required propType.
# @param {ASTNode} propTypeExpression node to check. Must be a `PropTypes` MemberExpression.
# @returns {Boolean} `true` if this PropType is required, `false` if not.
###
isRequiredPropType = (propTypeExpression) ->
  propTypeExpression.type is 'MemberExpression' and
  propTypeExpression.property.name is 'isRequired'

module.exports = {
  isPropTypesDeclaration
  isContextTypesDeclaration
  isChildContextTypesDeclaration
  isDefaultPropsDeclaration
  isRequiredPropType
}
