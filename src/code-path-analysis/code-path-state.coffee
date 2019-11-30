###*
# @fileoverview A class to manage state of generating a code path.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

CodePathSegment = require './code-path-segment'
ForkContext = require './fork-context'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Adds given segments into the `dest` array.
# If the `others` array does not includes the given segments, adds to the `all`
# array as well.
#
# This adds only reachable and used segments.
#
# @param {CodePathSegment[]} dest - A destination array (`returnedSegments` or `thrownSegments`).
# @param {CodePathSegment[]} others - Another destination array (`returnedSegments` or `thrownSegments`).
# @param {CodePathSegment[]} all - The unified destination array (`finalSegments`).
# @param {CodePathSegment[]} segments - Segments to add.
# @returns {void}
###
addToReturnedOrThrown = (dest, others, all, segments) ->
  i = 0
  while i < segments.length
    segment = segments[i]

    dest.push segment
    if others.indexOf(segment) is -1 then all.push segment
    ++i

###*
# Gets a loop-context for a `continue` statement.
#
# @param {CodePathState} state - A state to get.
# @param {string} label - The label of a `continue` statement.
# @returns {LoopContext} A loop-context for a `continue` statement.
###
getContinueContext = (state, label) ->
  return state.loopContext unless label

  context = state.loopContext

  while context
    return context if context.label is label
    context = context.upper

  ### istanbul ignore next: foolproof (syntax error) ###
  null

###*
# Gets a context for a `break` statement.
#
# @param {CodePathState} state - A state to get.
# @param {string} label - The label of a `break` statement.
# @returns {LoopContext|SwitchContext} A context for a `break` statement.
###
getBreakContext = (state, label) ->
  context = state.breakContext

  while context
    return context if (
      if label then context.label is label else context.breakable
    )
    context = context.upper

  ### istanbul ignore next: foolproof (syntax error) ###
  null

###*
# Gets a context for a `return` statement.
#
# @param {CodePathState} state - A state to get.
# @returns {TryContext|CodePathState} A context for a `return` statement.
###
getReturnContext = (state) ->
  context = state.tryContext

  while context
    return context if context.hasFinalizer and context.position isnt 'finally'
    context = context.upper

  state

###*
# Gets a context for a `throw` statement.
#
# @param {CodePathState} state - A state to get.
# @returns {TryContext|CodePathState} A context for a `throw` statement.
###
getThrowContext = (state) ->
  context = state.tryContext

  while context
    return context if (
      context.position is 'try' or
      (context.hasFinalizer and context.position is 'catch')
    )
    context = context.upper

  state

###*
# Removes a given element from a given array.
#
# @param {any[]} xs - An array to remove the specific element.
# @param {any} x - An element to be removed.
# @returns {void}
###
remove = (xs, x) -> xs.splice xs.indexOf(x), 1

###*
# Disconnect given segments.
#
# This is used in a process for switch statements.
# If there is the "default" chunk before other cases, the order is different
# between node's and running's.
#
# @param {CodePathSegment[]} prevSegments - Forward segments to disconnect.
# @param {CodePathSegment[]} nextSegments - Backward segments to disconnect.
# @returns {void}
###
removeConnection = (prevSegments, nextSegments) ->
  i = 0
  while i < prevSegments.length
    prevSegment = prevSegments[i]
    nextSegment = nextSegments[i]

    remove prevSegment.nextSegments, nextSegment
    remove prevSegment.allNextSegments, nextSegment
    remove nextSegment.prevSegments, prevSegment
    remove nextSegment.allPrevSegments, prevSegment
    ++i

###*
# Creates looping path.
#
# @param {CodePathState} state - The instance.
# @param {CodePathSegment[]} unflattenedFromSegments - Segments which are source.
# @param {CodePathSegment[]} unflattenedToSegments - Segments which are destination.
# @returns {void}
###
makeLooped = (state, unflattenedFromSegments, unflattenedToSegments) ->
  fromSegments = CodePathSegment.flattenUnusedSegments unflattenedFromSegments
  toSegments = CodePathSegment.flattenUnusedSegments unflattenedToSegments

  end = Math.min fromSegments.length, toSegments.length

  i = 0
  while i < end
    fromSegment = fromSegments[i]
    toSegment = toSegments[i]

    if toSegment.reachable then fromSegment.nextSegments.push toSegment
    if fromSegment.reachable then toSegment.prevSegments.push fromSegment
    fromSegment.allNextSegments.push toSegment
    toSegment.allPrevSegments.push fromSegment

    if toSegment.allPrevSegments.length >= 2
      CodePathSegment.markPrevSegmentAsLooped toSegment, fromSegment

    state.notifyLooped fromSegment, toSegment
    ++i

###*
# Finalizes segments of `test` chunk of a ForStatement.
#
# - Adds `false` paths to paths which are leaving from the loop.
# - Sets `true` paths to paths which go to the body.
#
# @param {LoopContext} context - A loop context to modify.
# @param {ChoiceContext} choiceContext - A choice context of this loop.
# @param {CodePathSegment[]} head - The current head paths.
# @returns {void}
###
finalizeTestSegmentsOfFor = (context, choiceContext, head) ->
  unless choiceContext.processed
    choiceContext.trueForkContext.add head
    choiceContext.falseForkContext.add head

  unless context.test is yes
    context.brokenForkContext.addAll choiceContext.falseForkContext
  context.endOfTestSegments = choiceContext.trueForkContext.makeNext 0, -1

#------------------------------------------------------------------------------
# Public Interface
#------------------------------------------------------------------------------

###*
# A class which manages state to analyze code paths.
###
class CodePathState
  ###*
  # @param {IdGenerator} idGenerator - An id generator to generate id for code
  #   path segments.
  # @param {Function} onLooped - A callback function to notify looping.
  ###
  constructor: (@idGenerator, @notifyLooped) ->
    @forkContext = ForkContext.newRoot @idGenerator
    @choiceContext = null
    @switchContext = null
    @tryContext = null
    @loopContext = null
    @breakContext = null

    @currentSegments = []
    @initialSegment = @forkContext.head[0]

    # returnedSegments and thrownSegments push elements into finalSegments also.
    final = @finalSegments = []
    returned = @returnedForkContext = []
    thrown = @thrownForkContext = []

    returned.add = addToReturnedOrThrown.bind null, returned, thrown, final
    thrown.add = addToReturnedOrThrown.bind null, thrown, returned, final

  ###*
  # Creates and stacks new forking context.
  #
  # @param {boolean} forkLeavingPath - A flag which shows being in a
  #   "finally" block.
  # @returns {ForkContext} The created context.
  ###
  pushForkContext: (forkLeavingPath) ->
    @forkContext = ForkContext.newEmpty @forkContext, forkLeavingPath

    @forkContext

  ###*
  # Pops and merges the last forking context.
  # @returns {ForkContext} The last context.
  ###
  popForkContext: ->
    lastContext = @forkContext

    @forkContext = lastContext.upper
    @forkContext.replaceHead lastContext.makeNext 0, -1

    lastContext

  ###*
  # Creates a new path.
  # @returns {void}
  ###
  forkPath: -> @forkContext.add @parentForkContext.makeNext -1, -1

  ###*
  # Creates a bypass path.
  # This is used for such as IfStatement which does not have "else" chunk.
  #
  # @returns {void}
  ###
  forkBypassPath: -> @forkContext.add @parentForkContext.head

  #--------------------------------------------------------------------------
  # ConditionalExpression, LogicalExpression, IfStatement
  #--------------------------------------------------------------------------

  ###*
  # Creates a context for ConditionalExpression, LogicalExpression,
  # IfStatement, WhileStatement, DoWhileStatement, or ForStatement.
  #
  # LogicalExpressions have cases that it goes different paths between the
  # `true` case and the `false` case.
  #
  # For Example:
  #
  #     if (a || b) {
  #         foo();
  #     } else {
  #         bar();
  #     }
  #
  # In this case, `b` is evaluated always in the code path of the `else`
  # block, but it's not so in the code path of the `if` block.
  # So there are 3 paths.
  #
  #     a -> foo();
  #     a -> b -> foo();
  #     a -> b -> bar();
  #
  # @param {string} kind - A kind string.
  #   If the new context is LogicalExpression's, this is `"&&"` or `"||"`.
  #   If it's IfStatement's or ConditionalExpression's, this is `"test"`.
  #   Otherwise, this is `"loop"`.
  # @param {boolean} isForkingAsResult - A flag that shows that goes different
  #   paths between `true` and `false`.
  # @returns {void}
  ###
  pushChoiceContext: (kind, isForkingAsResult) ->
    @choiceContext = {
      upper: @choiceContext
      kind
      isForkingAsResult
      trueForkContext: ForkContext.newEmpty @forkContext
      falseForkContext: ForkContext.newEmpty @forkContext
      processed: no
    }

  ###*
  # Pops the last choice context and finalizes it.
  #
  # @returns {ChoiceContext} The popped context.
  ###
  popChoiceContext: ->
    context = @choiceContext
    {
      trueForkContext
      falseForkContext
      processed
      upper
      kind
      isForkingAsResult
    } = context

    @choiceContext = upper

    {forkContext} = @
    headSegments = forkContext.head

    switch kind
      when '&&', '||', 'and', 'or', '?'
        ###
        # If any result were not transferred from child contexts,
        # this sets the head segments to both cases.
        # The head segments are the path of the right-hand operand.
        ###
        unless processed
          trueForkContext.add headSegments
          falseForkContext.add headSegments

        ###
        # Transfers results to upper context if this context is in
        # test chunk.
        ###
        if isForkingAsResult
          parentContext = @choiceContext

          parentContext.trueForkContext.addAll trueForkContext
          parentContext.falseForkContext.addAll falseForkContext
          parentContext.processed = yes

          return context

      when 'test'
        unless processed
          ###
          # The head segments are the path of the `if` block here.
          # Updates the `true` path with the end of the `if` block.
          ###
          trueForkContext.clear()
          trueForkContext.add headSegments
        else
          ###
          # The head segments are the path of the `else` block here.
          # Updates the `false` path with the end of the `else`
          # block.
          ###
          falseForkContext.clear()
          falseForkContext.add headSegments

      when 'loop'
        ###
        # Loops are addressed in popLoopContext().
        # This is called from popLoopContext().
        ###
        return context

      ### istanbul ignore next ###
      else
        throw new Error 'unreachable'

    # Merges all paths.
    prevForkContext = trueForkContext

    prevForkContext.addAll falseForkContext
    forkContext.replaceHead prevForkContext.makeNext 0, -1

    context

  ###*
  # Makes a code path segment of the right-hand operand of a logical
  # expression.
  #
  # @returns {void}
  ###
  makeLogicalRight: ->
    {choiceContext: context, forkContext} = @

    if context.processed
      ###
      # This got segments already from the child choice context.
      # Creates the next path from own true/false fork context.
      ###
      prevForkContext =
        if context.kind in ['&&', 'and']
          context.trueForkContext
        ### kind === "||" ###
        else
          context.falseForkContext

      forkContext.replaceHead prevForkContext.makeNext 0, -1
      prevForkContext.clear()

      context.processed = no
    else
      ###
      # This did not get segments from the child choice context.
      # So addresses the head segments.
      # The head segments are the path of the left-hand operand.
      ###
      if context.kind in ['&&', 'and']
        # The path does short-circuit if false.
        context.falseForkContext.add forkContext.head
      else
        # The path does short-circuit if true.
        context.trueForkContext.add forkContext.head

      forkContext.replaceHead forkContext.makeNext -1, -1

  ###*
  # Makes a code path segment of the `if` block.
  #
  # @returns {void}
  ###
  makeIfConsequent: ->
    {choiceContext: context, forkContext} = @
    {processed, trueForkContext, falseForkContext} = context
    {head} = forkContext

    ###
    # If any result were not transferred from child contexts,
    # this sets the head segments to both cases.
    # The head segments are the path of the test expression.
    ###
    unless processed
      trueForkContext.add head
      falseForkContext.add head

    context.processed = no

    # Creates new path from the `true` case.
    forkContext.replaceHead trueForkContext.makeNext 0, -1

  ###*
  # Makes a code path segment of the `else` block.
  #
  # @returns {void}
  ###
  makeIfAlternate: ->
    {choiceContext: context, forkContext} = @
    {trueForkContext, falseForkContext} = context
    {head} = forkContext

    ###
    # The head segments are the path of the `if` block.
    # Updates the `true` path with the end of the `if` block.
    ###
    trueForkContext.clear()
    trueForkContext.add head
    context.processed = yes

    # Creates new path from the `false` case.
    forkContext.replaceHead falseForkContext.makeNext 0, -1

  #--------------------------------------------------------------------------
  # SwitchStatement
  #--------------------------------------------------------------------------

  ###*
  # Creates a context object of SwitchStatement and stacks it.
  #
  # @param {boolean} hasCase - `true` if the switch statement has one or more
  #   case parts.
  # @param {string|null} label - The label text.
  # @returns {void}
  ###
  pushSwitchContext: (hasCase, label) ->
    @switchContext = {
      upper: @switchContext
      hasCase
      defaultSegments: null
      defaultBodySegments: null
      foundDefault: no
      lastIsDefault: no
      countForks: 0
    }

    @pushBreakContext yes, label

  ###*
  # Pops the last context of SwitchStatement and finalizes it.
  #
  # - Disposes all forking stack for `case` and `default`.
  # - Creates the next code path segment from `context.brokenForkContext`.
  # - If the last `SwitchCase` node is not a `default` part, creates a path
  #   to the `default` body.
  #
  # @returns {void}
  ###
  popSwitchContext: ->
    context = @switchContext

    @switchContext = context.upper

    {forkContext} = @
    {brokenForkContext} = @popBreakContext()

    if context.countForks is 0
      ###
      # When there is only one `default` chunk and there is one or more
      # `break` statements, even if forks are nothing, it needs to merge
      # those.
      ###
      unless brokenForkContext.empty
        brokenForkContext.add forkContext.makeNext -1, -1
        forkContext.replaceHead brokenForkContext.makeNext 0, -1

      return

    lastSegments = forkContext.head

    @forkBypassPath()
    lastCaseSegments = forkContext.head

    ###
    # `brokenForkContext` is used to make the next segment.
    # It must add the last segment into `brokenForkContext`.
    ###
    brokenForkContext.add lastSegments

    ###
    # A path which is failed in all case test should be connected to path
    # of `default` chunk.
    ###
    unless context.lastIsDefault
      if context.defaultBodySegments
        ###
        # Remove a link from `default` label to its chunk.
        # It's false route.
        ###
        removeConnection context.defaultSegments, context.defaultBodySegments
        makeLooped @, lastCaseSegments, context.defaultBodySegments
      else
        ###
        # It handles the last case body as broken if `default` chunk
        # does not exist.
        ###
        brokenForkContext.add lastCaseSegments

    i = 0
    # Pops the segment context stack until the entry segment.
    while i < context.countForks
      @forkContext = @forkContext.upper
      ++i

    ###
    # Creates a path from all brokenForkContext paths.
    # This is a path after switch statement.
    ###
    @forkContext.replaceHead brokenForkContext.makeNext 0, -1

  ###*
  # Makes a code path segment for a `SwitchCase` node.
  #
  # @param {boolean} isEmpty - `true` if the body is empty.
  # @param {boolean} isDefault - `true` if the body is the default case.
  # @returns {void}
  ###
  makeSwitchCaseBody: (isEmpty, isDefault) ->
    context = @switchContext

    return unless context.hasCase

    ###
    # Merge forks.
    # The parent fork context has two segments.
    # Those are from the current case and the body of the previous case.
    ###
    parentForkContext = @forkContext
    forkContext = @pushForkContext()

    forkContext.add parentForkContext.makeNext 0, -1

    ###
    # Save `default` chunk info.
    # If the `default` label is not at the last, we must make a path from
    # the last `case` to the `default` chunk.
    ###
    if isDefault
      context.defaultSegments = parentForkContext.head
      if isEmpty
        context.foundDefault = yes
      else
        context.defaultBodySegments = forkContext.head
    else if not isEmpty and context.foundDefault
      context.foundDefault = no
      context.defaultBodySegments = forkContext.head

    context.lastIsDefault = isDefault
    context.countForks += 1

  #--------------------------------------------------------------------------
  # TryStatement
  #--------------------------------------------------------------------------

  ###*
  # Creates a context object of TryStatement and stacks it.
  #
  # @param {boolean} hasFinalizer - `true` if the try statement has a
  #   `finally` block.
  # @returns {void}
  ###
  pushTryContext: (hasFinalizer) ->
    @tryContext = {
      upper: @tryContext
      position: 'try'
      hasFinalizer

      returnedForkContext:
        if hasFinalizer
          ForkContext.newEmpty @forkContext
        else
          null

      thrownForkContext: ForkContext.newEmpty @forkContext
      lastOfTryIsReachable: no
      lastOfCatchIsReachable: no
    }

  ###*
  # Pops the last context of TryStatement and finalizes it.
  #
  # @returns {void}
  ###
  popTryContext: ->
    context = @tryContext

    @tryContext = context.upper

    if context.position is 'catch'
      # Merges two paths from the `try` block and `catch` block merely.
      @popForkContext()
      return

    ###
    # The following process is executed only when there is the `finally`
    # block.
    ###

    returned = context.returnedForkContext
    thrown = context.thrownForkContext

    return if returned.empty and thrown.empty

    # Separate head to normal paths and leaving paths.
    headSegments = @forkContext.head

    @forkContext = @forkContext.upper
    normalSegments = headSegments.slice 0, (headSegments.length / 2) | 0
    leavingSegments = headSegments.slice (headSegments.length / 2) | 0

    # Forwards the leaving path to upper contexts.
    unless returned.empty
      getReturnContext(@).returnedForkContext.add leavingSegments
    unless thrown.empty
      getThrowContext(@).thrownForkContext.add leavingSegments

    # Sets the normal path as the next.
    @forkContext.replaceHead normalSegments

    ###
    # If both paths of the `try` block and the `catch` block are
    # unreachable, the next path becomes unreachable as well.
    ###
    if not context.lastOfTryIsReachable and not context.lastOfCatchIsReachable
      @forkContext.makeUnreachable()

  ###*
  # Makes a code path segment for a `catch` block.
  #
  # @returns {void}
  ###
  makeCatchBlock: ->
    {tryContext: context, forkContext} = @
    thrown = context.thrownForkContext

    # Update state.
    context.position = 'catch'
    context.thrownForkContext = ForkContext.newEmpty forkContext
    context.lastOfTryIsReachable = forkContext.reachable

    # Merge thrown paths.
    thrown.add forkContext.head
    thrownSegments = thrown.makeNext 0, -1

    # Fork to a bypass and the merged thrown path.
    @pushForkContext()
    @forkBypassPath()
    @forkContext.add thrownSegments

  ###*
  # Makes a code path segment for a `finally` block.
  #
  # In the `finally` block, parallel paths are created. The parallel paths
  # are used as leaving-paths. The leaving-paths are paths from `return`
  # statements and `throw` statements in a `try` block or a `catch` block.
  #
  # @returns {void}
  ###
  makeFinallyBlock: ->
    {tryContext: context, forkContext} = @
    returned = context.returnedForkContext
    thrown = context.thrownForkContext
    headOfLeavingSegments = forkContext.head

    # Update state.
    if context.position is 'catch'
      # Merges two paths from the `try` block and `catch` block.
      @popForkContext()
      {forkContext} = @

      context.lastOfCatchIsReachable = forkContext.reachable
    else
      context.lastOfTryIsReachable = forkContext.reachable
    context.position = 'finally'

    # This path does not leave.
    return if returned.empty and thrown.empty

    ###
    # Create a parallel segment from merging returned and thrown.
    # This segment will leave at the end of this finally block.
    ###
    segments = forkContext.makeNext -1, -1

    i = 0
    while i < forkContext.count
      prevSegsOfLeavingSegment = [headOfLeavingSegments[i]]

      j = 0
      while j < returned.segmentsList.length
        prevSegsOfLeavingSegment.push returned.segmentsList[j][i]
        ++j
      j = 0
      while j < thrown.segmentsList.length
        prevSegsOfLeavingSegment.push thrown.segmentsList[j][i]
        ++j

      segments.push(
        CodePathSegment.newNext @idGenerator.next(), prevSegsOfLeavingSegment
      )
      ++i

    @pushForkContext yes
    @forkContext.add segments

  ###*
  # Makes a code path segment from the first throwable node to the `catch`
  # block or the `finally` block.
  #
  # @returns {void}
  ###
  makeFirstThrowablePathInTryBlock: ->
    {forkContext} = @

    return unless forkContext.reachable

    context = getThrowContext @

    return if (
      context is @ or
      context.position isnt 'try' or
      not context.thrownForkContext.empty
    )

    context.thrownForkContext.add forkContext.head
    forkContext.replaceHead forkContext.makeNext -1, -1

  #--------------------------------------------------------------------------
  # Loop Statements
  #--------------------------------------------------------------------------

  ###*
  # Creates a context object of a loop statement and stacks it.
  #
  # @param {string} type - The type of the node which was triggered. One of
  #   `WhileStatement`, `DoWhileStatement`, `ForStatement`, `ForInStatement`,
  #   and `ForStatement`.
  # @param {string|null} label - A label of the node which was triggered.
  # @returns {void}
  ###
  pushLoopContext: (type, label) ->
    {forkContext} = @
    breakContext = @pushBreakContext yes, label

    switch type
      when 'WhileStatement'
        @pushChoiceContext 'loop', no
        @loopContext = {
          upper: @loopContext
          type
          label
          test: undefined
          continueDestSegments: null
          brokenForkContext: breakContext.brokenForkContext
        }

      when 'DoWhileStatement'
        @pushChoiceContext 'loop', no
        @loopContext = {
          upper: @loopContext
          type
          label
          test: undefined
          entrySegments: null
          continueForkContext: ForkContext.newEmpty forkContext
          brokenForkContext: breakContext.brokenForkContext
        }

      when 'ForStatement'
        @pushChoiceContext 'loop', no
        @loopContext = {
          upper: @loopContext
          type
          label
          test: undefined
          endOfInitSegments: null
          testSegments: null
          endOfTestSegments: null
          updateSegments: null
          endOfUpdateSegments: null
          continueDestSegments: null
          brokenForkContext: breakContext.brokenForkContext
        }

      when 'ForInStatement', 'ForOfStatement', 'For'
        @loopContext = {
          upper: @loopContext
          type
          label
          prevSegments: null
          leftSegments: null
          endOfLeftSegments: null
          continueDestSegments: null
          brokenForkContext: breakContext.brokenForkContext
        }

      ### istanbul ignore next ###
      else
        throw new Error "unknown type: \"#{type}\""

  ###*
  # Pops the last context of a loop statement and finalizes it.
  #
  # @returns {void}
  ###
  popLoopContext: ->
    context = @loopContext

    @loopContext = context.upper

    {forkContext} = @
    {brokenForkContext} = @popBreakContext()

    # Creates a looped path.
    switch context.type
      when 'WhileStatement', 'ForStatement'
        @popChoiceContext()
        makeLooped @, forkContext.head, context.continueDestSegments

      when 'DoWhileStatement'
        choiceContext = @popChoiceContext()

        unless choiceContext.processed
          choiceContext.trueForkContext.add forkContext.head
          choiceContext.falseForkContext.add forkContext.head
        unless context.test is yes
          brokenForkContext.addAll choiceContext.falseForkContext

        # `true` paths go to looping.
        {segmentsList} = choiceContext.trueForkContext

        i = 0
        while i < segmentsList.length
          makeLooped @, segmentsList[i], context.entrySegments
          ++i

      when 'ForInStatement', 'ForOfStatement', 'For'
        brokenForkContext.add forkContext.head
        makeLooped @, forkContext.head, context.leftSegments if (
          context.leftSegments
        )

      ### istanbul ignore next ###
      else
        throw new Error 'unreachable'

    # Go next.
    if brokenForkContext.empty
      forkContext.replaceHead forkContext.makeUnreachable -1, -1
    else
      forkContext.replaceHead brokenForkContext.makeNext 0, -1

  ###*
  # Makes a code path segment for the test part of a WhileStatement.
  #
  # @param {boolean|undefined} test - The test value (only when constant).
  # @returns {void}
  ###
  makeWhileTest: (test) ->
    context = @loopContext
    testSegments = @forkContext.makeNext 0, -1

    # Update state.
    context.test = test
    context.continueDestSegments = testSegments
    @forkContext.replaceHead testSegments

  ###*
  # Makes a code path segment for the body part of a WhileStatement.
  #
  # @returns {void}
  ###
  makeWhileBody: ->
    {loopContext: context, choiceContext, forkContext} = @

    unless choiceContext.processed
      choiceContext.trueForkContext.add forkContext.head
      choiceContext.falseForkContext.add forkContext.head

    # Update state.
    unless context.test is yes
      context.brokenForkContext.addAll choiceContext.falseForkContext
    forkContext.replaceHead choiceContext.trueForkContext.makeNext 0, -1

  ###*
  # Makes a code path segment for the body part of a DoWhileStatement.
  #
  # @returns {void}
  ###
  makeDoWhileBody: ->
    {loopContext: context, forkContext} = @
    bodySegments = forkContext.makeNext -1, -1

    # Update state.
    context.entrySegments = bodySegments
    forkContext.replaceHead bodySegments

  ###*
  # Makes a code path segment for the test part of a DoWhileStatement.
  #
  # @param {boolean|undefined} test - The test value (only when constant).
  # @returns {void}
  ###
  makeDoWhileTest: (test) ->
    {loopContext: context, forkContext} = @

    context.test = test

    # Creates paths of `continue` statements.
    unless context.continueForkContext.empty
      context.continueForkContext.add forkContext.head
      testSegments = context.continueForkContext.makeNext 0, -1

      forkContext.replaceHead testSegments

  ###*
  # Makes a code path segment for the test part of a ForStatement.
  #
  # @param {boolean|undefined} test - The test value (only when constant).
  # @returns {void}
  ###
  makeForTest: (test) ->
    {loopContext: context, forkContext} = @
    endOfInitSegments = forkContext.head
    testSegments = forkContext.makeNext -1, -1

    # Update state.
    context.test = test
    context.endOfInitSegments = endOfInitSegments
    context.continueDestSegments = context.testSegments = testSegments
    forkContext.replaceHead testSegments

  ###*
  # Makes a code path segment for the update part of a ForStatement.
  #
  # @returns {void}
  ###
  makeForUpdate: ->
    {loopContext: context, choiceContext, forkContext} = @

    # Make the next paths of the test.
    if context.testSegments
      finalizeTestSegmentsOfFor context, choiceContext, forkContext.head
    else
      context.endOfInitSegments = forkContext.head

    # Update state.
    updateSegments = forkContext.makeDisconnected -1, -1

    context.continueDestSegments = context.updateSegments = updateSegments
    forkContext.replaceHead updateSegments

  ###*
  # Makes a code path segment for the body part of a ForStatement.
  #
  # @returns {void}
  ###
  makeForBody: ->
    {loopContext: context, choiceContext, forkContext} = @

    # Update state.
    if context.updateSegments
      context.endOfUpdateSegments = forkContext.head

      # `update` -> `test`
      if context.testSegments
        makeLooped @, context.endOfUpdateSegments, context.testSegments
    else if context.testSegments
      finalizeTestSegmentsOfFor context, choiceContext, forkContext.head
    else
      context.endOfInitSegments = forkContext.head

    bodySegments = context.endOfTestSegments

    unless bodySegments
      ###
      # If there is not the `test` part, the `body` path comes from the
      # `init` part and the `update` part.
      ###
      prevForkContext = ForkContext.newEmpty forkContext

      prevForkContext.add context.endOfInitSegments
      if context.endOfUpdateSegments
        prevForkContext.add context.endOfUpdateSegments

      bodySegments = prevForkContext.makeNext 0, -1
    context.continueDestSegments or= bodySegments
    forkContext.replaceHead bodySegments

  ###*
  # Makes a code path segment for the left part of a ForInStatement and a
  # ForOfStatement.
  #
  # @returns {void}
  ###
  makeForInOfLeft: ->
    context = @loopContext
    return if context.leftSegments
    {forkContext} = @
    leftSegments = forkContext.makeDisconnected -1, -1

    # Update state.
    context.prevSegments = forkContext.head
    context.leftSegments = context.continueDestSegments = leftSegments
    forkContext.replaceHead leftSegments

  ###*
  # Makes a code path segment for the right part of a ForInStatement and a
  # ForOfStatement.
  #
  # @returns {void}
  ###
  makeForInOfRight: ->
    {loopContext: context, forkContext} = @
    temp = ForkContext.newEmpty forkContext
    if context.leftSegments
      temp.add context.prevSegments
    else
      temp.add forkContext.head
    rightSegments = temp.makeNext -1, -1

    # Update state.
    if context.leftSegments
      context.endOfLeftSegments = forkContext.head
    forkContext.replaceHead rightSegments

  ###*
  # Makes a code path segment for the body part of a ForInStatement and a
  # ForOfStatement.
  #
  # @returns {void}
  ###
  makeForInOfBody: ->
    context = @loopContext
    {forkContext} = @
    temp = ForkContext.newEmpty forkContext

    if context.leftSegments
      temp.add context.endOfLeftSegments
    else
      temp.add forkContext.head
    bodySegments = temp.makeNext -1, -1

    # Make a path: `right` -> `left`.
    makeLooped @, forkContext.head, context.leftSegments if context.leftSegments

    context.continueDestSegments or= bodySegments

    # Update state.
    context.brokenForkContext.add forkContext.head
    forkContext.replaceHead bodySegments

  #--------------------------------------------------------------------------
  # Control Statements
  #--------------------------------------------------------------------------

  ###*
  # Creates new context for BreakStatement.
  #
  # @param {boolean} breakable - The flag to indicate it can break by
  #      an unlabeled BreakStatement.
  # @param {string|null} label - The label of this context.
  # @returns {Object} The new context.
  ###
  pushBreakContext: (breakable, label) ->
    @breakContext = {
      upper: @breakContext
      breakable
      label
      brokenForkContext: ForkContext.newEmpty @forkContext
    }
    @breakContext

  ###*
  # Removes the top item of the break context stack.
  #
  # @returns {Object} The removed context.
  ###
  popBreakContext: ->
    {breakContext: context, forkContext} = @

    @breakContext = context.upper

    # Process this context here for other than switches and loops.
    unless context.breakable
      {brokenForkContext} = context

      unless brokenForkContext.empty
        brokenForkContext.add forkContext.head
        forkContext.replaceHead brokenForkContext.makeNext 0, -1

    context

  ###*
  # Makes a path for a `break` statement.
  #
  # It registers the head segment to a context of `break`.
  # It makes new unreachable segment, then it set the head with the segment.
  #
  # @param {string} label - A label of the break statement.
  # @returns {void}
  ###
  makeBreak: (label) ->
    {forkContext} = @

    return unless forkContext.reachable

    context = getBreakContext @, label

    ### istanbul ignore else: foolproof (syntax error) ###
    if context then context.brokenForkContext.add forkContext.head

    forkContext.replaceHead forkContext.makeUnreachable -1, -1

  ###*
  # Makes a path for a `continue` statement.
  #
  # It makes a looping path.
  # It makes new unreachable segment, then it set the head with the segment.
  #
  # @param {string} label - A label of the continue statement.
  # @returns {void}
  ###
  makeContinue: (label) ->
    {forkContext} = @

    return unless forkContext.reachable

    context = getContinueContext @, label

    ### istanbul ignore else: foolproof (syntax error) ###
    if context
      if context.continueDestSegments
        makeLooped @, forkContext.head, context.continueDestSegments

        # If the context is a for-in/of loop, this effects a break also.
        if context.type in ['ForInStatement', 'ForOfStatement', 'For']
          context.brokenForkContext.add forkContext.head
      else
        context.continueForkContext.add forkContext.head
    forkContext.replaceHead forkContext.makeUnreachable -1, -1

  ###*
  # Makes a path for a `return` statement.
  #
  # It registers the head segment to a context of `return`.
  # It makes new unreachable segment, then it set the head with the segment.
  #
  # @returns {void}
  ###
  makeReturn: ->
    {forkContext} = @

    if forkContext.reachable
      getReturnContext(@).returnedForkContext.add forkContext.head
      forkContext.replaceHead forkContext.makeUnreachable -1, -1

  ###*
  # Makes a path for a `throw` statement.
  #
  # It registers the head segment to a context of `throw`.
  # It makes new unreachable segment, then it set the head with the segment.
  #
  # @returns {void}
  ###
  makeThrow: ->
    {forkContext} = @

    if forkContext.reachable
      getThrowContext(@).thrownForkContext.add forkContext.head
      forkContext.replaceHead forkContext.makeUnreachable -1, -1

  ###*
  # Makes the final path.
  # @returns {void}
  ###
  makeFinal: ->
    segments = @currentSegments

    if segments.length > 0 and segments[0].reachable
      @returnedForkContext.add segments

###*
# The head segments.
# @type {CodePathSegment[]}
###
Object.defineProperty CodePathState::, 'headSegments', get: -> @forkContext.head

###*
# The parent forking context.
# This is used for the root of new forks.
# @type {ForkContext}
###
Object.defineProperty CodePathState::, 'parentForkContext',
  get: ->
    @forkContext?.upper

module.exports = CodePathState
