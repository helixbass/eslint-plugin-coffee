###*
# @fileoverview Rule to flag `else` after a `return` in `if`
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

# astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow `else` blocks after `return` statements in `if` statements'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-else-return'

    schema: [
      type: 'object'
      properties:
        allowElseIf:
          type: 'boolean'
      additionalProperties: no
    ]

    # fixable: 'code'

    messages:
      unexpected: "Unnecessary 'else' after 'return'."

  create: (context) ->
    sourceCode = context.getSourceCode()
    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Display the context report if rule is violated
    #
    # @param {Node} node The 'else' node
    # @returns {void}
    ###
    displayReport = (node) ->
      context.report {
        node
        messageId: 'unexpected'
      }

    ###*
    # Check to see if the node is a ReturnStatement
    #
    # @param {Node} node The node being evaluated
    # @returns {boolean} True if node is a return
    ###
    checkForReturn = (node) -> node.type is 'ReturnStatement'

    ###*
    # Naive return checking, does not iterate through the whole
    # BlockStatement because we make the assumption that the ReturnStatement
    # will be the last node in the body of the BlockStatement.
    #
    # @param {Node} node The consequent/alternate node
    # @returns {boolean} True if it has a return
    ###
    naiveHasReturn = (node) ->
      if node.type is 'BlockStatement'
        {body} = node
        lastChildNode = body[body.length - 1]

        return lastChildNode and checkForReturn lastChildNode
      checkForReturn node

    ###*
    # Check to see if the node is valid for evaluation,
    # meaning it has an else.
    #
    # @param {Node} node The node being evaluated
    # @returns {boolean} True if the node is valid
    ###
    hasElse = (node) -> node.alternate and node.consequent

    ###*
    # If the consequent is an IfStatement, check to see if it has an else
    # and both its consequent and alternate path return, meaning this is
    # a nested case of rule violation.  If-Else not considered currently.
    #
    # @param {Node} node The consequent node
    # @returns {boolean} True if this is a nested rule violation
    ###
    checkForIf = (node) ->
      node.type is 'IfStatement' and
      hasElse(node) and
      naiveHasReturn(node.alternate) and
      naiveHasReturn node.consequent

    ###*
    # Check the consequent/body node to make sure it is not
    # a ReturnStatement or an IfStatement that returns on both
    # code paths.
    #
    # @param {Node} node The consequent or body node
    # @param {Node} alternate The alternate node
    # @returns {boolean} `true` if it is a Return/If node that always returns.
    ###
    checkForReturnOrIf = (node) -> checkForReturn(node) or checkForIf node

    ###*
    # Check whether a node returns in every codepath.
    # @param {Node} node The node to be checked
    # @returns {boolean} `true` if it returns on every codepath.
    ###
    alwaysReturns = (node) ->
      # If we have a BlockStatement, check each consequent body node.
      return node.body.some checkForReturnOrIf if node.type is 'BlockStatement'

      ###
      # If not a block statement, make sure the consequent isn't a
      # ReturnStatement or an IfStatement with returns on both paths.
      ###
      checkForReturnOrIf node

    isNested = (childIf) ->
      elseToken = sourceCode.getTokenBefore childIf,
        filter: ({value}) -> value is 'else'
      return yes unless elseToken
      elseToken.loc.start.line < childIf.loc.start.line

    ###*
    # Check the if statement, but don't catch else-if blocks.
    # @returns {void}
    # @param {Node} node The node for the if statement to check
    # @private
    ###
    checkIfWithoutElse = (node) ->
      {parent} = node

      ###
      # Fixing this would require splitting one statement into two, so no error should
      # be reported if this node is in a position where only one statement is allowed.
      ###
      # return unless astUtils.STATEMENT_LIST_PARENTS.has parent.type
      return if (
        parent.type is 'IfStatement' and
        node is parent.alternate and
        not isNested node
      )

      consequents = []
      currentNode = node
      while (
        currentNode.type is 'IfStatement' and
        not (currentNode isnt node and isNested currentNode)
      )
        return unless currentNode.alternate
        consequents.push currentNode.consequent
        {alternate} = currentNode
        currentNode = currentNode.alternate

      if consequents.every alwaysReturns then displayReport alternate

    ###*
    # Check the if statement
    # @returns {void}
    # @param {Node} node The node for the if statement to check
    # @private
    ###
    checkIfWithElse = (node) ->
      {alternate} = node

      ###
      # Fixing this would require splitting one statement into two, so no error should
      # be reported if this node is in a position where only one statement is allowed.
      ###
      # return unless astUtils.STATEMENT_LIST_PARENTS.has parent.type

      if alternate and alwaysReturns node.consequent
        displayReport alternate

    allowElseIf = not (
      context.options[0] and context.options[0].allowElseIf is no
    )

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    'IfStatement:exit':
      if allowElseIf
        checkIfWithoutElse
      else
        checkIfWithElse
