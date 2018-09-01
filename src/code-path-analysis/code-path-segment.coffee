###*
# @fileoverview A class of the code path segment.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

debug = require 'eslint/lib/code-path-analysis/debug-helpers'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether or not a given segment is reachable.
#
# @param {CodePathSegment} segment - A segment to check.
# @returns {boolean} `true` if the segment is reachable.
###
isReachable = (segment) -> segment.reachable

#------------------------------------------------------------------------------
# Public Interface
#------------------------------------------------------------------------------

###*
# A code path segment.
###
class CodePathSegment
  ###*
  # @param {string} id - An identifier.
  # @param {CodePathSegment[]} allPrevSegments - An array of the previous segments.
  #   This array includes unreachable segments.
  # @param {boolean} reachable - A flag which shows this is reachable.
  ###
  constructor: (
    ###*
    # The identifier of this code path.
    # Rules use it to store additional information of each rule.
    # @type {string}
    ###
    @id
    ###*
    # An array of the previous segments.
    # This array includes unreachable segments.
    # @type {CodePathSegment[]}
    ###
    @allPrevSegments
    ###*
    # A flag which shows this is reachable.
    # @type {boolean}
    ###
    @reachable
  ) ->
    ###*
    # An array of the next segments.
    # @type {CodePathSegment[]}
    ###
    @nextSegments = []

    ###*
    # An array of the previous segments.
    # @type {CodePathSegment[]}
    ###
    @prevSegments = @allPrevSegments.filter isReachable

    ###*
    # An array of the next segments.
    # This array includes unreachable segments.
    # @type {CodePathSegment[]}
    ###
    @allNextSegments = []

    # Internal data.
    Object.defineProperty @, 'internal',
      value:
        used: no
        loopedPrevSegments: []

    ### istanbul ignore if ###
    if debug.enabled
      @internal.nodes = []
      @internal.exitNodes = []

  ###*
  # Checks a given previous segment is coming from the end of a loop.
  #
  # @param {CodePathSegment} segment - A previous segment to check.
  # @returns {boolean} `true` if the segment is coming from the end of a loop.
  ###
  isLoopedPrevSegment: (segment) ->
    @internal.loopedPrevSegments.indexOf(segment) isnt -1

  ###*
  # Creates the root segment.
  #
  # @param {string} id - An identifier.
  # @returns {CodePathSegment} The created segment.
  ###
  @newRoot: (id) -> new CodePathSegment id, [], yes

  ###*
  # Creates a segment that follows given segments.
  #
  # @param {string} id - An identifier.
  # @param {CodePathSegment[]} allPrevSegments - An array of the previous segments.
  # @returns {CodePathSegment} The created segment.
  ###
  @newNext: (id, allPrevSegments) ->
    new CodePathSegment(
      id
      CodePathSegment.flattenUnusedSegments allPrevSegments
      allPrevSegments.some isReachable
    )

  ###*
  # Creates an unreachable segment that follows given segments.
  #
  # @param {string} id - An identifier.
  # @param {CodePathSegment[]} allPrevSegments - An array of the previous segments.
  # @returns {CodePathSegment} The created segment.
  ###
  @newUnreachable: (id, allPrevSegments) ->
    segment = new CodePathSegment(
      id
      CodePathSegment.flattenUnusedSegments allPrevSegments
      no
    )

    ###
    # In `if (a) return a; foo();` case, the unreachable segment preceded by
    # the return statement is not used but must not be remove.
    ###
    CodePathSegment.markUsed segment

    segment

  ###*
  # Creates a segment that follows given segments.
  # This factory method does not connect with `allPrevSegments`.
  # But this inherits `reachable` flag.
  #
  # @param {string} id - An identifier.
  # @param {CodePathSegment[]} allPrevSegments - An array of the previous segments.
  # @returns {CodePathSegment} The created segment.
  ###
  @newDisconnected: (id, allPrevSegments) ->
    new CodePathSegment id, [], allPrevSegments.some isReachable

  ###*
  # Makes a given segment being used.
  #
  # And this function registers the segment into the previous segments as a next.
  #
  # @param {CodePathSegment} segment - A segment to mark.
  # @returns {void}
  ###
  @markUsed: (segment) ->
    return if segment.internal.used
    segment.internal.used = yes

    if segment.reachable
      for prevSegment in segment.allPrevSegments
        prevSegment.allNextSegments.push segment
        prevSegment.nextSegments.push segment
    else
      for prevSegment in segment.allPrevSegments
        prevSegment.allNextSegments.push segment

  ###*
  # Marks a previous segment as looped.
  #
  # @param {CodePathSegment} segment - A segment.
  # @param {CodePathSegment} prevSegment - A previous segment to mark.
  # @returns {void}
  ###
  @markPrevSegmentAsLooped: (segment, prevSegment) ->
    segment.internal.loopedPrevSegments.push prevSegment

  ###*
  # Replaces unused segments with the previous segments of each unused segment.
  #
  # @param {CodePathSegment[]} segments - An array of segments to replace.
  # @returns {CodePathSegment[]} The replaced array.
  ###
  @flattenUnusedSegments: (segments) ->
    done = Object.create null
    retv = []

    for segment in segments
      # Ignores duplicated.
      continue if done[segment.id]

      # Use previous segments if unused.
      unless segment.internal.used
        for prevSegment in segment.allPrevSegments
          unless done[prevSegment.id]
            done[prevSegment.id] = yes
            retv.push prevSegment
      else
        done[segment.id] = yes
        retv.push segment

    retv

module.exports = CodePathSegment
