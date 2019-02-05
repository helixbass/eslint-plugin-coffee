###*
# @fileoverview Disallow redundant return statements
# @author Teddy Katz
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'
utils = require '../util/ast-utils'
FixTracker = require 'eslint/lib/util/fix-tracker'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Removes the given element from the array.
#
# @param {Array} array - The source array to remove.
# @param {any} element - The target item to remove.
# @returns {void}
###
remove = (array, element) ->
  index = array.indexOf element

  unless index is -1 then array.splice index, 1

###*
# Checks whether it can remove the given return statement or not.
#
# @param {ASTNode} node - The return statement node to check.
# @returns {boolean} `true` if the node is removeable.
###
isRemovable = (node) ->
  return no if (
    node.parent.type is 'BlockStatement' and
    node.parent.parent.type is 'IfStatement' and
    node.parent.body.length is 1 and
    node is node.parent.body[0]
  )
  astUtils.STATEMENT_LIST_PARENTS.has node.parent.type

###*
# Checks whether the given return statement is in a `finally` block or not.
#
# @param {ASTNode} node - The return statement node to check.
# @returns {boolean} `true` if the node is in a `finally` block.
###
isInFinally = (node) ->
  currentNode = node
  while currentNode?.parent and not astUtils.isFunction currentNode
    return yes if (
      currentNode.parent.type is 'TryStatement' and
      currentNode.parent.finalizer is currentNode
    )
    currentNode = currentNode.parent

  no

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow redundant return statements'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-useless-return'
    fixable: 'code'
    schema: []

  create: (context) ->
    segmentInfoMap = new WeakMap()
    usedUnreachableSegments = new WeakSet()
    scopeInfo = null

    ###*
    # Checks whether the given segment is terminated by a return statement or not.
    #
    # @param {CodePathSegment} segment - The segment to check.
    # @returns {boolean} `true` if the segment is terminated by a return statement, or if it's still a part of unreachable.
    ###
    isReturned = (segment) ->
      info = segmentInfoMap.get segment

      not info or info.returned

    ###*
    # Collects useless return statements from the given previous segments.
    #
    # A previous segment may be an unreachable segment.
    # In that case, the information object of the unreachable segment is not
    # initialized because `onCodePathSegmentStart` event is not notified for
    # unreachable segments.
    # This goes to the previous segments of the unreachable segment recursively
    # if the unreachable segment was generated by a return statement. Otherwise,
    # this ignores the unreachable segment.
    #
    # This behavior would simulate code paths for the case that the return
    # statement does not exist.
    #
    # @param {ASTNode[]} uselessReturns - The collected return statements.
    # @param {CodePathSegment[]} prevSegments - The previous segments to traverse.
    # @param {WeakSet<CodePathSegment>} [providedTraversedSegments] A set of segments that have already been traversed in this call
    # @returns {ASTNode[]} `uselessReturns`.
    ###
    getUselessReturns = (
      uselessReturns
      prevSegments
      providedTraversedSegments
    ) ->
      traversedSegments = providedTraversedSegments or new WeakSet()

      for segment from prevSegments
        unless segment.reachable
          unless traversedSegments.has segment
            traversedSegments.add segment
            getUselessReturns(
              uselessReturns
              segment.allPrevSegments.filter isReturned
              traversedSegments
            )
          continue

        uselessReturns.push ...segmentInfoMap.get(segment).uselessReturns

      uselessReturns

    ###*
    # Removes the return statements on the given segment from the useless return
    # statement list.
    #
    # This segment may be an unreachable segment.
    # In that case, the information object of the unreachable segment is not
    # initialized because `onCodePathSegmentStart` event is not notified for
    # unreachable segments.
    # This goes to the previous segments of the unreachable segment recursively
    # if the unreachable segment was generated by a return statement. Otherwise,
    # this ignores the unreachable segment.
    #
    # This behavior would simulate code paths for the case that the return
    # statement does not exist.
    #
    # @param {CodePathSegment} segment - The segment to get return statements.
    # @returns {void}
    ###
    markReturnStatementsOnSegmentAsUsed = (segment) ->
      unless segment.reachable
        usedUnreachableSegments.add segment
        segment.allPrevSegments
        .filter isReturned
        .filter (prevSegment) -> not usedUnreachableSegments.has prevSegment
        .forEach markReturnStatementsOnSegmentAsUsed
        return

      info = segmentInfoMap.get segment

      for node from info.uselessReturns then remove(
        scopeInfo.uselessReturns
        node
      )
      info.uselessReturns = []

    ###*
    # Removes the return statements on the current segments from the useless
    # return statement list.
    #
    # This function will be called at every statement except FunctionDeclaration,
    # BlockStatement, and BreakStatement.
    #
    # - FunctionDeclarations are always executed whether it's returned or not.
    # - BlockStatements do nothing.
    # - BreakStatements go the next merely.
    #
    # @returns {void}
    ###
    markReturnStatementsOnCurrentSegmentsAsUsed = ->
      scopeInfo.codePath.currentSegments.forEach(
        markReturnStatementsOnSegmentAsUsed
      )

    #----------------------------------------------------------------------
    # Public
    #----------------------------------------------------------------------

    # Makes and pushs a new scope information.
    onCodePathStart: (codePath) ->
      scopeInfo = {
        upper: scopeInfo
        uselessReturns: []
        codePath
      }

    # Reports useless return statements if exist.
    onCodePathEnd: ->
      for node from scopeInfo.uselessReturns then context.report {
        node
        loc: node.loc
        message: 'Unnecessary return statement.'
        # eslint-disable-next-line coffee/no-loop-func
        fix: (fixer) ->
          ###
          # Extend the replacement range to include the
          # entire function to avoid conflicting with
          # no-else-return.
          # https://github.com/eslint/eslint/issues/8026
          ###
          return new FixTracker(fixer, context.getSourceCode())
          .retainEnclosingFunction(node)
          .remove node if isRemovable node
          null
      }

      scopeInfo ###:### = scopeInfo.upper

    ###
    # Initializes segments.
    # NOTE: This event is notified for only reachable segments.
    ###
    onCodePathSegmentStart: (segment) ->
      info =
        uselessReturns: getUselessReturns [], segment.allPrevSegments
        returned: no

      # Stores the info.
      segmentInfoMap.set segment, info

    # Adds ReturnStatement node to check whether it's useless or not.
    ReturnStatement: (node) ->
      if node.argument then markReturnStatementsOnCurrentSegmentsAsUsed()
      return if node.argument or utils.isInLoop(node) or isInFinally node

      for segment from scopeInfo.codePath.currentSegments
        info = segmentInfoMap.get segment

        if info
          info.uselessReturns.push node
          info.returned = yes
      scopeInfo.uselessReturns.push node

    ###
    # Registers for all statement nodes except FunctionDeclaration, BlockStatement, BreakStatement.
    # Removes return statements of the current segments from the useless return statement list.
    ###
    ClassDeclaration: markReturnStatementsOnCurrentSegmentsAsUsed
    ContinueStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    DebuggerStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    DoWhileStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    EmptyStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    ExpressionStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    ForInStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    ForOfStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    ForStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    For: markReturnStatementsOnCurrentSegmentsAsUsed
    IfStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    ImportDeclaration: markReturnStatementsOnCurrentSegmentsAsUsed
    LabeledStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    SwitchStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    ThrowStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    TryStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    VariableDeclaration: markReturnStatementsOnCurrentSegmentsAsUsed
    WhileStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    WithStatement: markReturnStatementsOnCurrentSegmentsAsUsed
    ExportNamedDeclaration: markReturnStatementsOnCurrentSegmentsAsUsed
    ExportDefaultDeclaration: markReturnStatementsOnCurrentSegmentsAsUsed
    ExportAllDeclaration: markReturnStatementsOnCurrentSegmentsAsUsed
