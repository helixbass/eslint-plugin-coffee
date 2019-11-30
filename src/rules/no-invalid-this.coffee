###*
# @fileoverview A rule to disallow `this` keywords outside of classes or class-like objects.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{
  getUpperFunction
  isNullLiteral
  isArrayFromMethod
  isES5Constructor
} = require '../eslint-ast-utils'
{
  # getFunctionName
  isFatArrowFunction
  isBoundMethod
} = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

startsWithUpperCase = (s) ->
  s and s[0] isnt s[0].toLocaleLowerCase()

bindOrCallOrApplyPattern = /^(?:bind|call|apply)$/
arrayMethodPattern = /^(?:every|filter|find|findIndex|forEach|map|some)$/
thisTagPattern = /^[\s*#]*@this/m

# isES5Constructor = (node) ->
#   startsWithUpperCase getFunctionName node

isCallee = (node) ->
  return yes if (
    node.parent.type is 'CallExpression' and node.parent.callee is node
  )
  return yes if (
    node.parent.type is 'UnaryExpression' and node.parent.operator is 'do'
  )
  no

hasJSDocThisTag = (node, sourceCode) ->
  jsdocComment = sourceCode.getJSDocComment node

  return yes if jsdocComment and thisTagPattern.test jsdocComment.value

  sourceCode
  .getCommentsBefore node
  .some (comment) -> thisTagPattern.test comment.value

isNullOrUndefined = (node) ->
  isNullLiteral(node) or
  (node.type is 'Identifier' and node.name is 'undefined') or
  (node.type is 'UnaryExpression' and node.operator is 'void')

isReflectApply = (node) ->
  node.type is 'MemberExpression' and
  node.object.type is 'Identifier' and
  node.object.name is 'Reflect' and
  node.property.type is 'Identifier' and
  node.property.name is 'apply' and
  not node.computed

isMethodWhichHasThisArg = (node) ->
  currentNode = node
  while currentNode.type is 'MemberExpression' and not currentNode.computed
    return arrayMethodPattern.test currentNode.property.name if (
      currentNode.property.type is 'Identifier'
    )
    currentNode = currentNode.property

  no

###*
# Checks whether or not a given function node is the default `this` binding.
#
# First, this checks the node:
#
# - The function name does not start with uppercase (it's a constructor).
# - The function does not have a JSDoc comment that has a @this tag.
#
# Next, this checks the location of the node.
# If the location is below, this judges `this` is valid.
#
# - The location is not on an object literal.
# - The location is not assigned to a variable which starts with an uppercase letter.
# - The location is not on an ES2015 class.
# - Its `bind`/`call`/`apply` method is not called directly.
# - The function is not a callback of array methods (such as `.forEach()`) if `thisArg` is given.
#
# @param {ASTNode} node - A function node to check.
# @param {SourceCode} sourceCode - A SourceCode instance to get comments.
# @returns {boolean} The function node is the default `this` binding.
###
isDefaultThisBinding = (node, sourceCode) ->
  return no if isES5Constructor(node) or hasJSDocThisTag node, sourceCode
  isAnonymous = node.id is null
  currentNode = node

  while currentNode
    {parent} = currentNode

    if currentNode.returns
      func = getUpperFunction parent

      return yes if func is null or not isCallee func
      currentNode = func.parent
      continue

    switch parent.type
      ###
      # Looks up the destination.
      # e.g., obj.foo = nativeFoo || function foo() { ... };
      ###
      when 'LogicalExpression', 'ConditionalExpression'
        currentNode = parent

      ###
      # If the upper function is IIFE, checks the destination of the return value.
      # e.g.
      #   obj.foo = (function() {
      #     // setup...
      #     return function foo() { ... };
      #   })();
      #   obj.foo = (() =>
      #     function foo() { ... }
      #   )();
      ###
      when 'ReturnStatement'
        func = getUpperFunction parent

        return yes if func is null or not isCallee func
        currentNode = func.parent
      when 'FunctionExpression'
        return yes unless parent.bound
        return yes unless currentNode is parent.body and isCallee parent
        currentNode = parent.parent

      ###
      # e.g.
      #   var obj = { foo() { ... } };
      #   var obj = { foo: function() { ... } };
      #   class A { constructor() { ... } }
      #   class A { foo() { ... } }
      #   class A { get foo() { ... } }
      #   class A { set foo() { ... } }
      #   class A { static foo() { ... } }
      ###
      when 'Property', 'MethodDefinition'
        return parent.value isnt currentNode

      ###
      # e.g.
      #   obj.foo = function foo() { ... };
      #   Foo = function() { ... };
      #   [obj.foo = function foo() { ... }] = a;
      #   [Foo = function() { ... }] = a;
      ###
      when 'AssignmentExpression', 'AssignmentPattern'
        return no if parent.left.type is 'MemberExpression'
        return no if (
          isAnonymous and
          parent.left.type is 'Identifier' and
          startsWithUpperCase parent.left.name
        )
        return yes

      ###
      # e.g.
      #   var Foo = function() { ... };
      ###
      when 'VariableDeclarator'
        return not (
          isAnonymous and
          parent.init is currentNode and
          parent.id.type is 'Identifier' and
          startsWithUpperCase parent.id.name
        )

      ###
      # e.g.
      #   var foo = function foo() { ... }.bind(obj);
      #   (function foo() { ... }).call(obj);
      #   (function foo() { ... }).apply(obj, []);
      ###
      when 'MemberExpression'
        return (
          parent.object isnt currentNode or
          parent.property.type isnt 'Identifier' or
          not bindOrCallOrApplyPattern.test(parent.property.name) or
          not isCallee(parent) or
          parent.parent.arguments.length is 0 or
          isNullOrUndefined parent.parent.arguments[0]
        )

      ###
      # e.g.
      #   Reflect.apply(function() {}, obj, []);
      #   Array.from([], function() {}, obj);
      #   list.forEach(function() {}, obj);
      ###
      when 'CallExpression'
        return (
          parent.arguments.length isnt 3 or
          parent.arguments[0] isnt currentNode or
          isNullOrUndefined parent.arguments[1]
        ) if isReflectApply parent.callee
        return (
          parent.arguments.length isnt 3 or
          parent.arguments[1] isnt currentNode or
          isNullOrUndefined parent.arguments[2]
        ) if isArrayFromMethod parent.callee
        return (
          parent.arguments.length isnt 2 or
          parent.arguments[0] isnt currentNode or
          isNullOrUndefined parent.arguments[1]
        ) if isMethodWhichHasThisArg parent.callee
        return yes

      # Otherwise `this` is default.
      else
        return yes

  yes

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow `this` keywords outside of classes or class-like objects'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-invalid-this'

    schema: [
      type: 'object'
      properties:
        fatArrowsOk: type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    stack = []
    sourceCode = context.getSourceCode()
    {fatArrowsOk} = context.options[0] ? {}

    ###*
    # Gets the current checking context.
    #
    # The return value has a flag that whether or not `this` keyword is valid.
    # The flag is initialized when got at the first time.
    #
    # @returns {{valid: boolean}}
    #   an object which has a flag that whether or not `this` keyword is valid.
    ###
    stack.getCurrent = ->
      current = @[@length - 1]

      unless current.init
        current.init = yes
        current.valid =
          if fatArrowsOk and isFatArrowFunction current.node
            yes
          else
            not isDefaultThisBinding current.node, sourceCode
      current

    ###*
    # Pushs new checking context into the stack.
    #
    # The checking context is not initialized yet.
    # Because most functions don't have `this` keyword.
    # When `this` keyword was found, the checking context is initialized.
    #
    # @param {ASTNode} node - A function node that was entered.
    # @returns {void}
    ###
    enterFunction = (node) ->
      return if (
        isFatArrowFunction(node) and
        not isBoundMethod(node) and
        not fatArrowsOk
      )
      # `this` can be invalid only under strict mode.
      stack.push {
        init: not context.getScope().isStrict
        node
        valid: yes
      }

    ###*
    # Pops the current checking context from the stack.
    # @returns {void}
    ###
    exitFunction = (node) ->
      return if isFatArrowFunction node
      stack.pop()

    ###
    # `this` is invalid only under strict mode.
    # Modules is always strict mode.
    ###
    Program: (node) ->
      scope = context.getScope()
      features = context.parserOptions.ecmaFeatures or {}

      stack.push {
        init: yes
        node
        valid: not (
          scope.isStrict or
          node.sourceType is 'module' or
          (features.globalReturn and scope.childScopes[0].isStrict)
        )
      }

    'Program:exit': -> stack.pop()

    FunctionDeclaration: enterFunction
    'FunctionDeclaration:exit': exitFunction
    FunctionExpression: enterFunction
    'FunctionExpression:exit': exitFunction
    ArrowFunctionExpression: enterFunction
    'ArrowFunctionExpression:exit': exitFunction

    # Reports if `this` of the current context is invalid.
    ThisExpression: (node) ->
      current = stack.getCurrent()

      if current and not current.valid
        context.report {node, message: "Unexpected 'this'."}
