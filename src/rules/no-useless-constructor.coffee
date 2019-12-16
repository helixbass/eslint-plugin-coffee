###*
# @fileoverview Rule to flag the use of redundant constructors in classes.
# @author Alberto Rodríguez
###
'use strict'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether a given array of statements is a single call of `super`.
# @param {ASTNode[]} body An array of statements to check.
# @returns {boolean} `true` if the body is a single call of `super`.
###
isSingleSuperCall = (body) ->
  body.length is 1 and
  body[0].type is 'ExpressionStatement' and
  body[0].expression.type is 'CallExpression' and
  body[0].expression.callee.type is 'Super'

###*
# Checks whether a given node is a pattern which doesn't have any side effects.
# Default parameters and Destructuring parameters can have side effects.
# @param {ASTNode} node A pattern node.
# @returns {boolean} `true` if the node doesn't have any side effects.
###
isSimple = (node) -> node.type in ['Identifier', 'RestElement']

###*
# Checks whether a given array of expressions is `...arguments` or not.
# `super(...arguments)` passes all arguments through.
# @param {ASTNode[]} superArgs An array of expressions to check.
# @returns {boolean} `true` if the superArgs is `...arguments`.
###
isSpreadArguments = (superArgs) ->
  superArgs.length is 1 and
  superArgs[0].type is 'SpreadElement' and
  superArgs[0].argument.type is 'Identifier' and
  superArgs[0].argument.name is 'arguments'

###*
# Checks whether given 2 nodes are identifiers which have the same name or not.
# @param {ASTNode} ctorParam A node to check.
# @param {ASTNode} superArg A node to check.
# @returns {boolean} `true` if the nodes are identifiers which have the same
#      name.
###
isValidIdentifierPair = (ctorParam, superArg) ->
  ctorParam.type is 'Identifier' and
  superArg.type is 'Identifier' and
  ctorParam.name is superArg.name

###*
# Checks whether given 2 nodes are a rest/spread pair which has the same values.
# @param {ASTNode} ctorParam A node to check.
# @param {ASTNode} superArg A node to check.
# @returns {boolean} `true` if the nodes are a rest/spread pair which has the
#      same values.
###
isValidRestSpreadPair = (ctorParam, superArg) ->
  ctorParam.type is 'RestElement' and
  superArg.type is 'SpreadElement' and
  isValidIdentifierPair ctorParam.argument, superArg.argument

###*
# Checks whether given 2 nodes have the same value or not.
# @param {ASTNode} ctorParam A node to check.
# @param {ASTNode} superArg A node to check.
# @returns {boolean} `true` if the nodes have the same value or not.
###
isValidPair = (ctorParam, superArg) ->
  isValidIdentifierPair(ctorParam, superArg) or
  isValidRestSpreadPair ctorParam, superArg

###*
# Checks whether the parameters of a constructor and the arguments of `super()`
# have the same values or not.
# @param {ASTNode} ctorParams The parameters of a constructor to check.
# @param {ASTNode} superArgs The arguments of `super()` to check.
# @returns {boolean} `true` if those have the same values.
###
isPassingThrough = (ctorParams, superArgs) ->
  return no unless ctorParams.length is superArgs.length

  i = 0
  while i < ctorParams.length
    return no unless isValidPair ctorParams[i], superArgs[i]
    ++i

  yes

###*
# Checks whether the constructor body is a redundant super call.
# @param {Array} body constructor body content.
# @param {Array} ctorParams The params to check against super call.
# @returns {boolean} true if the construtor body is redundant
###
isRedundantSuperCall = (body, ctorParams) ->
  isSingleSuperCall(body) and
  ctorParams.every(isSimple) and
  (isSpreadArguments(body[0].expression.arguments) or
    isPassingThrough ctorParams, body[0].expression.arguments)

isThisParam = (param) ->
  current = param
  while current
    switch current.type
      when 'ThisExpression'
        return yes
      when 'MemberExpression'
        current = current.object
      when 'ArrayPattern'
        return (
          (yes for element in current.elements when isThisParam element)
          .length > 0
        )
      when 'ObjectPattern'
        return (
          (yes for property in current.properties when isThisParam property)
          .length > 0
        )
      when 'Property'
        current = current.value
      when 'AssignmentPattern'
        current = current.left
      else
        return no
  no

hasThisParams = (params) ->
  for param in params when isThisParam param
    return yes
  no

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    type: 'suggestion'

    docs:
      description: 'disallow unnecessary constructors'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-useless-constructor'

    schema: []

  create: (context) ->
    ###*
    # Checks whether a node is a redundant constructor
    # @param {ASTNode} node node to check
    # @returns {void}
    ###
    checkForConstructor = (node) ->
      return unless node.kind is 'constructor'

      {body} = node.value.body
      ctorParams = node.value.params
      {superClass} = node.parent.parent

      if (
        if superClass
          isRedundantSuperCall body, ctorParams
        else
          body.length is 0 and not hasThisParams ctorParams
      )
        context.report {
          node
          message: 'Useless constructor.'
        }

    MethodDefinition: checkForConstructor
