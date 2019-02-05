###*
# @fileoverview Rule to flag assignment in a conditional statement's test expression
# @author Stephen Murray <spmurrayzzz>
###
'use strict'

astUtils = require '../eslint-ast-utils'

NODE_DESCRIPTIONS =
  DoWhileStatement: "a 'do...while' statement"
  ForStatement: "a 'for' statement"
  IfStatement: "an 'if' statement"
  WhileStatement: "a 'while' statement"

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow assignment operators in conditional expressions'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-cond-assign'

    schema: [enum: ['except-parens', 'always']]

    messages:
      unexpected: 'Unexpected assignment within {{type}}.'

      # must match JSHint's error message
      missing:
        'Expected a conditional expression and instead saw an assignment.'

  create: (context) ->
    prohibitAssign = context.options[0] or 'except-parens'

    sourceCode = context.getSourceCode()

    ###*
    # Check whether an AST node is the test expression for a conditional statement.
    # @param {!Object} node The node to test.
    # @returns {boolean} `true` if the node is the text expression for a conditional statement; otherwise, `false`.
    ###
    isConditionalTestExpression = (node) ->
      node.parent?.test and node is node.parent.test

    ###*
    # Given an AST node, perform a bottom-up search for the first ancestor that represents a conditional statement.
    # @param {!Object} node The node to use at the start of the search.
    # @returns {?Object} The closest ancestor node that represents a conditional statement.
    ###
    findConditionalAncestor = (node) ->
      currentAncestor = node

      return currentAncestor.parent if isConditionalTestExpression(
        currentAncestor
      )

      while (
        (currentAncestor = currentAncestor.parent) and
        not astUtils.isFunction currentAncestor
      )
        return currentAncestor.parent if isConditionalTestExpression(
          currentAncestor
        )

      null

    ###*
    # Check a conditional statement's test expression for top-level assignments that are not enclosed in parentheses.
    # @param {!Object} node The node for the conditional statement.
    # @returns {void}
    ###
    testForAssign = (node) ->
      if (
        node.test and
        node.test.type is 'AssignmentExpression' and
        not astUtils.isParenthesised sourceCode, node.test
      )
        context.report {
          node
          loc: node.test.loc.start
          messageId: 'missing'
        }

    ###*
    # Check whether an assignment expression is descended from a conditional statement's test expression.
    # @param {!Object} node The node for the assignment expression.
    # @returns {void}
    ###
    testForConditionalAncestor = (node) ->
      ancestor = findConditionalAncestor node

      if ancestor
        context.report
          node: ancestor
          messageId: 'unexpected'
          data:
            type: NODE_DESCRIPTIONS[ancestor.type] or ancestor.type

    return {
      AssignmentExpression: testForConditionalAncestor
    } if prohibitAssign is 'always'

    DoWhileStatement: testForAssign
    ForStatement: testForAssign
    IfStatement: testForAssign
    WhileStatement: testForAssign
    ConditionalExpression: testForAssign
