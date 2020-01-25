// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview disallow using an async function as a Promise executor
   * @author Teddy Katz
   */
  'use strict';
  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'disallow using an async function as a Promise executor',
        category: 'Possible Errors',
        recommended: false,
        url: 'https://eslint.org/docs/rules/no-async-promise-executor'
      },
      fixable: null,
      schema: []
    },
    create: function(context) {
      return {
        "NewExpression[callee.name='Promise'][arguments.0.async=true]": function(node) {
          return context.report({
            node: node.arguments[0],
            message: 'Promise executor functions should not be async.'
          });
        }
      };
    }
  };

}).call(this);