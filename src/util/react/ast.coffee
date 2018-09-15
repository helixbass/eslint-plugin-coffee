###*
# @fileoverview Utility functions for AST
###
'use strict'

###*
# Find a return statment in the current node
#
# @param {ASTNode} ASTnode The AST node being checked
###
findReturnStatement = (node) ->
  return no if not node.value?.body?.body and not node.body?.body

  bodyNodes = if node.value then node.value.body.body else node.body.body

  for bodyNode in bodyNodes by -1
    return bodyNode if (
      bodyNode.type is 'ReturnStatement' or
      # bodyNode.returns or
      bodyNode.expression?.returns
    )
  no

###*
# Get node with property's name
# @param {Object} node - Property.
# @returns {Object} Property name node.
###
getPropertyNameNode = (node) ->
  if node.key or ['MethodDefinition', 'Property'].indexOf(node.type) isnt -1
    return node.key
  else
    return node.property if node.type is 'MemberExpression'
  null

###*
# Get properties name
# @param {Object} node - Property.
# @returns {String} Property name.
###
getPropertyName = (node) ->
  nameNode = getPropertyNameNode node
  nameNode?.name ? ''

###*
# Get properties for a given AST node
# @param {ASTNode} node The AST node being checked.
# @returns {Array} Properties array.
###
getComponentProperties = (node) ->
  switch node.type
    when 'ClassDeclaration', 'ClassExpression'
      return node.body.body
    when 'ObjectExpression'
      return node.properties
    else
      return []

###*
# Checks if the node is the first in its line, excluding whitespace.
# @param {Object} context The node to check
# @param {ASTNode} node The node to check
# @return {Boolean} true if it's the first node in its line
###
isNodeFirstInLine = (context, node) ->
  sourceCode = context.getSourceCode()
  token = node
  token = sourceCode.getTokenBefore token
  lines =
    if token.type is 'JSXText'
      token.value.split '\n'
    else
      null
  while token.type is 'JSXText' and /^\s*$/.test lines[lines.length - 1]
    token = sourceCode.getTokenBefore token
    lines =
      if token.type is 'JSXText'
        token.value.split '\n'
      else
        null

  startLine = node.loc.start.line
  endLine = if token then token.loc.end.line else -1
  startLine isnt endLine

###*
# Checks if the node is a function or arrow function expression.
# @param {Object} context The node to check
# @return {Boolean} true if it's a function-like expression
###
isFunctionLikeExpression = (node) ->
  node.type in ['FunctionExpression', 'ArrowFunctionExpression']

module.exports = {
  findReturnStatement
  getPropertyName
  getPropertyNameNode
  getComponentProperties
  isNodeFirstInLine
  isFunctionLikeExpression
}
