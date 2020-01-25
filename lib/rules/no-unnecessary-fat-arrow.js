// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview This rule should warn about unnecessary usage of fat arrows.
   * @author Julian Rosse
   */
  'use strict';
  var isFatArrowFunction,
    slice = [].slice;

  //------------------------------------------------------------------------------
  // Requirements
  //------------------------------------------------------------------------------
  ({isFatArrowFunction} = require('../util/ast-utils'));

  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'warn about unnecessary usage of fat arrows',
        category: 'Best Practices',
        recommended: true
      },
      // url: 'https://eslint.org/docs/rules/space-unary-ops'
      schema: []
    },
    create: function(context) {
      var enterFunction, exitFunction, markUsed, stack;
      stack = [];
      markUsed = function(node) {
        var current;
        if (!stack.length) {
          return;
        }
        [current] = slice.call(stack, -1);
        return current.push(node);
      };
      enterFunction = function(node) {
        if (isFatArrowFunction(node)) {
          markUsed(node);
        }
        return stack.push([]);
      };
      exitFunction = function(node) {
        var uses;
        uses = stack.pop();
        if (!isFatArrowFunction(node)) {
          return;
        }
        if (uses.length) {
          return;
        }
        return context.report({
          node,
          message: "Prefer '->' for functions that don't use 'this'/'@'"
        });
      };
      return {
        //--------------------------------------------------------------------------
        // Public
        //--------------------------------------------------------------------------
        FunctionExpression: enterFunction,
        'FunctionExpression:exit': exitFunction,
        ArrowFunctionExpression: enterFunction,
        'ArrowFunctionExpression:exit': exitFunction,
        ClassMethod: enterFunction,
        'ClassMethod:exit': exitFunction,
        ThisExpression: markUsed
      };
    }
  };

}).call(this);