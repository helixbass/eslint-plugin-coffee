// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview HTML special characters should be escaped.
   * @author Patrick Hayes
   */
  'use strict';
  var DEFAULTS, docsUrl, jsxUtil;

  docsUrl = require('eslint-plugin-react/lib/util/docsUrl');

  jsxUtil = require('../util/react/jsx');

  // ------------------------------------------------------------------------------
  // Rule Definition
  // ------------------------------------------------------------------------------

  // NOTE: '<' and '{' are also problematic characters, but they do not need
  // to be included here because it is a syntax error when these characters are
  // included accidentally.
  DEFAULTS = ['>', '"', "'", '}'];

  module.exports = {
    meta: {
      docs: {
        description: 'Detect unescaped HTML entities, which might represent malformed tags',
        category: 'Possible Errors',
        recommended: true,
        url: docsUrl('no-unescaped-entities')
      },
      schema: [
        {
          type: 'object',
          properties: {
            forbid: {
              type: 'array',
              items: {
                type: 'string'
              }
            }
          },
          additionalProperties: false
        }
      ]
    },
    create: function(context) {
      var reportInvalidEntity;
      reportInvalidEntity = function(node) {
        var c, configuration, end, entities, entity, i, index, j, rawLine, ref, ref1, results, start;
        configuration = context.options[0] || {};
        entities = configuration.forbid || DEFAULTS;
// HTML entites are already escaped in node.value (as well as node.raw),
// so pull the raw text from context.getSourceCode()
        results = [];
        for (i = j = ref = node.loc.start.line, ref1 = node.loc.end.line; (ref <= ref1 ? j <= ref1 : j >= ref1); i = ref <= ref1 ? ++j : --j) {
          rawLine = context.getSourceCode().lines[i - 1];
          start = 0;
          end = rawLine.length;
          if (i === node.loc.start.line) {
            start = node.loc.start.column;
          }
          if (i === node.loc.end.line) {
            end = node.loc.end.column;
          }
          rawLine = rawLine.substring(start, end);
          results.push((function() {
            var k, len, results1;
            results1 = [];
            for (k = 0, len = entities.length; k < len; k++) {
              entity = entities[k];
              results1.push((function() {
                var l, len1, results2;
                results2 = [];
                for (index = l = 0, len1 = rawLine.length; l < len1; index = ++l) {
                  c = rawLine[index];
                  if (c === entity) {
                    results2.push(context.report({
                      loc: {
                        line: i,
                        column: start + index
                      },
                      message: 'HTML entities must be escaped.',
                      node
                    }));
                  } else {
                    results2.push(void 0);
                  }
                }
                return results2;
              })());
            }
            return results1;
          })());
        }
        return results;
      };
      return {
        'Literal, JSXText': function(node) {
          if (jsxUtil.isJSX(node.parent)) {
            return reportInvalidEntity(node);
          }
        }
      };
    }
  };

}).call(this);