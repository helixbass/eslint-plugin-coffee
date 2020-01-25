// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Warn when using template string syntax in regular strings
   * @author Jeroen Engels
   */
  'use strict';
  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'disallow template literal placeholder syntax in regular strings',
        category: 'Possible Errors',
        recommended: false,
        url: 'https://eslint.org/docs/rules/no-template-curly-in-string'
      },
      schema: []
    },
    create: function(context) {
      var regex;
      regex = /#\{[^}]+\}/;
      return {
        Literal: function(node) {
          if (typeof node.value === 'string' && regex.test(node.value)) {
            return context.report({
              node,
              message: 'Unexpected template string expression.'
            });
          }
        },
        TemplateElement: function(node) {
          if (regex.test(node.value.raw)) {
            return context.report({
              node,
              message: 'Unexpected template string expression.'
            });
          }
        }
      };
    }
  };

}).call(this);