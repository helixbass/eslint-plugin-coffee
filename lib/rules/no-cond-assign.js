// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Rule to flag assignment in a conditional statement's test expression
   * @author Stephen Murray <spmurrayzzz>
   */
  'use strict';
  var NODE_DESCRIPTIONS, astUtils;

  astUtils = require('../eslint-ast-utils');

  NODE_DESCRIPTIONS = {
    DoWhileStatement: "a 'do...while' statement",
    ForStatement: "a 'for' statement",
    IfStatement: "an 'if' statement",
    WhileStatement: "a 'while' statement"
  };

  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'disallow assignment operators in conditional expressions',
        category: 'Possible Errors',
        recommended: true,
        url: 'https://eslint.org/docs/rules/no-cond-assign'
      },
      schema: [
        {
          enum: ['except-parens',
        'always']
        }
      ],
      messages: {
        unexpected: 'Unexpected assignment within {{type}}.',
        // must match JSHint's error message
        missing: 'Expected a conditional expression and instead saw an assignment.'
      }
    },
    create: function(context) {
      /**
       * Given an AST node, perform a bottom-up search for the first ancestor that represents a conditional statement.
       * @param {!Object} node The node to use at the start of the search.
       * @returns {?Object} The closest ancestor node that represents a conditional statement.
       */
      /**
       * Check whether an AST node is the test expression for a conditional statement.
       * @param {!Object} node The node to test.
       * @returns {boolean} `true` if the node is the text expression for a conditional statement; otherwise, `false`.
       */
      /**
       * Check a conditional statement's test expression for top-level assignments that are not enclosed in parentheses.
       * @param {!Object} node The node for the conditional statement.
       * @returns {void}
       */
      /**
       * Check whether an assignment expression is descended from a conditional statement's test expression.
       * @param {!Object} node The node for the assignment expression.
       * @returns {void}
       */
      var findConditionalAncestor, isConditionalTestExpression, prohibitAssign, sourceCode, testForAssign, testForConditionalAncestor;
      prohibitAssign = context.options[0] || 'except-parens';
      sourceCode = context.getSourceCode();
      isConditionalTestExpression = function(node) {
        var ref;
        return ((ref = node.parent) != null ? ref.test : void 0) && node === node.parent.test;
      };
      findConditionalAncestor = function(node) {
        var currentAncestor;
        currentAncestor = node;
        if (isConditionalTestExpression(currentAncestor)) {
          return currentAncestor.parent;
        }
        while ((currentAncestor = currentAncestor.parent) && !astUtils.isFunction(currentAncestor)) {
          if (isConditionalTestExpression(currentAncestor)) {
            return currentAncestor.parent;
          }
        }
        return null;
      };
      testForAssign = function(node) {
        if (node.test && node.test.type === 'AssignmentExpression' && !astUtils.isParenthesised(sourceCode, node.test)) {
          return context.report({
            node,
            loc: node.test.loc.start,
            messageId: 'missing'
          });
        }
      };
      testForConditionalAncestor = function(node) {
        var ancestor;
        ancestor = findConditionalAncestor(node);
        if (ancestor) {
          return context.report({
            node: ancestor,
            messageId: 'unexpected',
            data: {
              type: NODE_DESCRIPTIONS[ancestor.type] || ancestor.type
            }
          });
        }
      };
      if (prohibitAssign === 'always') {
        return {
          AssignmentExpression: testForConditionalAncestor
        };
      }
      return {
        DoWhileStatement: testForAssign,
        ForStatement: testForAssign,
        IfStatement: testForAssign,
        WhileStatement: testForAssign,
        ConditionalExpression: testForAssign
      };
    }
  };

}).call(this);