###*
# @fileoverview Rule to flag creation of function inside a loop
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Gets the containing loop node of a specified node.
#
# We don't need to check nested functions, so this ignores those.
# `Scope.through` contains references of nested functions.
#
# @param {ASTNode} node - An AST node to get.
# @returns {ASTNode|null} The containing loop node of the specified node, or
#      `null`.
###
getContainingLoopNode = (node) ->
  currentNode = node
  while currentNode.parent
    {parent} = currentNode

    switch parent.type
      when 'WhileStatement', 'DoWhileStatement'
        return parent

      when 'ForStatement'
        return parent unless parent.init is currentNode

      when 'ForInStatement', 'ForOfStatement'
        return parent unless parent.right is currentNode

      when 'For'
        return parent unless parent.source is currentNode

      when 'ArrowFunctionExpression', 'FunctionExpression', 'FunctionDeclaration'
        return null
    currentNode = currentNode.parent

  # `init` is outside of the loop.
  # `right` is outside of the loop.
  # We don't need to check nested functions.
  null

###*
# Gets the containing loop node of a given node.
# If the loop was nested, this returns the most outer loop.
#
# @param {ASTNode} node - A node to get. This is a loop node.
# @param {ASTNode|null} excludedNode - A node that the result node should not
#      include.
# @returns {ASTNode} The most outer loop node.
###
getTopLoopNode = (node, excludedNode) ->
  border = if excludedNode then excludedNode.range[1] else 0
  retv = node
  containingLoopNode = node

  while containingLoopNode and containingLoopNode.range[0] >= border
    retv = containingLoopNode
    containingLoopNode = getContainingLoopNode containingLoopNode

  retv

###*
# Checks whether a given reference which refers to an upper scope's variable is
# safe or not.
#
# @param {ASTNode} loopNode - A containing loop node.
# @param {eslint-scope.Reference} reference - A reference to check.
# @returns {boolean} `true` if the reference is safe or not.
###
isSafe = (loopNode, reference) ->
  variable = reference.resolved
  definition = variable?.defs[0]
  declaration = definition?.parent
  kind =
    if declaration and declaration.type is 'VariableDeclaration'
      declaration.kind
    else
      ''

  # Variables which are declared by `const` is safe.
  return yes if kind is 'const'

  ###
  # Variables which are declared by `let` in the loop is safe.
  # It's a different instance from the next loop step's.
  ###
  return yes if (
    kind is 'let' and
    declaration.range[0] > loopNode.range[0] and
    declaration.range[1] < loopNode.range[1]
  )

  ###
  # WriteReferences which exist after this border are unsafe because those
  # can modify the variable.
  ###
  border =
    getTopLoopNode(loopNode, if kind is 'let' then declaration else null).range[
      0
    ]

  ###*
  # Checks whether a given reference is safe or not.
  # The reference is every reference of the upper scope's variable we are
  # looking now.
  #
  # It's safeafe if the reference matches one of the following condition.
  # - is readonly.
  # - doesn't exist inside a local function and after the border.
  #
  # @param {eslint-scope.Reference} upperRef - A reference to check.
  # @returns {boolean} `true` if the reference is safe.
  ###
  isSafeReference = (upperRef) ->
    id = upperRef.identifier

    not upperRef.isWrite() or
      (variable.scope.variableScope is upperRef.from.variableScope and
        id.range[0] < border)

  Boolean(variable) and variable.references.every isSafeReference

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow `function` declarations and expressions inside loop statements'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-loop-func'

    schema: []

  create: (context) ->
    ###*
    # Reports functions which match the following condition:
    #
    # - has a loop node in ancestors.
    # - has any references which refers to an unsafe variable.
    #
    # @param {ASTNode} node The AST node to check.
    # @returns {boolean} Whether or not the node is within a loop.
    ###
    checkForLoops = (node) ->
      loopNode = getContainingLoopNode node

      return unless loopNode

      references = context.getScope().through

      if (
        references.length > 0 and
        not references.every isSafe.bind null, loopNode
      )
        context.report {node, message: "Don't make functions within a loop."}

    ArrowFunctionExpression: checkForLoops
    FunctionExpression: checkForLoops
    FunctionDeclaration: checkForLoops
