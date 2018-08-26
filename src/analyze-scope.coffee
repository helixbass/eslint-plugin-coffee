escope = require 'eslint-scope'
{Definition} = require 'eslint-scope/lib/definition'
OriginalReferencer = require 'eslint-scope/lib/referencer'
# PatternVisitor = require 'eslint-scope/lib/pattern-visitor'

class Referencer extends OriginalReferencer
  AssignmentExpression: (node) ->
    # @visit node.left if node.left.type is 'Identifier'
    @visitPattern node.left, (identifier) =>
      @_createScopeVariable identifier if identifier.declaration

    super node

  For: (node) ->
    @visitPattern node.name, (identifier) =>
      @_createScopeVariable identifier if identifier.declaration
    @visitPattern node.index, (identifier) =>
      @_createScopeVariable identifier if identifier.declaration

    @visitChildren node

  Identifier: (node) ->
    super node unless node.declaration
  # Identifier: (node) ->
  #   dump {node}
  #   @_createScopeVariable node if node.declaration
  #   super node

  _createScopeVariable: (node) ->
    @currentScope().variableScope.__define(
      node
      new Definition 'Variable', node, node, null, null, null
    )

module.exports = (ast, parserOptions) ->
  options =
    fallback: 'iteration'
    sourceType: ast.sourceType
    ecmaVersion: parserOptions.ecmaVersion or 2018
  scopeManager = new escope.ScopeManager options
  referencer = new Referencer options, scopeManager
  # dump {ast}
  referencer.visit ast
  scopeManager

# dump = (obj) ->
#   console.log require('util').inspect obj, no, null
