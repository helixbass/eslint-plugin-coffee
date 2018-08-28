###*
# @fileoverview Helpers to test EventGenerator interface.
# @author Toru Nagashima
###
'use strict'

### global describe, it ###

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

assert = require 'assert'

#------------------------------------------------------------------------------
# Public Interface
#------------------------------------------------------------------------------

module.exports =
  ###*
  # Overrideable `describe` function to test.
  # @param {string} text - A description.
  # @param {Function} method - A test logic.
  # @returns {any} The returned value with the test logic.
  ###
  describe:
    if typeof describe is 'function'
      describe
    ### istanbul ignore next ###
    else
      (text, method) -> method.apply @

  ###*
  # Overrideable `it` function to test.
  # @param {string} text - A description.
  # @param {Function} method - A test logic.
  # @returns {any} The returned value with the test logic.
  ###
  it:
    if typeof it is 'function'
      it
    ### istanbul ignore next ###
    else
      (text, method) -> method.apply @

  ###*
  # Does some tests to check a given object implements the EventGenerator interface.
  # @param {Object} instance - An object to check.
  # @returns {void}
  ###
  testEventGeneratorInterface: (instance) ->
    @describe 'should implement EventGenerator interface', =>
      @it 'should have `emitter` property.', ->
        assert.strictEqual typeof instance.emitter, 'object'
        assert.strictEqual typeof instance.emitter.emit, 'function'

      @it 'should have `enterNode` property.', ->
        assert.strictEqual typeof instance.enterNode, 'function'

      @it 'should have `leaveNode` property.', ->
        assert.strictEqual typeof instance.leaveNode, 'function'
