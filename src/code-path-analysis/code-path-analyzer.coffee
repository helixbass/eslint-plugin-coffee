###*
# @fileoverview A class of the code path analyzer.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

assert = require 'assert'
CodePath = require './code-path'
CodePathSegment = require './code-path-segment'
IdGenerator = require '../eslint-code-path-analysis-id-generator'
debug = require '../eslint-code-path-analysis-debug-helpers'
astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether or not a given node is a `case` node (not `default` node).
#
# @param {ASTNode} node - A `SwitchCase` node to check.
# @returns {boolean} `true` if the node is a `case` node (not `default` node).
###
isCaseNode = (node) -> Boolean node.test

###*
# Checks whether the given logical operator is taken into account for the code
# path analysis.
#
# @param {string} operator - The operator found in the LogicalExpression node
# @returns {boolean} `true` if the operator is "&&" or "||"
###
isHandledLogicalOperator = (operator) ->
  operator in ['&&', '||', 'and', 'or', '?']

###*
# Checks whether or not a given logical expression node goes different path
# between the `true` case and the `false` case.
#
# @param {ASTNode} node - A node to check.
# @returns {boolean} `true` if the node is a test of a choice statement.
###
isForkingByTrueOrFalse = (node) ->
  {parent} = node

  switch parent.type
    when 'ConditionalExpression', 'IfStatement', 'WhileStatement', 'DoWhileStatement', 'ForStatement'
      parent.test is node
    when 'LogicalExpression'
      isHandledLogicalOperator parent.operator
    else
      no

###*
# Gets the boolean value of a given literal node.
#
# This is used to detect infinity loops (e.g. `while (true) {}`).
# Statements preceded by an infinity loop are unreachable if the loop didn't
# have any `break` statement.
#
# @param {ASTNode} node - A node to get.
# @returns {boolean|undefined} a boolean value if the node is a Literal node,
#   otherwise `undefined`.
###
getBooleanValueIfSimpleConstant = (node) ->
  return Boolean node.value if node.type is 'Literal'
  undefined

###*
# Checks that a given identifier node is a reference or not.
#
# This is used to detect the first throwable node in a `try` block.
#
# @param {ASTNode} node - An Identifier node to check.
# @returns {boolean} `true` if the node is a reference.
###
isIdentifierReference = (node) ->
  {parent} = node

  switch parent.type
    when 'LabeledStatement', 'BreakStatement', 'ContinueStatement', 'ArrayPattern', 'RestElement', 'ImportSpecifier', 'ImportDefaultSpecifier', 'ImportNamespaceSpecifier', 'CatchClause'
      no

    when 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression', 'ClassDeclaration', 'ClassExpression', 'VariableDeclarator'
      parent.id isnt node

    when 'Property', 'MethodDefinition'
      parent.key isnt node or parent.computed or parent.shorthand

    when 'AssignmentPattern'
      parent.key isnt node

    when 'For'
      parent.index isnt node and parent.name isnt node

    else
      yes

###*
# Updates the current segment with the head segment.
# This is similar to local branches and tracking branches of git.
#
# To separate the current and the head is in order to not make useless segments.
#
# In this process, both "onCodePathSegmentStart" and "onCodePathSegmentEnd"
# events are fired.
#
# @param {CodePathAnalyzer} analyzer - The instance.
# @param {ASTNode} node - The current AST node.
# @returns {void}
###
forwardCurrentToHead = ({codePath, emitter}, node) ->
  state = CodePath.getState codePath
  {currentSegments, headSegments} = state
  end = Math.max currentSegments.length, headSegments.length
  # Fires leaving events.
  for i in [0...end]
    currentSegment = currentSegments[i]
    headSegment = headSegments[i]

    if currentSegment isnt headSegment and currentSegment
      debug.dump "onCodePathSegmentEnd #{currentSegment.id}"

      if currentSegment.reachable
        emitter.emit 'onCodePathSegmentEnd', currentSegment, node

  # Update state.
  state.currentSegments = headSegments

  # Fires entering events.
  for i in [0...end]
    currentSegment = currentSegments[i]
    headSegment = headSegments[i]

    if currentSegment isnt headSegment and headSegment
      debug.dump "onCodePathSegmentStart #{headSegment.id}"

      CodePathSegment.markUsed headSegment
      if headSegment.reachable
        emitter.emit 'onCodePathSegmentStart', headSegment, node

###*
# Updates the current segment with empty.
# This is called at the last of functions or the program.
#
# @param {CodePathAnalyzer} analyzer - The instance.
# @param {ASTNode} node - The current AST node.
# @returns {void}
###
leaveFromCurrentSegment = (analyzer, node) ->
  state = CodePath.getState analyzer.codePath
  {currentSegments} = state

  i = 0
  while i < currentSegments.length
    currentSegment = currentSegments[i]

    debug.dump "onCodePathSegmentEnd #{currentSegment.id}"
    if currentSegment.reachable
      analyzer.emitter.emit 'onCodePathSegmentEnd', currentSegment, node
    ++i

  state.currentSegments = []

###*
# Updates the code path due to the position of a given node in the parent node
# thereof.
#
# For example, if the node is `parent.consequent`, this creates a fork from the
# current path.
#
# @param {CodePathAnalyzer} analyzer - The instance.
# @param {ASTNode} node - The current AST node.
# @returns {void}
###
preprocess = ({codePath}, node) ->
  state = CodePath.getState codePath
  {parent} = node

  switch parent.type
    when 'LogicalExpression'
      if parent.right is node and isHandledLogicalOperator parent.operator
        state.makeLogicalRight()

    when 'ConditionalExpression', 'IfStatement'
      ###
      # Fork if this node is at `consequent`/`alternate`.
      # `popForkContext()` exists at `IfStatement:exit` and
      # `ConditionalExpression:exit`.
      ###
      if parent.consequent is node
        state.makeIfConsequent()
      else if parent.alternate is node
        state.makeIfAlternate()

    when 'SwitchCase'
      if parent.consequent[0] is node
        state.makeSwitchCaseBody no, not parent.test

    when 'TryStatement'
      if parent.handler is node
        state.makeCatchBlock()
      else if parent.finalizer is node
        state.makeFinallyBlock()

    when 'WhileStatement'
      if parent.test is node
        state.makeWhileTest getBooleanValueIfSimpleConstant node
      else
        assert parent.body is node
        state.makeWhileBody()

    when 'DoWhileStatement'
      if parent.body is node
        state.makeDoWhileBody()
      else
        assert parent.test is node
        state.makeDoWhileTest getBooleanValueIfSimpleConstant node

    when 'ForStatement'
      if parent.test is node
        state.makeForTest getBooleanValueIfSimpleConstant node
      else if parent.update is node
        state.makeForUpdate()
      else if parent.body is node
        state.makeForBody()

    when 'ForInStatement', 'ForOfStatement'
      if parent.left is node
        state.makeForInOfLeft()
      else if parent.right is node
        state.makeForInOfRight()
      else
        assert parent.body is node
        state.makeForInOfBody()

    when 'For'
      if node in [parent.name, parent.index]
        state.makeForInOfLeft()
      else if parent.source is node
        state.makeForInOfRight()
      else if parent.body is node
        state.makeForInOfBody()

    when 'AssignmentPattern'
      ###
      # Fork if this node is at `right`.
      # `left` is executed always, so it uses the current path.
      # `popForkContext()` exists at `AssignmentPattern:exit`.
      ###
      if parent.right is node
        state.pushForkContext()
        state.forkBypassPath()
        state.forkPath()

getLabel = (node) ->
  return node.parent.label.name if node.parent.type is 'LabeledStatement'
  null

###*
# Updates the code path due to the type of a given node in entering.
#
# @param {CodePathAnalyzer} analyzer - The instance.
# @param {ASTNode} node - The current AST node.
# @returns {void}
###
processCodePathToEnter = (analyzer, node) ->
  {codePath, idGenerator, emitter, onLooped} = analyzer
  state = CodePath.getState codePath if codePath
  {parent} = node

  switch node.type
    when 'Program', 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression'
      if codePath
        # Emits onCodePathSegmentStart events if updated.
        forwardCurrentToHead analyzer, node
        debug.dumpState node, state, no

      # Create the code path of this scope.
      codePath = analyzer.codePath = new CodePath(
        idGenerator.next()
        codePath
        onLooped
      )
      state = CodePath.getState codePath

      # Emits onCodePathStart events.
      debug.dump "onCodePathStart #{codePath.id}"
      emitter.emit 'onCodePathStart', codePath, node

    when 'LogicalExpression'
      if isHandledLogicalOperator node.operator
        state.pushChoiceContext node.operator, isForkingByTrueOrFalse node

    when 'ConditionalExpression', 'IfStatement'
      state.pushChoiceContext 'test', no

    when 'SwitchStatement'
      state.pushSwitchContext node.cases.some(isCaseNode), getLabel node

    when 'TryStatement'
      state.pushTryContext Boolean node.finalizer

    when 'SwitchCase'
      ###
      # Fork if this node is after the 2st node in `cases`.
      # It's similar to `else` blocks.
      # The next `test` node is processed in this path.
      ###
      if parent.discriminant isnt node and parent.cases[0] isnt node
        state.forkPath()

    when 'WhileStatement', 'DoWhileStatement', 'ForStatement', 'ForInStatement', 'ForOfStatement', 'For'
      state.pushLoopContext node.type, getLabel node

    when 'LabeledStatement'
      unless astUtils.isBreakableStatement node.body
        state.pushBreakContext no, node.label.name

  # Emits onCodePathSegmentStart events if updated.
  forwardCurrentToHead analyzer, node
  debug.dumpState node, state, no

###*
# Updates the code path due to the type of a given node in leaving.
#
# @param {CodePathAnalyzer} analyzer - The instance.
# @param {ASTNode} node - The current AST node.
# @returns {void}
###
processCodePathToExit = (analyzer, node) ->
  {codePath} = analyzer
  state = CodePath.getState codePath
  dontForward = no

  switch node.type
    when 'IfStatement', 'ConditionalExpression'
      state.popChoiceContext()

    when 'LogicalExpression'
      if isHandledLogicalOperator node.operator then state.popChoiceContext()

    when 'SwitchStatement'
      state.popSwitchContext()

    when 'SwitchCase'
      ###
      # This is the same as the process at the 1st `consequent` node in
      # `preprocess` function.
      # Must do if this `consequent` is empty.
      ###
      if node.consequent.length is 0
        state.makeSwitchCaseBody yes, not node.test
      unless (
        node.trailing? # preserve JS compatibility
      )
        if state.forkContext.reachable then dontForward = yes

      # implicit BreakStatement
      if node.trailing
        forwardCurrentToHead analyzer, node
        state.makeBreak node.label?.name
        dontForward = yes

    when 'TryStatement'
      state.popTryContext()

    when 'BreakStatement'
      forwardCurrentToHead analyzer, node
      state.makeBreak node.label?.name
      dontForward = yes

    when 'ContinueStatement'
      forwardCurrentToHead analyzer, node
      state.makeContinue node.label?.name
      dontForward = yes

    when 'ReturnStatement'
      forwardCurrentToHead analyzer, node
      state.makeReturn()
      dontForward = yes

    when 'ThrowStatement'
      forwardCurrentToHead analyzer, node
      state.makeThrow()
      dontForward = yes

    when 'Identifier'
      if isIdentifierReference node
        state.makeFirstThrowablePathInTryBlock()
        dontForward = yes

    when 'CallExpression', 'MemberExpression', 'NewExpression'
      state.makeFirstThrowablePathInTryBlock()

    when 'WhileStatement', 'DoWhileStatement', 'ForStatement', 'ForInStatement', 'ForOfStatement', 'For'
      state.popLoopContext()

    when 'AssignmentPattern'
      state.popForkContext()

    when 'LabeledStatement'
      unless astUtils.isBreakableStatement node.body
        state.popBreakContext()

  # Emits onCodePathSegmentStart events if updated.
  unless dontForward then forwardCurrentToHead analyzer, node
  debug.dumpState node, state, yes

###*
# Updates the code path to finalize the current code path.
#
# @param {CodePathAnalyzer} analyzer - The instance.
# @param {ASTNode} node - The current AST node.
# @returns {void}
###
postprocess = (analyzer, node) ->
  switch node.type
    when 'Program', 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression'
      {codePath} = analyzer

      # Mark the current path as the final node.
      CodePath.getState(codePath).makeFinal()

      # Emits onCodePathSegmentEnd event of the current segments.
      leaveFromCurrentSegment analyzer, node

      # Emits onCodePathEnd event of this code path.
      debug.dump "onCodePathEnd #{codePath.id}"
      analyzer.emitter.emit 'onCodePathEnd', codePath, node
      debug.dumpDot codePath

      codePath = analyzer.codePath = analyzer.codePath.upper
      if codePath then debug.dumpState node, CodePath.getState(codePath), yes

#------------------------------------------------------------------------------
# Public Interface
#------------------------------------------------------------------------------

###*
# The class to analyze code paths.
# This class implements the EventGenerator interface.
###
class CodePathAnalyzer
  ###*
  # @param {EventGenerator} eventGenerator - An event generator to wrap.
  ###
  constructor: (eventGenerator) ->
    @original = eventGenerator
    @emitter = eventGenerator.emitter
    @codePath = null
    @idGenerator = new IdGenerator 's'
    @currentNode = null

  ###*
  # Does the process to enter a given AST node.
  # This updates state of analysis and calls `enterNode` of the wrapped.
  #
  # @param {ASTNode} node - A node which is entering.
  # @returns {void}
  ###
  enterNode: (node) ->
    @currentNode = node

    # Updates the code path due to node's position in its parent node.
    if node.parent then preprocess @, node

    ###
    # Updates the code path.
    # And emits onCodePathStart/onCodePathSegmentStart events.
    ###
    processCodePathToEnter @, node

    # Emits node events.
    @original.enterNode node

    @currentNode = null

  ###*
  # Does the process to leave a given AST node.
  # This updates state of analysis and calls `leaveNode` of the wrapped.
  #
  # @param {ASTNode} node - A node which is leaving.
  # @returns {void}
  ###
  leaveNode: (node) ->
    @currentNode = node

    ###
    # Updates the code path.
    # And emits onCodePathStart/onCodePathSegmentStart events.
    ###
    processCodePathToExit @, node

    # Emits node events.
    @original.leaveNode node

    # Emits the last onCodePathStart/onCodePathSegmentStart events.
    postprocess @, node

    @currentNode = null

  ###*
  # This is called on a code path looped.
  # Then this raises a looped event.
  #
  # @param {CodePathSegment} fromSegment - A segment of prev.
  # @param {CodePathSegment} toSegment - A segment of next.
  # @returns {void}
  ###
  onLooped: (fromSegment, toSegment) =>
    if fromSegment.reachable and toSegment.reachable
      debug.dump "onCodePathSegmentLoop #{fromSegment.id} -> #{toSegment.id}"
      @emitter.emit(
        'onCodePathSegmentLoop'
        fromSegment
        toSegment
        @currentNode
      )

module.exports = CodePathAnalyzer
