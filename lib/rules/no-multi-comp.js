// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Prevent multiple component definition per file
   * @author Yannick Croissant
   */
  'use strict';
  var Components, docsUrl,
    hasProp = {}.hasOwnProperty;

  Components = require('../util/react/Components');

  docsUrl = require('eslint-plugin-react/lib/util/docsUrl');

  // ------------------------------------------------------------------------------
  // Rule Definition
  // ------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'Prevent multiple component definition per file',
        category: 'Stylistic Issues',
        recommended: false,
        url: docsUrl('no-multi-comp')
      },
      schema: [
        {
          type: 'object',
          properties: {
            ignoreStateless: {
              default: false,
              type: 'boolean'
            }
          },
          additionalProperties: false
        }
      ]
    },
    create: Components.detect(function(context, components) {
      /**
       * Checks if the component is ignored
       * @param {Object} component The component being checked.
       * @returns {Boolean} True if the component is ignored, false if not.
       */
      var MULTI_COMP_MESSAGE, configuration, ignoreStateless, isIgnored;
      configuration = context.options[0] || {};
      ignoreStateless = configuration.ignoreStateless || false;
      MULTI_COMP_MESSAGE = 'Declare only one React component per file';
      isIgnored = function(component) {
        return ignoreStateless && /Function/.test(component.node.type);
      };
      return {
        // --------------------------------------------------------------------------
        // Public
        // --------------------------------------------------------------------------
        'Program:exit': function() {
          var _, component, i, list, results;
          if (components.length() <= 1) {
            return;
          }
          list = components.list();
          i = 0;
          results = [];
          for (_ in list) {
            if (!hasProp.call(list, _)) continue;
            component = list[_];
            if (isIgnored(component) || ++i === 1) {
              continue;
            }
            results.push(context.report({
              node: component.node,
              message: MULTI_COMP_MESSAGE
            }));
          }
          return results;
        }
      };
    })
  };

}).call(this);