###*
# @fileoverview A class of the code path.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

CodePathState = require './code-path-state'
IdGenerator = require 'eslint/lib/code-path-analysis/id-generator'

#------------------------------------------------------------------------------
# Public Interface
#------------------------------------------------------------------------------

###*
# A code path.
###
class CodePath
  ###*
  # @param {string} id - An identifier.
  # @param {CodePath|null} upper - The code path of the upper function scope.
  # @param {Function} onLooped - A callback function to notify looping.
  ###
  constructor: (
    ###*
    # The identifier of this code path.
    # Rules use it to store additional information of each rule.
    # @type {string}
    ###
    @id
    ###*
    # The code path of the upper function scope.
    # @type {CodePath|null}
    ###
    @upper
    onLooped
  ) ->
    ###*
    # The code paths of nested function scopes.
    # @type {CodePath[]}
    ###
    @childCodePaths = []

    # Initializes internal state.
    Object.defineProperty @, 'internal',
      value: new CodePathState new IdGenerator("#{@id}_"), onLooped

    # Adds this into `childCodePaths` of `upper`.
    @upper?.childCodePaths.push @

  ###*
  # Gets the state of a given code path.
  #
  # @param {CodePath} codePath - A code path to get.
  # @returns {CodePathState} The state of the code path.
  ###
  @getState: (codePath) -> codePath.internal

  ###*
  # Traverses all segments in this code path.
  #
  #     codePath.traverseSegments(function(segment, controller) {
  #         // do something.
  #     });
  #
  # This method enumerates segments in order from the head.
  #
  # The `controller` object has two methods.
  #
  # - `controller.skip()` - Skip the following segments in this branch.
  # - `controller.break()` - Skip all following segments.
  #
  # @param {Object} [options] - Omittable.
  # @param {CodePathSegment} [options.first] - The first segment to traverse.
  # @param {CodePathSegment} [options.last] - The last segment to traverse.
  # @param {Function} callback - A callback function.
  # @returns {void}
  ###
  traverseSegments: (options, callback) ->
    if typeof options is 'function'
      resolvedCallback = options
      resolvedOptions = {}
    else
      resolvedOptions = options or {}
      resolvedCallback = callback

    startSegment = resolvedOptions.first or @internal.initialSegment
    lastSegment = resolvedOptions.last

    item = null
    index = 0
    end = 0
    segment = null
    visited = Object.create null
    stack = [[startSegment, 0]]
    skippedSegment = null
    broken = no
    controller =
      skip: ->
        if stack.length <= 1
          broken = yes
        else
          skippedSegment = stack[stack.length - 2][0]
      break: -> broken = yes

    ###*
    # Checks a given previous segment has been visited.
    # @param {CodePathSegment} prevSegment - A previous segment to check.
    # @returns {boolean} `true` if the segment has been visited.
    ###
    isVisited = (prevSegment) ->
      visited[prevSegment.id] or segment.isLoopedPrevSegment prevSegment

    while stack.length > 0
      item = stack[stack.length - 1]
      segment = item[0]
      index = item[1]

      if index is 0
        # Skip if this segment has been visited already.
        if visited[segment.id]
          stack.pop()
          continue

        # Skip if all previous segments have not been visited.
        if (
          segment isnt startSegment and
          segment.prevSegments.length > 0 and
          not segment.prevSegments.every isVisited
        )
          stack.pop()
          continue

        # Reset the flag of skipping if all branches have been skipped.
        if (
          skippedSegment and
          segment.prevSegments.indexOf(skippedSegment) isnt -1
        )
          skippedSegment = null
        visited[segment.id] = yes

        # Call the callback when the first time.
        unless skippedSegment
          resolvedCallback.call @, segment, controller
          if segment is lastSegment then controller.skip()
          if broken then break

      # Update the stack.
      end = segment.nextSegments.length - 1
      if index < end
        item[1] += 1
        stack.push [segment.nextSegments[index], 0]
      else if index is end
        item[0] = segment.nextSegments[index]
        item[1] = 0
      else
        stack.pop()

###*
# Current code path segments.
# @type {CodePathSegment[]}
###
Object.defineProperty CodePath.prototype, 'currentSegments',
  get: -> @internal.currentSegments

###*
# The initial code path segment.
# @type {CodePathSegment}
###
Object.defineProperty CodePath.prototype, 'initialSegment',
  get: -> @internal.initialSegment

###*
# Final code path segments.
# This array is a mix of `returnedSegments` and `thrownSegments`.
# @type {CodePathSegment[]}
###
Object.defineProperty CodePath.prototype, 'finalSegments',
  get: -> @internal.finalSegments

###*
# Final code path segments which is with `return` statements.
# This array contains the last path segment if it's reachable.
# Since the reachable last path returns `undefined`.
# @type {CodePathSegment[]}
###
Object.defineProperty CodePath.prototype, 'returnedSegments',
  get: -> @internal.returnedForkContext

###*
# Final code path segments which is with `throw` statements.
# @type {CodePathSegment[]}
###
Object.defineProperty CodePath.prototype, 'thrownSegments',
  get: -> @internal.thrownForkContext

module.exports = CodePath
