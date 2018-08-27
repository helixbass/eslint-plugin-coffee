###*
# @fileoverview A class to operate forking.
#
# This is state of forking.
# This has a fork list and manages it.
#
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

assert = require 'assert'
CodePathSegment = require './code-path-segment'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Gets whether or not a given segment is reachable.
#
# @param {CodePathSegment} segment - A segment to get.
# @returns {boolean} `true` if the segment is reachable.
###
isReachable = (segment) -> segment.reachable

###*
# Creates new segments from the specific range of `context.segmentsList`.
#
# When `context.segmentsList` is `[[a, b], [c, d], [e, f]]`, `begin` is `0`, and
# `end` is `-1`, this creates `[g, h]`. This `g` is from `a`, `c`, and `e`.
# This `h` is from `b`, `d`, and `f`.
#
# @param {ForkContext} context - An instance.
# @param {number} begin - The first index of the previous segments.
# @param {number} end - The last index of the previous segments.
# @param {Function} create - A factory function of new segments.
# @returns {CodePathSegment[]} New segments.
###
makeSegments = (context, begin, end, create) ->
  list = context.segmentsList

  normalizedBegin = if begin >= 0 then begin else list.length + begin
  normalizedEnd = if end >= 0 then end else list.length + end

  segments = []

  i = 0
  while i < context.count
    allPrevSegments = []

    j = normalizedBegin
    while j <= normalizedEnd
      allPrevSegments.push list[j][i]
      ++j

    segments.push create context.idGenerator.next(), allPrevSegments
    ++i

  segments

###*
# `segments` becomes doubly in a `finally` block. Then if a code path exits by a
# control statement (such as `break`, `continue`) from the `finally` block, the
# destination's segments may be half of the source segments. In that case, this
# merges segments.
#
# @param {ForkContext} context - An instance.
# @param {CodePathSegment[]} segments - Segments to merge.
# @returns {CodePathSegment[]} The merged segments.
###
mergeExtraSegments = (context, segments) ->
  currentSegments = segments

  while currentSegments.length > context.count
    merged = []

    length = (currentSegments.length / 2) | 0
    for i in [0...length]
      merged.push(
        CodePathSegment.newNext context.idGenerator.next(), [
          currentSegments[i]
          currentSegments[i + length]
        ]
      )
    currentSegments = merged
  currentSegments

#------------------------------------------------------------------------------
# Public Interface
#------------------------------------------------------------------------------

###*
# A class to manage forking.
###
class ForkContext
  ###*
  # @param {IdGenerator} idGenerator - An identifier generator for segments.
  # @param {ForkContext|null} upper - An upper fork context.
  # @param {number} count - A number of parallel segments.
  ###
  constructor: (@idGenerator, @upper, @count) ->
    @segmentsList = []

  ###*
  # Creates new segments from this context.
  #
  # @param {number} begin - The first index of previous segments.
  # @param {number} end - The last index of previous segments.
  # @returns {CodePathSegment[]} New segments.
  ###
  makeNext: (begin, end) -> makeSegments @, begin, end, CodePathSegment.newNext

  ###*
  # Creates new segments from this context.
  # The new segments is always unreachable.
  #
  # @param {number} begin - The first index of previous segments.
  # @param {number} end - The last index of previous segments.
  # @returns {CodePathSegment[]} New segments.
  ###
  makeUnreachable: (begin, end) ->
    makeSegments @, begin, end, CodePathSegment.newUnreachable

  ###*
  # Creates new segments from this context.
  # The new segments don't have connections for previous segments.
  # But these inherit the reachable flag from this context.
  #
  # @param {number} begin - The first index of previous segments.
  # @param {number} end - The last index of previous segments.
  # @returns {CodePathSegment[]} New segments.
  ###
  makeDisconnected: (begin, end) ->
    makeSegments @, begin, end, CodePathSegment.newDisconnected

  ###*
  # Adds segments into this context.
  # The added segments become the head.
  #
  # @param {CodePathSegment[]} segments - Segments to add.
  # @returns {void}
  ###
  add: (segments) ->
    assert segments.length >= @count, "#{segments.length} >= #{@count}"

    @segmentsList.push mergeExtraSegments @, segments

  ###*
  # Replaces the head segments with given segments.
  # The current head segments are removed.
  #
  # @param {CodePathSegment[]} segments - Segments to add.
  # @returns {void}
  ###
  replaceHead: (segments) ->
    assert segments.length >= @count, "#{segments.length} >= #{@count}"

    @segmentsList.splice -1, 1, mergeExtraSegments @, segments

  ###*
  # Adds all segments of a given fork context into this context.
  #
  # @param {ForkContext} context - A fork context to add.
  # @returns {void}
  ###
  addAll: (context) ->
    assert context.count is @count

    source = context.segmentsList

    i = 0
    while i < source.length
      @segmentsList.push source[i]
      ++i

  ###*
  # Clears all secments in this context.
  #
  # @returns {void}
  ###
  clear: -> @segmentsList = []

  ###*
  # Creates the root fork context.
  #
  # @param {IdGenerator} idGenerator - An identifier generator for segments.
  # @returns {ForkContext} New fork context.
  ###
  @newRoot: (idGenerator) ->
    context = new ForkContext idGenerator, null, 1

    context.add [CodePathSegment.newRoot idGenerator.next()]

    context

  ###*
  # Creates an empty fork context preceded by a given context.
  #
  # @param {ForkContext} parentContext - The parent fork context.
  # @param {boolean} forkLeavingPath - A flag which shows inside of `finally` block.
  # @returns {ForkContext} New fork context.
  ###
  @newEmpty: (parentContext, forkLeavingPath) ->
    new ForkContext(
      parentContext.idGenerator
      parentContext
      (if forkLeavingPath then 2 else 1) * parentContext.count
    )

###*
# The head segments.
# @type {CodePathSegment[]}
###
Object.defineProperty ForkContext::, 'head',
  get: ->
    list = @segmentsList

    if list.length is 0 then [] else list[list.length - 1]

###*
# A flag which shows empty.
# @type {boolean}
###
Object.defineProperty ForkContext::, 'empty', get: -> @segmentsList.length is 0

###*
# A flag which shows reachable.
# @type {boolean}
###
Object.defineProperty ForkContext::, 'reachable',
  get: ->
    segments = @head

    segments.length > 0 and segments.some isReachable

module.exports = ForkContext
