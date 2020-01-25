// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Helpers to test EventGenerator interface.
   * @author Toru Nagashima
   */
  'use strict';
  var assert;

  /* global describe, it */
  //------------------------------------------------------------------------------
  // Requirements
  //------------------------------------------------------------------------------
  assert = require('assert');

  //------------------------------------------------------------------------------
  // Public Interface
  //------------------------------------------------------------------------------
  module.exports = {
    /**
     * Overrideable `describe` function to test.
     * @param {string} text - A description.
     * @param {Function} method - A test logic.
     * @returns {any} The returned value with the test logic.
     */
    /* istanbul ignore next */
    describe: typeof describe === 'function' ? describe : function(text, method) {
      return method.apply(this);
    },
    /**
     * Overrideable `it` function to test.
     * @param {string} text - A description.
     * @param {Function} method - A test logic.
     * @returns {any} The returned value with the test logic.
     */
    /* istanbul ignore next */
    it: typeof it === 'function' ? it : function(text, method) {
      return method.apply(this);
    },
    /**
     * Does some tests to check a given object implements the EventGenerator interface.
     * @param {Object} instance - An object to check.
     * @returns {void}
     */
    testEventGeneratorInterface: function(instance) {
      return this.describe('should implement EventGenerator interface', () => {
        this.it('should have `emitter` property.', function() {
          assert.strictEqual(typeof instance.emitter, 'object');
          return assert.strictEqual(typeof instance.emitter.emit, 'function');
        });
        this.it('should have `enterNode` property.', function() {
          return assert.strictEqual(typeof instance.enterNode, 'function');
        });
        return this.it('should have `leaveNode` property.', function() {
          return assert.strictEqual(typeof instance.leaveNode, 'function');
        });
      });
    }
  };

}).call(this);