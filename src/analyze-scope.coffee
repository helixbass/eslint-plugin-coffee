escope = require 'eslint-scope'
{Definition} = require 'eslint-scope/lib/definition'
OriginalReferencer = require 'eslint-scope/lib/referencer'
Reference = require 'eslint-scope/lib/reference'
# PatternVisitor = require 'eslint-scope/lib/pattern-visitor'

class Referencer extends OriginalReferencer
  visitClass: (node) ->
    if node.id?.declaration
      @currentScope().__define(
        node.id
        new Definition 'ClassName', node.id, node, null, null, null
      )

    @visit node.superClass

    @scopeManager.__nestClassScope node

    if node.id
      @currentScope().__define(
        node.id
        new Definition 'ClassName', node.id, node
      )
      @visit node.id

    @visit node.body
    @close node

  markDoIifeParamsAsRead: (node) ->
    for param in node.params when param.type isnt 'AssignmentPattern'
      @visit param

  visitFunction: (node) ->
    @markDoIifeParamsAsRead node if (
      # node.parent.type is 'UnaryExpression' and node.parent.operator is 'do'
      node._isDoIife
    )
    super node

  UnaryExpression: (node) ->
    isDoIife =
      node.operator is 'do' and node.argument.type is 'FunctionExpression'
    node.argument._isDoIife = yes if isDoIife
    @visitChildren node
    delete node.argument._isDoIife if isDoIife

  OptionalMemberExpression: (node) ->
    @visit node.object
    @visit node.property if node.computed

  OptionalCallExpression: (node) ->
    {callee} = node
    if (
      not @scopeManager.__ignoreEval() and
      callee.type is 'Identifier' and
      callee.name is 'eval'
    )
      @currentScope().variableScope.__detectEval()
    @visitChildren node

  AssignmentExpression: (node) ->
    # @visit node.left if node.left.type is 'Identifier'
    @visitPattern node.left, (identifier) =>
      @_createScopeVariable identifier if identifier.declaration

    super node

  For: (node) ->
    visitForVariable = (identifier) =>
      @_createScopeVariable identifier if identifier.declaration
      @currentScope().__referencing(
        identifier
        Reference.WRITE
        node.source
        null
        yes
        yes
      )

    @visitPattern node.name, visitForVariable
    @visitPattern node.index, visitForVariable
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
      new Definition(
        'Variable'
        node
        node
        # TODO: shouldBeStatically() in eslint-scope/lib/scope.js is breaking
        # if a Variable Definition doesn't have a parent
        # so for now passing `node` but don't know what the implications are
        node
        null
        null
      )
    )

  ClassProperty: (node) ->
    @visitProperty node

  ClassPrototypeProperty: (node) ->
    @visitProperty node

class ScopeManager extends escope.ScopeManager
  # catch variables belong to outer scope in Coffeescript so don't create a
  # separate "catch scope" for the catch variables.
  __nestCatchScope: ->
    @__currentScope

module.exports = (ast, parserOptions) ->
  options =
    fallback: 'iteration'
    sourceType: ast.sourceType
    ecmaVersion: parserOptions.ecmaVersion or 2018 # TODO: what should this be? breaks without
    ignoreEval: yes
  scopeManager = new ScopeManager options
  referencer = new Referencer options, scopeManager
  # dump {ast}
  referencer.visit ast
  scopeManager

# dump = (obj) ->
#   console.log require('util').inspect obj, no, null
