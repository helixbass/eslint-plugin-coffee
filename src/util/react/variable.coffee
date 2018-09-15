###*
# @fileoverview Utility functions for React components detection
# @author Yannick Croissant
###
'use strict'

###*
# Search a particular variable in a list
# @param {Array} variables The variables list.
# @param {Array} name The name of the variable to search.
# @returns {Boolean} True if the variable was found, false if not.
###
findVariable = (variables, name) ->
  variables.some (variable) -> variable.name is name

###*
# Find and return a particular variable in a list
# @param {Array} variables The variables list.
# @param {Array} name The name of the variable to search.
# @returns {Object} Variable if the variable was found, null if not.
###
getVariable = (variables, name) ->
  variables.find (variable) -> variable.name is name

###*
# List all variable in a given scope
#
# Contain a patch for babel-eslint to avoid https://github.com/babel/babel-eslint/issues/21
#
# @param {Object} context The current rule context.
# @returns {Array} The variables list
###
variablesInScope = (context) ->
  scope = context.getScope()
  {variables} = scope

  while scope.type isnt 'global'
    scope = scope.upper
    variables = scope.variables.concat variables
  if scope.childScopes.length
    variables = scope.childScopes[0].variables.concat variables
    if scope.childScopes[0].childScopes.length
      variables = scope.childScopes[0].childScopes[0].variables.concat variables
  variables.reverse()

  variables

###*
# Find a variable by name in the current scope.
# @param {Object} context The current rule context.
# @param  {string} name Name of the variable to look for.
# @returns {ASTNode|null} Return null if the variable could not be found, ASTNode otherwise.
###
findVariableByName = (context, name) ->
  variable = getVariable variablesInScope(context), name

  return null unless (node = variable?.defs[0]?.node)

  return node.right if node.type is 'TypeAlias'

  return node.init if node.init?
  return node.parent.right if (
    node.declaration and node.parent.type is 'AssignmentExpression'
  )
  null

module.exports = {
  findVariable
  findVariableByName
  getVariable
  variablesInScope
}
