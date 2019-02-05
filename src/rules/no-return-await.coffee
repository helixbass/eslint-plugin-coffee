###*
# @fileoverview Disallows unnecessary `return await`
# @author Jordan Harband
###
'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

message = 'Redundant use of `await` on a return value.'

module.exports =
  meta:
    docs:
      description: 'disallow unnecessary `return await`'
      category: 'Best Practices'

      recommended: no

      url: 'https://eslint.org/docs/rules/no-return-await'
    fixable: null
    schema: [
      type: 'object'
      properties:
        implicit:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    {implicit = yes} = context.options[0] ? {}

    ###*
    # Reports a found unnecessary `await` expression.
    # @param {ASTNode} node The node representing the `await` expression to report
    # @returns {void}
    ###
    reportUnnecessaryAwait = (node) ->
      context.report {
        node: context.getSourceCode().getFirstToken(node)
        loc: node.loc
        message
      }

    ###*
    # Determines whether a thrown error from this node will be caught/handled within this function rather than immediately halting
    # this function. For example, a statement in a `try` block will always have an error handler. A statement in
    # a `catch` block will only have an error handler if there is also a `finally` block.
    # @param {ASTNode} node A node representing a location where an could be thrown
    # @returns {boolean} `true` if a thrown error will be caught/handled in this function
    ###
    hasErrorHandler = (node) ->
      ancestor = node

      while not astUtils.isFunction(ancestor) and ancestor.type isnt 'Program'
        return yes if (
          ancestor.parent.type is 'TryStatement' and
          (ancestor is ancestor.parent.block or
            (ancestor is ancestor.parent.handler and ancestor.parent.finalizer))
        )
        ancestor = ancestor.parent
      no

    ###*
    # Checks if a node is placed in tail call position. Once `return` arguments (or arrow function expressions) can be a complex expression,
    # an `await` expression could or could not be unnecessary by the definition of this rule. So we're looking for `await` expressions that are in tail position.
    # @param {ASTNode} node A node representing the `await` expression to check
    # @returns {boolean} The checking result
    ###
    isInTailCallPosition = (node) ->
      return yes if node.returns and implicit
      return yes if node.parent.type is 'ArrowFunctionExpression'
      return not hasErrorHandler node.parent if (
        node.parent.type is 'ReturnStatement'
      )
      return isInTailCallPosition node.parent if (
        node.parent.type is 'ConditionalExpression' and
        node in [node.parent.consequent, node.parent.alternate]
      )
      return isInTailCallPosition node.parent if (
        node.parent.type is 'LogicalExpression' and node is node.parent.right
      )
      return isInTailCallPosition node.parent if (
        node.parent.type is 'SequenceExpression' and
        node is node.parent.expressions[node.parent.expressions.length - 1]
      )
      no

    AwaitExpression: (node) ->
      if isInTailCallPosition(node) and not hasErrorHandler node
        reportUnnecessaryAwait node
