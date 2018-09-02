###*
# @fileoverview Rule to disallow uses of await inside of loops.
# @author Nat Mote (nmote)
###
'use strict'

###*
# Check whether it should stop traversing ancestors at the given node.
# @param {ASTNode} node A node to check.
# @returns {boolean} `true` if it should stop traversing.
###
isBoundary = (node) ->
  t = node.type

  t in [
    'FunctionDeclaration'
    'FunctionExpression'
    'ArrowFunctionExpression'
  ] or
    ###
    # Don't report the await expressions on for-await-of loop since it's
    # asynchronous iteration intentionally.
    ###
    (t is 'For' and node.await is yes)

###*
# Check whether the given node is in loop.
# @param {ASTNode} node A node to check.
# @param {ASTNode} parent A parent node to check.
# @returns {boolean} `true` if the node is in loop.
###
isLooped = (node, parent) ->
  switch parent.type
    when 'For'
      return node is parent.body

    when 'WhileStatement'
      return node in [parent.test, parent.body]

    else
      return no

module.exports =
  meta:
    docs:
      description: 'disallow `await` inside of loops'
      category: 'Possible Errors'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-await-in-loop'
    schema: []
    messages:
      unexpectedAwait: 'Unexpected `await` inside a loop.'
  create: (context) ->
    ###*
    # Validate an await expression.
    # @param {ASTNode} awaitNode An AwaitExpression or ForOfStatement node to validate.
    # @returns {void}
    ###
    validate = (awaitNode) ->
      return if awaitNode.type is 'For' and not awaitNode.await

      node = awaitNode
      {parent} = node

      while parent and not isBoundary parent
        if isLooped node, parent
          context.report
            node: awaitNode
            messageId: 'unexpectedAwait'
          return
        node = parent
        {parent} = parent

    AwaitExpression: validate
    For: validate
