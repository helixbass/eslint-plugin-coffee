// Generated by CoffeeScript 2.3.1
(function() {
  /**
   * @fileoverview Rule to flag use constant conditions
   * @author Christian Schulz <http://rndm.de>
   */
  'use strict';
  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'disallow constant expressions in conditions',
        category: 'Possible Errors',
        recommended: true,
        url: 'https://eslint.org/docs/rules/no-constant-condition'
      },
      schema: [
        {
          type: 'object',
          properties: {
            checkLoops: {
              type: 'boolean'
            }
          },
          additionalProperties: false
        }
      ],
      messages: {
        unexpected: 'Unexpected constant condition.'
      }
    },
    create: function(context) {
      /**
       * Reports when the set contains the given constant condition node
       * @param {ASTNode} node The AST node to check.
       * @returns {void}
       * @private
       */
      /**
       * Checks node when checkLoops option is enabled
       * @param {ASTNode} node The AST node to check.
       * @returns {void}
       * @private
       */
      /**
       * Stores current set of constant loops in loopSetStack temporarily
       * and uses a new set to track constant loops
       * @returns {void}
       * @private
       */
      /**
       * Reports when the set still contains stored constant conditions
       * @param {ASTNode} node The AST node to check.
       * @returns {void}
       * @private
       */
      /**
       * Checks if a node has a constant truthiness value.
       * @param {ASTNode} node The AST node to check.
       * @param {boolean} inBooleanPosition `false` if checking branch of a condition.
       *  `true` in all other cases
       * @returns {Bool} true when node's truthiness is constant
       * @private
       */
      /**
       * Reports when the given node contains a constant condition.
       * @param {ASTNode} node The AST node to check.
       * @returns {void}
       * @private
       */
      /**
       * Tracks when the given node contains a constant condition.
       * @param {ASTNode} node The AST node to check.
       * @returns {void}
       * @private
       */
      var checkConstantConditionLoopInSet, checkLoop, checkLoops, enterFunction, exitFunction, isConstant, isLogicalIdentity, loopSetStack, loopsInCurrentScope, options, reportIfConstant, trackConstantConditionLoop;
      options = context.options[0] || {};
      checkLoops = options.checkLoops !== false;
      loopSetStack = [];
      loopsInCurrentScope = new Set();
      //--------------------------------------------------------------------------
      // Helpers
      //--------------------------------------------------------------------------
      /**
       * Checks if a branch node of LogicalExpression short circuits the whole condition
       * @param {ASTNode} node The branch of main condition which needs to be checked
       * @param {string} operator The operator of the main LogicalExpression.
       * @returns {boolean} true when condition short circuits whole condition
       */
      isLogicalIdentity = function(node, operator) {
        switch (node.type) {
          case 'Literal':
            return ((operator === '||' || operator === 'or') && node.value === true) || ((operator === '&&' || operator === 'and') && node.value === false);
          case 'UnaryExpression':
            return (operator === '&&' || operator === 'and') && node.operator === 'void';
          case 'LogicalExpression':
            return isLogicalIdentity(node.left, node.operator) || isLogicalIdentity(node.right, node.operator);
        }
        // no default
        return false;
      };
      isConstant = function(node, inBooleanPosition) {
        var isLeftConstant, isLeftShortCircuit, isRightConstant, isRightShortCircuit;
        switch (node.type) {
          case 'Literal':
          case 'ArrowFunctionExpression':
          case 'FunctionExpression':
          case 'ObjectExpression':
          case 'ArrayExpression':
            return true;
          case 'UnaryExpression':
            if (node.operator === 'void') {
              return true;
            }
            return (node.operator === 'typeof' && inBooleanPosition) || isConstant(node.argument, true);
          case 'BinaryExpression':
            return isConstant(node.left, false) && isConstant(node.right, false) && node.operator !== 'of';
          case 'LogicalExpression':
            isLeftConstant = isConstant(node.left, inBooleanPosition);
            isRightConstant = isConstant(node.right, inBooleanPosition);
            isLeftShortCircuit = isLeftConstant && isLogicalIdentity(node.left, node.operator);
            isRightShortCircuit = isRightConstant && isLogicalIdentity(node.right, node.operator);
            return (isLeftConstant && isRightConstant) || isLeftShortCircuit || isRightShortCircuit;
          case 'AssignmentExpression':
            return node.operator === '=' && isConstant(node.right, inBooleanPosition);
          case 'SequenceExpression':
            return isConstant(node.expressions[node.expressions.length - 1], inBooleanPosition);
        }
        // no default
        return false;
      };
      trackConstantConditionLoop = function(node) {
        if (node.test && isConstant(node.test, true)) {
          return loopsInCurrentScope.add(node);
        }
      };
      checkConstantConditionLoopInSet = function(node) {
        if (loopsInCurrentScope.has(node)) {
          loopsInCurrentScope.delete(node);
          return context.report({
            node: node.test,
            messageId: 'unexpected'
          });
        }
      };
      reportIfConstant = function(node) {
        if (node.test && isConstant(node.test, true)) {
          return context.report({
            node: node.test,
            messageId: 'unexpected'
          });
        }
      };
      enterFunction = function() {
        loopSetStack.push(loopsInCurrentScope);
        return (loopsInCurrentScope = new Set());
      };
      exitFunction = function() {
        return (loopsInCurrentScope = loopSetStack.pop());
      };
      checkLoop = function(node) {
        if (checkLoops) {
          return trackConstantConditionLoop(node);
        }
      };
      return {
        //--------------------------------------------------------------------------
        // Public
        //--------------------------------------------------------------------------
        ConditionalExpression: reportIfConstant,
        IfStatement: reportIfConstant,
        WhileStatement: checkLoop,
        'WhileStatement:exit': checkConstantConditionLoopInSet,
        DoWhileStatement: checkLoop,
        'DoWhileStatement:exit': checkConstantConditionLoopInSet,
        ForStatement: checkLoop,
        'ForStatement > .test': function(node) {
          return checkLoop(node.parent);
        },
        'ForStatement:exit': checkConstantConditionLoopInSet,
        FunctionDeclaration: enterFunction,
        'FunctionDeclaration:exit': exitFunction,
        FunctionExpression: enterFunction,
        'FunctionExpression:exit': exitFunction,
        YieldExpression: function() {
          return loopsInCurrentScope.clear();
        }
      };
    }
  };

}).call(this);