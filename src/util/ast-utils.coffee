###*
# @fileoverview Common utils for AST.
# @author Gyandeep Singh
###

'use strict'

astUtils = require '../eslint-ast-utils'
{getStaticPropertyName} = astUtils

anyLoopPattern = /^WhileStatement|For$/

#------------------------------------------------------------------------------
# Public Interface
#------------------------------------------------------------------------------

###*
# Get the precedence level based on the node type
# @param {ASTNode} node node to evaluate
# @returns {int} precedence level
# @private
###
getPrecedence = (node) ->
  switch node.type
    # when 'SequenceExpression'
    #   return 0

    when 'AssignmentExpression' # ,'ArrowFunctionExpression', 'YieldExpression'
      return 1

    # when 'ConditionalExpression'
    #   return 3
    when 'LogicalExpression'
      switch node.operator
        when '?'
          return 3
        when '||', 'or'
          return 4
        when '&&', 'and'
          return 5

        # no default

    ### falls through ###
    when 'BinaryExpression'
      switch node.operator
        when '|'
          return 6
        when '^'
          return 7
        when '&'
          return 8
        when '==', '!=', '===', '!=='
          return 9
        when '<', '<=', '>', '>=', 'in', 'instanceof'
          return 10
        when '<<', '>>', '>>>'
          return 11
        when '+', '-'
          return 12
        when '*', '/', '%'
          return 13
        when '**'
          return 15

        # no default

    ### falls through ###

    # when 'UnaryExpression', 'AwaitExpression'
    #   return 16

    # when 'UpdateExpression'
    #   return 17

    # when 'CallExpression'
    #   return 18

    # when 'NewExpression'
    #   return 19

    # else
    #   return 20

isLoop = (node) ->
  !!(node and anyLoopPattern.test node.type)

isInLoop = (node) ->
  currentNode = node
  while currentNode and not astUtils.isFunction currentNode
    return yes if isLoop currentNode
    currentNode = currentNode.parent
  no

getFunctionName = (node) ->
  return null unless (
    node?.type is 'FunctionExpression' and
    node.parent.type is 'AssignmentExpression' and
    node.parent.left.type is 'Identifier'
  )
  node.parent.left.name

###*
# Gets the name and kind of the given function node.
#
# - `function foo() {}`  .................... `function 'foo'`
# - `(function foo() {})`  .................. `function 'foo'`
# - `(function() {})`  ...................... `function`
# - `function* foo() {}`  ................... `generator function 'foo'`
# - `(function* foo() {})`  ................. `generator function 'foo'`
# - `(function*() {})`  ..................... `generator function`
# - `() => {}`  ............................. `arrow function`
# - `async () => {}`  ....................... `async arrow function`
# - `({ foo: function foo() {} })`  ......... `method 'foo'`
# - `({ foo: function() {} })`  ............. `method 'foo'`
# - `({ ['foo']: function() {} })`  ......... `method 'foo'`
# - `({ [foo]: function() {} })`  ........... `method`
# - `({ foo() {} })`  ....................... `method 'foo'`
# - `({ foo: function* foo() {} })`  ........ `generator method 'foo'`
# - `({ foo: function*() {} })`  ............ `generator method 'foo'`
# - `({ ['foo']: function*() {} })`  ........ `generator method 'foo'`
# - `({ [foo]: function*() {} })`  .......... `generator method`
# - `({ *foo() {} })`  ...................... `generator method 'foo'`
# - `({ foo: async function foo() {} })`  ... `async method 'foo'`
# - `({ foo: async function() {} })`  ....... `async method 'foo'`
# - `({ ['foo']: async function() {} })`  ... `async method 'foo'`
# - `({ [foo]: async function() {} })`  ..... `async method`
# - `({ async foo() {} })`  ................. `async method 'foo'`
# - `({ get foo() {} })`  ................... `getter 'foo'`
# - `({ set foo(a) {} })`  .................. `setter 'foo'`
# - `class A { constructor() {} }`  ......... `constructor`
# - `class A { foo() {} }`  ................. `method 'foo'`
# - `class A { *foo() {} }`  ................ `generator method 'foo'`
# - `class A { async foo() {} }`  ........... `async method 'foo'`
# - `class A { ['foo']() {} }`  ............. `method 'foo'`
# - `class A { *['foo']() {} }`  ............ `generator method 'foo'`
# - `class A { async ['foo']() {} }`  ....... `async method 'foo'`
# - `class A { [foo]() {} }`  ............... `method`
# - `class A { *[foo]() {} }`  .............. `generator method`
# - `class A { async [foo]() {} }`  ......... `async method`
# - `class A { get foo() {} }`  ............. `getter 'foo'`
# - `class A { set foo(a) {} }`  ............ `setter 'foo'`
# - `class A { static foo() {} }`  .......... `static method 'foo'`
# - `class A { static *foo() {} }`  ......... `static generator method 'foo'`
# - `class A { static async foo() {} }`  .... `static async method 'foo'`
# - `class A { static get foo() {} }`  ...... `static getter 'foo'`
# - `class A { static set foo(a) {} }`  ..... `static setter 'foo'`
#
# @param {ASTNode} node - The function node to get.
# @returns {string} The name and kind of the function node.
###
getFunctionNameWithKind = (node) ->
  {parent} = node
  tokens = []

  if parent.type is 'MethodDefinition' and parent.static
    tokens.push 'static'
  if node.async then tokens.push 'async'
  if node.generator then tokens.push 'generator'

  if node.type is 'ArrowFunctionExpression'
    tokens.push 'arrow', 'function'
  else if parent.type in ['Property', 'MethodDefinition']
    return 'constructor' if parent.kind is 'constructor'
    if parent.kind is 'get'
      tokens.push 'getter'
    else if parent.kind is 'set'
      tokens.push 'setter'
    else
      tokens.push 'method'
  else
    tokens.push 'function'

  name = getFunctionName node
  name ?= getStaticPropertyName parent
  tokens.push "'#{name}'" if name

  tokens.join ' '

isIife = (func) ->
  return no unless func?.type is 'FunctionExpression'
  return yes if (
    func.parent.type is 'UnaryExpression' and func.parent.operator is 'do'
  )
  return yes if (
    func.parent.type is 'CallExpression' and func.parent.callee is func
  )
  no

hasIndentedLastLine = ({node, sourceCode}) ->
  return no unless node.loc.start.line < node.loc.end.line
  lastLineText =
    sourceCode.getText()[(node.range[1] - node.loc.end.column)...node.range[1]]
  match = /^\s+/.exec lastLineText
  return no unless match
  lastLineIndent = match[0]
  lastLineIndent.length + 1 > node.loc.start.column

containsDeclaration = (node) ->
  switch node?.type
    when 'Identifier'
      node.declaration
    when 'ObjectPattern'
      for prop in node.properties
        return yes if containsDeclaration prop
      no
    when 'Property'
      containsDeclaration node.value
    when 'RestElement'
      containsDeclaration node.argument
    when 'ArrayPattern'
      for element in node.elements
        return yes if containsDeclaration element
      no
    when 'AssignmentPattern'
      containsDeclaration node.left

isDeclarationAssignment = (node) ->
  return no unless node?.type is 'AssignmentExpression'
  containsDeclaration node.left

isFatArrowFunction = (node) ->
  return unless node?
  {bound, type, parent} = node
  type is 'ArrowFunctionExpression' or
    bound or
    (parent?.type is 'MethodDefinition' and parent.bound)

isBoundMethod = (node) ->
  return unless node?
  {parent} = node
  parent?.type is 'MethodDefinition' and parent.bound

module.exports = {
  getPrecedence
  isInLoop
  getFunctionName
  getFunctionNameWithKind
  isIife
  hasIndentedLastLine
  isDeclarationAssignment
  isFatArrowFunction
  isBoundMethod
}
